import 'package:cloud_otp/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_otp/models/snackbar.dart';

class AuthPage extends StatefulWidget {
  final VoidCallback onLoginCallback;
  const AuthPage({super.key, required this.onLoginCallback});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isObscure = true;
  bool _isLoading = false;
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _enterGuestMode() {
    // Implement guest mode logic here
    isGuest = true;
    prefs.setBool("isGuest", isGuest);
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(builder: (_) => const MainPage()),
    // );
    widget.onLoginCallback();
  }


  Future<void> _overrideLocal(BuildContext context, List cloudOtpUris) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Data exist on cloud'),
          content: const Text('Do you want to pull data from cloud to local? This will overwrite the data in local'),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(false),
            ),

          ],
        );
      },
    );

    if (confirm == true) {
      // Perform the pull data operation
      try {
        var userData = cloudOtpUris;
        otpUris = List.from(userData);
        await prefs.setStringList("otpUris", otpUris);
        context.showBeautifulSnackBar(message: 'Data pulled successfully');

      }catch (e){
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to pull data, maybe there is no data in cloud. Error: ${e.toString()}')),
        // );
        context.showBeautifulSnackBar(message: 'Failed to pull data, maybe there is no data in cloud. Error: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isLogin) {
          var response = await supabase.auth.signInWithPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          //  success sign in
          String id = response.user!.id;
          isGuest = false;
          prefs.setBool("isGuest", isGuest);
          dynamic tResponse;
          tResponse = await supabase
              .from('user_data')
              .select()
              .maybeSingle();
          // no data at all
          if (tResponse==null){
            await supabase
                .from('user_data')
                .insert({ 'user_id': id,'user_data': [] });
          }else {
            if (tResponse['user_data'] == null) {
              await supabase
                  .from('user_data')
                  .update({'user_data': []})
                  .eq('user_id', id);
            } else {
              List cloudOtpUris = List.from(tResponse['user_data']);
              if (cloudOtpUris.isNotEmpty) {
                if (otpUris.isEmpty){
                  otpUris = List.from(cloudOtpUris);
                  await prefs.setStringList("otpUris", otpUris);
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Data pulled successfully')),
                  // );

                  context.showBeautifulSnackBar(message: 'Data pulled successfully');
                }else{
                  await _overrideLocal(context, cloudOtpUris);
                }
              }
            }
          }

          loginUsername = _emailController.text;
          loginPassword = _passwordController.text;

          await prefs.setString("loginUsername", loginUsername);
          await prefs.setString("loginPassword", loginPassword);
          await prefs.setStringList("otpUris", otpUris);

          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(builder: (_) => const MainPage()),
          // );
          widget.onLoginCallback();
        }
        else {
          final response = await supabase.auth.signUp(
            email: _emailController.text,
            password: _passwordController.text,
          );

          if (response.user != null) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text('Sign up successful. You can now log in.')),
            // );
            context.showBeautifulSnackBar(message: 'Sign up successful. You can now log in.');
            setState(() => _isLogin = true);
          }
        }
      } on AuthException catch (e) {
        context.showBeautifulSnackBar(message: 'Error: ${e.toString()}', isError: true);
      } catch (e) {
        context.showBeautifulSnackBar(message: 'Error: ${e.toString()}', isError: true);
      } finally {
        setState(() {
          _isLoading = false;
        });
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
          child: Stack(
            children: [
              Center(
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
                                const Icon(
                                  Icons.lock,
                                  size: 80,
                                  color: Colors.green,
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
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: const Icon(Icons.email),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) =>
                                  value!.isEmpty ? 'Please enter your email' : null,
                                  keyboardType: TextInputType.emailAddress,
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
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
                                  onFieldSubmitted: (_) {
                                    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                                      _submitForm();
                                    }
                                  },
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator()
                                      : Text(_isLogin ? 'Login' : 'Sign Up'),
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
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  onPressed: _enterGuestMode,
                  icon: const Icon(Icons.person_outline),
                  label: const Text('Local/Guest Mode'),
                  backgroundColor: Colors.purple.shade400,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

