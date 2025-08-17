import 'package:flutter/material.dart';
import 'package:my_paint/screens/home_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  //initialize FFI for desktop platform like ubuntu
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Paint',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomeScreen(),
    );
  }
}
