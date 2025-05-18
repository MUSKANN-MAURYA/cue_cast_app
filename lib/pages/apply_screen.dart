import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplyAuditionForm extends StatefulWidget {
  final String auditionId;
  final String auditionTitle;
  const ApplyAuditionForm({
    super.key,
    required this.auditionId,
    required this.auditionTitle,
  });

  @override
  State<ApplyAuditionForm> createState() => _ApplyAuditionFormState();
}

class _ApplyAuditionFormState extends State<ApplyAuditionForm> {
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedVideo;
  bool _isUploading = false;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _roleController.text = widget.auditionTitle;
  }

  @override
  void dispose() {
    _roleController.dispose();
    _descriptionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    if (_isUploading) return;
    setState(() => _isUploading = true);

    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedVideo = File(pickedFile.path));
        _videoController?.dispose();
        _videoController = VideoPlayerController.file(_selectedVideo!)
          ..initialize().then((_) {
            setState(() => _isUploading = false);
            _videoController?.setLooping(true);
            _videoController?.play();
          });
      } else {
        setState(() => _isUploading = false);
      }
    } catch (_) {
      setState(() => _isUploading = false);
    }
  }

  Future<String?> _uploadVideoToSupabase(File videoFile) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final fileName = 'submissions/$userId-${DateTime.now().millisecondsSinceEpoch}.mp4';
    final supabase = Supabase.instance.client;
    final response = await supabase.storage.from('testscripts').upload(
      fileName,
      videoFile,
      fileOptions: const FileOptions(upsert: true),
    );
    if (response.isNotEmpty) {
      return supabase.storage.from('testscripts').getPublicUrl(fileName);
    }
    return null;
  }

  Future<void> _submitForm() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    if (_selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a video')));
      return;
    }

    setState(() => _isUploading = true);

    final videoUrl = await _uploadVideoToSupabase(_selectedVideo!);
    if (videoUrl == null) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video upload failed')));
      return;
    }

    await FirebaseFirestore.instance.collection('submissions').add({
      'auditionId': widget.auditionId,
      'auditionTitle': widget.auditionTitle,
      'userId': userId,
      'role': _roleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'videoUrl': videoUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'Submitted',
    });

    setState(() => _isUploading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application submitted!')));
    Navigator.pop(context, 'submitted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Apply', style: TextStyle(color: Colors.white,  )),
        backgroundColor: Colors.black,
        elevation: 0,
        //centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Role Title", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _roleController,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Description", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tell us about your audition",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Upload Your Audition Video", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Icon(Icons.video_library, size: 24, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isUploading ? null : _pickVideo,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueGrey.shade200),
                ),
                child: Center(
                  child: (_selectedVideo != null && _videoController != null && _videoController!.value.isInitialized)
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                            IconButton(
                              iconSize: 48,
                              icon: Icon(
                                _videoController!.value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_videoController!.value.isPlaying) {
                                    _videoController!.pause();
                                  } else {
                                    _videoController!.play();
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.play_circle_outline, size: 60, color: Colors.blueGrey),
                            SizedBox(height: 10),
                            Text("Tap to upload video", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3A47),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Application",
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
