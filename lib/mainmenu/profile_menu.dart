import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/models/user.dart';
import 'package:i_read_app/services/api.dart';
import 'package:i_read_app/services/storage.dart';

class ProfileMenu extends StatefulWidget {
  const ProfileMenu({super.key});

  @override
  _ProfileMenuState createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  int? xp = 0;
  int? completedModules = 0;
  int? totalModules = 0;
  String fullName = ''; // Declare fullName
  String strand = ''; // Declare strand
  String schoolName = 'Tanauan School of Fisheries'; // Declare school name
  String rank = 'Unranked'; // Declare school name
  List<CompletedModule>? completedModuelsList = [];
  ApiService apiService = ApiService();
  StorageService storageService = StorageService();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    UserProfile? userProfile = await apiService.getProfile(); // Fetch user data
    List<Module> moduleList = await apiService.getModules();
    setState(() {
      fullName = '${userProfile?.firstName} ${userProfile?.lastName}';
      xp = userProfile?.experience;
      completedModules = userProfile?.completedModules.length;
      strand = userProfile?.section ?? '';
      completedModuelsList = userProfile?.completedModules;
      rank = userProfile?.rank.toString() ?? '';
      totalModules = moduleList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/home');
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5E8C7), // Manila paper background
          elevation: 0, // Remove shadow
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          title: Text(
            'Profile',
            style: GoogleFonts.montserrat(
              color: const Color(0xFF8B4513), // Brown text
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Container(
          color: const Color(0xFFF5E8C7), // Manila paper background
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.05, vertical: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFFF5E8C7), // Manila paper
                  child: Icon(
                    Icons.account_circle,
                    size: 120,
                    color:
                        const Color(0xFF8B4513).withOpacity(0.5), // Light brown
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  fullName.isEmpty
                      ? 'Loading...'
                      : fullName, // Show 'Loading...' until the data is fetched
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    color: const Color(0xFF8B4513), // Brown text
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  strand.isEmpty
                      ? 'Loading...'
                      : strand, // Handle empty or loading strand value
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      color: const Color(0xFF8B4513)), // Brown text
                ),
              ),
              Center(
                child: Text(
                  schoolName, // Add school name here
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      color: const Color(0xFF8B4513)), // Brown text
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Statistics',
                style: GoogleFonts.montserrat(
                    color: const Color(0xFF8B4513), // Brown text
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Ranking', '#$rank'),
                        ),
                        Expanded(
                          child: _buildStatCard('XP Earned', xp.toString()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildStatCard(
                        'Modules Completed', '$completedModules/$totalModules'),
                  ],
                ),
              ),
              Text(
                'Points earned per module',
                style: GoogleFonts.montserrat(
                    color: const Color(0xFF8B4513), // Brown text
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: completedModuelsList?.length,
                  itemBuilder: (context, index) {
                    CompletedModule? currentModule =
                        completedModuelsList?[index];
                    return _buildStatCard(currentModule?.moduleTitle ?? '',
                        currentModule?.pointsEarned.toString() ?? '');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      color: const Color.fromARGB(255, 249, 222, 194), // Lighter manila shade
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                  color: const Color(0xFF8B4513), // Brown text
                  fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: GoogleFonts.montserrat(
                  color: const Color(0xFF8B4513), // Brown text
                  fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
