import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  String? _fullName; // Store full name
  String? _selectedStrand; // Store the selected strand

  // List of strands
  final List<String> strands = [
    'Technical-Vocational-Livelihood (TVL)',
    'Humanities and Social Sciences (HUMSS)',
    'Accountancy, Business, & Management (ABM)',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the page initializes
  }

  Future<void> _fetchUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      setState(() {
        _fullName = userSnapshot.get('fullName') ?? ''; // Fetch full name
        _selectedStrand =
            userSnapshot.get('strand') ?? strands[0]; // Default to first strand
        _usernameController.text =
            userSnapshot.get('username') ?? ''; // Fetch username
      });
    } else {
      print('User document does not exist');
    }
  }

  Future<void> _updateProfile() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'username': _usernameController.text, // Only update username
    });

    Navigator.of(context).pop(); // Go back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Edit Profile',
            style: GoogleFonts.montserrat(color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Full Name - uneditable
            TextField(
              controller: TextEditingController(text: _fullName),
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Strand - uneditable
            TextField(
              controller: TextEditingController(text: _selectedStrand),
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Strand',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Username - editable
            TextField(
              controller: _usernameController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10)
              ], // Restrict to 10 characters
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _updateProfile,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
              child: Text('Save Changes',
                  style: GoogleFonts.montserrat(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
