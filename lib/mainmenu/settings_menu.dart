import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key});

  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
  }

  void _logout() async {
    // Clear stored login data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('loginTime');
    await storage.delete(key: 'email');
    await storage.delete(key: 'password');

    // Navigate to login page
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/home'); // Navigate back to HomeMenu
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5E8C7), // Manila paper background
          elevation: 0, // Flat look
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF8B4513)), // Brown back arrow
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          title: Text(
            'Settings',
            style: GoogleFonts.montserrat(
              fontSize: 20, // Match ProfileMenu and ModulesMenu
              fontWeight: FontWeight.bold, // Match ProfileMenu and ModulesMenu
              color: const Color(0xFF8B4513), // Brown text
            ),
          ),
        ),
        body: Container(
          color: const Color(0xFFF5E8C7), // Manila paper background
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.05, vertical: height * 0.02),
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              // Removed the "Settings" title from the body since it's now in the AppBar
              const SizedBox(height: 20),
              // Removed the Edit Profile button
              _buildSettingsButton('Log Out', context, isLogout: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton(String title, BuildContext context,
      {bool isLogout = false}) {
    return Card(
      color: const Color.fromARGB(255, 249, 222, 194), // Lighter manila shade
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            color: const Color(0xFF8B4513), // Brown text
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          if (isLogout) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: const Color(0xFFF5E8C7), // Manila paper
                  title: Text(
                    'Confirm Logout',
                    style: GoogleFonts.montserrat(
                        color: const Color(0xFF8B4513)), // Brown text
                  ),
                  content: Text(
                    'Are you sure you want to log out?',
                    style: GoogleFonts.montserrat(
                        color: const Color(0xFF8B4513)), // Brown text
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.montserrat(
                            color: const Color(0xFF8B4513)), // Brown text
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        _logout(); // Call the logout function
                      },
                      child: Text(
                        'Logout',
                        style: GoogleFonts.montserrat(
                            color: const Color(0xFF8B4513)), // Brown text
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
