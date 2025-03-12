import 'dart:async';
import 'dart:developer'; // Added for logging
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/models/answer.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/models/question.dart';
import 'package:i_read_app/services/api.dart';
import 'package:i_read_app/services/storage.dart';

class ReadCompQuiz extends StatefulWidget {
  final String moduleTitle;
  final String difficulty;
  final List<String> uniqueIds;

  const ReadCompQuiz({
    super.key,
    required this.moduleTitle,
    required this.difficulty,
    required this.uniqueIds,
  });

  @override
  _ReadCompQuizState createState() => _ReadCompQuizState();
}

class _ReadCompQuizState extends State<ReadCompQuiz> {
  int score = 0;
  int mistakes = 0;
  List<Question> questions = [];
  bool isLoading = true;
  bool isAnswerSubmitted = false;
  bool hasEarnedXP = false;
  int selectedAnswerIndex = -1;
  StorageService storageService = StorageService();
  ApiService apiService = ApiService();
  List<Answer> answers = [];
  String moduleId = '';
  String moduleTitle = '';
  bool isAnswerSelected = false;
  String feedbackMessage = '';

  Question? currentQuestion;
  int currentQuestionIndex = 0;
  late Timer _timer;
  int _remainingTime = 300; // 5 minutes for each question
  bool isCalculatingResults = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      List<Module> modules = await apiService.getModules();
      log('Fetched ${modules.length} modules'); // Debug all modules
      for (var m in modules) {
        log('Module ID: ${m.id}, Title: ${m.title}, Questions: ${m.questionsPerModule.length}');
      }

      // Find the specific module by ID
      Module module = modules.firstWhere(
        (element) => element.id == widget.uniqueIds[0],
        orElse: () =>
            throw Exception('Module with ID ${widget.uniqueIds[0]} not found'),
      );
      log('Selected Module ID: ${module.id}, Title: ${module.title}, Questions: ${module.questionsPerModule.length}');

      List<Question> moduleQuestions = module.questionsPerModule;
      if (moduleQuestions.isEmpty) {
        log('No questions found for module ID: ${module.id}');
      }

      setState(() {
        questions = moduleQuestions;
        isLoading = false;
        moduleId = module.id;
        moduleTitle = module.title;
      });
    } catch (e) {
      log('Error loading questions: $e');
      _showErrorDialog('Failed to load questions: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _remainingTime = 300;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        if (mounted) {
          setState(() {
            _remainingTime--;
          });
        }
      } else {
        _timer.cancel();
        _nextQuestion();
      }
    });
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
        isAnswerSelected = false;
        selectedAnswerIndex = -1;
        feedbackMessage = '';
      });
      _startTimer(); // Restart timer for next question
    } else {
      _showResults();
    }
  }

  Future<void> _showResults() async {
    setState(() {
      isCalculatingResults = true;
    });
    try {
      Map<String, dynamic> response =
          await apiService.postSubmitModuleAnswer(moduleId, answers);
      List<Module>? modules = await apiService.getModules();

      if (modules.isNotEmpty) {
        await storageService.storeModules(modules);
      }
      if (mounted) {
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
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.pop(context); // Return to ModuleContentPage
                    Navigator.pop(context); // Return to ReadCompEasy
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
    } catch (e) {
      log('Error submitting answers: $e');
      _showErrorDialog('Failed to submit answers: $e');
    } finally {
      setState(() {
        isCalculatingResults = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quiz', style: GoogleFonts.montserrat()),
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
          actions: [
            const Icon(Icons.access_time),
            const SizedBox(width: 10),
            Text(
              '${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF003366), Color(0xFF0052CC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : questions.isEmpty
                  ? const Center(
                      child: Text(
                        'No questions available.',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : isCalculatingResults
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: _buildQuizContent(),
                        ),
        ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              question,
              style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Column(
              children: options.map<Widget>((option) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10.0), // Fix to 'bottom'
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedAnswerIndex = options.indexOf(option);
                        feedbackMessage = '';
                        isAnswerSelected = true; // Fixed logic
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedAnswerIndex == options.indexOf(option)
                              ? Colors.orange
                              : Colors.blue[700],
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
              onPressed: selectedAnswerIndex != -1
                  ? () {
                      _nextQuestion();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(150, 40),
              ),
              child: Text(
                'Next',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Back to ModuleContentPage
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
