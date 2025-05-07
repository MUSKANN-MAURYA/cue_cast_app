import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cue_cast_app/pages/all_auditions.dart';
import 'package:cue_cast_app/pages/artist_profile.dart';
import 'package:cue_cast_app/pages/category_audition_screen.dart';

import 'package:cue_cast_app/pages/postscreen.dart';
import 'package:cue_cast_app/pages/recruiter_profile.dart';
import 'package:cue_cast_app/pages/settings.dart';

import 'package:cue_cast_app/pages/notifications.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String role;
  const HomeScreen({super.key, required this.role, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
  }

  Future<void> _fetchProfileImage() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get();
      if (userDoc.exists) {
        setState(() {
          profileImageUrl = userDoc.data()?['profileImageUrl'];
        });
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  int _selectedIndex = 0;

  // List of screens for Bottom Navigation
  List<Widget> get _screens => [
    HomeWidget(),
    PostAuditionScreen(role: widget.role),
    NotificationScreen(),
    SettingsScreen(role: widget.role),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Welcome, ${widget.role}';
      case 1:
        return "Post Audition";
      case 2:
        return "Notifications";
      case 3:
        return "Settings";
      default:
        return "Cue Cast";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(_getAppBarTitle(), style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon:
                profileImageUrl != null
                    ? CircleAvatar(
                      radius: 15,
                      backgroundImage: NetworkImage(profileImageUrl!),
                    )
                    : const Icon(Icons.account_circle, size: 30),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          widget.role == 'Artist'
                              ? const UserProfileScreen()
                              : RecruiterProfile(),
                ),
              );

              // If profile was updated, refresh the image
              if (result == 'profileUpdated') {
                _fetchProfileImage();
              }
            },
            color: Colors.white,
          ),
        ],
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Color(0xFF2C3A47),
      ),
      body:
          _selectedIndex == 0 ? _buildHomeContent() : _screens[_selectedIndex],

      // Bottom Navigation Bar
      bottomNavigationBar: Theme(
        data: Theme.of(
          context,
        ).copyWith(iconTheme: IconThemeData(color: Colors.white)),
        child: CurvedNavigationBar(
          index: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          color: Color(0xFF2C3A47),
          buttonBackgroundColor: Colors.black,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 300),
          items: const <Widget>[
            Icon(Icons.home, size: 30),
            Icon(Icons.add, size: 30),
            Icon(Icons.notifications, size: 30),
            Icon(Icons.settings, size: 30),
          ],
          height: 60,
        ),
      ),

      // body: _pages[_selectedIndex],
    );
  }

  // Home Screen Content
  Widget _buildHomeContent() {
    return Container(
      color: Colors.white10,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Banner
            Container(
              height: 171,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/top.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),

            // All Auditions Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllAuditionsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    15,
                  ), // Adjust the value for more/less curve
                ),
                backgroundColor: Color(0xFF2C3A47),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "All Auditions",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            // All Categories Section
            Text(
              "All Categories",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
              shrinkWrap: true, // Important
              physics:
                  NeverScrollableScrollPhysics(), // Prevents nested scrolling
              children: [
                categoryTile("Acting", "assets/acting.jpeg"),
                categoryTile("Modelling", "assets/modelling.jpeg"),
                categoryTile("VoiceOver", "assets/voiceover.jpeg"),
                categoryTile("Music", "assets/music.jpeg"),
                categoryTile("Writing", "assets/writing.jpeg"),
              ],
            ),

            SizedBox(height: 5),

            // Recent Auditions
            Text(
              "Recent Auditions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(child: Text("Auditions will be listed here")),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget categoryTile(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryAuditionsScreen(categoryName: title),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Image.asset(
                imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.black.withOpacity(0.6),
                width: double.infinity,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dummy Placeholder Screens
class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Home Screen", style: TextStyle(fontSize: 24)));
  }
}
