import 'package:cafeite/user/navigation_bar_user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreenUser extends StatelessWidget {
  const ProfileScreenUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('Tidak ada data pengguna ditemukan');
                }

                var userData = snapshot.data!.data() as Map<String, dynamic>;
                String username =
                    userData['username'] ?? 'Tidak Ada Nama Pengguna';
                String status = userData['status'] ?? 'Tidak Ada Status';
                String email = user?.email ?? 'Tidak Ada Email';

                return Column(
                  children: [
                    Text(
                      username,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      status,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                );
              },
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Riwayat Pesanan',
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Pengaturan',
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.help,
                    title: 'Bantuan',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationUser(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('is_logged_in');

          Navigator.pushNamed(context, 'login_page');
        },
        child: const Icon(Icons.logout),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
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
          const SizedBox(width: 16),
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
