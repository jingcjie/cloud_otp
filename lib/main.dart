

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';
import 'dart:async';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';


final supabase = Supabase.instance.client;
late List<String> otpUris;
late String? loginUsername;
late String? loginPasswordHash;
bool needToLogin=true;
final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bclaahfvyffqzoqwwegd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJjbGFhaGZ2eWZmcXpvcXd3ZWdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQ5MTcyMjcsImV4cCI6MjA0MDQ5MzIyN30.wAmbOCF70IcnqVylOUq9FqSzv3_pXcc7uEgVi7_qTQk',
  );

  otpUris = (await asyncPrefs.getStringList("otpUris"))??[];
  loginUsername = (await asyncPrefs.getString("loginUsername"));
  loginPasswordHash = (await asyncPrefs.getString("loginPasswordHash"));
  if (loginUsername != null && loginPasswordHash != null){
    needToLogin = false;
  }
  
  runApp(MyApp());
}

String _hashPassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    StatefulWidget home;
    if (needToLogin){
      home = AuthPage();
    }else{
      home = const MainPage(userData: null);
    }
    return MaterialApp(
      title: 'Supabase Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light, // Light theme
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark, // Dark theme
        useMaterial3: true,
      ),
      themeMode: ThemeMode.light, // Use this to switch between dark and light modes
      home: home,
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}


class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isObscure = true;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_isLogin) {
          var user_name = _usernameController.text;
          var password_hash = (_passwordController.text);
          final response = await Supabase.instance.client
              .from('users')
              .select()
              .eq('username', user_name)
              .maybeSingle();

          if (response != null) {
            if (response['password_hash'] == password_hash) {
              var userData = response['data'];
              if(userData!=null){
                userData=jsonDecode(userData);
              }else{
                userData=List.empty();
              }
              asyncPrefs.setString("loginUsername", user_name);
              asyncPrefs.setString("loginPasswordHash", password_hash);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => MainPage(userData: userData,)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid username or password')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not found')),
            );
          }
        } else {
          // Check if username already exists
          final existingUser = await Supabase.instance.client
              .from('users')
              .select()
              .eq('username', _usernameController.text)
              .maybeSingle();

          if (existingUser != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Username already exists')),
            );
          } else {
            // Create new user
            await Supabase.instance.client.from('users').insert({
              'username': _usernameController.text,
              'password_hash': _hashPassword(_passwordController.text),
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign up successful. Please log in.')),
            );
            setState(() => _isLogin = true);
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade300, Colors.purple.shade300],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock,
                            size: 80,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _isLogin ? 'Welcome Back' : 'Create Account',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter your username' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscure ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: _isObscure,
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter your password' : null,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: Text(_isLogin ? 'Login' : 'Sign Up'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => setState(() => _isLogin = !_isLogin),
                            child: Text(
                              _isLogin
                                  ? 'Need an account? Sign Up'
                                  : 'Already have an account? Login',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> logout(BuildContext context) async {
  await asyncPrefs.remove("loginUsername");
  await asyncPrefs.remove("loginPasswordHash");
  Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => AuthPage()),
              );
  
}

class MainPage extends StatefulWidget {
  final dynamic userData;
  const MainPage({super.key, required this.userData});

  
  @override
  _MainPageState createState() => _MainPageState(userData: userData);
}

class _MainPageState extends State<MainPage> {


  final dynamic userData;

  int _selectedIndex = 0;

  late List<Widget> _widgetOptions;
  
  _MainPageState({required this.userData});

  @override
  void initState() {
    super.initState();
    try{
      if (userData != null){
        otpUris = List.from(userData);
      }
    }catch(e){
      if (kDebugMode) {
        print("Error in getting OTP URIs");
      }
    }
    _widgetOptions = <Widget>[
      ListViewPage(),
      SettingsPage(),
    ];
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud OTP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              logout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}


class OtpItem {
  final String label;
  final String secret;
  final String issuer;
  final int length;
  final int interval;
  final Algorithm algorithm;

  OtpItem({
    required this.label,
    required this.secret,
    required this.issuer,
    this.length = 6,
    this.interval = 30,
    this.algorithm = Algorithm.SHA1,
  });

