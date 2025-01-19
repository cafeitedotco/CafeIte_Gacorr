import 'package:cafeite/adminSemua/admin_makanan/navigation_bar_admin.dart';
import 'package:cafeite/adminSemua/admin_makanan/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafeite/adminSemua/admin_makanan/navigation_bar_admin.dart';
import 'package:cafeite/adminSemua/admin_makanan/pages/dashboard.dart'; // Import your Dashboard class

class ProfileScreenAdminMakanan extends StatefulWidget {
  const ProfileScreenAdminMakanan({Key? key}) : super(key: key);

  @override
  _ProfileScreenAdminMakananState createState() =>
      _ProfileScreenAdminMakananState();
}

class _ProfileScreenAdminMakananState extends State<ProfileScreenAdminMakanan> {
  User? user;
  String username = '';
  String phoneNumber = '';
  String status = '';

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (snapshot.exists) {
        var userData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          username = userData['username'] ?? 'No Username';
          phoneNumber = userData['phoneNumber'] ?? 'No Phone';
          status = userData['status'] ?? 'No Status';
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
      'username': username,
      'phoneNumber': phoneNumber,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7EED3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardMakanan()),
            );
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF7EED3),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30.0)),
              ),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.orange,
                    child: Text(
                      user?.email?.substring(0, 1).toUpperCase() ?? '',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Email Display
                  Text(
                    user?.email ?? 'No Email',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // User Info
            Column(
              children: [
                _buildInfoCard(
                  title: 'Username',
                  subtitle: username,
                  icon: Icons.person,
                ),
                _buildInfoCard(
                  title: 'No Handphone',
                  subtitle: phoneNumber,
                  icon: Icons.phone,
                ),
                _buildInfoCard(
                  title: 'Status',
                  subtitle: status,
                  icon: Icons.info,
                ),
                const SizedBox(height: 40), // Space below the status card
              ],
            ),

            // Logout Button
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
              child: SizedBox(
                width: double.infinity, // Make the button full width
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamed(context, 'landingpage');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 143, 20, 12), // Background color
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationAdminMakanan(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEditDialog(context);
        },
        child: const Icon(Icons.edit),
        backgroundColor: const Color(0xFF915A5A), // Change to specified color
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController usernameController =
        TextEditingController(text: username);
    final TextEditingController phoneNumberController =
        TextEditingController(text: phoneNumber);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit User Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: phoneNumberController,
                decoration: const InputDecoration(labelText: "No Handphone"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Update user data
                setState(() {
                  username = usernameController.text;
                  phoneNumber = phoneNumberController.text;
                });
                await _updateUserData(); // Save to Firestore
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EED3), // Change background color
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 24), // Icon on the left
          const SizedBox(width: 16), // Space between icon and text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
