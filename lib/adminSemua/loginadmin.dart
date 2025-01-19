import 'package:cafeite/adminSemua/admin_makanan/pages/dashboard.dart';
import 'package:cafeite/adminSemua/admin_minuman/pages/dashboard.dart';
import 'package:cafeite/adminSemua/admin_snack/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth package
import 'package:cafeite/adminSemua/admin_snack/pages/home_admin.dart';
import 'package:cafeite/adminSemua/admin_makanan/pages/home_admin.dart';
import 'package:cafeite/adminSemua/admin_minuman/pages/home_admin.dart';
import 'package:cafeite/cust/pages/home_user.dart';
import 'package:cafeite/adminSemua/register.dart';

class LoginPageAdmin extends StatefulWidget {
  @override
  _LoginPageAdminState createState() => _LoginPageAdminState();
}

class _LoginPageAdminState extends State<LoginPageAdmin> {
  final _formKey = GlobalKey<FormState>();
  late String email;
  late String password;

  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

  // Theme colors
  final Color primaryColor = const Color(0xFF8B0000);
  final Color backgroundColor = const Color(0xFFF7EED3);

  // Function to save login status
  Future<void> _saveSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'logo.png',
                  height: 150,
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Selamat Datang di CafeIte\nLogin Anda Sebagai Admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 40.0),
                _buildEmailField(),
                const SizedBox(height: 20.0),
                _buildPasswordField(),
                const SizedBox(height: 30.0),
                _buildLoginButton(),
                const SizedBox(height: 20.0),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return SizedBox(
      width: 800,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Email',
          prefixIcon: Icon(Icons.email),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          email = value;
        },
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
    );
  }

  Widget _buildPasswordField() {
    return SizedBox(
      width: 800,
      child: TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Password',
          prefixIcon: Icon(Icons.lock),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          password = value;
        },
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
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: 800,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            try {
              UserCredential userCredential =
                  await _auth.signInWithEmailAndPassword(
                email: email,
                password: password,
              );

              await _saveSession();

              // Navigate to the appropriate page based on the tenant
              switch (email) {
                case 'tenant1@gmail.com':
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardMakanan()),
                    (Route<dynamic> route) => false,
                  );
                  break;
                case 'tenant2@gmail.com':
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardMinuman()),
                    (Route<dynamic> route) => false,
                  );
                  break;
                case 'tenant3@gmail.com':
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardSnack()),
                    (Route<dynamic> route) => false,
                  );
                  break;
              }
            } on FirebaseAuthException catch (e) {
              String message;
              if (e.code == 'user-not-found') {
                message = 'No user found for that email.';
              } else if (e.code == 'wrong-password') {
                message = 'Wrong password provided for that user.';
              } else {
                message = 'Login failed. Please try again.';
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            }
          }
        },
        child: Text(
          'LOGIN',
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterPage(),
          ),
        );
      },
      child: Text(
        'Don’t have an account? Register here',
        style: TextStyle(color: primaryColor),
      ),
    );
  }
}
