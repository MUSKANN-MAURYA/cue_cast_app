

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
    text: DateTime.now().toString().substring(0, 10), // yyyy-MM-dd
  );
  final TextEditingController _productionLocationController =
      TextEditingController();
  final TextEditingController _seekingTalentFromController =
      TextEditingController();
  final TextEditingController _durationController = TextEditingController();



  // Category-related variables
  final List<String> _categories = [
    'Acting',
    'Modelling',
    'VoiceOver',
    'Music',
    'Writing',
  ];
  String? _selectedCategory;

  

  

  Future<void> _postAudition() async {
    try {
      
      // Create a Firestore instance
      final firestore = FirebaseFirestore.instance;

      // Add data to the "auditions" collection
      await firestore.collection('auditions').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requirements': _requirementsController.text.trim(),
        'instructions': _instructionsController.text.trim(),
        'deadline': _deadlineController.text.trim(),
        'category': _selectedCategory,
        'postedBy': _postedByController.text.trim(),
        'productionLocation': _productionLocationController.text.trim(),
        'seekingTalentFrom': _seekingTalentFromController.text.trim(),
        'duration': _durationController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audition posted successfully!')),
      );

      // Clear the text fields and reset the category and test script
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
        
      });
    } catch (e) {
      // Show error message
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
              children: _categories.map((category) {
                return RadioListTile<String>(
                  title: Text(category),
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    Navigator.pop(context); // Close the dialog
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Enter the Audition Details"),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: 24,
          ), // Add extra bottom padding
          child: Padding(
            padding: const EdgeInsets.only(
              top: kToolbarHeight + 10,
              left: 14,
              right: 14,
            ),
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField("Enter project title", _titleController),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _showCategoryDialog, // Show category dialog
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(
                          text: _selectedCategory ?? 'Select Category',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Select Category',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.blueGrey.shade700,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
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
                    "Enter special instructions",
                    _instructionsController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    "Enter submission deadline",
                    _deadlineController,
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
                  const SizedBox(height: 16),
                  
                  
                  SizedBox(
                    height: 30,
                    width: 70,
                    child: ElevatedButton(
                      onPressed: widget.role == "Artist" ? null : _postAudition,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3A47),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Post Audition",
                        style: TextStyle(
                          fontSize: 16,
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
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      readOnly: widget.role == "Artist",
      onTap: () {
        if (widget.role == "Artist") {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Not Allowed"),
                ],
              ),
              content: const Text(
                "Artist cannot post Audition. Try making a Recruiter Account.",
                style: TextStyle(fontSize: 16),
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
        hintStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.blueGrey.shade700,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
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
