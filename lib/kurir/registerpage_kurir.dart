// 992024006 Masyitah Nanda Yassril

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafeite/kurir/loginpage_kurir.dart';

class RegisterPageKurir extends StatefulWidget {
  @override
  _RegisterPageKurirState createState() => _RegisterPageKurirState();
}

class _RegisterPageKurirState extends State<RegisterPageKurir> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveSession() async {
    // Implement your session saving logic here
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Color(0xFFFFF1E6),
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('logo.png', height: 80.0),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                              hintText: 'Email',
                              filled: true,
                              fillColor: Colors.grey[200],
                              prefixIcon:
                                  Icon(Icons.mail, color: Colors.black87),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              )),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                              hintText: 'Username',
                              filled: true,
                              fillColor: Colors.grey[200],
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.black87),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              )),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            hintText: 'Phone',
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon:
                                Icon(Icons.phone, color: Colors.black87),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.lock, color: Colors.black87),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
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
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.lock, color: Colors.black87),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24.0),
                        // Register Button
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                final email = _emailController.text.trim();
                                final password =
                                    _passwordController.text.trim();
                                final username =
                                    _usernameController.text.trim();
                                final phoneNumber =
                                    _phoneNumberController.text.trim();

                                final result =
                                    await _auth.createUserWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );

                                User? user = result.user;
                                if (user != null) {
                                  await user.updateProfile(
                                      displayName: username);
                                  await user.reload();

                                  await _firestore
                                      .collection('users')
                                      .doc(user.uid)
                                      .set({
                                    'username': username,
                                    'email': email,
                                    'phoneNumber': phoneNumber,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPageKurir()),
                                  );
                                }
                              } catch (e) {
                                String errorMessage =
                                    'An error occurred, please try again.';
                                if (e is FirebaseAuthException) {
                                  errorMessage = e.message ?? errorMessage;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMessage)),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF4A261),
                            padding: EdgeInsets.symmetric(
                              horizontal: 400,
                              vertical: 20.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // TextButton for existing users
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPageKurir()),
                            );
                          },
                          child: Text(
                            'Already have an account? Log in',
                            style: TextStyle(
                              color: Color(0xFFF4A261),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
