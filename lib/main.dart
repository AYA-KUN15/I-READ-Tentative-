import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:i_read_app/pages/login_page.dart'; // Adjust path
import 'package:i_read_app/services/api.dart'; // Adjust path
import 'package:i_read_app/models/user.dart'; // Adjust path
import 'package:i_read_app/models/module.dart'; // Adjust path
import 'package:i_read_app/services/storage.dart';

import 'help.dart';
import 'levels/readcomp_levels/readcomp_easy.dart';
import 'levels/readcomp_levels/readcomp_hard.dart';
import 'levels/readcomp_levels/readcomp_levels.dart';
import 'levels/readcomp_levels/readcomp_medium.dart';
import 'levels/sentcomp_levels/sentcomp_levels.dart';
import 'levels/vocabskills_levels/vocabskills_levels.dart';
import 'levels/wordpro_levels/wordpro_levels.dart';
import 'levels/wordpro_levels/wordpro_easy.dart'; // Add these imports
import 'levels/wordpro_levels/wordpro_medium.dart';
import 'levels/wordpro_levels/wordpro_hard.dart';
import 'levels/sentcomp_levels/sentcomp_easy.dart';
import 'levels/sentcomp_levels/sentcomp_medium.dart';
import 'levels/sentcomp_levels/sentcomp_hard.dart';
import 'levels/vocabskills_levels/vocabskills_easy.dart';
import 'levels/vocabskills_levels/vocabskills_medium.dart';
import 'levels/vocabskills_levels/vocabskills_hard.dart';
import 'mainmenu/home_menu.dart';
import 'mainmenu/modules_menu.dart';
import 'mainmenu/profile_menu.dart';
import 'mainmenu/settings_menu.dart'; // Adjust path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = FlutterSecureStorage();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final loginTime = prefs.getInt('loginTime') ?? 0;
  final String? email = await storage.read(key: 'email');
  final String? password = await storage.read(key: 'password');

  // Check if login is valid (within 4 hours)
  bool shouldAutoLogin = isLoggedIn &&
      email != null &&
      password != null &&
      DateTime.now().millisecondsSinceEpoch - loginTime <
          4 * 60 * 60 * 1000; // 4 hours in milliseconds

  if (shouldAutoLogin) {
    // Attempt to auto-login using stored credentials
    try {
      final apiService = ApiService();
      final storageService = StorageService();
      await apiService.postGenerateToken(email, password);
      UserProfile? userProfile = await apiService.getProfile();
      List<Module>? modules = await apiService.getModules();

      if (userProfile != null) {
        await storageService.storeUserProfile(userProfile);
      }
      if (modules != null && modules.isNotEmpty) {
        await storageService.storeModules(modules);
      }
    } catch (e) {
      // If auto-login fails, clear stored data and redirect to login
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('loginTime');
      await storage.delete(key: 'email');
      await storage.delete(key: 'password');
      shouldAutoLogin = false;
    }
  }

  runApp(MyApp(initialRoute: shouldAutoLogin ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iRead App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) =>
            const HomeMenu(uniqueIds: []), // Adjust uniqueIds as needed
        '/modules_menu': (context) => ModulesMenu(
              onModulesUpdated: (updatedModules) {
                // Handle module updates if needed
              },
            ), // Adjust as per your app
        '/profile_menu': (context) =>
            const ProfileMenu(), // Replace with actual ProfileMenu
        '/settings_menu': (context) =>
            const SettingsMenu(), // Now points to SettingsMenu
        '/reading_comprehension_levels': (context) =>
            const ReadingComprehensionLevels(),
        '/wordpro_levels': (context) => const WordPronunciationLevels(),
        '/sentcomp_levels': (context) => const SentenceCompositionLevels(),
        '/vocabskills_levels': (context) => const VocabularySkillsLevels(),
        '/help': (context) => const HelpPage(),
      },
      onGenerateRoute: (settings) {
        // Dynamic routes for difficulty levels
        if (settings.name == '/read_comp_easy') {
          return MaterialPageRoute(builder: (context) => const ReadCompEasy());
        } else if (settings.name == '/read_comp_medium') {
          return MaterialPageRoute(
              builder: (context) => const ReadCompMedium());
        } else if (settings.name == '/read_comp_hard') {
          return MaterialPageRoute(builder: (context) => const ReadCompHard());
        }
        // Word Pronunciation routes
        else if (settings.name == '/wordpro_easy') {
          return MaterialPageRoute(builder: (context) => const WordProEasy());
        } else if (settings.name == '/wordpro_medium') {
          return MaterialPageRoute(builder: (context) => const WordProMedium());
        } else if (settings.name == '/wordpro_hard') {
          return MaterialPageRoute(builder: (context) => const WordProHard());
        }
        // Sentence Composition routes
        else if (settings.name == '/sentcomp_easy') {
          return MaterialPageRoute(builder: (context) => const SentCompEasy());
        } else if (settings.name == '/sentcomp_medium') {
          return MaterialPageRoute(
              builder: (context) => const SentCompMedium());
        } else if (settings.name == '/sentcomp_hard') {
          return MaterialPageRoute(builder: (context) => const SentCompHard());
        }
        // Vocabulary Skills routes
        else if (settings.name == '/vocabskills_easy') {
          return MaterialPageRoute(
              builder: (context) => const VocabSkillsEasy());
        } else if (settings.name == '/vocabskills_medium') {
          return MaterialPageRoute(
              builder: (context) => const VocabSkillsMedium());
        } else if (settings.name == '/vocabskills_hard') {
          return MaterialPageRoute(
              builder: (context) => const VocabSkillsHard());
        }
        return null;
      },
    );
  }
}
