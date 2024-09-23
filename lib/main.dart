import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:window_manager/window_manager.dart';

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
    isGuest = (await prefs.getBool("isGuest"))??false;
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
  if (!kIsWeb){
    if(kIsWIN||kIsMAC||kIsLIN){
      WidgetsFlutterBinding.ensureInitialized();
      await windowManager.ensureInitialized();
      windowManager.waitUntilReadyToShow().then((_) async {
        await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

        // Restore window size and position from SharedPreferences
        double width =  await prefs.getDouble('window_width') ?? 360.0;
        double height = await prefs.getDouble('window_height') ?? 720.0;
        await windowManager.setSize(Size(width, height));

        double? x =  await prefs.getDouble('window_x') ?? 10.0;
        double? y = await prefs.getDouble('window_y') ?? 10.0;
        await windowManager.setPosition(Offset(x, y));

        await windowManager.setMinimumSize(const Size(360, 360));
        await windowManager.show();
        await windowManager.setSkipTaskbar(false);
      });
      windowManager.addListener(MyWindowListener());
    }

  }

  runApp(const MyApp());
}

class MyWindowListener extends WindowListener {


  @override
  void onWindowResized() async {
    // This method is called when the window is resized
    await windowManager.ensureInitialized();
    Size? size = await windowManager.getSize();
    // Save size
    await prefs.setDouble('window_width', size.width);
    await prefs.setDouble('window_height', size.height);
    }

  @override
  void onWindowMoved() async {
    // This method is called when the window is moved
    await windowManager.ensureInitialized();
    Offset? position = await windowManager.getPosition();
    // Save position
    await prefs.setDouble('window_x', position.dx);
    await prefs.setDouble('window_y', position.dy);
    }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    StatefulWidget home;
    if (needToLogin) {
      home = const AuthPage();
    } else {
      home = const MainPage();
    }
    return MaterialApp(
      title: 'Cloud OTP',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      home: Scaffold(
        body: Column(
          children: [
            if (!kIsWeb && (kIsWIN || kIsLIN || kIsMAC))
              GestureDetector(
                onPanStart: (details) {
                  windowManager.startDragging();
                },
                child: Container(
                  height: 32,
                  color: Colors.transparent,
                  child: Center(
                    child: Icon(
                      Icons.drag_handle,
                      size: 24,
                      color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: home,
            ),
          ],
        ),
      ),
    );
  }
}


