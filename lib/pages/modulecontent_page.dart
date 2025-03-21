import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/services/api.dart';
import 'package:url_launcher/url_launcher.dart';

import '../quiz/app_quiz.dart';
import '../quiz/wordpro_quiz.dart';

class ModuleContentPage extends StatelessWidget {
  final Module module;
  final String backRoute;
  final ApiService apiService = ApiService();

  ModuleContentPage({super.key, required this.module, required this.backRoute});

  Future<void> _downloadFile(String url, BuildContext context) async {
    log('Attempting to download: $url');
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        log('URL is launchable');
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        log('Download launched');
      } else {
        log('Cannot launch URL');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch file URL')),
        );
      }
    } catch (e) {
      log('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  // Check if the quiz is completed using the 'completed' field
  Future<bool> _isQuizCompleted(String moduleId) async {
    try {
      List<Module> modules = await apiService.getModules();
      Module updatedModule = modules.firstWhere((m) => m.id == moduleId);
      log('Module ${updatedModule.title} completion status: ${updatedModule.completed}');
      return updatedModule.completed > 0;
    } catch (e) {
      log('Error checking quiz completion: $e');
      return false; // Default to false if check fails
    }
  }

  // Show confirmation dialog for completed quiz
  Future<bool> _showReattemptConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF5E8C7), // Manila paper
              title: Text(
                'Quiz Already Completed',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF8B4513),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'The quiz you\'re about to take is already completed. Answering it again won\'t earn you points, and all answers will be marked as mistakes. Do you want to continue?',
                style: GoogleFonts.montserrat(color: const Color(0xFF8B4513)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // No
                  child: Text(
                    'No',
                    style:
                        GoogleFonts.montserrat(color: const Color(0xFF8B4513)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Yes
                  child: Text(
                    'Yes',
                    style:
                        GoogleFonts.montserrat(color: const Color(0xFF8B4513)),
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dismissed
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    log('Module: ${module.title}, Materials count: ${module.materials.length}');
    if (module.materials.isNotEmpty) {
      log('First material: ${module.materials[0].name}, URL: ${module.materials[0].fileUrl}');
    }

    final String fileTitle = module.materials.isNotEmpty
        ? module.materials[0].name
        : 'Untitled File';
    final String fileUrl = module.materials.isNotEmpty
        ? 'http://127.0.0.1:8000/${module.materials[0].fileUrl}' // Adjust base URL as needed
        : '';

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, backRoute);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5E8C7), // Manila paper
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
            onPressed: () {
              Navigator.pushNamed(context, backRoute);
            },
          ),
          title: Text(
            'Module Description',
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
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF8B4513),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(height: 2, color: const Color(0xFF8B4513)), // Divider
                const SizedBox(height: 20),
                Text(
                  'Description:',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF8B4513),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  module.description,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF8B4513),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Container(height: 2, color: const Color(0xFF8B4513)), // Divider
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        fileTitle,
                        style: GoogleFonts.montserrat(
                          color: const Color(0xFF8B4513),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.download, color: Color(0xFF8B4513)),
                      onPressed: fileUrl.isNotEmpty
                          ? () => _downloadFile(fileUrl, context)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(height: 2, color: const Color(0xFF8B4513)), // Divider
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 400,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool isCompleted = await _isQuizCompleted(module.id);
                        if (isCompleted) {
                          bool proceed =
                              await _showReattemptConfirmation(context);
                          if (proceed) {
                            if (module.category == 'Word Pronunciation') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WordProQuiz(
                                    moduleTitle: module.title,
                                    uniqueIds: [module.id], // Adjust if needed
                                    difficulty: module.difficulty,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppQuiz(
                                    module: module,
                                    backRoute: backRoute,
                                  ),
                                ),
                              );
                            }
                          }
                        } else {
                          if (module.category == 'Word Pronunciation') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WordProQuiz(
                                  moduleTitle: module.title,
                                  uniqueIds: [module.id], // Adjust if needed
                                  difficulty: module.difficulty,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppQuiz(
                                  module: module,
                                  backRoute: backRoute,
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        padding: const EdgeInsets.symmetric(vertical: 25),
                      ),
                      child: Text(
                        'Start Quiz',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
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
        ),
      ),
    );
  }
}
