import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DictionaryMenu extends StatefulWidget {
  const DictionaryMenu({super.key});

  @override
  _DictionaryMenuState createState() => _DictionaryMenuState();
}

class _DictionaryMenuState extends State<DictionaryMenu> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, String>> _dictionaryEntries = [];
  List<Map<String, String>> _filteredEntries = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchDictionaryEntries();
  }

  Future<void> _fetchDictionaryEntries() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('fields').doc('Dictionary').get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        if (data!.containsKey('Words')) {
          Map<String, dynamic> wordsMap = data['Words'];

          setState(() {
            _dictionaryEntries = [];
            wordsMap.forEach((key, value) {
              // Ensure value is a List<dynamic>
              if (value is List<dynamic>) {
                // Check that we have at least 2 elements: title and description
                if (value.length >= 2) {
                  _dictionaryEntries.add({
                    'title': value[0] as String,
                    'description': value[1] as String,
                  });
                }
              }
            });
            _filteredEntries =
                _dictionaryEntries; // Initialize filtered entries
          });
        }
      }
    } catch (e) {
      print('Error fetching dictionary entries: $e');
    }
  }

  void _filterEntries(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredEntries =
            _dictionaryEntries; // Show all entries when query is empty
      } else {
        _filteredEntries = _dictionaryEntries.where((entry) {
          return entry['title']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      }
    });
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
              horizontal: width * 0.05, vertical: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  'Dictionary',
                  style: GoogleFonts.montserrat(
                    fontSize: width * 0.06,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
// Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  onChanged: _filterEntries,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                    hintStyle: GoogleFonts.montserrat(
                      color: Colors.white.withOpacity(0.7), // Hint text color
                    ),
                  ),
                  style: GoogleFonts.montserrat(
                    color: Colors.white, // Text color
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: _filteredEntries.map((entry) {
                    return Card(
                      color: Colors.white, // White background for cards
                      child: ListTile(
                        title: Text(
                          entry['title']!,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, // Blue color for module name
                          ),
                        ),
                        subtitle: Text(
                          entry['description']!,
                          style: GoogleFonts.montserrat(
                            color: Colors.black, // Black color for description
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
        BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Dictionary'), // Dictionary icon
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      currentIndex: 2,
      selectedItemColor: Colors.blue[900],
      unselectedItemColor: Colors.lightBlue,
      backgroundColor: Colors.white,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/modules_menu');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile_menu');
            break;
          case 4:
            Navigator.pushNamed(context, '/settings_menu');
            break;
        }
      },
    );
  }
}
