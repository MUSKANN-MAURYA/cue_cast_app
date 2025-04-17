import 'package:flutter/material.dart';
import 'package:cue_cast_app/pages/login.dart';
import 'package:cue_cast_app/pages/register.dart';
import 'package:cue_cast_app/pages/home.dart';


void main() {
  runApp(
    MaterialApp(
      initialRoute: 'login',
      routes: {
        'login': (context) => MyLogin(),
        'register': (context) => MyRegister(),
        'home': (context) => HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    ),
  );
}

