import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:cafeite/kurir/pages/navbar_kurir.dart';

class ProfileScreenKurir extends StatelessWidget {
  const ProfileScreenKurir({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mengambil pengguna saat ini
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // Tambahkan SingleChildScrollView untuk scrollable
        child: Column(
          children: [
            // Gambar Profil
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

            // Informasi Pengguna
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
                String email = user?.email ?? 'Tidak Ada Email';

                return Column(
                  children: [
                    Text(
                      username,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                );
              },
            ),

            // Menu Item
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Riwayat Pengiriman',
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // Keluar dari pengguna
                      await FirebaseAuth.instance
                          .signOut(); // Keluar dari Firebase

                      // Hapus status login
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.remove('is_logged_in');

                      // Navigasi ke halaman login
                      Navigator.pushReplacementNamed(context, 'landingpage');
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationKurir(),
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
