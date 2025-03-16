import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/services/api.dart';
import 'package:i_read_app/models/module.dart';

class ModulesMenu extends StatefulWidget {
  const ModulesMenu({super.key, required Null Function(dynamic modules) onModulesUpdated});

  @override
  _ModulesMenuState createState() => _ModulesMenuState();
}

class _ModulesMenuState extends State<ModulesMenu> {
  List<Map<String, dynamic>> modules = [];
  bool isLoading = true;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadModules(); // Automatically called when the screen loads
  }

  Future<void> _loadModules() async {
    try {
      List<Module> storedModules = await apiService.getModules();
      Map<String, Map<String, dynamic>> moduleMap = {};

      for (var module in storedModules) {
        if (!moduleMap.containsKey(module.category)) {
          moduleMap[module.category] = {
            'category': module.category,
            'completed': 0,
            'total': 0,
          };
        }
        moduleMap[module.category]!['total'] += 1;
        if (module.completed == 1) {
          moduleMap[module.category]!['completed'] += 1;
        }
      }

      setState(() {
        modules = moduleMap.values.toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load modules: $e')),
      );
    }
  }

  int get totalModules {
    int sum = 0;
    for (var module in modules) {
      final total = module['total'];
      sum += (total is int) ? total : (total as num).toInt();
    }
    return sum;
  }

  int get completedModules {
    int sum = 0;
    for (var module in modules) {
      final completed = module['completed'];
      sum += (completed is int) ? completed : (completed as num).toInt();
    }
    return sum;
  }

  String get overallStatus {
    if (completedModules == 0) return 'NOT FINISHED';
    if (completedModules == totalModules) return 'COMPLETED';
    return 'IN PROGRESS';
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E8C7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
        title: Text(
          'Modules',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8B4513),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5E8C7),
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.05, vertical: height * 0.02),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B4513)))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall progress section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Progress',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8B4513),
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: totalModules > 0
                              ? completedModules / totalModules
                              : 0,
                          backgroundColor: Colors.grey[300],
                          color: const Color(0xFF8B4513),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$completedModules / $totalModules completed',
                          style: GoogleFonts.montserrat(
                              color: const Color(0xFF8B4513)),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Status: $overallStatus',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: const Color(0xFF8B4513),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Module categories list
                  Expanded(
                    child: ListView.builder(
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        String currentModule = modules[index]['category'];
                        int completed = modules[index]['completed'] as int;
                        int total = modules[index]['total'] as int;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          color: const Color.fromARGB(255, 249, 222, 194),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentModule,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: const Color(0xFF8B4513),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                LinearProgressIndicator(
                                  value: total > 0 ? completed / total : 0,
                                  backgroundColor: Colors.grey[300],
                                  color: const Color(0xFF8B4513),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '$completed / $total completed',
                                  style: GoogleFonts.montserrat(
                                      color: const Color(0xFF8B4513)),
                                ),
                              ],
                            ),
                            onTap: () {
                              if (currentModule == 'Reading Comprehension') {
                                Navigator.pushNamed(
                                    context, '/reading_comprehension_levels');
                              } else if (currentModule ==
                                  'Word Pronunciation') {
                                Navigator.pushNamed(
                                    context, '/word_pronunciation_levels');
                              } else if (currentModule ==
                                  'Sentence Composition') {
                                Navigator.pushNamed(
                                    context, '/sentence_composition_levels');
                              } else if (currentModule == 'Vocabulary Skills') {
                                Navigator.pushNamed(
                                    context, '/vocabulary_skills_levels');
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
    );
  }
}
