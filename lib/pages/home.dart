import 'package:cue_cast_app/pages/acting.dart';
import 'package:cue_cast_app/pages/modelling.dart';
import 'package:cue_cast_app/pages/music.dart';
import 'package:cue_cast_app/pages/postscreen.dart';
import 'package:cue_cast_app/pages/settings.dart';
import 'package:cue_cast_app/pages/voiceover.dart';
import 'package:cue_cast_app/pages/writing.dart';
import 'package:cue_cast_app/pages/notifications.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


 
  

  int _selectedIndex = 0;

  // List of screens for Bottom Navigation
  final List<Widget> _screens = [
    HomeWidget(),
    PostAuditionScreen(),
    NotificationScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Hello, Name";
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
            icon: Icon(Icons.account_circle),
            onPressed: () {},
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
              onPressed: () {},
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
            builder: (context) => CategoryScreen(categoryName: title),
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

// Category Screen
class CategoryScreen extends StatelessWidget {
  final String categoryName;

  const CategoryScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    Widget categoryWidget;

    // Navigate to the correct screen based on category
    switch (categoryName) {
      case "Acting":
        categoryWidget = ActingScreen();
        break;
      case "Modelling":
        categoryWidget = ModellingScreen();
        break;
      case "VoiceOver":
        categoryWidget = VoiceOverScreen();
        break;
      case "Music":
        categoryWidget = MusicScreen();
        break;
      case "Writing":
        categoryWidget = WritingScreen();
        break;
      default:
        categoryWidget = Center(child: Text("Category not found"));
    }

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: categoryWidget,
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
