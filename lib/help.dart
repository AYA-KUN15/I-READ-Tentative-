import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E8C7), // Manila paper
        elevation: 0, // Flat look
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFF8B4513)), // Brown back arrow
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Need Help?',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8B4513), // Brown
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: const Color(0xFFF5E8C7), // Manila paper background
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHelpSection(
                title: 'Reading Comprehension/Sentence Composition',
                steps: [
                  'Type: Multiple Choice',
                  '1. Choose the best answer out of the given options.',
                  '2. Press "Submit" if your answer is final.',
                ],
              ),
              const SizedBox(height: 20),
              _buildHelpSection(
                title: 'Word Pronunciation',
                steps: [
                  'Type: Auditory',
                  '1. Press the Record (microphone) button.',
                  '2. Say the words prompted on the screen.',
                  '3. Press "Next" to go to the next item.',
                ],
              ),
              const SizedBox(height: 20),
              _buildHelpSection(
                title: 'Sentence Composition',
                steps: [
                  'Type: Multiple Choice',
                  '1. Choose the best answer out of the given options.',
                  '2. Press "Submit" if your answer is final.',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection(
      {required String title, required List<String> steps}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF8B4513), // Brown
          ),
        ),
        const SizedBox(height: 10),
        for (var step in steps)
          Text(
            step,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: const Color(0xFF8B4513), // Brown
            ),
          ),
      ],
    );
  }
}
