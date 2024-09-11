import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';


import 'utils/constants.dart';
import 'pages/auth_page.dart';
import 'pages/main_page.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bclaahfvyffqzoqwwegd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJjbGFhaGZ2eWZmcXpvcXd3ZWdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQ5MTcyMjcsImV4cCI6MjA0MDQ5MzIyN30.wAmbOCF70IcnqVylOUq9FqSzv3_pXcc7uEgVi7_qTQk',
  );

  otpUris = (await prefs.getStringList("otpUris"))??[];
  try{
    bool isGuest = (await prefs.getBool("isGuest"))??false;
    String savedLoginusername = (await prefs.getString("loginUsername"))??"";
    String savedLoginPassword = (await prefs.getString("loginPassword"))??"";
    if (!isGuest){
      if (savedLoginPassword!="" && savedLoginusername!=""){
        final response = await supabase.auth.signInWithPassword(
          email: savedLoginusername,
          password: savedLoginPassword,
        );
        if (response.user != null) {
          needToLogin = false;
        }
      }
    }else{
      needToLogin = false;
    }
  }catch(e) {
    if (kDebugMode) {
      print(e);
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    StatefulWidget home;
    if (needToLogin){
      home = const AuthPage();
    }else{
      home = const MainPage();
    }
    return MaterialApp(
      title: 'Cloud OTP',
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




