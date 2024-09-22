import 'package:cloud_otp/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_otp/models/otp_item.dart';
import 'dart:async';
import 'package:otp/otp.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io' show Platform;
import 'package:file_picker/file_picker.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_otp/widgets/qr_code_dialog.dart';

class ListViewPage extends StatefulWidget {
  ListViewPage({super.key});

  // late List<String> originalUris;
  final List<String> initialOtpUris = List.from(otpUris);

  @override
  _ListViewPageState createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  late List<OtpItem> otpItems;
  late List<String> currentOtps;
  late List<bool> _isExpanded;
  late List<double> _progress;
  late List<Timer> _timers;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void didUpdateWidget(ListViewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialOtpUris != oldWidget.initialOtpUris) {
      initState();
    }
  }

  void _initializeState() {
    try {
      // Create a new modifiable list from widget.otpUris
      // originalUris = List<String>.from(otpUris);
      otpItems = List<OtpItem>.from(otpUris.map((uri) => OtpItem.fromUri(uri)));

      // Use List.filled to create modifiable lists
      _isExpanded = List<bool>.filled(otpItems.length, false, growable: true);
      _progress = List<double>.filled(otpItems.length, 0.0, growable: true);
      _timers = List<Timer>.generate(otpItems.length, (_) => Timer(Duration.zero, () {}), growable: true);
      currentOtps = List<String>.filled(otpItems.length, '', growable: true);

      if (otpItems.isNotEmpty) {
        _generateAllOtps();
      }
    } catch (e) {
      print('Error in initState: $e');
      _setDefaultValues();
    }
  }

  void _setDefaultValues() {
    // Initialize modifiable lists
    // originalUris = [];
    otpItems = [];
    _isExpanded = [];
    _progress = [];
    _timers = [];
    currentOtps = [];
  }

  @override
  void dispose() {
    for (var timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  void _resetAndStartTimer(int index) {
    if (index < 0 || index >= _timers.length) return;

    _timers[index].cancel();
    _progress[index] = 0.0;

    const updateInterval = Duration(milliseconds: 100);
    final totalDuration = Duration(seconds: otpItems[index].interval);
    var elapsed = Duration.zero;

    _timers[index] = Timer.periodic(updateInterval, (timer) {
      elapsed += updateInterval;
      if (mounted) {
        setState(() {
          _progress[index] = elapsed.inMilliseconds / totalDuration.inMilliseconds;
        });
      }

      if (elapsed >= totalDuration) {
        timer.cancel();
        _refreshOtp(index);
      }
    });
  }

  void _refreshOtp(int index) {
    if (index < 0 || index >= otpItems.length) return;

    setState(() {
      currentOtps[index] = _generateOtp(otpItems[index]);
      _resetAndStartTimer(index);
    });
  }

  void _generateAllOtps() {
    setState(() {
      for (int i = 0; i < otpItems.length; i++) {
        currentOtps[i] = _generateOtp(otpItems[i]);
        _resetAndStartTimer(i);
      }
    });
  }

  void _addOtp(String uri) {
    setState(() {
      try {
        otpUris.add(uri);
        prefs.setStringList('otpUris', otpUris);
        // originalUris.add(uri);
        final newOtpItem = OtpItem.fromUri(uri);
        otpItems.add(newOtpItem);
        _isExpanded.add(false);
        _progress.add(0.0);
        _timers.add(Timer(Duration.zero, () {}));
        currentOtps.add('');
        final newIndex = otpItems.length - 1;
        currentOtps[newIndex] = _generateOtp(newOtpItem);
        _resetAndStartTimer(newIndex);
      } catch (e) {
        print('Error adding OTP: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add OTP: $e')),
        );
      }
    });
  }

  String _generateOtp(OtpItem item) {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      return OTP.generateTOTPCodeString(
        item.secret,
        currentTime,
        length: item.length,
        interval: item.interval,
        algorithm: item.algorithm,
        isGoogle: true,
      );
    } catch (e) {
      print('Error generating OTP: $e');
      return 'Error';
    }
  }



  void _copyOtp(int index) {
    if (index < 0 || index >= currentOtps.length) return;

    Clipboard.setData(ClipboardData(text: currentOtps[index]));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP copied to clipboard')),
    );
  }


  void _exportOtp(BuildContext context, int index) {
    var singleOtpUri = otpUris[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QRCodeDialog(uri: singleOtpUri);
      },
    );
  }

  void _deleteOtp(int index) {
    try {
      // Remove the OTP URI from the list
      otpUris.removeAt(index);
      // Remove the OTP item from the list
      otpItems.removeAt(index);
      // Remove the corresponding expansion state
      _isExpanded.removeAt(index);
      // Cancel and remove the timer
      _timers[index].cancel();
      _timers.removeAt(index);
      // Remove the progress indicator value
      _progress.removeAt(index);
      // Remove the current OTP value
      currentOtps.removeAt(index);
      // Update the stored URIs in SharedPreferences
      prefs.setStringList('otpUris', otpUris);
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted successfully')),
      );
    } catch (e) {
      print('Error deleting OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete OTP: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP List'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: otpItems.isEmpty
          ? const Center(child: Text('No OTPs added yet. Tap the + button to add one.'))
          : ListView.builder(
        itemCount: otpItems.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Text(
                otpItems[index].label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(otpItems[index].issuer),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.ios_share),
                    onPressed: () => _exportOtp(context, index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteOtp(index),
                  ),
                ],
              ),
              onExpansionChanged: (expanded) {
                setState(() {
                  _isExpanded[index] = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OTP: ${currentOtps[index]}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Digits: ${otpItems[index].length}'),
                      Text('Interval: ${otpItems[index].interval}s'),
                      Text('Algorithm: ${otpItems[index].algorithm.toString().split('.').last}'),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _progress[index],
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () => _copyOtp(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => _refreshOtp(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.input),
            label: 'Manual Input',
            onTap: _manualInput,
          ),
          SpeedDialChild(
            child: const Icon(Icons.qr_code_scanner),
            label: 'QR Scanner',
            onTap: _qrScanner,
          ),
        ],
      ),
    );
  }

  void _manualInput() async {
    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String secret = '';
        String label = '';
        String issuer = '';

        return AlertDialog(
          title: const Text('Manual Input'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Secret'),
                onChanged: (value) {
                  secret = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Label'),
                onChanged: (value) {
                  label = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Issuer (optional)'),
                onChanged: (value) {
                  issuer = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final uri = Uri(
                  scheme: 'otpauth',
                  host: 'totp',
                  path: label,
                  queryParameters: {
                    'secret': secret,
                    if (issuer.isNotEmpty) 'issuer': issuer,
                  },
                );
                Navigator.of(context).pop(uri.toString());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      _addOtp(result);
    }
  }

  void _qrScanner() async {
    String? scannedData;
    if (kIsWeb){
      scannedData = await _webQRScanner();
    }else{
      if (Platform.isAndroid) {
        // Check for mobile platforms without using dart:io
        scannedData = await _mobileQRScanner();
      } else {
        // Web-specific implementation
        scannedData = await _webQRScanner();
      }
    }
    if (scannedData != null) {
      if (isValidOtpUri(scannedData)) {
        _addOtp(scannedData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP QR code')),
        );
      }
    }
  }

  Future<String?> _webQRScanner() async {
    String? string_result;
    // For web, we'll use file picker to select an image
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      Uint8List fileBytes = result.files.first.bytes!;
      img.Image? image = img.decodeImage(fileBytes);

      if (image != null) {
        string_result = _processQRCodeImage(image);
      }
    }
    return string_result;
  }

  String? _processQRCodeImage(img.Image image) {
    LuminanceSource source = RGBLuminanceSource(
        image.width,
        image.height,
        image
            .convert(numChannels: 4)
            .getBytes(order: img.ChannelOrder.abgr)
            .buffer
            .asInt32List());
    var bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));

    try {
      var result = QRCodeReader().decode(bitmap);
      return result.text;
    } catch (e) {
      print('Error decoding QR code: $e');
      return null;
    }
  }




  Future<String?> _mobileQRScanner() async {
    String? result;
    bool hasScanned = false;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Scan QR Code'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: MobileScanner(
            onDetect: (capture) {
              if (hasScanned) return; // Prevent multiple scans
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  hasScanned = true;
                  result = barcode.rawValue;
                  Navigator.of(context).pop(); // This should close the scanner page
                  return;
                }
              }
            },
          ),
        ),
      ),
    );

    // If we've reached this point and hasScanned is still false,
    // it means the user manually went back without scanning
    if (!hasScanned) {
      result = null;
    }

    return result;
  }

}

