import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/services/api.dart';
import 'package:i_read_app/services/storage.dart';
import '../models/question.dart';
import '../quiz/sentcompcontent/sentcompdifficulty/sentcomp_1.dart';

class SentenceCompositionLevels extends StatefulWidget {
  const SentenceCompositionLevels({super.key});

  @override
  _SentenceCompositionLevelsState createState() =>
      _SentenceCompositionLevelsState();
}

class _SentenceCompositionLevelsState extends State<SentenceCompositionLevels> {
  String userId = '';
  final String easyId = 'm91vLaASKnJf23AYwoDj'; // Easy unique ID
  final String mediumId = 'yVZ7S6Wo5QIOLRF8Npmx'; // Medium unique ID
  final String hardId = '12HN1FAdEff0Juxv36Bv'; // Hard unique ID

  bool isEasyCompleted = true;
  bool isMediumCompleted = true;
  bool isHardCompleted = true;
  StorageService storageService = StorageService();
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus();
  }

  Future<void> _checkCompletionStatus() async {
    List<Module> modules = await storageService.getModules();
    // Module easyModule = modules.where((element) => element.difficulty == 'Easy' && element.category == 'Sentence Composition').last;
    // Module mediumModule = modules.where((element) => element.difficulty == 'Medium' && element.category == 'Sentence Composition').last;
    // Module hardModule = modules.where((element) => element.difficulty == 'Hard' && element.category == 'Sentence Composition').last;
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
        title: Text('Sentence Composition Levels',
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
                isMediumCompleted), // Unlocked if Medium is completed
          ],
        ),
      ),
    );
  }

  Future<List<Question>> fetchQuestions(String difficulty) async {
    try {
      List<Module> modules = await apiService.getModules();
      Module module = modules
          .where((element) =>
              element.difficulty == difficulty &&
              element.category == 'Sentence Composition')
          .last;
      List<Question> moduleQuestions = module.questionsPerModule;

      return moduleQuestions;
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  Widget _buildLevelButton(
      BuildContext context, String level, bool isUnlocked) {
    return ElevatedButton(
      onPressed: isUnlocked
          ? () async {
              List<String> uniqueIds = await _fetchUniqueIds(level);
              List<Question> questions = await fetchQuestions(level);

              if (questions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('No questions available for this level.'),
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SentCompQuiz(
                    title: 'Sentence Composition',
                    uniqueIds: uniqueIds, // Pass unique IDs
                    difficulty: level, // Pass difficulty level
                  ),
                ),
              ).then((result) {
                // Handle completion result for the level
                if (result == true) {
                  // _updateUserProgress(); // Update progress on completion
                }
              });
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
}
