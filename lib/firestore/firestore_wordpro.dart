import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreWordPro {
  final String userId;

  FirestoreWordPro(this.userId);

  Future<List<Map<String, dynamic>>> getQuestions(String moduleId) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('fields')
          .doc(moduleId)
          .get();

      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('No data found for $moduleId');
      }

      var modules = snapshot.data()?['modules'] as List<dynamic>?;

      if (modules == null || modules.isEmpty) {
        throw Exception('No modules found for $moduleId');
      }

      List<Map<String, dynamic>> questions = [];
      for (var module in modules) {
        if (module['questions'] != null) {
          questions
              .addAll(List<Map<String, dynamic>>.from(module['questions']));
        }
      }

      if (questions.isEmpty) {
        throw Exception('No questions found in module $moduleId');
      }

      return questions;
    } catch (e) {
      print('Error fetching questions: $e'); // Debugging line
      rethrow; // Rethrow the error after logging
    }
  }
}
