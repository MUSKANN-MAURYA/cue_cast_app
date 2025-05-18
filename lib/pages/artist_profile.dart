import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For formatting the date
import 'package:path/path.dart' as path; // For handling file paths
import 'package:video_player/video_player.dart';

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
  List<String> headshotUrls = [];
  List<String> videoUrls = [];

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
            headshotUrls = List<String>.from(userData?['headshots'] ?? []);
            videoUrls = List<String>.from(userData?['videos'] ?? []);
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

  Future<void> _pickAndUploadVideo() async {
    final XFile? pickedVideo = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    final userId = FirebaseAuth.instance.currentUser?.uid;
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

      // Save URL to Firestore under user's document
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'videos': FieldValue.arrayUnion([publicUrl]),
      });

      setState(() {
        videoUrls.add(publicUrl);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
      children: [
        ListTile(
          title: const Text('Headshots'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        HeadshotsScreen(initialHeadshots: headshotUrls),
              ),
            );
          },
        ),
        Divider(),
        ListTile(
          title: const Text('Show Reel'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            await showDialog(
              context: context,
              builder:
                  (context) => StatefulBuilder(
                    builder:
                        (context, setStateDialog) => AlertDialog(
                          title: const Text('Videos'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child:
                                videoUrls.isEmpty
                                    ? const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Text('No videos uploaded.'),
                                    )
                                    : SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: videoUrls.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (context) => Center(
                                                        child: Dialog(
                                                          backgroundColor:
                                                              Colors.black,
                                                          child: AspectRatio(
                                                            aspectRatio: 16 / 9,
                                                            child: VideoPlayerWidget(
                                                              videoUrl:
                                                                  videoUrls[index],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                );
                                              },
                                              child: Container(
                                                width: 120,
                                                color: Colors.black12,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.play_circle_fill,
                                                    size: 48,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                          ),
                          actions: [
                            FloatingActionButton(
                              heroTag: 'addVideo',
                              onPressed: () async {
                                await _pickAndUploadVideo();
                                setState(() {});
                                setStateDialog(() {});
                              },
                              child: const Icon(Icons.add),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                  ),
            );
          },
        ),
        Divider(),
      ],
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
        ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
        : const Center(child: CircularProgressIndicator());
  }
}

class HeadshotsScreen extends StatefulWidget {
  final List<String> initialHeadshots;
  const HeadshotsScreen({super.key, required this.initialHeadshots});

  @override
  State<HeadshotsScreen> createState() => _HeadshotsScreenState();
}

class _HeadshotsScreenState extends State<HeadshotsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];
  List<String> headshotUrls = [];

  @override
  void initState() {
    super.initState();
    headshotUrls = List<String>.from(widget.initialHeadshots);
  }

  Future<void> _pickImages() async {
    final List<XFile> picked = await _picker.pickMultiImage();
    setState(() {
      selectedImages.addAll(picked);
    });
  }

  Future<void> _uploadImages() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || selectedImages.isEmpty) return;

    List<String> newUrls = [];
    for (var image in selectedImages) {
      final fileName =
          'submissions/${userId}_${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
      await supabase.storage
          .from('testscripts')
          .upload(
            fileName,
            File(image.path),
            fileOptions: const FileOptions(upsert: true),
          );
      final publicUrl = supabase.storage
          .from('testscripts')
          .getPublicUrl(fileName);
      newUrls.add(publicUrl);
    }
    // Save URLs to Firestore under user's document
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'headshots': FieldValue.arrayUnion(newUrls),
    });
    setState(() {
      headshotUrls.addAll(newUrls);
      selectedImages.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Headshots uploaded successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Headshots')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: headshotUrls.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  return Image.network(headshotUrls[index], fit: BoxFit.cover);
                },
              ),
            ),
            if (selectedImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.file(File(selectedImages[index].path)),
                    );
                  },
                ),
              ),
            if (selectedImages.isNotEmpty)
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload'),
                onPressed: _uploadImages,
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImages,
        child: const Icon(Icons.add),
      ),
    );
  }
}
