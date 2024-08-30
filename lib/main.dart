import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';
import 'dart:async';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bclaahfvyffqzoqwwegd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJjbGFhaGZ2eWZmcXpvcXd3ZWdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQ5MTcyMjcsImV4cCI6MjA0MDQ5MzIyN30.wAmbOCF70IcnqVylOUq9FqSzv3_pXcc7uEgVi7_qTQk',
  );
  
  runApp(MyApp());
}

final supabase = Supabase.instance.client;


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      home: AuthPage(),
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

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_isLogin) {
          final response = await Supabase.instance.client
              .from('users')
              .select()
              .eq('username', _usernameController.text)
              .maybeSingle();

          if (response != null) {
            if (response['password_hash'] == _hashPassword(_passwordController.text)) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => MainPage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invalid username or password')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User not found')),
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
              SnackBar(content: Text('Username already exists')),
            );
          } else {
            // Create new user
            await Supabase.instance.client.from('users').insert({
              'username': _usernameController.text,
              'password_hash': _hashPassword(_passwordController.text),
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sign up successful. Please log in.')),
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
                padding: EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
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
                          SizedBox(height: 24),
                          Text(
                            _isLogin ? 'Welcome Back' : 'Create Account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 24),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter your username' : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
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
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: Text(_isLogin ? 'Login' : 'Sign Up'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
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



class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Define your list of OTP URIs
  final List<String> otpUris = [
    'otpauth://totp/Example1?secret=JBSWY3DPEHPK3PXP&issuer=ExampleIssuer1&digits=6&period=30&algorithm=SHA1',
    'otpauth://totp/Example2?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&issuer=ExampleIssuer2&digits=8&period=60&algorithm=SHA256',
    // Add more OTP URIs as needed
  ];

  // Initialize _widgetOptions with ListViewPage using otpUris
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      ListViewPage(otpUris: otpUris),
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
        title: Text('My App'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => AuthPage()),
              );
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
  final List<String> otpUris;

  ListViewPage({required this.otpUris});

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
    otpItems = widget.otpUris.map((uri) => OtpItem.fromUri(uri)).toList();
    _isExpanded = List.generate(otpItems.length, (_) => false);
    _progress = List.generate(otpItems.length, (_) => 0.0);
    _timers = List.generate(otpItems.length, (_) => Timer(Duration.zero, () {}));
    currentOtps = List.filled(otpItems.length, '');
    _generateAllOtps();
  }


    @override
  void dispose() {
    for (var timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  void _resetAndStartTimer(int index) {
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

  String _generateOtp(OtpItem item) {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return OTP.generateTOTPCodeString(
      item.secret,
      currentTime,
      length: item.length,
      interval: item.interval,
      algorithm: item.algorithm,
      isGoogle: true,
    );
  }

  void _copyOtp(int index) {
    Clipboard.setData(ClipboardData(text: currentOtps[index]));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OTP copied to clipboard')),
    );
  }
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP List'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView.builder(
        itemCount: otpItems.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Text(
                otpItems[index].label,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(otpItems[index].issuer),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () => _copyOtp(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () => _refreshOtp(index),
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
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OTP: ${currentOtps[index]}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Digits: ${otpItems[index].length}'),
                      Text('Interval: ${otpItems[index].interval}s'),
                      Text('Algorithm: ${otpItems[index].algorithm.toString().split('.').last}'),
                      SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _progress[index],
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateAllOtps,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh all OTPs',
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
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
          leading: Icon(Icons.person),
          title: Text('Account'),
          onTap: () {
            // TODO: Implement account settings
          },
        ),
        ListTile(
          leading: Icon(Icons.notifications),
          title: Text('Notifications'),
          onTap: () {
            // TODO: Implement notification settings
          },
        ),
        ListTile(
          leading: Icon(Icons.security),
          title: Text('Privacy'),
          onTap: () {
            // TODO: Implement privacy settings
          },
        ),
        ListTile(
          leading: Icon(Icons.help),
          title: Text('Help & Support'),
          onTap: () {
            // TODO: Implement help & support
          },
        ),
        ListTile(
          leading: Icon(Icons.delete_forever, color: Colors.red),
          title: Text('Delete Account', style: TextStyle(color: Colors.red)),
          onTap: () => _deleteAccount(context),
        ),
      ],
    );
  }
}