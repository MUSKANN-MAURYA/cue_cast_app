import 'package:cue_cast_app/api/firebase_api.dart';
import 'package:cue_cast_app/pages/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:cue_cast_app/pages/home.dart';
import 'package:cue_cast_app/pages/login.dart';
//import 'package:cue_cast_app/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final  navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://efywhwvswzqzhoshndez.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVmeXdod3Zzd3pxemhvc2huZGV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5MTcyOTMsImV4cCI6MjA2MTQ5MzI5M30.zd0tyJL6VfmUbOnmfEl5mLWQXawnYAAXImW3tFXy4rg',
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseApi().initNotifications();
  

  

  runApp(MaterialApp(home: AuthWrapper(), debugShowCheckedModeBanner: false,
  navigatorKey: navigatorKey,
  routes:{
    '/notifications': (context) => const NotificationScreen(),
  }),
  );
}



class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in
          final user = snapshot.data!;
          // Fetch user role from Firestore if needed
          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
              return HomeScreen(
                userId: user.uid,
                role: userData['role'] ?? 'Artist',
              );
            },
          );
        }
        // User not logged in
        return MyLogin();
      },
    );
  }
}
