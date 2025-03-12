import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/services/storage.dart';
import 'package:i_read_app/models/module.dart';

import '../services/api.dart';
import 'readcomp_levels/readcomp_easy.dart';

class VocabularySkillsLevels extends StatefulWidget {
  const VocabularySkillsLevels({super.key});

  @override
  _VocabularySkillsLevelsState createState() => _VocabularySkillsLevelsState();
}

class _VocabularySkillsLevelsState extends State<VocabularySkillsLevels> {
  String userId = '';
  final String easyId = 'sOOI4k8t4pzArVZkKG3f'; // Easy unique ID
  final String mediumId = 'JeGtBN3k2Ni4LAVAY2z7'; // Medium unique ID
  final String hardId = '7bdxc9Mr3F46ywnt7mRt'; // Hard unique ID

  bool isEasyCompleted = true;
  bool isMediumCompleted = true;
  bool isHardCompleted = true;

  StorageService storageService = StorageService();
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Vocabulary Skills Levels', style: GoogleFonts.montserrat()),
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
                isMediumCompleted), // Unlocked if Easy is completed
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
          ? () => _navigateToReadingContent(context, level)
          : null, // Disable button if locked
      style: ElevatedButton.styleFrom(
        backgroundColor: isUnlocked ? Colors.green : Colors.grey,
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

  Future<void> _navigateToReadingContent(
      BuildContext context, String level) async {
    List<String> uniqueIds = await _fetchUniqueIds(level);
    List<Module> modules = await apiService.getModules();
    List<Module> filteredModules = modules
        .where((element) =>
            element.difficulty == level &&
            element.category == 'Vocabulary Skills')
        .toList();

    if (filteredModules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No modules available for this level.')),
      );
      return;
    }

    Module module = filteredModules.first;
    String title = module.title;
    String desc = module.description;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadCompEasy(),
      ),
    ).then((result) {
      // Handle completion result for the level
      if (result == true) {
        // _updateUserProgress(); // Update progress on completion
      }
    });
  }

  Future<List<String>> _fetchUniqueIds(String difficulty) async {
    // Return the unique IDs based on difficulty level
    switch (difficulty) {
      case 'Easy':
        return [easyId];
      case 'Medium':
        return [mediumId];
      case 'Hard':
        return [hardId];
      default:
        return [];
    }
  }

  void _onLevelCompleted(String level) {
    setState(() {
      if (level == 'Easy') {
        isEasyCompleted = true;
      } else if (level == 'Medium') {
        isMediumCompleted = true;
      } else if (level == 'Hard') {
        isHardCompleted = true;
      }
    });
  }
}
