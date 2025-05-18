import 'package:cue_cast_app/pages/apply_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class AllAuditionsScreen extends StatelessWidget {
  const AllAuditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Auditions",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:  Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the back arrow color to white

        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('auditions')
                .orderBy(
                  'timestamp',
                  descending: true,
                ) // Fetch in descending order
                .snapshots(),   
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No auditions found."));
          }

          final auditions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: auditions.length,
            itemBuilder: (context, index) {
              final audition = auditions[index];
              final auditionData = audition.data() as Map<String, dynamic>;
              auditionData['id'] = audition.id; // Add the Firestore doc ID
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Stack(
                  children: [
                    ListTile(
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

class AuditionDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> auditionData;

  const AuditionDetailsScreen({super.key, required this.auditionData});

  @override
  State<AuditionDetailsScreen> createState() => _AuditionDetailsScreenState();
}

class _AuditionDetailsScreenState extends State<AuditionDetailsScreen> {
  VideoPlayerController? _videoController;
  bool _showVideo = false;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _playVideo(String url) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(url);
    await _videoController!.initialize();
    setState(() {
      _showVideo = true;
    });
    _videoController!.play();
  }

  @override
  Widget build(BuildContext context) {
    final auditionData = widget.auditionData;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Audition Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:  Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  auditionData['title'] ?? "No Title",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Posted On
                const SizedBox(height: 4),
                Text(
                  "Posted On: ${auditionData['timestamp'] != null ? (auditionData['timestamp'] as Timestamp).toDate().toString().substring(0, 10) : 'N/A'}",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 12),

                // Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 89, 146, 101),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    auditionData['category'] ?? "Category",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Project Description
                const Text(
                  "Description",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Text(
                //   auditionData['description'] ?? "No Description",
                //   style: const TextStyle(fontSize: 16),
                // ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    auditionData['description'] ?? "No Description",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Contact Info
                const Text(
                  "Email",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(" ${auditionData['email'] ?? 'N/A'}"),
                //Text("WhatsApp: ${auditionData['phone'] ?? 'N/A'}"),

                const SizedBox(height: 24),

                // Roles
                const Text(
                  "Roles",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    auditionData['requirements'] ?? "No Role Details",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Roles
                const Text(
                  "Testscript",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    auditionData['instructions'] ?? "No Role Details",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),

// Watch Video Text
if (auditionData['videoUrl'] != null && auditionData['videoUrl'].toString().isNotEmpty)
  GestureDetector(
    onTap: () async {
      await _playVideo(auditionData['videoUrl']);
    },
    child: const Text(
      "Watch Video",
      style: TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
if (_showVideo && _videoController != null && _videoController!.value.isInitialized)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: VideoPlayer(_videoController!),
    ),
  ),


                const SizedBox(height: 16),

                // Location
                rowWithIcon(
                  Icons.location_on,
                  "Production Location:",
                  auditionData['productionLocation'] ?? "Not Specified",
                ),

                const SizedBox(height: 8),

                // Seeking Talent From
                rowWithIcon(
                  Icons.map,
                  "Seeking Talent From:",
                  auditionData['seekingTalentFrom'] ?? "Not Specified",
                ),

                const SizedBox(height: 8),

                // Duration
                rowWithIcon(
                  Icons.schedule,
                  "Duration:",
                  auditionData['duration'] ?? "Not Specified",
                ),
                const SizedBox(height: 8),
                rowWithIcon(
                  Icons.event,
                  "Expiring On:",
                  auditionData['deadline'] ?? "Not Specified",
                ),

                const SizedBox(height: 32),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ApplyAuditionForm(
                                auditionId: auditionData['id'],
                                auditionTitle: auditionData['title'] ?? '',
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3A47),
                      padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Apply",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // View Test Script Button
                
              ],
            ),
            // Expiring On Badge (Top Right)
            // Positioned(
            //   top: 0,
            //   right: 0,
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 8,
            //       vertical: 5,
            //     ),
            //     decoration: BoxDecoration(
            //       color: Colors.green.shade600,
            //       borderRadius: BorderRadius.circular(14),
            //     ),
            //     child: Text(
            //       "Expiring On: ${auditionData['deadline'] ?? 'N/A'}",
            //       style: const TextStyle(
            //         color: Colors.white,
                    
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget rowWithIcon(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: "$label ",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
