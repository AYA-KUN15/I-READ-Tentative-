import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFadeInAnimation;
  late Animation<double> _textFadeInAnimation;
  late Animation<double> _buttonFadeInAnimation;
  late Animation<Offset> _slideUpAnimation;

  @override
  void initState() {
    super.initState();
    log('hello world');

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _logoFadeInAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _textFadeInAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ));

    _slideUpAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, -0.5))
            .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _buttonFadeInAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward(); // Start animations without auto-navigation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF5E8C7), // Manila paper background
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.05, vertical: height * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 250), // Space above the logo
            SlideTransition(
              position: _slideUpAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _logoFadeInAnimation,
                    child: Image.asset(
                      'assets/black_logo_readi.png',
                      width: 200,
                      height: 100,
                    ),
                  ),
                  // Removed SizedBox(height: 10) here
                  FadeTransition(
                    opacity: _textFadeInAnimation,
                    child: const Text(
                      'where learning gets better.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FadeTransition(
                    opacity: _buttonFadeInAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 295, // Adjusted width for Log In button
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF8B4513), // Brown button
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Text(
                              'Log In',
                              style: GoogleFonts.montserrat(
                                color: Colors.white, // White text for contrast
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Uncomment and adjust if needed:
                        /*
                        SizedBox(
                          width: 250, // Width for Sign Up button
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const IntroPage()),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF8B4513), // Brown button
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20),
                              minimumSize: const Size(double.infinity, 50),
                              side: const BorderSide(color: Color(0xFF8B4513)),
                            ),
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // White text
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        */
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Padding below the buttons
                  const Text(
                    'V2 (Alpha 4.1.2)',
                    style: TextStyle(
                      color: Color(0xFF8B4513), // Brown text
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '© 2024 Tanauan School of Fisheries',
                    style: TextStyle(
                      color: Color(0xFF8B4513), // Brown text
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40), // Additional padding below
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
