import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'register_screen.dart';
import 'update_screen.dart';
import 'constants.dart';

class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key}); 

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  /// Sends login request to the backend and navigates to update screen on success.
  Future<void> _login() async {
    // Client-side validation
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Email cannot be empty';
      });
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Password cannot be empty';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.backendUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if the widget is still mounted before navigating
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateScreen(token: data['access_token']),
          ),
        );
        setState(() {
          _errorMessage = 'Login successful!';
        });
      } else {
        // Handle FastAPI error response
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('detail')) {
            final detail = errorData['detail'];
            if (detail is List && detail.isNotEmpty) {
              // Handle validation errors (e.g., invalid email)
              final errors = detail
                  .where((e) => e['msg'] != null)
                  .map((e) => e['msg'] as String)
                  .join(', ');
              setState(() {
                _errorMessage = errors.contains('email')
                    ? 'Please enter a valid email address'
                    : errors.isEmpty
                    ? 'Invalid input'
                    : errors;
              });
            } else if (detail is String) {
              setState(() {
                _errorMessage = detail;
              });
            } else {
              setState(() {
                _errorMessage = 'Unexpected error format';
              });
            }
          } else {
            setState(() {
              _errorMessage = errorData['detail'] ?? 'Invalid credentials';
            });
          }
        } catch (e) {
          setState(() {
            _errorMessage = 'Error: Unable to process server response';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    }
  }

  /// Navigates to the registration screen.
  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: AppStyles.titleText),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign In',
                style: AppStyles.titleText,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: AppStyles.textFieldDecoration.copyWith(
                  labelText: 'Email',
                  labelStyle: AppStyles.labelText,
                  errorText: _errorMessage.contains('email') ? _errorMessage : null,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: AppStyles.textFieldDecoration.copyWith(
                  labelText: 'Password',
                  labelStyle: AppStyles.labelText,
                  errorText: _errorMessage.contains('Password') ? _errorMessage : null,
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: AppStyles.elevatedButtonStyle,
                child: Text('Login'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: _goToRegister,
                child: Text(
                  'Don\'t have an account? Register',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
              SizedBox(height: 20),
              Text(_errorMessage, style: AppStyles.errorText),
            ],
          ),
        ),
      ),
    );
  }
}