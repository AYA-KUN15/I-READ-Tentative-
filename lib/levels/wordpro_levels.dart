import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/levels/readcomp_levels/readcomp_easy.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/services/api.dart';
import 'package:i_read_app/services/storage.dart';

class WordPronunciationLevels extends StatefulWidget {
  const WordPronunciationLevels({super.key});

  @override
  _WordPronunciationLevelsState createState() =>
      _WordPronunciationLevelsState();
}

class _WordPronunciationLevelsState extends State<WordPronunciationLevels> {
  String userId = '';
  final String moduleName = 'Word Pronunciation';
  final String easyId = 'sPB0TBLavMJimWriirGr'; // Unique ID for Easy level
  final String mediumId = '0gDRHXVKhjGmlDj993DQ'; // Unique ID for Medium level
  final String hardId = 'DKWdld9O5Iu3yfMkmO00'; // Unique ID for Hard level
  StorageService storageService = StorageService();
  ApiService apiService = ApiService();
  bool isEasyCompleted = true; // Initialize to false
  bool isMediumCompleted = true;
  bool isHardCompleted = true;

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus();
  }

  Future<void> _checkCompletionStatus() async {
    await _fetchDifficultyStatuses();
  }

  Future<void> _fetchDifficultyStatuses() async {
    List<Module> modules = await storageService.getModules();
    // Module easyModule = modules.where((element) => element.difficulty == 'Easy' && element.category == 'Word Pronunciation').last;
    // Module mediumModule = modules.where((element) => element.difficulty == 'Medium' && element.category == 'Word Pronunciation').last;
    // Module hardModule = modules.where((element) => element.difficulty == 'Hard' && element.category == 'Word Pronunciation').last;
    //
    // setState(() {
    //   isEasyCompleted = !easyModule.isLocked; // Track completion for Easy
    //   isMediumCompleted = !mediumModule.isLocked;
    //   isHardCompleted = !hardModule.isLocked; // Track completion for Hard
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Word Pronunciation Levels', style: GoogleFonts.montserrat()),
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
                isMediumCompleted), // Unlocked if Medium is completed
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton(
      BuildContext context, String level, bool isUnlocked) {
    return ElevatedButton(
      onPressed: isUnlocked
          ? () async {
              // Fetch unique IDs for the level
              List<String> uniqueIds = await _fetchUniqueIds(level);
              List<Module> modules = await apiService.getModules();
              String title = modules
                      .where((element) =>
                          element.difficulty == level &&
                          element.category == 'Word Pronunciation')
                      .isEmpty
                  ? ''
                  : modules
                      .where((element) =>
                          element.difficulty == level &&
                          element.category == 'Word Pronunciation')
                      .last
                      .title;

              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No data for this difficulty')));
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadCompEasy(),
                  ),
                ).then((result) {
                  // Assume result is a boolean indicating completion
                  if (result == true) {
                    // _updateUserProgress(level); // Update progress on completion
                  }
                });
              }
            }
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

  Future<List<String>> _fetchUniqueIds(String difficulty) async {
    // Return the unique IDs based on difficulty level
    if (difficulty == 'Easy') {
      return [easyId];
    } else if (difficulty == 'Medium') {
      return [mediumId];
    } else if (difficulty == 'Hard') {
      return [hardId];
    }
    return [];
  }
}