  factory OtpItem.fromUri(String uri) {
    final parsedUri = Uri.parse(uri);
    final label = parsedUri.path.substring(1); // Remove leading '/'
    final secret = parsedUri.queryParameters['secret'] ?? '';
    final issuer = parsedUri.queryParameters['issuer'] ?? '';
    final length = int.tryParse(parsedUri.queryParameters['digits'] ?? '6') ?? 6;
    final interval = int.tryParse(parsedUri.queryParameters['period'] ?? '30') ?? 30;
    final algorithm = _parseAlgorithm(parsedUri.queryParameters['algorithm']);
    
    return OtpItem(
      label: label,
      secret: secret,
      issuer: issuer,
      length: length,
      interval: interval,
      algorithm: algorithm,
    );
  }

  static Algorithm _parseAlgorithm(String? algorithmStr) {
    switch (algorithmStr?.toUpperCase()) {
      case 'SHA256':
        return Algorithm.SHA256;
      case 'SHA512':
        return Algorithm.SHA512;
      default:
        return Algorithm.SHA1;
    }
  }
}

class ListViewPage extends StatefulWidget {

  @override
  _ListViewPageState createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  late List<OtpItem> otpItems;
  late List<String> currentOtps;
  late List<bool> _isExpanded;
  late List<double> _progress;
  late List<Timer> _timers;
  // late List<String> originalUris;

  @override
  void initState() {
    super.initState();
    _initializeState();
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
        asyncPrefs.setStringList('otpUris', otpUris);
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

  void _exportOtp(int index) {

  }

  void _deleteOtp(int index) {
    setState(() {
      try {
        // Remove the OTP URI from the list
        otpUris.removeAt(index);
        // Update the stored URIs in SharedPreferences
        asyncPrefs.setStringList('otpUris', otpUris);

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

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted successfully')),
        );
      } catch (e) {
        print('Error deleting OTP: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete OTP: $e')),
        );
      }
    });
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
          ? Center(child: Text('No OTPs added yet. Tap the + button to add one.'))
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
                          onPressed: () => _exportOtp(index),
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
            child: Icon(Icons.input),
            label: 'Manual Input',
            onTap: _manualInput,
          ),
          SpeedDialChild(
            child: Icon(Icons.qr_code_scanner),
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
          title: Text('Manual Input'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Secret'),
                onChanged: (value) {
                  secret = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Label'),
                onChanged: (value) {
                  label = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Issuer (optional)'),
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
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final uri = Uri(
                  scheme: 'otpauth',
                  host: 'totp',
                  path: '$label',
                  queryParameters: {
                    'secret': secret,
                    if (issuer.isNotEmpty) 'issuer': issuer,
                  },
                );
                Navigator.of(context).pop(uri.toString());
              },
              child: Text('Save'),
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

  if (kIsWeb) {
    // Web-specific implementation
    scannedData = await _webQRScanner();
  } else {
    // Check for mobile platforms without using dart:io
    scannedData = await _mobileQRScanner();
  }

  if (scannedData != null) {
    if (_isValidOtpUri(scannedData)) {
      _addOtp(scannedData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP QR code')),
      );
    }
  }
}

Future<String?> _webQRScanner() async {
  // For web, we'll use file picker to select an image
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );

  if (result != null) {
    Uint8List fileBytes = result.files.first.bytes!;
    img.Image? image = img.decodeImage(fileBytes);
    
    if (image != null) {
      return _processQRCodeImage(image);
    }
  }
  return null;
}

Future<String?> _mobileQRScanner() async {
  // This function will handle both Android and iOS
  final qrKey = GlobalKey(debugLabel: 'QR');
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text('Scan QR Code')),
        body: QRView(
          key: qrKey,
          onQRViewCreated: (QRViewController controller) {
            controller.scannedDataStream.listen((scanData) {
              controller.dispose();
              Navigator.of(context).pop(scanData.code);
            });
          },
        ),
      ),
    ),
  );
}

