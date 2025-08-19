// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://192.168.1.150:8080';

  // Method to register a new user
  // Now takes username, email, and password
  Future<http.Response> registerUser(
    String username,
    String email,
    String password,
  ) {
    return http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username, // Added username to the JSON body
        'email': email,
        'password': password,
      }),
    );
  }

  Future<http.Response> loginUser(String email, String password) {
    return http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );
  }
}
