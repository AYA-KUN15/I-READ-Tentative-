
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:i_read_app/levels/sentcomp_levels.dart';
import 'package:i_read_app/levels/vocabskills_levels.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/services/api.dart';
import 'package:i_read_app/services/storage.dart';
import '../levels/readcomp_levels/readcomp_levels.dart'; // Import for Reading Comprehension
import '../levels/wordpro_levels.dart'; // Import for Word Pronunciation

class ModulesMenu extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onModulesUpdated;

  const ModulesMenu({super.key, required this.onModulesUpdated});

  @override
  _ModulesMenuState createState() => _ModulesMenuState();
}

class _ModulesMenuState extends State<ModulesMenu> {
  List<Map<String, dynamic>> modules = [];
  List<String> moduleStatuses = [];
  List<int> moduleCompleted = [];
  List<int> moduleTotal = [];
  Map<String, int> completedDifficultiesCountMap = {};
  bool isLoading = true;
  StorageService storageService = StorageService();
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

 Future<void> _loadModules() async {
  List<Module> storedModules = await apiService.getModules();
  List<Map<String, dynamic>> fetchedModules = [];
  Set<String> uniqueCategories = {};

  for (var module in storedModules) {
    if (!uniqueCategories.contains(module.category)) {
      uniqueCategories.add(module.category);
      fetchedModules.add({
        'category': module.category,
        'completed': module.completed
      });
    }
  }

  // Ensure all modules are included
  if (!uniqueCategories.contains('Reading Comprehension')) {
    fetchedModules.add({'category': 'Reading Comprehension', 'completed': 0});
  }
  if (!uniqueCategories.contains('Word Pronunciation')) {
    fetchedModules.add({'category': 'Word Pronunciation', 'completed': 0});
  }
  if (!uniqueCategories.contains('Vocabulary Skills')) {
    fetchedModules.add({'category': 'Vocabulary Skills', 'completed': 0});
  }
  if (!uniqueCategories.contains('Sentence Composition')) {
    fetchedModules.add({'category': 'Sentence Composition', 'completed': 0});
  }

  setState(() {
    modules = fetchedModules;
    isLoading = false;
  });
}
  //
  // Future<void> _fetchModuleStatuses(List<String> fetchedModules) async {
  //   String userId = FirebaseAuth.instance.currentUser!.uid;
  //   List<String> statuses = [];
  //
  //   for (String module in fetchedModules) {
  //     var moduleDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .collection('progress')
  //         .doc(module) // Ensure module name matches Firestore
  //         .get();
  //
  //     if (moduleDoc.exists) {
  //       var data = moduleDoc.data() as Map<String, dynamic>;
  //       statuses.add(data['status'] ?? 'NOT FINISHED');
  //     } else {
  //       statuses.add('NOT FINISHED');
  //     }
  //   }
  //
  //   moduleStatuses = statuses;
  // }

  Future<void> _fetchDifficultyCompletion() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    List<String> moduleTitles = [
      'Reading Comprehension',
      'Word Pronunciation',
      'Vocabulary Skills',
      'Sentence Composition',
    ];
    List<String> difficultyLevels = ['Easy', 'Medium', 'Hard'];

    for (String moduleTitle in moduleTitles) {
      for (String difficulty in difficultyLevels) {
        String uniqueId = '$userId-$moduleTitle-$difficulty';
        var difficultyDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('progress')
            .doc(moduleTitle)
            .collection('difficulty')
            .doc(uniqueId)
            .get();

        if (difficultyDoc.exists) {
          String status = difficultyDoc.data()?['status'] ?? 'NOT STARTED';
          if (status == 'COMPLETED') {
            completedDifficultiesCountMap[moduleTitle] =
                (completedDifficultiesCountMap[moduleTitle] ?? 0) + 1;
          }
        }
      }

      // Update the module status based on difficulty completion
      if (completedDifficultiesCountMap[moduleTitle] == 1) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('progress')
            .doc(moduleTitle)
            .update({'status': 'IN PROGRESS'});
      } else if (completedDifficultiesCountMap[moduleTitle] == 3) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('progress')
            .doc(moduleTitle)
            .update({'status': 'COMPLETED'});
      }
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        return true; // Exit the app when back is pressed
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[700]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: height * 0.01), // Reduced vertical padding
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Modules',
                        style: GoogleFonts.montserrat(
                            fontSize: width * 0.06, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: modules.length,
                        itemBuilder: (context, index) {
                          String currentModule = modules[index]["category"];
                          int completed = modules[index]["completed"];
                          // int completedCount =
                          //     completedDifficultiesCountMap[currentModule] ?? 0;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentModule,
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22, // Increased font size
                                        color: Colors.blue),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Status: In progress',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                  const SizedBox(height: 5),
                                  LinearProgressIndicator(
                                    value: completed / 3.0,
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.green,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '$completed / 3 completed',
                                    style: GoogleFonts.montserrat(),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (currentModule == 'Reading Comprehension') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ReadingComprehensionLevels()),
                                  );
                                } else if (currentModule ==
                                    'Word Pronunciation') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const WordPronunciationLevels(),
                                    ),
                                  );
                                } else if (currentModule ==
                                    'Sentence Composition') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SentenceCompositionLevels(),
                                    ),
                                  );
                                } else if (currentModule ==
                                    'Vocabulary Skills') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VocabularySkillsLevels(),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Modules'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      currentIndex: 1,
      selectedItemColor: Colors.blue[900],
      unselectedItemColor: Colors.lightBlue,
      backgroundColor: Colors.white,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/module_menu');
            break;
          case 2:
            Navigator.pushNamed(context, '/profile_menu');
            break;
          case 3:
            Navigator.pushNamed(context, '/settings_menu');
            break;
        }
      },
    );
  }
}
