import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/services/storage.dart';

import 'readcomp_easy.dart';
import 'readcomp_medium.dart';
import 'readcomp_hard.dart';
import 'package:i_read_app/services/api.dart';

class ReadingComprehensionLevels extends StatefulWidget {
  const ReadingComprehensionLevels({super.key});

  @override
  _ReadingComprehensionLevelsState createState() =>
      _ReadingComprehensionLevelsState();
}

class _ReadingComprehensionLevelsState
    extends State<ReadingComprehensionLevels> {
  String userId = '';
  final String moduleName = 'Reading Comprehension';
  StorageService storageService = StorageService();
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/modules_menu');
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5E8C7), // Manila paper
          elevation: 0, // Flat look
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF8B4513)), // Brown back arrow
            onPressed: () {
              Navigator.pushNamed(context, '/modules_menu');
            },
          ),
          title: Text(
            'Reading Comprehension Levels',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B4513),
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0xFFF5E8C7), // Manila paper background
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLevelButton(context, 'Easy'),
              const SizedBox(height: 20),
              _buildLevelButton(context, 'Medium'),
              const SizedBox(height: 20),
              _buildLevelButton(context, 'Hard'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, String level) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20.0), // Horizontal padding for alignment
      child: ElevatedButton(
        onPressed: () {
          switch (level) {
            case 'Easy':
              Navigator.pushNamed(context, '/read_comp_easy');
              break;
            case 'Medium':
              Navigator.pushNamed(context, '/read_comp_medium');
              break;
            case 'Hard':
              Navigator.pushNamed(context, '/read_comp_hard');
              break;
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B4513), // Reverted to brown
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
          minimumSize:
              const Size(400, 60), // Increased width to 300 for larger buttons
        ),
        child: Text(
          level,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
