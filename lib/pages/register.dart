import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafeit_gacor/pages/login.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 
  final _formKey = GlobalKey<FormState>();
  late String email = '';
  late String password = '';
  late String username = '';
  late String phoneNumber = ''; 
  late String status = '';       

  final Color primaryColor = const Color(0xFFF4A261);
  final Color accentColor = const Color(0xFFE9C46A);
  final Color backgroundColor = const Color(0xFFFFF1E6);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(
              color: backgroundColor,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'logo.png',
                          height: size.height * 0.2,
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // Field Username
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Username',
                            prefixIcon: Icon(Icons.person, color: Colors.black87),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          onChanged: (value) {
                            username = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),

                        // Field Email
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.email, color: Colors.black87),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
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
                        const SizedBox(height: 16.0),

                        // Field Phone Number
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone, color: Colors.black87),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          onChanged: (value) {
                            phoneNumber = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),

                        // Dropdown for Status
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: 'Select Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          value: status.isEmpty ? null : status,
                          items: [
                            DropdownMenuItem(
                              value: 'mahasiswa',
                              child: Text('Mahasiswa'),
                            ),
                            DropdownMenuItem(
                              value: 'dosen',
                              child: Text('Dosen'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              status = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Status is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),

                        // Field Password
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock, color: Colors.black87),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
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
                        const SizedBox(height: 24.0),

                        // Register Button
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                final result = await _auth.createUserWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );

                                User? user = result.user;

                                if (user != null) {
                                  await user.updateProfile(displayName: username);
                                  await user.reload();
                                  user = FirebaseAuth.instance.currentUser;

                                  // Store user data in Firestore
                                  await _firestore.collection('users').doc(user!.uid).set({
                                    'username': username,
                                    'email': email,
                                    'phoneNumber': phoneNumber,
                                    'status': status,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginPage()),
                                  );
                                }
                              } catch (e) {
                                String errorMessage = 'An error occurred, please try again.';
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
                            backgroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.1,
                              vertical: 10.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // TextButton for existing users
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          },
                          child: Text(
                            'Already have an account? Log in',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}