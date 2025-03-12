
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/models/answer.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/models/question.dart';
import 'package:i_read_app/services/api.dart';
import 'package:i_read_app/services/storage.dart';

class VocabSkillsQuiz extends StatefulWidget {
  final String moduleTitle;
  final List<String> uniqueIds;
  final String difficulty;

  const VocabSkillsQuiz(
      {super.key,
      required this.moduleTitle,
      required this.uniqueIds,
      required this.difficulty,
      });


  @override
  _VocabSkillsQuizState createState() => _VocabSkillsQuizState();
}

class _VocabSkillsQuizState extends State<VocabSkillsQuiz> {
  int currentQuestionIndex = 0;
  int score = 0;
  int mistakes = 0;
  List<Question> questions = [];
  bool isLoading = true;
  bool isAnswerSelected = false;
  int selectedAnswerIndex = -1; // Track selected option
  String feedbackMessage = '';
  bool isCorrect = false;
  StorageService storageService = StorageService();
  ApiService apiService = ApiService();
  List<Answer> answers = [];
  String moduleId = '';
  String moduleTitle = '';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      log(widget.difficulty);
      List<Module> modules = await apiService.getModules();
      Module module =
          modules.where((element) => element.difficulty == widget.difficulty && element.category == 'Vocabulary Skills' ).last;
      List<Question> moduleQuestions = module.questionsPerModule;

      setState(() {
        questions = moduleQuestions;
        isLoading = false;
        moduleId = module.id;
        moduleTitle = module.title;
      });
    } catch (e) {
      _showErrorDialog('Error loading questions: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _nextQuestion() {
    Question currentQuestion = questions[currentQuestionIndex];
    Answer answer = Answer(
        questionId: currentQuestion.id,
        answer: currentQuestion.choices[selectedAnswerIndex].text);
    answers.add(answer);

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswerSelected = false; // Reset for the next question
        selectedAnswerIndex = -1; // Reset the selected answer
        feedbackMessage = ''; // Clear feedback
      });
    } else if (currentQuestionIndex == questions.length - 1) {
      _showResults(); // Only show results if it's the last question
    } else {
      _showResults(); // Only show results if it's the last question
    }
  }

  Future<void> _showResults() async {
    Map<String, dynamic> response = await apiService.postSubmitModuleAnswer(moduleId, answers);
    List<Module>? modules = await apiService.getModules();

    if (modules.isNotEmpty) {
      await storageService.storeModules(modules);
    }
    // Show completion dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          title: Text(
            '$moduleTitle Quiz Complete',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          content: Text(
            'Score: ${response['score']}/${questions.length}\nMistakes: ${questions.length - response['score']}\nXP Earned: ${response['points_gained']}',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pop(context); // Return to modules menu
              },
              child: Text(
                'Done',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // Return to previous screen
        return false; // Prevent default back action
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.moduleTitle, style: GoogleFonts.montserrat()),
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : questions.isEmpty
                ? const Center(
                    child: Text('No questions available.',
                        style: TextStyle(fontSize: 18)))
                : _buildQuizContent(),
      ),
    );
  }

  Widget _buildQuizContent() {
    final question = questions[currentQuestionIndex].text;
    final options = questions[currentQuestionIndex].choices;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF003366), Color(0xFF0052CC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the content vertically
          children: [
            Text(
              question,
              style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Column(
              children: options.map<Widget>((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedAnswerIndex = options.indexOf(option);
                        feedbackMessage = ''; // Reset feedback message
                        isAnswerSelected = false; // Allow resubmission
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedAnswerIndex == options.indexOf(option)
                              ? Colors.orange // Color for selected options
                              : Colors.blue[700], // Updated button color
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      option.text,
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedAnswerIndex != -1) {
                  _nextQuestion(); // Allow moving to the next question after feedback is shown
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(150, 40),
              ),
              child: Text(
                'Next', // Change button text based on selection
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            if (isAnswerSelected) ...[
              Text(
                feedbackMessage,
                style: TextStyle(
                  color: isCorrect
                      ? const Color(0xFF00FF00)
                      : const Color(0xFFFF6666),
                  fontSize: 18, // Made feedback message smaller
                ),
              ),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect
                    ? const Color(0xFF00FF00)
                    : const Color(0xFFFF6666),
                size: 60,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
