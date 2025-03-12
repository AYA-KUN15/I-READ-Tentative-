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
              const SizedBox(height: 30),
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      AssetImage('assets/i_read_pic_old.png'), // Default image
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  strand.isEmpty
                      ? 'Loading...'
                      : strand, // Handle empty or loading strand value
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(color: Colors.white),
                ),
              ),
              Center(
                child: Text(
                  schoolName, // Add school name here
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text('Statistics',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.bold)),
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
                    _buildStatCard('Modules Completed',
                        '$completedModules/$totalModules'),
                  ],
                ),
              ),

              Text('Points earned per module',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                    itemCount: completedModuelsList?.length,
                    itemBuilder: (context, index) {
                      CompletedModule? currentModule =
                          completedModuelsList?[index];
                      return _buildStatCard(currentModule?.moduleTitle ?? '',
                          currentModule?.pointsEarned.toString() ?? '');
                    }),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      color: Colors.blue[800],
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: GoogleFonts.montserrat(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Text(value,
                style:
                    GoogleFonts.montserrat(color: Colors.white, fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Modules'),
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
          case 2:
            Navigator.pushNamed(context, '/profile_menu');
            break;
          case 3:
            Navigator.pushNamed(context, '/settings_menu');
            break;
        }
      },
    );
  }
}
