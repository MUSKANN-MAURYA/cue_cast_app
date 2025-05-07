import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

class RecruiterProfile extends StatefulWidget {
  const RecruiterProfile({super.key});

  @override
  State<RecruiterProfile> createState() => _RecruiterProfileState();
}

class _RecruiterProfileState extends State<RecruiterProfile>
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
  TextEditingController emailController = TextEditingController(
    text: 'harry@gmail.com',
  );
  TextEditingController locationController = TextEditingController(
    text: 'New York',
  );
  TextEditingController mobileController = TextEditingController(
    text: "123456xxxxx",
  );
  TextEditingController infoController = TextEditingController(
    text: 'Write about yourself ',
  );
  TextEditingController dobController = TextEditingController(
    text: '1992-01-01',
  );

  // Skills-related variables
  List<String> allprofessions = [
    'Casting Associate',
    'Stunt Associate',
    'Casting Director',
    'Choreography',
    'Director',
    'Producer',
    'Director of Photography',
  ];
  List<String> selectedSkills = [];
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            mobileController.text = userData?['mobile'] ?? '';
            emailController.text = userData?['email'] ?? '';
            profileImageUrl = userData?['profileImageUrl'];
            locationController.text = userData?['location'] ?? '';
            infoController.text = userData?['info'] ?? '';
            dobController.text = userData?['dob'] ?? '';
            selectedSkills = List<String>.from(userData?['skills'] ?? []);
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
        if (!mounted) return;
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
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
              'mobile': mobileController.text.trim(),
              'location': locationController.text.trim(),
              'info': infoController.text.trim(),
              'dob': dobController.text.trim(),
              'skills': selectedSkills,
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
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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
                  allprofessions.map((skill) {
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
            onTap: () => _pickImage(ImageSource.gallery),
            child: CircleAvatar(
              radius: 70,
              backgroundImage:
                  _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : null),
              child:
                  _selectedImage == null && profileImageUrl == null
                      ? const Icon(
                        Icons.account_circle,
                        size: 80,
                        color: Colors.grey,
                      )
                      : null,
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
            tabs: const [
              Tab(text: 'Basic Information'),
              Tab(text: 'All Jobs'),
              Tab(text: 'Submissions'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [buildBasicInfo(), buildUploads(), buildSubmissions()],
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
        buildField('Mobile', mobileController),
        buildField('Email', emailController),
        buildField('Location', locationController),
        buildField('Info', infoController),
        buildField('Date of Birth', dobController),
        buildSkillsField(),
      ],
    );
  }

  Widget buildSubmissions() {
    return FutureBuilder<QuerySnapshot>(
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
          children:
              grouped.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SubmissionListScreen(
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
              onTap: () => _selectDate(context),
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
          title: Text('All Auditions'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        Divider(),
        ListTile(
          title: Text('Active Auditions'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        Divider(),
        ListTile(
          title: Text('Completed Auditions'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }
}

class SubmissionListScreen extends StatelessWidget {
  final String title;
  final List<QueryDocumentSnapshot> submissions;
  const SubmissionListScreen({
    super.key,
    required this.title,
    required this.submissions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Submissions for "$title"')),
      body: ListView.builder(
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          final data = submissions[index].data() as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(data['role'] ?? 'No Role'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['description'] ?? ''),
                  if (data['videoUrl'] != null)
                    TextButton(
                      onPressed: () async {
                        final videoUrl = data['videoUrl'];
                        if (videoUrl != null) {
                          showDialog(
                            context: context,
                            builder: (context) => Center(
                              child: VideoDialog(videoUrl: videoUrl),
                            ),
                          );
                        }
                      },
                      child: const Text('View Video'),
                    ),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(data['userId'])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Text('Loading user info...');
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Text('User info not found');
                      }
                      final user = snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${user['name'] ?? ''}'),
                          Text('Email: ${user['email'] ?? ''}'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class VideoDialog extends StatefulWidget {
  final String videoUrl;
  const VideoDialog({super.key, required this.videoUrl});

  @override
  State<VideoDialog> createState() => _VideoDialogState();
}

class _VideoDialogState extends State<VideoDialog> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: _controller.value.isInitialized
            ? _controller.value.aspectRatio
            : 16 / 9,
        child: _controller.value.isInitialized
            ? Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  Positioned(
                    bottom: 16,
                    child: IconButton(
                      iconSize: 48,
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                        });
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? VideoPlayer(_controller)
        : const Center(child: CircularProgressIndicator());
  }
}
