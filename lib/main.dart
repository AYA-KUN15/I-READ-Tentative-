import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:i_read_app/functions/editprofilepage.dart';
import 'firebase_options.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'mainmenu/home_menu.dart';
import 'mainmenu/modules_menu.dart';
import 'mainmenu/dictionary_menu.dart';
import 'mainmenu/profile_menu.dart';
import 'mainmenu/settings_menu.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(name: "Main", options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  void _startInactivityTimer() {
    _inactivityTimer = Timer.periodic(const Duration(hours: 2), _onInactivityTimeout);
  }

  void _onInactivityTimeout(Timer timer) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _resetInactivityTimer,
      onPanUpdate: (_) => _resetInactivityTimer(),
      child: MaterialApp(
        title: 'I-READ App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => HomeMenu(uniqueIds: []),
          '/modules_menu': (context) => ModulesMenu(
                onModulesUpdated: (updatedModules) {},
              ),
          '/dictionary_menu': (context) => const DictionaryMenu(),
          '/profile_menu': (context) => const ProfileMenu(),
          '/settings_menu': (context) => const SettingsMenu(),
          '/editprofilepage': (context) => const EditProfilePage(),
        },
      ),
    );
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _startInactivityTimer();
  }
}
