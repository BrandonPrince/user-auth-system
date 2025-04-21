import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'login_screen.dart';
import 'constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _errorMessage = '';

  /// Validates inputs and sends registration request to the backend.
  Future<void> _register() async {
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
    if (_firstNameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'First name cannot be empty';
      });
      return;
    }
    if (_lastNameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Last name cannot be empty';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.backendUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
        }),
      );
      if (response.statusCode == 200) {
        // Check if the widget is still mounted before navigating
        if (!mounted) return;
        // Navigate to login screen on successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        setState(() {
          _errorMessage = 'Registration successful! Please log in.';
        });
      } else {
        // Handle FastAPI error response
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('detail')) {
            final detail = errorData['detail'];
            if (detail is List && detail.isNotEmpty) {
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
              _errorMessage = errorData['detail'] ?? 'Registration failed';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register', style: AppStyles.titleText),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
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
              SizedBox(height: 10),
              TextField(
                controller: _firstNameController,
                decoration: AppStyles.textFieldDecoration.copyWith(
                  labelText: 'First Name',
                  labelStyle: AppStyles.labelText,
                  errorText: _errorMessage.contains('First name') ? _errorMessage : null,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _lastNameController,
                decoration: AppStyles.textFieldDecoration.copyWith(
                  labelText: 'Last Name',
                  labelStyle: AppStyles.labelText,
                  errorText: _errorMessage.contains('Last name') ? _errorMessage : null,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                style: AppStyles.elevatedButtonStyle,
                child: Text('Register'),
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