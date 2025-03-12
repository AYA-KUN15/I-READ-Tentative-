import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/services/api.dart';

import '../../pages/modulecontent_page.dart'; // Import the new file

class ReadCompEasy extends StatefulWidget {
  const ReadCompEasy({super.key});

  @override
  _ReadCompEasyState createState() => _ReadCompEasyState();
}

class _ReadCompEasyState extends State<ReadCompEasy> {
  final ApiService apiService = ApiService();
  late Future<List<Module>> _easyModulesFuture;

  @override
  void initState() {
    super.initState();
    _easyModulesFuture = _fetchEasyModules();
  }

  Future<List<Module>> _fetchEasyModules() async {
    List<Module> modules = await apiService.getModules();
    return modules
        .where((module) =>
            module.difficulty == 'Easy' &&
            module.category == 'Reading Comprehension')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Easy Reading Comprehension',
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<Module>>(
          future: _easyModulesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading modules: ${snapshot.error}',
                  style: GoogleFonts.montserrat(color: Colors.white),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No Easy modules available',
                  style: GoogleFonts.montserrat(color: Colors.white),
                ),
              );
            }

            final easyModules = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: easyModules
                    .map((module) => _buildModuleButton(context, module))
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModuleButton(BuildContext context, Module module) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10.0), // Should be 'bottom' (see note)
      child: SizedBox(
        width: 300,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModuleContentPage(module: module),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 25),
          ),
          child: Text(
            module.title,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
