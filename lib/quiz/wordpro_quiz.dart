import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/models/answer.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/models/question.dart';
import 'package:i_read_app/services/api.dart';
import 'package:i_read_app/services/storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../mainmenu/modules_menu.dart';

class WordProQuiz extends StatefulWidget {
  final String moduleTitle;
  final List<String> uniqueIds;
  final String difficulty;

  const WordProQuiz({
    super.key,
    required this.moduleTitle,
    required this.uniqueIds,
    required this.difficulty,
  });

  @override
  _WordProQuizState createState() => _WordProQuizState();
}

class _WordProQuizState extends State<WordProQuiz> {
  final FlutterTts flutterTts = FlutterTts();
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  String recognizedText = '';
  bool isListening = false;
  String feedbackMessage = '';
  IconData feedbackIcon = Icons.help;
  int attemptCounter = 0;
  int mistakes = 0;
  double totalAccuracy = 0;
  double bestAccuracy = 0;
  bool showNextButton = false;
  late String userId;
  Timer? _silenceTimer;
  bool isSpeaking = false;
  bool canProceedToNext = false;
  Timer? _nextButtonTimer;
  bool xpEarned = false;
  StorageService storageService = StorageService();
  ApiService apiService = ApiService();
  List<Answer> answers = [];
  String moduleId = '';
  String moduleTitle = '';
  bool isAnswerSelected = false;
  bool isLoading = true;
  double accuracy_score = 0;
  double fluency_score = 0;
  double pronunciation_score = 0;
  double completeness_score = 0;
  Map<String, dynamic> assesment_result = {};
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  StreamSubscription? _recorderSubscription;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _initRecorder();
  }

  void _initRecorder() async {
    await _recorder.openRecorder();
  }

  Future<void> _loadQuestions() async {
    try {
      List<Module> modules = await apiService.getModules();
      Module module = modules
          .where((element) =>
              element.difficulty == widget.difficulty &&
              element.category == 'Word Pronunciation')
          .last;
      List<Question> moduleQuestions = module.questionsPerModule;
      setState(() {
        questions = moduleQuestions;
        isLoading = false;
        moduleId = module.id;
        moduleTitle = module.title;
      });
      await _speakQuestion();
    } catch (e) {
      log('Error loading questions: $e');
    }
  }

  Future<void> _speakQuestion() async {
    if (questions.isNotEmpty) {
      setState(() {
        isSpeaking = true;
        recognizedText = '';
      });
      await flutterTts.speak(
          "Please repeat after me, ${questions[currentQuestionIndex].text}" ??
              'Loading Question');
      flutterTts.setCompletionHandler(() {
        setState(() {
          isSpeaking = false;
          canProceedToNext = true;
        });
      });
    }
  }

  void startListening() async {
    if (await Permission.microphone.request().isGranted) {
      setState(() {
        recognizedText = 'Listening...';
        feedbackMessage = '';
        feedbackIcon = Icons.help;
        showNextButton = false;
        isListening = true;
      });
      startRecorder();
    } else {
      setState(() {
        recognizedText = 'Microphone permission denied.';
      });
    }
  }

  void startRecorder() async {
    try {
      await _recorder.startRecorder(
        toFile: '/storage/emulated/0/Download/myFile.wav',
        codec: Codec.pcm16WAV,
      );
      await Future.delayed(Duration(seconds: 3)); // Wait for 3 seconds
      await _recorder.setSubscriptionDuration(Duration(milliseconds: 500));
      _recorderSubscription = _recorder.onProgress?.listen((e) {
        double volume = e.decibels ?? 0;
        log('Volume: $volume');
        if (volume > 50) {
          setState(() => isListening = true);
        } else {
          stopListening();
        }
      });
    } catch (e) {
      log('Error starting recorder: $e');
    }
  }

  void stopRecorder() async {
    await _recorder.stopRecorder();
    if (_recorderSubscription != null) {
      _recorderSubscription!.cancel();
      _recorderSubscription = null;
    }
  }

  void stopListening() async {
    try {
      setState(() {
        isListening = false;
        recognizedText = 'Processing...';
      });
      stopRecorder();
      final filePath = '/storage/emulated/0/Download/myFile.wav';
      try {
        Map<String, dynamic> response =
            await apiService.postAssessPronunciation(
          filePath,
          questions[currentQuestionIndex].text,
          questions[currentQuestionIndex].id,
        );

        setState(() {
          recognizedText = response['recognized_text'];
          feedbackMessage =
              'Your pronunciation is ${response['accuracy_score']}% accurate';
          if (response['accuracy_score'] >= 80) {
            feedbackIcon = Icons.check_circle;
            showNextButton = true;
          } else {
            feedbackIcon = Icons.cancel;
            showNextButton = false;
          }
        });

        await Future.delayed(Duration(seconds: 1));
        if (response.isNotEmpty) {
          await _showAssesmentResult(response);
        }
      } catch (e) {
        log('Error assessing pronunciation: $e');
      }
    } catch (e) {
      log('Error stopping recorder: $e');
    }
  }

  Future<void> _nextQuestion() async {
    if (currentQuestionIndex < questions.length - 1 && canProceedToNext) {
      setState(() {
        currentQuestionIndex++;
        recognizedText = '';
        feedbackMessage = '';
        feedbackIcon = Icons.help;
        attemptCounter = 0;
        showNextButton = false;
        canProceedToNext = false;
      });
      await _speakQuestion();
    } else {
      await _showCompletionScreen();
    }
  }

  Future<void> _showAssesmentResult(Map<String, dynamic> result) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5E8C7), // Manila paper
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Assessment Breakdown',
            style: GoogleFonts.montserrat(
              color: const Color(0xFF8B4513),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Recognized Text: ${result['recognized_text']}',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF8B4513),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Accuracy: ${result['accuracy_score']}%',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF8B4513),
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Fluency: ${result['fluency_score']}%',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF8B4513),
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Pronunciation: ${result['pronunciation_score']}%',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF8B4513),
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Completeness: ${result['completeness_score']}%',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF8B4513),
                    fontSize: 16,
                  ),
                ),
                if (result['prosody_score'] != null)
                  Text(
                    'Prosody: ${result['prosody_score']}%',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFF8B4513),
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _nextQuestion();
              },
              child: Text(
                'Close',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF8B4513),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCompletionScreen() async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5E8C7), // Manila paper
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Quiz Complete!',
            style: GoogleFonts.montserrat(
              color: const Color(0xFF8B4513),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) =>
                          ModulesMenu(onModulesUpdated: (modules) {})),
                  (route) => false,
                );
              },
              child: Text(
                'Finish',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF8B4513),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    _recorder.closeRecorder();
    _recorderSubscription?.cancel();
    _silenceTimer?.cancel();
    _nextButtonTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E8C7), // Manila paper
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Word Pronunciation',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8B4513),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity, // Ensure the container takes full width
        height: double.infinity, // Ensure the container takes full height
        color: const Color(0xFFF5E8C7), // Manila paper background
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF8B4513),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center horizontally
                children: [
                  Container(
                    constraints: const BoxConstraints(
                        maxWidth: 600), // Limit width for readability
                    child: Text(
                      questions.isNotEmpty
                          ? questions[currentQuestionIndex].text
                          : 'No question...',
                      style: GoogleFonts.montserrat(
                        fontSize: 26,
                        color: const Color(0xFF8B4513),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    constraints:
                        const BoxConstraints(maxWidth: 600), // Match text width
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFF8B4513), width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF8B4513).withOpacity(0.1),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      recognizedText,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        color: const Color(0xFF8B4513),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: (isListening || isSpeaking)
                        ? stopListening
                        : startListening,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isListening
                            ? Colors.red
                            : (isSpeaking || showNextButton)
                                ? Colors.grey
                                : const Color(0xFF8B4513),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        isListening ? Icons.mic : Icons.mic_off,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    constraints:
                        const BoxConstraints(maxWidth: 600), // Match text width
                    child: Text(
                      feedbackMessage,
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: feedbackIcon == Icons.check_circle
                            ? Colors.green
                            : Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (showNextButton)
                    Container(
                      constraints: const BoxConstraints(
                          maxWidth: 600), // Match text width
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B4513),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                          child: Text(
                            'Next',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