String? _processQRCodeImage(img.Image image) {
  // Convert image to grayscale
  img.Image grayscale = img.grayscale(image);
  
  // Convert the grayscale image to Int32List
  Int32List pixels = Int32List(grayscale.width * grayscale.height);
  for (int y = 0; y < grayscale.height; y++) {
    for (int x = 0; x < grayscale.width; x++) {
      img.Pixel pixel = grayscale.getPixel(x, y);
      // In a grayscale image, we can use any channel (r, g, or b) as they should all be the same
      int grayscaleValue = pixel.r.toInt();
      pixels[y * grayscale.width + x] = grayscaleValue;
    }
  }

  LuminanceSource source = RGBLuminanceSource(
    grayscale.width,
    grayscale.height,
    pixels,
  );
  var bitmap = BinaryBitmap(HybridBinarizer(source));
  
  try {
    var result = QRCodeReader().decode(bitmap);
    return result.text;
  } catch (e) {
    print('Error decoding QR code: $e');
    return null;
  }
}

bool _isValidOtpUri(String uri) {
  // Basic validation for OTP URI format
  RegExp otpUriRegex = RegExp(r'^otpauth:\/\/(totp|hotp)\/(.+)\?secret=([A-Z2-7]+)(&.+)?$');
  return otpUriRegex.hasMatch(uri);
}
}



class SettingsPage extends StatelessWidget {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _changePassword(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Old Password'),
            ),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_newPasswordController.text != _confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New passwords do not match')),
                );
                return;
              }
              
              var user_name = Supabase.instance.client.auth.currentUser?.email;
              var old_password_hash = _hashPassword(_oldPasswordController.text);
              
              final response = await Supabase.instance.client
                .from('users')
                .select()
                .eq('username', user_name)
                .maybeSingle();
              
              if (response != null && response['password_hash'] == old_password_hash) {
                // Implement password change logic here
                // For now, just show a success message
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid old password')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _pullData(BuildContext context) async {
    var user_name = Supabase.instance.client.auth.currentUser?.email;
    final response = await Supabase.instance.client
      .from('users')
      .select()
      .eq('username', user_name)
      .maybeSingle();
    
    if (response != null) {
      var userData = response['userdata'];
      // Use the userData as needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pulled successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pull data')),
      );
    }
  }

  Future<void> _backupData(BuildContext context) async {
    var user_name = Supabase.instance.client.auth.currentUser?.email;
    var userData = {}; // Populate this with the user data to be backed up
    
    final response = await Supabase.instance.client
      .from('users')
      .update({'userdata': userData})
      .eq('username', user_name);
    
    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data backed up successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to backup data')),
      );
    }
  }

  Future<void> _exportData(BuildContext context) async {
    var user_name = Supabase.instance.client.auth.currentUser?.email;
    final response = await Supabase.instance.client
      .from('users')
      .select()
      .eq('username', user_name)
      .maybeSingle();
    
    if (response != null) {
      var userData = response['userdata'];
      String jsonData = json.encode(userData);
      
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'user_data.json',
      );

      if (outputFile != null) {
        // Write jsonData to the file
        // Note: The actual file writing process depends on the platform (web, Windows, Android)
        // You'll need to implement platform-specific file writing here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data exported successfully')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export data')),
      );
    }
  }

  Future<void> _loadData(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String content;
        if (kIsWeb) {
          // For web
          var fileBytes = result.files.first.bytes;
          content = utf8.decode(fileBytes!);
        } else {
          // For mobile and desktop
          File file = File(result.files.single.path!);
          content = await file.readAsString();
        }

      Map<String, dynamic> userData = json.decode(content);
      
      // Use the userData to update the application state
      // You'll need to implement this part based on your app's structure
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data loaded successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Implement account deletion here
        // For now, just return to the login page
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => AuthPage()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Change Password'),
          onTap: () => _changePassword(context),
        ),
        ListTile(
          leading: const Icon(Icons.cloud_download),
          title: const Text('Pull Data'),
          onTap: () => _pullData(context),
        ),
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('Backup Data'),
          onTap: () => _backupData(context),
        ),
        ListTile(
          leading: const Icon(Icons.file_download),
          title: const Text('Export Data'),
          onTap: () => _exportData(context),
        ),
        ListTile(
          leading: const Icon(Icons.file_upload),
          title: const Text('Load Data'),
          onTap: () => _loadData(context),
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
          onTap: () => _deleteAccount(context),
        ),
      ],
    );
  }
}