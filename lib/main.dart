import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_paint/screens/auth/registration_screen.dart';
import 'package:my_paint/screens/home_screen.dart';
import 'package:my_paint/services/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  //User sqflite_common_ffi only for desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Paint',
      theme: ThemeData(primarySwatch: Colors.teal),
      // Use a FutureBuilder to check for a user on startup
      home: FutureBuilder<bool>(
        future: DatabaseHelper.instance.hasUserRegistered(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data!) {
            // User exists, show the home screen
            return const HomeScreen();
          } else {
            // No user found, show the registration screen
            return const RegistrationScreen();
          }
        },
      ),
    );
  }
}
