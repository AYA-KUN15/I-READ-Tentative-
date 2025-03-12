import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/services/storage.dart';

import 'readcomp_easy.dart';
import 'readcomp_hard.dart';
import 'readcomp_medium.dart';

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

  bool isEasyCompleted = true;
  bool isMediumCompleted = true;
  bool isHardCompleted = true;

  @override
  void initState() {
    super.initState();
    // _checkCompletionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reading Comprehension Levels',
            style: GoogleFonts.montserrat()),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLevelButton(context, 'Easy', true), // Always unlocked
            const SizedBox(height: 20),
            _buildLevelButton(context, 'Medium',
                isEasyCompleted), // Unlocked if Easy is completed
            const SizedBox(height: 20),
            _buildLevelButton(context, 'Hard',
                isHardCompleted), // Unlocked if Medium is completed
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton(
      BuildContext context, String level, bool isUnlocked) {
    return ElevatedButton(
      onPressed: isUnlocked
          ? () {
              // Navigate directly to the respective difficulty page
              switch (level) {
                case 'Easy':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReadCompEasy(),
                    ),
                  );
                  break;
                case 'Medium':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReadCompMedium(),
                    ),
                  );
                  break;
                case 'Hard':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReadCompHard(),
                    ),
                  );
                  break;
              }
            }
          : null, // Disable button if locked
      style: ElevatedButton.styleFrom(
        backgroundColor: isUnlocked
            ? (level == 'Easy' && isEasyCompleted
                ? Colors.green
                : (level == 'Medium' && isMediumCompleted
                    ? Colors.green
                    : (level == 'Hard' && isHardCompleted
                        ? Colors.green
                        : Colors.blue)))
            : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isUnlocked) ...[
            const Icon(Icons.lock, color: Colors.white),
            const SizedBox(width: 10),
          ],
          Text(
            level,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
