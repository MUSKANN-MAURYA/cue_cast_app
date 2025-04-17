import 'package:flutter/material.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({super.key});

  @override
  State<MyRegister> createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  String? selectedRole;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg_2.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(left: 47, top: 137),
              child: Text(
                'Create Account',
                style: TextStyle(color: Colors.white, fontSize: 37),
              ),
            ),

            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.30,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  children: [
                    Row(
  children: [
    Expanded(
      child: ListTile(
        dense: true,
        leading: Radio(
          value: "Artist",
          activeColor: const Color.fromARGB(255, 232, 240, 217),
          groupValue: selectedRole,
          onChanged: (value) {
            setState(() {
              selectedRole = value;
            });
          },
        ),
        title: const Flexible(
          child: Text(
            "Artist",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color.fromARGB(246, 252, 251, 251),
            ),
          ),
        ),
      ),
    ),
    Expanded(
      child: ListTile(
        dense: true,
        leading: Radio(
          value: "Recruiter",
          activeColor: const Color.fromARGB(255, 232, 240, 217),
          groupValue: selectedRole,
          onChanged: (value) {
            setState(() {
              selectedRole = value;
            });
          },
        ),
        title: const Flexible(
          child: Text(
            "Recruiter",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color.fromARGB(246, 252, 251, 251),
            ),
          ),
        ),
      ),
    ),
  ],
),
                    SizedBox(height: 30),
                    TextField(
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    TextField(
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    SizedBox(height: 40),
                    TextField(
                      obscureText: _obscurePassword,
                      //obscureText: true,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color.fromARGB(255, 251, 252, 253),
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                            
                          ),
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Color.fromARGB(255, 10, 10, 10),
                          child: IconButton(
                            color: Colors.white,
                            onPressed: () {
                              Navigator.pushNamed(context, 'home');
                            },
                            icon: Icon(Icons.arrow_forward),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
