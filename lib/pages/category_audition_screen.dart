import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'all_auditions.dart'; // For AuditionDetailsScreen

class CategoryAuditionsScreen extends StatelessWidget {
  final String categoryName;
  const CategoryAuditionsScreen({super.key, required this.categoryName});
  @override
  Widget build(BuildContext context) {
  print("Category: $categoryName");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$categoryName Auditions",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C3A47),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('auditions')
            .where('category', isEqualTo: categoryName)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No $categoryName auditions found."));
          }

          

          final auditions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: auditions.length,
            itemBuilder: (context, index) {
              final audition = auditions[index];
              final auditionData = audition.data() as Map<String, dynamic>;
              auditionData['id'] = audition.id;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(audition['title'] ?? "No Title"),
                  subtitle: Text(audition['description'] ?? "No Description"),
                  trailing: Text(audition['deadline'] ?? "No Deadline"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuditionDetailsScreen(
                          auditionData: auditionData,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}