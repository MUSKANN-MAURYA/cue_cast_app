import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For formatting the date
import 'package:path/path.dart' as path; // For handling file paths

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  bool isEditing = false;
  late TabController _tabController;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isuploading = false;

  // Controllers for user data
  TextEditingController nameController = TextEditingController(text: 'Ethan');
  TextEditingController genderController = TextEditingController(text: 'Male');
  TextEditingController ageController = TextEditingController(text: '30');
  TextEditingController emailController = TextEditingController(
    text: 'ethan@gmail.com',
  );
  TextEditingController locationController = TextEditingController(
    text: 'San Francisco, CA',
  );
  TextEditingController heightController = TextEditingController(
    text: "5'10\"",
  );
  TextEditingController weightController = TextEditingController(
    text: '160 lbs',
  );
  TextEditingController dobController = TextEditingController(
    text: '1992-01-01',
  );
  TextEditingController professionController = TextEditingController(
    text: 'Actor, Musician',
  );

  // Skills-related variables
  List<String> allSkills = [
    'Dancing',
    'Acting',
    'Choreography',
    'Comedy',
    'Modeling',
    'Voiceover',
    'Singing',
  ];
  List<String> selectedSkills = [];
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          setState(() {
            nameController.text = userData?['name'] ?? '';
            genderController.text = userData?['gender'] ?? '';
            ageController.text = userData?['age'] ?? '';
            emailController.text = userData?['email'] ?? '';
            profileImageUrl = userData?['profileImageUrl'];
            locationController.text = userData?['location'] ?? '';
            heightController.text = userData?['height'] ?? '';
            weightController.text = userData?['weight'] ?? '';
            dobController.text = userData?['dob'] ?? '';
            selectedSkills = List<String>.from(userData?['skills'] ?? []);
            professionController.text = userData?['profession'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: source);

      if (pickedImage != null) {
        if (!mounted) return; // <-- Add this line
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      if (!mounted) return; // <-- Add this line
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _saveUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        if (_selectedImage == null && profileImageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an image')),
          );
          return;
        }

        setState(() {
          _isuploading = true;
        });

        if (_selectedImage != null) {
          final String fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${path.basename(_selectedImage!.path)}';

          await supabase.storage
              .from('cuecast.11')
              .upload(
                'public/$fileName',
                _selectedImage!,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: true,
                ),
              );

          // Get the public URL from Supabase
          profileImageUrl = supabase.storage
              .from('cuecast.11')
              .getPublicUrl('public/$fileName');
        }

        // Save user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
              'name': nameController.text.trim(),
              'gender': genderController.text.trim(),
              'age': ageController.text.trim(),
              'location': locationController.text.trim(),
              'height': heightController.text.trim(),
              'weight': weightController.text.trim(),
              'dob': dobController.text.trim(),
              'skills': selectedSkills,
              'profession': professionController.text.trim(),
              'profileImageUrl': profileImageUrl,
            });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
    } finally {
      setState(() {
        _isuploading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(1900), // Earliest date
      lastDate: DateTime.now(), // Latest date
    );
    if (pickedDate != null) {
      setState(() {
        dobController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(pickedDate); // Format the date
      });
    }
  }

  Future<void> _showSkillsDialog() async {
    List<String> tempSelectedSkills = List.from(selectedSkills);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Skills'),
          content: SingleChildScrollView(
            child: Column(
              children:
                  allSkills.map((skill) {
                    return CheckboxListTile(
                      title: Text(skill),
                      value: tempSelectedSkills.contains(skill),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedSkills.add(skill);
                          } else {
                            tempSelectedSkills.remove(skill);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedSkills = tempSelectedSkills;
                });
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap:
                () => _pickImage(
                  ImageSource.gallery,
                ), // Trigger image picker with a default source
            child: CircleAvatar(
              radius: 70,
              backgroundImage:
                  _selectedImage != null
                      ? FileImage(_selectedImage!) // Display selected image
                      : (profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : null), // No background image if no profile image is selected
              child:
                  _selectedImage == null && profileImageUrl == null
                      ? const Icon(
                        Icons.account_circle,
                        size: 80,
                        color: Colors.grey, // Default icon color
                      )
                      : null, // No child if a profile image is selected
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (isEditing) {
                _saveUserData();
              }
              setState(() {
                isEditing = !isEditing;
              });
            },
            child: Text(isEditing ? 'Save' : 'Edit Profile'),
          ),
          const SizedBox(height: 10),
          TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Basic Information'), Tab(text: 'Uploads')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [buildBasicInfo(), buildUploads()],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBasicInfo() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        buildField('Name', nameController),
        buildField('Gender', genderController),
        buildField('Age', ageController),
        buildField('Email', emailController),
        buildField('Location', locationController),
        buildField('Height', heightController),
        buildField('Weight', weightController),
        buildField('Date of Birth', dobController),
        buildSkillsField(),
        buildField('Professions', professionController),
      ],
    );
  }

  Widget buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (label == 'Date of Birth' && isEditing)
            GestureDetector(
              onTap: () => _selectDate(context), // Show date picker when tapped
              child: AbsorbPointer(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Select Date of Birth',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            )
          else if (isEditing)
            TextField(controller: controller)
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(controller.text),
            ),
        ],
      ),
    );
  }

  Widget buildSkillsField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Skills', style: TextStyle(fontWeight: FontWeight.bold)),
          if (isEditing)
            GestureDetector(
              onTap: _showSkillsDialog,
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                    text: selectedSkills.join(', '),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Select Skills',
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(selectedSkills.join(', ')),
            ),
        ],
      ),
    );
  }

  Widget buildUploads() {
    return ListView(
      children: const [
        ListTile(
          title: Text('Photos'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        Divider(),
        ListTile(
          title: Text('Videos'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        Divider(),
        ListTile(
          title: Text('Experience'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }
}
