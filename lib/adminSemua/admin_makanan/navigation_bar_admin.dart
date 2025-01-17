// ignore_for_file: unused_import, unnecessary_import

import 'package:cafeite/adminSemua/admin_makanan/pages/home_admin.dart';
import 'package:cafeite/adminSemua/admin_makanan/pages/profile_admin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cafeite/utils/restapi.dart';
import 'package:cafeite/utils/model.dart';
import 'package:cafeite/adminSemua/admin_makanan/pages/pesanan.dart';
import 'package:cafeite/adminSemua/admin_makanan/pages/dashboard.dart';

class BottomNavigationAdminMakanan extends StatelessWidget {
  const BottomNavigationAdminMakanan({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home Button
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.home, size: 30),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardMakanan()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              const Text(
                "Dashboard",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.fastfood, size: 30),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePageAdminMakanan()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              const Text(
                "Makanan",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),

          // Pesanan Saya Button
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_basket, size: 30),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PesananAdmin()));
                },
              ),
              const Text(
                "Pesanan",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),

          // Profile Button
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.person, size: 30),
                onPressed: () {
                  // Uncomment and replace with your ProfileScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileScreenAdminMakanan()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              const Text(
                "Profile",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Function to show the insert dialog
