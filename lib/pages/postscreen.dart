import 'package:flutter/material.dart';

class PostAuditionScreen extends StatelessWidget {
  const PostAuditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        
        elevation: 0,
        title: Text("Enter the Audition Details",),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + 10, left: 14, right: 14),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField("Enter project title"),
                const SizedBox(height: 16),
                _buildTextField("Enter project description", maxLines: 4),
                const SizedBox(height: 16),
                _buildTextField("Enter role requirements", maxLines: 4),
                const SizedBox(height: 16),
                _buildTextField("Enter special instructions", maxLines: 3),
                const SizedBox(height: 16),
                _buildTextField("Enter submission deadline"),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Color(0xFF2C3A47),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        
                      ),
                    ),
                    child: const Text(
                      "Post Audition",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: const Color.fromARGB(255, 112, 155, 127),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
