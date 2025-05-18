import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReadOnlyProfile extends StatelessWidget {
  final String userId;
  const ReadOnlyProfile({super.key, required this.userId});

  int _calculateAge(String dob) {
    try {
      final birthDate = DateTime.parse(dob);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: const Text("Artist's Profile")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          final user = snapshot.data!.data() as Map<String, dynamic>;
          final name = user['name'] ?? 'N/A';
          final email = user['email'] ?? 'N/A';
          final dob = user['dob'] ?? '';
          final age = dob.isNotEmpty ? _calculateAge(dob) : 'N/A';
          final gender = user['gender'] ?? 'N/A';
          final height = user['height'] ?? 'N/A';
          final profileImageUrl = user['profileImageUrl'] ?? '';
          final skills = List<String>.from(user['skills'] ?? []);
          final professionsRaw = user['profession'];
          final professions = (professionsRaw is List)
              ? List<String>.from(professionsRaw)
              : professionsRaw?.toString().split(',') ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : null,
                  child: profileImageUrl.isEmpty ? const Icon(Icons.person, size: 50) : null,
                ),
                const SizedBox(height: 16),
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(email, style: const TextStyle(color: Colors.blue)),
                const SizedBox(height: 24),
                _buildSectionTitle('Details'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.female, '$gender, $age years old'),
                _buildDetailRow(Icons.height, height.toString()),
                const SizedBox(height: 24),
                _buildSectionTitle('Skills'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map((skill) => _buildChip(skill)).toList(),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Professions'),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: professions.map((p) => _buildProfessionRow(p)).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label),
    );
  }

  Widget _buildProfessionRow(String profession) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.work_outline),
          const SizedBox(width: 8),
          Text(profession, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
