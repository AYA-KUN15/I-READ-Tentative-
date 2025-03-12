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
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';
import '../../../mainmenu/modules_menu.dart';

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
  final stt.SpeechToText speech = stt.SpeechToText();
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
  StreamSubscription? _speechSubscription;
  bool isUserSpeaking = false;
  final SpeechToText _speechToText = SpeechToText();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    // _initSpeech();
  }

  void _initRecorder() async {
    await _recorder.openRecorder();
  }

  void _initSpeech() async {
    if (!_speechToText.isAvailable) {
      await _speechToText.initialize(
        onStatus: (status) => log('onStatus: $status'),
        onError: (errorNotification) => log('onError: $errorNotification'),
      );
    }
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
      print('Error loading questions: $e');
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
      // _speechSubscription = await _speechToText.listen(
      //   onResult: _onSpeechResult,
      //   listenFor: Duration(seconds: 99),
      //   pauseFor: Duration(seconds: 3),
      //   localeId: 'en_US',
      //   onSoundLevelChange: (level) {
      //     log('Sound level: $level');
      //   },
      // );

      startRecorder();
    } else {
      setState(() {
        recognizedText = 'Microphone permission denied.';
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      setState(() {
        recognizedText = result.recognizedWords;
        isListening = false;
      });
      stopListening();
    }
  }

  void startRecorder() async {
    try {
      await _recorder.openRecorder();
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
          isUserSpeaking = true;
        } else {
          if (isUserSpeaking) {
            isUserSpeaking = false;
          } else {
            stopListening();
          }
        }
      });
    } catch (e) {
      log('Error starting recorder: $e');
    }
  }

  void stopRecorder() async {
    await _recorder.stopRecorder();

    // await _recorder.closeRecorder();
    if (_recorderSubscription != null) {
      _recorderSubscription!.cancel();
      _recorderSubscription = null;
    }

    if (_speechSubscription != null) {
      _speechSubscription!.cancel();
      _speechSubscription = null;
    }

    if (_speechToText.isListening) {
      await _speechToText.stop();
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

        await Future.delayed(Duration(seconds: 1), () {});

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
    // Question currentQuestion = questions[currentQuestionIndex];
    // Answer answer = Answer(
    //     questionId: currentQuestion.id,
    //     answer: currentQuestion.choices[selectedAnswerIndex].text);
    // answers.add(answer);

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

  Future<void> _showAssesmentResult(result) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[900]!, Colors.blue[700]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    'Assessment Breakdown',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: 28),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Recognized Text: ${result['recognized_text']}',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Accuracy Score: ${result['accuracy_score']}',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: 18),
                ),
                Text(
                  'Fluency Score: ${result['fluency_score']}',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: 18),
                ),
                Text(
                  'Pronunciation Score: ${result['pronunciation_score']}',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: 18),
                ),
                Text(
                  'Completeness Score: ${result['completeness_score']}',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: 18),
                ),
                if (result['prosody_score'] != null)
                  Text(
                    'Prosody Score: ${result['prosody_score']}',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: 18),
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // This closes the dialog
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(dialogContext)
                          .pop(); // This closes the dialog
                      _nextQuestion();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCompletionScreen() async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[900]!, Colors.blue[700]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    'Quiz Complete!',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: 28),
                  ),
                ),
                const SizedBox(height: 20),
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
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    _recorder.closeRecorder();
    _recorderSubscription?.cancel();
    _recorderSubscription = null;
    _silenceTimer?.cancel();
    _nextButtonTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Pronunciation', style: GoogleFonts.montserrat()),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  questions.isNotEmpty
                      ? questions[currentQuestionIndex].text
                      : 'No question...',
                  style:
                      GoogleFonts.montserrat(fontSize: 26, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.2),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    recognizedText,
                    style: GoogleFonts.montserrat(
                        fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: (isListening || isSpeaking)
                      ? stopListening // Disable tap when isSpeaking is true
                      : startListening,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening
                          ? Colors.red // Red when listening
                          : (isSpeaking || showNextButton)
                              ? Colors
                                  .grey // Grey when speaking or showing the next button
                              : Colors.blue[
                                  600], // Default to blue when neither listening nor speaking
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
                Text(
                  feedbackMessage,
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: feedbackIcon == Icons.check_circle
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                if (showNextButton)
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
