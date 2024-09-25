import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'utils/constants.dart';
import 'pages/auth_page.dart';
import 'pages/main_page.dart';
import 'models/theme_provider.dart';
import 'package:animations/animations.dart';

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
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
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
            themeMode: themeProvider.themeMode,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}

//
// class AppShell extends StatefulWidget {
//   const AppShell({super.key});
//
//   @override
//   State<AppShell> createState() => _AppShellState();
// }
// class _AppShellState extends State<AppShell> {
//   int pageNum = 0;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           if (!kIsWeb && (kIsWIN || kIsMAC || kIsLIN))
//             Stack(
//               children: [
//                 GestureDetector(
//                   onPanStart: (details) {
//                     windowManager.startDragging();
//                   },
//                   child: Container(
//                     height: 32,
//                     color: Colors.transparent,
//                     child: Center(
//                       child: Icon(
//                         Icons.drag_handle,
//                         size: 24,
//                         color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 0,
//                   right: 0,
//                   child: IconButton(
//                     icon: const Icon(Icons.exit_to_app_rounded),
//                     onPressed: () {
//                         exit(0);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           Expanded(
//             child: Navigator(
//               key: ValueKey(pageNum), // Force rebuild when pageNum changes
//               onGenerateRoute: (settings) {
//                 late Widget page;
//                 switch(pageNum) {
//                   case 0:
//                     page = AuthPage(onLoginCallback: () {
//                       setState(() => pageNum = 1);
//                     });
//                     break;
//                   case 1:
//                     page = MainPage(onLogoutCallback: () {
//                       setState(() => pageNum = 0);
//                     });
//                     break;
//                   default:
//                     throw StateError('Invalid pageNum: $pageNum');
//                 }
//                 return MaterialPageRoute(builder: (_) => page);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int pageNum = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (!kIsWeb && (kIsWIN || kIsMAC || kIsLIN))
            Stack(
              children: [
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
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.exit_to_app_rounded),
                    onPressed: () {
                      exit(0);
                    },
                  ),
                ),
              ],
            ),
          Expanded(
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 300),
              reverse: pageNum == 0, // Reverse animation when going back to AuthPage
              transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  ) {
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
              child: _buildPage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (pageNum) {
      case 0:
        return AuthPage(onLoginCallback: () {
          setState(() => pageNum = 1);
        });
      case 1:
        return MainPage(onLogoutCallback: () {
          setState(() => pageNum = 0);
        });
      default:
        throw StateError('Invalid pageNum: $pageNum');
    }
  }
}