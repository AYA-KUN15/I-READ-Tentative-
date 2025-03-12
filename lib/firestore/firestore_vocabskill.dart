import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreVocabSkill {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getModules() async {
    var snapshot =
        await _firestore.collection('fields').doc('Vocabulary Skills').get();
    return List<Map<String, dynamic>>.from(snapshot.data()?['modules'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getQuestions(String moduleId) async {
    try {
      var snapshot =
          await _firestore.collection('fields').doc('Vocabulary Skills').get();

      var data = snapshot.data();
      if (data != null && data['modules'] != null) {
        var modules = List<Map<String, dynamic>>.from(data['modules']);

        // Find the module matching the given moduleId
        var module = modules.firstWhere(
          (module) => module['title'] == moduleId,
          orElse: () =>
              {'questions': []}, // Return an empty structure if not found
        );

        // Check if questions exist
        if (module['questions'] != null) {
          return List<Map<String, dynamic>>.from(module['questions']);
        } else {
          print('No questions found for module $moduleId.');
        }
      } else {
        print('Data or modules are null.');
      }
    } catch (e) {
      print('Error fetching questions: $e');
    }

    return []; // Return an empty list if no questions are found
  }
}
