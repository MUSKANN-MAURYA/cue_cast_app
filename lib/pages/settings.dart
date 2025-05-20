import 'package:cue_cast_app/pages/artist_profile.dart';
import 'package:cue_cast_app/pages/recruiter_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cue_cast_app/pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  final String role;
  const SettingsScreen({super.key, required this.role});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        //centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
           // const SizedBox(height: 2),
            ..._getSettingsTiles(widget.role),
          ],
        ),
      ),
    );
  }

  List<Widget> _getSettingsTiles(String role) {
    final List<String> items = role == 'Artist'
        ? ['Profile',  'Applied',  'Log out']
        : ['Profile',  'Submissions', 'Log out'];
    return items
        .map((title) => _buildSettingsTile(context, title))
        .toList();
  }

  Widget _buildSettingsTile(BuildContext context, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leading: _getTileIcon(title),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
      onTap: () async {
        if (title == 'Profile') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  widget.role == 'Artist' ? const UserProfileScreen() : RecruiterProfile(),
            ),
          );
        } else if (title == 'Applied') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AppliedAuditionsScreen(),
            ),
          );
        } else if (title == 'Log out') {
          _showLogoutConfirmation();
        } else if ( title == 'Submissions') {
          // Show grouped submissions by auditionTitle
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Submissions', style: TextStyle(color: Colors.white)),
                  backgroundColor:Colors.black,
                  // const Color(0xFF2C3A47),
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
                body: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('submissions').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No submissions found."));
                    }
                    // Group submissions by auditionTitle
                    final Map<String, List<QueryDocumentSnapshot>> grouped = {};
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final title = data['auditionTitle'] ?? 'Untitled';
                      grouped.putIfAbsent(title, () => []).add(doc);
                    }
                    return ListView(
                      children: grouped.entries.map((entry) {
                        return ListTile(
                          title: Text(entry.key),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubmissionListScreen(
                                  title: entry.key,
                                  submissions: entry.value,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          );
        }
      },
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you want to log out?',style: TextStyle(fontSize: 15,),),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyLogin()),
                  (route) => false,
                );
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Widget _getTileIcon(String title) {
    switch (title) {
      case 'Profile':
        return const Icon(Icons.person, color: Colors.blueGrey);
      case 'Password':
        return const Icon(Icons.lock, color: Colors.blueGrey);
      case 'Theme':
        return const Icon(Icons.color_lens, color: Colors.blueGrey);
      case 'Log out':
        return const Icon(Icons.logout, color: Colors.redAccent);
      case 'Applied':
      case 'Submissions':
        return const Icon(Icons.assignment_turned_in, color: Colors.blueGrey);
      default:
        return const Icon(Icons.settings, color: Colors.black);
    }
  }
}

class AppliedAuditionsScreen extends StatelessWidget {
  const AppliedAuditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Applied Auditions', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('submissions')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No applied auditions found."));
          }
          final submissions = snapshot.data!.docs;
          return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final data = submissions[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    data['auditionTitle'] ?? "No Title",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(data['description'] ?? "No Description"),
                      const SizedBox(height: 6),
                      Text(
                        "Status: ${data['status'] ?? 'N/A'}",
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    data['timestamp'] != null
                        ? (data['timestamp'] as Timestamp)
                            .toDate()
                            .toString()
                            .substring(0, 10)
                        : '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

