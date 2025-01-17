import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cafeite/kurir/pages/home_kurir.dart';
import 'package:cafeite/kurir/pages/registerpage.dart';
import 'package:cafeite/adminSemua/admin_makanan/pages/home_admin.dart';
import 'package:cafeite/cust/pages/home_user.dart';
import 'package:cafeite/adminSemua/register.dart';

class LoginPageKurir extends StatefulWidget {
  @override
  _LoginPageKurirState createState() => _LoginPageKurirState();
}

class _LoginPageKurirState extends State<LoginPageKurir> {
  final _formKey = GlobalKey<FormState>();
  late String _email;
  late String _password;

  // Theme colors
  final Color _primaryColor = const Color(0xFFF4A261);
  final Color _backgroundColor = const Color(0xFFFFF1E6);

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
  }

  Future<void> _showErrorSnackBar(String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('logo.png', height: 150),
                const SizedBox(height: 20.0),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Selamat Datang di CafeIte',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 20.0),
                _buildTextField(
                  hintText: 'Email',
                  prefixIcon: Icons.email,
                  isObscure: false,
                  onChanged: (value) => _email = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                _buildTextField(
                  hintText: 'Password',
                  prefixIcon: Icons.lock,
                  isObscure: true,
                  onChanged: (value) => _password = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                _buildLoginButton(),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegisterPageKurir()),
                  ),
                  child: Text(
                    'Don’t have an account? Register here',
                    style: TextStyle(color: _primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData prefixIcon,
    required bool isObscure,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return SizedBox(
      width: 800,
      child: TextFormField(
        obscureText: isObscure,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          prefixIcon: Icon(prefixIcon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: 800,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            try {
              final userCredential = await FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                      email: _email, password: _password);

              await _saveSession();

              final nextPage = userCredential.user != null
                  ? HomePageKurir()
                  : HomePageUser();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => nextPage),
                (route) => false,
              );
            } on FirebaseAuthException catch (e) {
              String errorMessage;
              if (e.code == 'user-not-found') {
                errorMessage = 'No user found with this email.';
              } else if (e.code == 'wrong-password') {
                errorMessage = 'Incorrect password.';
              } else {
                errorMessage = 'An error occurred. Please try again.';
              }
              _showErrorSnackBar(errorMessage);
            }
          }
        },
        child: const Text(
          'LOGIN',
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ),
    );
  }
}
