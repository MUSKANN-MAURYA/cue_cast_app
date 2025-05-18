import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class PostAuditionScreen extends StatefulWidget {
  final String role;
  const PostAuditionScreen({super.key, required this.role});

  @override
  State<PostAuditionScreen> createState() => _PostAuditionScreenState();
}

class _PostAuditionScreenState extends State<PostAuditionScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _postedByController = TextEditingController(
    text: DateTime.now().toString().substring(0, 10),
  );
  final TextEditingController _productionLocationController =
      TextEditingController();
  final TextEditingController _seekingTalentFromController =
      TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  final List<String> _categories = [
    'Acting',
    'Modelling',
    'VoiceOver',
    'Music',
    'Writing',
  ];
  String? _selectedCategory;

  File? _selectedVideo;
  bool _isUploadingVideo = false;
  String? _videoUrl;

  Future<void> _postAudition() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _requirementsController.text.trim().isEmpty ||
        _instructionsController.text.trim().isEmpty ||
        _deadlineController.text.trim().isEmpty ||
        _selectedCategory == null ||
        _productionLocationController.text.trim().isEmpty ||
        _seekingTalentFromController.text.trim().isEmpty ||
        _durationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all the fields before posting.'),
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('auditions').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requirements': _requirementsController.text.trim(),
        'instructions': _instructionsController.text.trim(),
        'deadline': _deadlineController.text.trim(),
        'category': _selectedCategory?.trim(),
        'postedBy': _postedByController.text.trim(),
        'userId': user?.uid,
        'email': user?.email,
        'productionLocation': _productionLocationController.text.trim(),
        'seekingTalentFrom': _seekingTalentFromController.text.trim(),
        'duration': _durationController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'videoUrl': _videoUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audition posted successfully!')),
      );

      _titleController.clear();
      _descriptionController.clear();
      _requirementsController.clear();
      _instructionsController.clear();
      _deadlineController.clear();
      _productionLocationController.clear();
      _seekingTalentFromController.clear();
      _durationController.clear();

      setState(() {
        _selectedCategory = null;
        _selectedVideo = null;
        _videoUrl = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to post audition: $e')));
    }
  }

  Future<void> _showCategoryDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: SingleChildScrollView(
            child: Column(
              children:
                  _categories.map((category) {
                    return RadioListTile<String>(
                      title: Text(category),
                      value: category,
                      groupValue: _selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDeadlineDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _deadlineController.text = picked.toIso8601String().substring(0, 10);
      setState(() {});
    }
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    int? minLines,
    int? maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87),
      readOnly: widget.role == "Artist",
      onTap: () {
        if (widget.role == "Artist") {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Row(
                    children: const [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Not Allowed"),
                    ],
                  ),
                  content: const Text(
                    "Artist cannot post Audition. Try making a Recruiter Account.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
          );
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.blueGrey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
    );
  }

  Future<void> _pickAndUploadVideo() async {
    final picker = ImagePicker();
    final XFile? pickedVideo = await picker.pickVideo(
      source: ImageSource.gallery,
    );
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final supabase = Supabase.instance.client;

    if (pickedVideo != null && userId != null) {
      final fileName =
          'videos/${userId}_${DateTime.now().millisecondsSinceEpoch}_${path.basename(pickedVideo.path)}';
      await supabase.storage
          .from('testscripts')
          .upload(
            fileName,
            File(pickedVideo.path),
            fileOptions: const FileOptions(upsert: true),
          );
      final publicUrl = supabase.storage
          .from('testscripts')
          .getPublicUrl(fileName);

      setState(() {
        _selectedVideo = File(pickedVideo.path);
        _videoUrl = publicUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post Audition',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              _buildTextField("Enter project title", _titleController),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _showCategoryDialog,
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(
                      text: _selectedCategory ?? 'Select Category',
                    ),
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Select Category',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.blueGrey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Enter project description",
                _descriptionController,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Enter role requirements",
                _requirementsController,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Enter Test Script",
                _instructionsController,
                minLines: 1,
                maxLines: 10,
              ),
              const SizedBox(height: 16),
              // Video upload field
Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Upload Audition Video",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
),
const SizedBox(height: 8),
Row(
  children: [
    ElevatedButton.icon(
      onPressed: _isUploadingVideo ? null : _pickAndUploadVideo,
      icon: const Icon(Icons.upload_file),
      label: Text(_isUploadingVideo ? "Uploading..." : "Upload Video"),
      style: ElevatedButton.styleFrom(
        //backgroundColor: const Color(0xFF2C3A47),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    const SizedBox(width: 12),
    if (_selectedVideo != null)
      const Icon(Icons.check_circle, color: Colors.green),
  ],
),
if (_videoUrl != null)
  Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Text(
      "Video uploaded!",
      style: TextStyle(color: Colors.green),
    ),
  ),
const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDeadlineDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _deadlineController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Submission deadline",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.blueGrey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField("Posted By (Date)", _postedByController),
              const SizedBox(height: 16),
              _buildTextField(
                "Production Location",
                _productionLocationController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Seeking Talent From",
                _seekingTalentFromController,
              ),
              const SizedBox(height: 16),
              _buildTextField("Duration", _durationController),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: widget.role == "Artist" ? null : _postAudition,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3A47),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Post Audition",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _instructionsController.dispose();
    _deadlineController.dispose();
    _postedByController.dispose();
    _productionLocationController.dispose();
    _seekingTalentFromController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
