import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:my_paint/models/user.dart';
import 'package:my_paint/screens/auth/login_screen.dart';
import 'package:my_paint/screens/home_screen.dart';
import 'package:my_paint/screens/auth/registration_screen.dart';
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
      home: FutureBuilder<bool>(
        future: DatabaseHelper.instance.hasUserRegistered(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!) {
            // A user exists locally, proceed with the synced user check.
            return FutureBuilder<User?>(
              future: DatabaseHelper.instance.getSyncedUser(),
              builder: (context, syncedSnapshot) {
                if (syncedSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (syncedSnapshot.hasData && syncedSnapshot.data != null) {
                  // User is synced, go to home screen
                  return const HomeScreen();
                } else {
                  // User is pending, show the LoginScreen to allow them to sync.
                  return const LoginScreen();
                }
              },
            );
          } else {
            // No user found locally, check for internet connection
            return FutureBuilder<ConnectivityResult>(
              future: Connectivity().checkConnectivity(),
              builder: (context, connectivitySnapshot) {
                if (connectivitySnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (connectivitySnapshot.hasData &&
                    connectivitySnapshot.data != ConnectivityResult.none) {
                  // No local user, but we are online. Go to login screen.
                  return const LoginScreen();
                } else {
                  // No local user and no internet. Go to registration screen.
                  return const RegistrationScreen();
                }
              },
            );
          }
        },
      ),
    );
  }
}
