import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/models/answer.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/models/question.dart';
import 'package:i_read_app/services/api.dart';
import 'package:i_read_app/services/storage.dart';
import 'package:string_similarity/string_similarity.dart';

class SentCompQuiz extends StatefulWidget {
  final String difficulty; // Add this field
  final String title; // Add this field

  const SentCompQuiz(
      {super.key,
      required this.title,
      required List<String> uniqueIds,
      required this.difficulty});

  @override
  _SentenceCompositionQuizState createState() =>
      _SentenceCompositionQuizState();
}

class _SentenceCompositionQuizState extends State<SentCompQuiz> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  List<String> options = [];
  String correctAnswer = '';
  List<String> userSelections = [];
  String sentenceWithBlanks = '';
  bool hasSubmittedCurrentQuestion = false;
  bool _isCorrect = false;
  String _feedbackMessage = '';
  StorageService storageService = StorageService();
  ApiService apiService = ApiService();
  String moduleId = '';
  String moduleTitle = '';
  List<Answer> answers = [];
  List<String> wordsInBlanks = [];
  String userAnswer = '';
  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      List<Module> modules = await apiService.getModules();
      Module module = modules
          .where((element) =>
              element.difficulty == widget.difficulty &&
              element.category == 'Sentence Composition')
          .last;
      List<Question> moduleQuestions = module.questionsPerModule;

      setState(() {
        questions = moduleQuestions;
        moduleId = module.id;
        moduleTitle = module.title;
      });

      setState(() {
        currentQuestionIndex = 0;
        options =
            List.from(questions[currentQuestionIndex].choices.map((choice) {
          return choice.text;
        }));
        sentenceWithBlanks = questions[currentQuestionIndex].text;
        userSelections = List.filled(sentenceWithBlanks.split(' ').length, '');
      });
    } catch (e) {
      print('Error fetching questions: $e');
    }
  }

  void handleOptionClick(String selectedWord) {
    setState(() {
      for (int i = 0; i < userSelections.length; i++) {
        if (userSelections[i].isEmpty &&
            sentenceWithBlanks.split(' ')[i].contains('_')) {
          userSelections[i] = selectedWord;
          options.remove(selectedWord);
          break;
        }
      }
    });
  }

  void toggleSelection(int index) {
    if (!hasSubmittedCurrentQuestion) {
      setState(() {
        if (userSelections[index].isNotEmpty) {
          options.add(userSelections[index]);
          userSelections[index] = '';
        }
      });
    }
  }


  void submitAnswer() async {
    Map<String, dynamic> answer =
        await apiService.getQuestionAnswer(questions[currentQuestionIndex].id);
    String originalAnswer = '';

    setState(() {
      hasSubmittedCurrentQuestion = true;
      correctAnswer = answer['text'];

      String userAnswer = wordsInBlanks
          .asMap()
          .map((index, word) {
        if (word.contains('_')) {
          String replacedWord = word.replaceAll('_', '');
          return MapEntry(index, '${userSelections[index]}$replacedWord');
        } else {
          return MapEntry(index, word);
        }
      })
          .values
          .join(' ').toLowerCase();
      // Remove all special characters
      originalAnswer = answer['text'].toString().toLowerCase();

      double similarity =
          StringSimilarity.compareTwoStrings(userAnswer, originalAnswer);

      if (similarity > 0.99) {
        // Adjust the threshold as needed
        _isCorrect = true;
        _feedbackMessage = 'You are correct.';
      } else {
        _isCorrect = false;
        _feedbackMessage = 'Not quite correct.';
      }

      Answer userAns = Answer(
          questionId: questions[currentQuestionIndex].id,
          answer: userAnswer,
          correct: _isCorrect);
      answers.add(userAns);
    });
  }

  Future<void> submitQuiz() async {
    await apiService.postSubmitModuleAnswer(moduleId, answers);
    Navigator.pushReplacementNamed(context, '/modules_menu');
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        options =
            List.from(questions[currentQuestionIndex].choices.map((choice) {
          return choice.text;
        }));
        sentenceWithBlanks = questions[currentQuestionIndex].text;
        userSelections = List.filled(sentenceWithBlanks.split(' ').length, '');
        hasSubmittedCurrentQuestion = false;
        _isCorrect = false;
        _feedbackMessage = '';
      });
    } else {
      // If there are no more questions, show the completion dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.blue, // Set background color
          title: Text(
            'Quiz Completed',
            style: GoogleFonts.montserrat(
                color: Colors.white), // Set title font and color
          ),
          content: Text(
            'You have successfully completed the Sentence Composition quiz. Press OK to submit scores!',
            style: GoogleFonts.montserrat(
                color: Colors.white), // Set content font and color
          ),
          actions: [
            TextButton(
              onPressed: () {
                submitQuiz();
              },
              child: Text(
                'OK',
                style: GoogleFonts.montserrat(
                    color: Colors.white), // Set button font and color
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

     wordsInBlanks = sentenceWithBlanks.split(' ');

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[900]!, Colors.blue[700]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the sentence with blanks
            RichText(
              text: TextSpan(
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                  children:
                      List<InlineSpan>.generate(wordsInBlanks.length, (index) {
                    String word = wordsInBlanks[index];
                    if (word.contains('_')) {
                      return TextSpan(
                        text: userSelections[index].isEmpty
                            ? '$word '
                            : '${userSelections[index]}${word.replaceAll('_', '')} ',
                        style: TextStyle(
                          color: Colors.white,
                          // decoration: hasSubmittedCurrentQuestion &&
                          //         userSelections[index] ==
                          //             correctAnswer.split(' ')[index]
                          //     ? TextDecoration.none
                          //     : TextDecoration.none,
                          decorationThickness: 2,
                        ),
                        recognizer: hasSubmittedCurrentQuestion
                            ? null
                            : TapGestureRecognizer()
                          ?..onTap = () {
                            toggleSelection(index);
                          },
                      );
                    } else {
                      return TextSpan(
                        text: '$word ',
                        style: GoogleFonts.montserrat(color: Colors.white),
                      );
                    }
                  })),
            ),
            const SizedBox(height: 20),
            // Display the given words as options
            Wrap(
              spacing: 8,
              children: options.map((option) {
                return ElevatedButton(
                  onPressed: hasSubmittedCurrentQuestion
                      ? null
                      : () {
                          handleOptionClick(option);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: options.indexOf(option) ==
                            options.indexWhere((o) =>
                                o ==
                                userSelections.firstWhere((s) => s == option,
                                    orElse: () => ''))
                        ? Colors.blue[800]
                        : Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    option,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_feedbackMessage.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isCorrect ? Icons.check : Icons.cancel,
                    color: _isCorrect ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _feedbackMessage,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: _isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: hasSubmittedCurrentQuestion
                  ? () {
                      goToNextQuestion();
                    }
                  : () {
                      submitAnswer();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
              ),
              child: Text(
                hasSubmittedCurrentQuestion ? 'Next' : 'Submit',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
