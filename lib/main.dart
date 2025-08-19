// lib/main.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_paint/models/user.dart';
import 'package:my_paint/screens/auth/login_screen.dart';
import 'package:my_paint/screens/home_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_paint/services/database_helper.dart';

void main() {
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
      home: FutureBuilder<User?>(
        future: DatabaseHelper.instance.getSyncedUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data != null) {
            // User is already logged in and synced.
            return const HomeScreen();
          } else {
            // No synced user found locally, show the login screen.
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
