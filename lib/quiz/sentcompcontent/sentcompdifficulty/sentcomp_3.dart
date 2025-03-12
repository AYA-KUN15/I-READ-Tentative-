import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';

class SentCompQuiz3 extends StatefulWidget {
  const SentCompQuiz3(
      {super.key,
      required String moduleTitle,
      required List<String> uniqueIds,
      required String difficulty});

  @override
  _SentCompQuiz3State createState() => _SentCompQuiz3State();
}

class _SentCompQuiz3State extends State<SentCompQuiz3> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  List<String> options = [];
  String correctAnswer = '';
  List<String> userSelections = [];
  String sentenceWithBlanks = '';
  bool hasSubmittedCurrentQuestion = false;
  bool _isCorrect = false;
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      // Update the path to match the new Firestore structure
      var snapshot = await FirebaseFirestore.instance
          .collection('fields')
          .doc('Sentence Composition') // Field Document
          .collection('Hard') // Difficulty Collection
          .doc('12HN1FAdEff0Juxv36Bv') // Module Document
          .get();

      if (snapshot.exists) {
        var modules = snapshot.data()?['modules'] as List<dynamic>? ?? [];
        if (modules.isNotEmpty) {
          var questionsData = modules[0]['questions'] as List<dynamic>? ?? [];
          for (var question in questionsData) {
            var blanks = question['blanks'];
            var correctAnswer = question['correctAnswer'];
            var options = List<String>.from(
                question['options'].map((option) => option.toString()));

            questions.add({
              'blanks': blanks,
              'correctAnswer': correctAnswer,
              'options': options,
            });
          }

          if (questions.isNotEmpty) {
            setState(() {
              currentQuestionIndex = 0;
              correctAnswer =
                  questions[currentQuestionIndex]['correctAnswer'].trim();
              options = List.from(questions[currentQuestionIndex]['options']);
              sentenceWithBlanks = questions[currentQuestionIndex]['blanks'];
              userSelections =
                  List.filled(sentenceWithBlanks.split(' ').length, '');
            });
          }
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching questions: $e');
    }
  }

  void handleOptionClick(String selectedWord) {
    setState(() {
      for (int i = 0; i < userSelections.length; i++) {
        if (userSelections[i].isEmpty &&
            sentenceWithBlanks.split(' ')[i] == '___') {
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
          _isCorrect = false;
          _feedbackMessage = '';
        }
      });
    }
  }

  void submitAnswer() {
    setState(() {
      hasSubmittedCurrentQuestion = true;
      String userAnswer = '';
      List<String> wordsInBlanks = sentenceWithBlanks.split(' ');

      for (int i = 0; i < wordsInBlanks.length; i++) {
        if (wordsInBlanks[i] == '___') {
          userAnswer += '${userSelections[i]} ';
        } else {
          userAnswer += '${wordsInBlanks[i]} ';
        }
      }

      userAnswer = userAnswer.trim();

      if (userAnswer.toLowerCase() == correctAnswer.toLowerCase()) {
        _isCorrect = true;
        _feedbackMessage = 'You are correct.';
      } else {
        _isCorrect = false;
        _feedbackMessage = 'Not quite correct.';
      }
    });
  }

  Future<void> submitQuiz() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Update user's progress in the users collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc('Sentence Composition') // Module document
        .collection('difficulty') // Difficulty collection
        .doc('$userId-Sentence Composition-Hard') // Specific document
        .set({
      'status': 'COMPLETED',
    }, SetOptions(merge: true));

    // Update user XP in the users collection
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'xp': FieldValue.increment(500),
    });

    // Add module to completedModules
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'completedModules': FieldValue.arrayUnion(['Sentence Composition']),
    });

    // Navigate to modules_menu
    Navigator.pushReplacementNamed(context, '/modules_menu');
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        correctAnswer = questions[currentQuestionIndex]['correctAnswer'].trim();
        options = List.from(questions[currentQuestionIndex]['options']);
        sentenceWithBlanks = questions[currentQuestionIndex]['blanks'];
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
            'You have successfully completed the Sentence Composition quiz!',
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

    List<String> wordsInBlanks = sentenceWithBlanks.split(' ');

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
                  if (word == '___') {
                    return TextSpan(
                      text: userSelections[index].isEmpty
                          ? '___ '
                          : '${userSelections[index]} ',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: hasSubmittedCurrentQuestion &&
                                userSelections[index] ==
                                    correctAnswer.split(' ')[index]
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        decorationColor: _isCorrect ? Colors.green : Colors.red,
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
                }),
              ),
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
