import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:cue_cast_app/pages/all_auditions.dart';
import 'package:cue_cast_app/pages/artist_profile.dart';
import 'package:cue_cast_app/pages/category_audition_screen.dart';
import 'package:cue_cast_app/pages/postscreen.dart';
import 'package:cue_cast_app/pages/recruiter_profile.dart';
import 'package:cue_cast_app/pages/settings.dart';
import 'package:cue_cast_app/pages/notifications.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String role;
  const HomeScreen({super.key, required this.role, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? profileImageUrl;
  String? userName;

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
          userName = userDoc.data()?['name'];
        });
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  int _selectedIndex = 0;

  List<Widget> get _screens => [
    HomeWidget(userId: widget.userId, role: widget.role),
    PostAuditionScreen(role: widget.role),
    NotificationScreen(),
    SettingsScreen(role: widget.role),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar:
          _selectedIndex == 0
              ? AppBar(
                title: Text(
                  'Welcome, ${userName ?? ""}',
                  style: TextStyle(color: Colors.white),
                ),
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
                      if (result == 'profileUpdated') {
                        _fetchProfileImage();
                      }
                    },
                    color: Colors.white,
                  ),
                ],
                automaticallyImplyLeading: false,
                elevation: 0,
                backgroundColor: Colors.black,
              )
              : null,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Post'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeWidget extends StatelessWidget {
  final String userId;
  final String role;
  const HomeWidget({super.key, required this.userId, required this.role});

  @override
  Widget build(BuildContext context) {
    return HomeContent(userId: userId, role: role);
  }
}

class HomeContent extends StatelessWidget {
  final String userId;
  final String role;
  const HomeContent({super.key, required this.userId, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: Colors.black,
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
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                categoryTile(context, "Acting", "assets/acting.jpeg"),
                categoryTile(context, "Modelling", "assets/modelling.jpeg"),
                categoryTile(context, "VoiceOver", "assets/voiceover.jpeg"),
                categoryTile(context, "Music", "assets/music.jpeg"),
                categoryTile(context, "Writing", "assets/writing.jpeg"),
              ],
            ),
            SizedBox(height: 5),
            Text(
              "Recent Auditions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('auditions')
                        .orderBy('timestamp', descending: true)
                        .limit(5)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No recent auditions found."),
                    );
                  }
                  final auditions = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: auditions.length,
                    itemBuilder: (context, index) {
                      final audition = auditions[index];
                      final auditionData =
                          audition.data() as Map<String, dynamic>;
                      auditionData['id'] = audition.id;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Stack(
                          children: [
                            ListTile(
                              title: Text(
                                auditionData['title'] ?? "No Title",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                auditionData['description'] ?? "No Description",
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => AuditionDetailsScreen(
                                          auditionData: auditionData,
                                        ),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Text(
                                auditionData['deadline'] ?? "No Deadline",
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget categoryTile(BuildContext context, String title, String imagePath) {
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
