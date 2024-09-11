import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:cloud_otp/pages/auth_page.dart';

// Global variables
final supabase = Supabase.instance.client;
late List<String> otpUris;
late String loginUsername;
late String loginPassword;
bool needToLogin=true;
final SharedPreferencesAsync prefs = SharedPreferencesAsync();
const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');
bool isGuest = false;

bool isValidOtpUri(String uri) {
  // Basic validation for OTP URI format
  RegExp otpUriRegex = RegExp(r'^otpauth:\/\/(totp|hotp)\/(.+)\?secret=([A-Z2-7]+)(&.+)?$');
  return otpUriRegex.hasMatch(uri);
}

Future<void> logout(BuildContext context) async {
  await prefs.remove("loginUsername");
  await prefs.remove("loginPassword");
  supabase.auth.signOut();
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => const AuthPage()),
  );

}

