import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'all_auditions.dart'; // For AuditionDetailsScreen

class CategoryAuditionsScreen extends StatefulWidget {
  final String categoryName;
  const CategoryAuditionsScreen({super.key, required this.categoryName});

  @override
  State<CategoryAuditionsScreen> createState() =>
      _CategoryAuditionsScreenState();
}

class _CategoryAuditionsScreenState extends State<CategoryAuditionsScreen> {
  @override
  Widget build(BuildContext context) {
    print("Category: ${widget.categoryName}");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.categoryName} Auditions",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor:  Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('auditions')
                .where('category', isEqualTo: widget.categoryName)
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          print("Snapshot data: ${snapshot.hasData}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No ${widget.categoryName} auditions found."),
            );
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
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                      child: ListTile(
                        title: Text(
                          audition['title'] ?? "No Title",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(audition['description'] ?? "No Description"),
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
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      
                        child: Text(
                          audition['deadline'] ?? "No Deadline",
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                     // ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
