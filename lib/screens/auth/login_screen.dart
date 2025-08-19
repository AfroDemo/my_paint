import 'package:flutter/material.dart';
import 'package:my_paint/screens/home_screen.dart';
import 'package:my_paint/services/api_service.dart';
import 'package:my_paint/services/database_helper.dart';
import 'package:my_paint/models/user.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password are required.")),
      );
      return;
    }

    try {
      final response = await ApiService().loginUser(email, password);

      if (response.statusCode == 200) {
        // Login successful. We should save the user data locally.
        final userData = jsonDecode(response.body);
        final user = User(
          remoteId: userData['id'],
          userName: userData['username'],
          email: userData['email'],
          password: password, // For simplicity, we save the password
          syncStatus: 'synced',
        );

        // This is a new method we'll add to DatabaseHelper to check if a user is already logged in locally.
        await DatabaseHelper.instance.insertUser(user.toMap());

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));

        // Navigate to the home screen, replacing the login screen in the stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            ElevatedButton(onPressed: _login, child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}
