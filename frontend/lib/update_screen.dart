import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'login_screen.dart';
import 'constants.dart';

class UpdateScreen extends StatefulWidget {
  final String token; // JWT token from login

  const UpdateScreen({super.key, required this.token});

  @override
  UpdateScreenState createState() => UpdateScreenState();
}

class UpdateScreenState extends State<UpdateScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _email = '';
  String _message = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch user details when the screen loads
    _fetchUserDetails();
  }

  /// Fetches current user details from the backend and populates the UI.
  Future<void> _fetchUserDetails() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.backendUrl}/user/me'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _email = data['email'] ?? '';
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text = data['last_name'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _message = 'Error fetching user details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  /// Validates inputs and sends profile update request to the backend.
  Future<void> _updateUser() async {
    // Client-side validation
    if (_firstNameController.text.trim().isEmpty) {
      setState(() {
        _message = 'First name cannot be empty';
      });
      return;
    }
    if (_lastNameController.text.trim().isEmpty) {
      setState(() {
        _message = 'Last name cannot be empty';
      });
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('${Config.backendUrl}/user/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          _message = 'User updated successfully!';
        });
      } else {
        try {
          final errorData = jsonDecode(response.body);
          setState(() {
            _message = errorData['detail'] ?? 'Error updating user';
          });
        } catch (e) {
          setState(() {
            _message = 'Error: Invalid server response';
          });
        }
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  /// Logs out the user and navigates to the login screen.
  void _logout() {
    // Clear token (no server-side action needed as JWT is stateless)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile', style: AppStyles.titleText),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Profile',
                      style: AppStyles.titleText,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Email: $_email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _firstNameController,
                      decoration: AppStyles.textFieldDecoration.copyWith(
                        labelText: 'First Name',
                        labelStyle: AppStyles.labelText,
                        errorText: _message.contains('First name') ? _message : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _lastNameController,
                      decoration: AppStyles.textFieldDecoration.copyWith(
                        labelText: 'Last Name',
                        labelStyle: AppStyles.labelText,
                        errorText: _message.contains('Last name') ? _message : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateUser,
                      style: AppStyles.elevatedButtonStyle,
                      child: Text('Update'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _logout,
                      style: AppStyles.elevatedButtonStyle.copyWith(
                        backgroundColor: WidgetStateProperty.all(Colors.red),
                      ),
                      child: Text('Logout'),
                    ),
                    SizedBox(height: 20),
                    Text(_message, style: AppStyles.errorText),
                  ],
                ),
              ),
            ),
    );
  }
}