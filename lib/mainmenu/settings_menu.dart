import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import '../firestore/firestore_user.dart';
import '../functions/editprofilepage.dart'; // Ensure the correct import path

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key});

  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  // final FirestoreUser _firestoreUser = FirestoreUser();
  // User? _currentUser;

  @override
  void initState() {
    super.initState();
    // _currentUser = FirebaseAuth.instance.currentUser;
  }

  void _logout() async {
    // await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        return true; // Exit the app when back is pressed
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[700]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.05, vertical: height * 0.02),
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              Center(
                child: Text(
                  'Settings',
                  style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              // _buildSettingsButton('Edit Profile', context),
              _buildSettingsButton('Log Out', context, isLogout: true),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(
            context), // Ensure the nav bar is included
      ),
    );
  }

  Widget _buildSettingsButton(String title, BuildContext context,
      {bool isLogout = false}) {
    return Card(
      color: Colors.blue[800],
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.montserrat(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          if (isLogout) {
           showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.blue,
      title: Text(
        'Confirm Logout',
        style: GoogleFonts.montserrat(color: Colors.white),
      ),
      content: Text(
        'Are you sure you want to log out?',
        style: GoogleFonts.montserrat(color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(
            'Cancel',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            _logout(); // Call the logout function
          },
          child: Text(
            'Logout',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
        ),
      ],
    );
  },
);
          } else {
            // Navigate to Edit Profile page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfilePage(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Modules'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      currentIndex: 3,
      selectedItemColor: Colors.blue[900],
      unselectedItemColor: Colors.lightBlue,
      backgroundColor: Colors.white,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/modules_menu');
            break;
          case 2:
            Navigator.pushNamed(context, '/profile_menu');
            break;
          case 3:
            break;
        }
      },
    );
  }
}
