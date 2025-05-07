import 'package:cue_cast_app/pages/artist_profile.dart';
import 'package:cue_cast_app/pages/recruiter_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cue_cast_app/pages/login.dart';

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
      backgroundColor: const Color(0xFF101820),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSettingsTile(context, 'Profile'),
            _buildSettingsTile(context, 'Email'),
            _buildSettingsTile(context, 'Password'),
            _buildSettingsTile(context, 'Social Media'),
            _buildSettingsTile(context, 'Theme'),
            _buildSettingsTile(context, 'Log out'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, String title) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 16,
          ),
          onTap: () async {
            if (title == 'Profile') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          widget.role == 'Artist'
                              ? const UserProfileScreen()
                              : RecruiterProfile(),
                ),
              );
            } else if (title == 'Log out') {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context), // Cancel
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context); // Close dialog
                            await FirebaseAuth.instance.signOut();
                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyLogin(),
                                ),
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
          },
        ),
      ],
    );
  }
}
