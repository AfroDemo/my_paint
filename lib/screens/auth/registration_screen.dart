import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:my_paint/models/user.dart'; // Import the new User model
import 'package:my_paint/screens/home_screen.dart';
import 'package:my_paint/services/api_service.dart';
import 'package:my_paint/services/database_helper.dart'; // Import the database helper

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  void _registration() async {
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username, email, and password are required."),
        ),
      );
      return;
    }

    // Create the User object
    final user = User(
      userName: username,
      email: email,
      password: password,
      syncStatus: 'pending_create',
    );

    try {
      final connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult != ConnectivityResult.none) {
        // If connected, try to register online first
        final response = await ApiService().registerUser(
          user.userName,
          user.email,
          user.password,
        );

        if (response.statusCode == 201) {
          // Online registration successful! Save the user as synced.
          user.syncStatus = 'synced';
          await DatabaseHelper.instance.insertUser(user.toMap());

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
        } else {
          // Online registration failed (e.g., username taken). Save offline.
          await DatabaseHelper.instance.insertUser(user.toMap());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Online registration failed. Saved offline. Reason: ${response.body}',
              ),
            ),
          );
        }
      } else {
        // No internet connection, save offline directly.
        await DatabaseHelper.instance.insertUser(user.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet. Registration saved offline.'),
          ),
        );
      }

      // Always navigate to the home screen after handling registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _registration,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
