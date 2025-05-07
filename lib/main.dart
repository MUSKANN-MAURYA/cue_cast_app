import 'package:flutter/material.dart';
import 'package:cue_cast_app/pages/login.dart';
import 'package:cue_cast_app/pages/register.dart';
//import 'package:cue_cast_app/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://efywhwvswzqzhoshndez.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVmeXdod3Zzd3pxemhvc2huZGV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5MTcyOTMsImV4cCI6MjA2MTQ5MzI5M30.zd0tyJL6VfmUbOnmfEl5mLWQXawnYAAXImW3tFXy4rg',
  );
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(
    MaterialApp(
      initialRoute: 'login',
      routes: {
        'login': (context) => MyLogin(),
        'register': (context) => MyRegister(),
        //'home': (context) => HomeScreen(role: 'user'),
      },
      debugShowCheckedModeBanner: false,
    ),
  );
}

