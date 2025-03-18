import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/models/answer.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/models/question.dart';
import 'package:i_read_app/services/api.dart';
import 'package:i_read_app/services/storage.dart';
import 'package:i_read_app/pages/modulecontent_page.dart';

class AppQuiz extends StatefulWidget {
  final Module module;
  final String backRoute;

  const AppQuiz({
    super.key,
    required this.module,
    required this.backRoute,
  });

  @override
  _AppQuizState createState() => _AppQuizState();
}

class _AppQuizState extends State<AppQuiz> {
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
  bool isAnswerSelected = false;
  String feedbackMessage = '';

  int currentQuestionIndex = 0;
  bool isCalculatingResults = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        questions =
            widget.module.questionsPerModule; // Use module's questions directly
        isLoading = false;
      });
      log('Loaded ${questions.length} questions for module: ${widget.module.title}');
      if (questions.isEmpty) {
        log('No questions found for module ID: ${widget.module.id}');
      }
    } catch (e) {
      log('Error loading questions: $e');
      _showErrorDialog('Failed to load questions: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _nextQuestion() {
    Question currentQuestion = questions[currentQuestionIndex];
    Answer answer = Answer(
      questionId: currentQuestion.id,
      answer: currentQuestion.choices[selectedAnswerIndex].text,
    );
    answers.add(answer);

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswerSelected = false;
        selectedAnswerIndex = -1;
        feedbackMessage = '';
      });
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
          await apiService.postSubmitModuleAnswer(widget.module.id, answers);
      List<Module>? modules = await apiService.getModules();

      if (modules != null && modules.isNotEmpty) {
        await storageService.storeModules(modules);
      }
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF5E8C7), // Manila paper
              title: Text(
                '${widget.module.title} Quiz Complete',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF8B4513), // Brown
                ),
              ),
              content: Text(
                'Score: ${response['score']}/${questions.length}\nMistakes: ${questions.length - response['score']}\nXP Earned: ${response['points_gained']}',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF8B4513), // Brown
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModuleContentPage(
                          module: widget.module,
                          backRoute: widget.backRoute,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Done',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFF8B4513), // Brown
                    ),
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

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF5E8C7), // Manila paper
              title: Text(
                'Confirm Exit',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF8B4513), // Brown
                ),
              ),
              content: Text(
                'All your progress will be lost if you go back. Are you sure?',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF8B4513), // Brown
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // "No" - stay on page
                  },
                  child: Text(
                    'No',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFF8B4513), // Brown
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // "Yes" - proceed to go back
                  },
                  child: Text(
                    'Yes',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFF8B4513), // Brown
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        bool shouldGoBack = await _showConfirmationDialog();
        if (shouldGoBack) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModuleContentPage(
                module: widget.module,
                backRoute: widget.backRoute,
              ),
            ),
          );
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5E8C7), // Manila paper
          elevation: 0, // Flat look
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF8B4513)), // Brown back arrow
            onPressed: () async {
              bool shouldGoBack = await _showConfirmationDialog();
              if (shouldGoBack) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModuleContentPage(
                      module: widget.module,
                      backRoute: widget.backRoute,
                    ),
                  ),
                );
              }
            },
          ),
          title: Text(
            'Question #${currentQuestionIndex + 1}',
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
          color: const Color(0xFFF5E8C7), // Manila paper background
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF8B4513), // Brown
                  ),
                )
              : questions.isEmpty
                  ? const Center(
                      child: Text(
                        'No questions available.',
                        style: TextStyle(
                          color: Color(0xFF8B4513), // Brown
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    )
                  : isCalculatingResults
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF8B4513), // Brown
                          ),
                        )
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
      color: const Color(0xFFF5E8C7), // Manila paper background
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              question,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                color: const Color(0xFF8B4513), // Brown
              ),
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
                        feedbackMessage = '';
                        isAnswerSelected = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedAnswerIndex == options.indexOf(option)
                              ? const Color(0xFF8B4513) // Brown for selected
                              : const Color(0xFF8B4513)
                                  .withOpacity(0.8), // Lighter brown
                      minimumSize: const Size(double.infinity, 60),
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
                backgroundColor: selectedAnswerIndex != -1
                    ? const Color(0xFF8B4513) // Brown when enabled
                    : Colors.grey, // Grey when disabled
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
          backgroundColor: const Color(0xFFF5E8C7), // Manila paper
          title: Text(
            'Error',
            style: GoogleFonts.montserrat(color: const Color(0xFF8B4513)),
          ),
          content: Text(
            message,
            style: GoogleFonts.montserrat(color: const Color(0xFF8B4513)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModuleContentPage(
                      module: widget.module,
                      backRoute: widget.backRoute,
                    ),
                  ),
                );
              },
              child: Text(
                'OK',
                style: GoogleFonts.montserrat(color: const Color(0xFF8B4513)),
              ),
            ),
          ],
        );
      },
    );
  }
}
