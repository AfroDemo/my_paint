import 'package:flutter/material.dart';
import 'package:my_paint/models/user.dart'; // Import the new User model
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

    // Create a new User object with a 'pending_create' status
    final user = User(
      userName: username,
      email: email,
      password: password,
      syncStatus: 'pending_create',
    );

    try {
      // Save the user data to the local database
      await DatabaseHelper.instance.insertUser(user.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration saved offline!')),
      );

      // Navigate back to the home screen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving user data locally: $e')),
      );
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
