import 'package:cloud_otp/utils/constants.dart';
import 'package:flutter/material.dart';
import 'main_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
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
          String id = response.user!.id;
          //  success sign in
          isGuest = false;
          prefs.setBool("isGuest", isGuest);
          dynamic tResponse;
          tResponse = await supabase
              .from('user_data')
              .select()
              .maybeSingle();
          // no data
          if (tResponse==null){
            await supabase
                .from('user_data')
                .insert({ 'user_id': id,'user_data': [] });
            otpUris= [];

          }else {
            if (tResponse['user_data'] == null) {
              await supabase
                  .from('user_data')
                  .update({'user_data': []})
                  .eq('user_id', id);
              otpUris= [];
            } else {
              otpUris = List.from(tResponse['user_data']);
            }
          }
          loginUsername = _emailController.text;
          loginPassword = _passwordController.text;

          await prefs.setString("loginUsername", loginUsername);
          await prefs.setString("loginPassword", loginPassword);
          await prefs.setStringList("otpUris", otpUris);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        }
        else {
          final response = await supabase.auth.signUp(
            email: _emailController.text,
            password: _passwordController.text,
          );

          if (response.user != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign up successful. You can now log in.')),
            );
            setState(() => _isLogin = true);
          }
        }
      } on AuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Container(
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //           colors: [Colors.blue.shade300, Colors.purple.shade300],
  //         ),
  //       ),
  //       child: SafeArea(
  //         child: Center(
  //           child: SingleChildScrollView(
  //             child: Padding(
  //               padding: const EdgeInsets.all(24.0),
  //               child: Card(
  //                 elevation: 8,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(24.0),
  //                   child: Form(
  //                     key: _formKey,
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Icon(
  //                           Icons.lock,
  //                           size: 80,
  //                           color: Theme.of(context).primaryColor,
  //                         ),
  //                         const SizedBox(height: 24),
  //                         Text(
  //                           _isLogin ? 'Welcome Back' : 'Create Account',
  //                           style: const TextStyle(
  //                             fontSize: 24,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 24),
  //                         TextFormField(
  //                           controller: _emailController,
  //                           decoration: InputDecoration(
  //                             labelText: 'Email',
  //                             prefixIcon: const Icon(Icons.email),
  //                             border: OutlineInputBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                             ),
  //                           ),
  //                           validator: (value) =>
  //                           value!.isEmpty ? 'Please enter your email' : null,
  //                           keyboardType: TextInputType.emailAddress,
  //                           onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
  //                         ),
  //                         const SizedBox(height: 16),
  //                         TextFormField(
  //                           controller: _passwordController,
  //                           focusNode: _passwordFocusNode,
  //                           decoration: InputDecoration(
  //                             labelText: 'Password',
  //                             prefixIcon: const Icon(Icons.lock),
  //                             suffixIcon: IconButton(
  //                               icon: Icon(
  //                                 _isObscure ? Icons.visibility : Icons.visibility_off,
  //                               ),
  //                               onPressed: () {
  //                                 setState(() {
  //                                   _isObscure = !_isObscure;
  //                                 });
  //                               },
  //                             ),
  //                             border: OutlineInputBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                             ),
  //                           ),
  //                           obscureText: _isObscure,
  //                           validator: (value) =>
  //                           value!.isEmpty ? 'Please enter your password' : null,
  //                           onFieldSubmitted: (_) {
  //                             if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
  //                               _submitForm();
  //                             }
  //                           },
  //                         ),
  //                         const SizedBox(height: 24),
  //                         ElevatedButton(
  //                           onPressed: _isLoading ? null : _submitForm,
  //                           style: ElevatedButton.styleFrom(
  //                             minimumSize: Size(double.infinity, 50),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                             ),
  //                           ),
  //                           child: _isLoading
  //                               ? const CircularProgressIndicator()
  //                               : Text(_isLogin ? 'Login' : 'Sign Up'),
  //                         ),
  //                         const SizedBox(height: 16),
  //                         TextButton(
  //                           onPressed: () => setState(() => _isLogin = !_isLogin),
  //                           child: Text(
  //                             _isLogin
  //                                 ? 'Need an account? Sign Up'
  //                                 : 'Already have an account? Login',
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
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
