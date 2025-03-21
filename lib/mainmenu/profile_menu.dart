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
  String fullName = '';
  String strand = '';
  String schoolName = 'Tanauan School of Fisheries';
  String rank = 'Unranked';
  List<CompletedModule>? completedModuelsList = [];
  ApiService apiService = ApiService();
  StorageService storageService = StorageService();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    UserProfile? userProfile = await apiService.getProfile();
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
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5E8C7), // Manila paper background
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          title: Text(
            'Profile',
            style: GoogleFonts.montserrat(
              color: const Color(0xFF8B4513),
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
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFF5E8C7),
                    child: Icon(
                      Icons.account_circle,
                      size: 100,
                      color: const Color(0xFF8B4513).withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName.isEmpty ? 'Loading...' : fullName,
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            color: const Color(0xFF8B4513),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          strand.isEmpty ? 'Loading...' : strand,
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFF8B4513),
                          ),
                        ),
                        Text(
                          schoolName,
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFF8B4513),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Statistics',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF8B4513),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
              _buildProgressCard(
                'Modules Completed',
                '$completedModules/$totalModules',
                completedModules! / (totalModules! > 0 ? totalModules! : 1),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Points earned per module',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF8B4513),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: completedModuelsList?.length ?? 0,
                  itemBuilder: (context, index) {
                    CompletedModule? currentModule =
                        completedModuelsList?[index];
                    return _buildStatCard(
                      currentModule?.moduleTitle ?? '',
                      currentModule?.pointsEarned.toString() ?? '',
                    );
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
                color: const Color(0xFF8B4513),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.montserrat(
                color: const Color(0xFF8B4513),
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, String value, double progress) {
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
                color: const Color(0xFF8B4513),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF8B4513).withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.montserrat(
                color: const Color(0xFF8B4513),
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
