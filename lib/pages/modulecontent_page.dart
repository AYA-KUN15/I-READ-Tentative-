import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/models/module.dart';
import 'package:url_launcher/url_launcher.dart';

import '../quiz/readcompcontent/readcompdifficulty/readcomp_1.dart';

class ModuleContentPage extends StatelessWidget {
  final Module module;

  const ModuleContentPage({super.key, required this.module});

  Future<void> _downloadFile(String url, BuildContext context) async {
    log('Attempting to download: $url');
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        log('URL is launchable');
        await launchUrl(uri,
            mode: LaunchMode.inAppBrowserView); // Or externalApplication
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
        ? 'http://127.0.0.1:8000/${module.materials[0].fileUrl}' // Add your base URL
        : '';

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(
            context, '/read_comp_easy'); // Navigate back to ReadCompEasy
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5E8C7), // Manila paper
          elevation: 0, // Flat look
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF8B4513)), // Brown back arrow
            onPressed: () {
              Navigator.pushNamed(context, '/read_comp_easy');
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
                    color: const Color(0xFF8B4513), // Brown
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                    height: 2, color: const Color(0xFF8B4513)), // Brown divider
                const SizedBox(height: 20),
                Text(
                  'Description:',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF8B4513), // Brown
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  module.description,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF8B4513), // Brown
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                    height: 2,
                    color:
                        const Color(0xFF8B4513)), // Divider after description
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        fileTitle,
                        style: GoogleFonts.montserrat(
                          color: const Color(0xFF8B4513), // Brown
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download,
                          color: Color(0xFF8B4513)), // Brown
                      onPressed: fileUrl.isNotEmpty
                          ? () => _downloadFile(fileUrl, context)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                    height: 2,
                    color: const Color(
                        0xFF8B4513)), // Divider after material download
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 400, // Updated to 400 to match module buttons
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadCompQuiz(
                              moduleTitle: module.title,
                              difficulty: module.difficulty,
                              uniqueIds: [module.id],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513), // Brown
                        padding: const EdgeInsets.symmetric(vertical: 25),
                      ),
                      child: Text(
                        'Start Quiz',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White text
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
