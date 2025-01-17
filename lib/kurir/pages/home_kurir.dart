import 'package:flutter/material.dart';
import 'package:cafeite/kurir/pages/navbar_kurir.dart';
import 'package:cafeite/kurir/pages/pengiriman.dart'; // Pastikan Anda mengimpor halaman tujuan

class HomePageKurir extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF4A261),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', // Ganti dengan path logo Anda
              height: 100,
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to the Kurir Home Page!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'pengirimanpage');
              },
              child: Text('Delivery'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationKurir(),
    );
  }
}
