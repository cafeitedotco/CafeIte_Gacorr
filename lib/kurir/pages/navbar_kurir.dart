import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cafeite/utils/restapi.dart';
import 'package:cafeite/utils/model.dart';
import 'package:cafeite/kurir/pages/pengiriman.dart';
import 'package:cafeite/kurir/pages/home_kurir.dart';
import 'package:cafeite/kurir/pages/profile_kurir.dart';

class BottomNavigationKurir extends StatelessWidget {
  const BottomNavigationKurir({Key? key}) : super(key: key);

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
                    MaterialPageRoute(builder: (context) => HomePageKurir()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              const Text(
                "Home",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.delivery_dining, size: 30),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PengirimanPage()));
                },
              ),
              const Text(
                "Pesanan Saya",
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
                        builder: (context) => ProfileScreenKurir()),
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