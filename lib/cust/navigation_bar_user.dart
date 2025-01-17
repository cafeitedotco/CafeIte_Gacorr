import 'package:cafeite/cust/pages/home_user.dart';
import 'package:cafeite/cust/pages/profile_user.dart';
import 'package:cafeite/cust/pages/pesanan_saya.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BottomNavigationUser extends StatelessWidget {
  const BottomNavigationUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xFFF7EED3),
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.home, size: 30),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePageUser()),
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
                icon: const Icon(Icons.shopping_basket, size: 30),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => PesananSaya()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              const Text(
                "Pesanan Saya",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.person, size: 30),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileScreenUser()),
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
