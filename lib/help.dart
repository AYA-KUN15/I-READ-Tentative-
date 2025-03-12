import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                Text(
                  'Need Help?',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 30),
              ],
            ),
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
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        for (var step in steps)
          Text(
            step,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}