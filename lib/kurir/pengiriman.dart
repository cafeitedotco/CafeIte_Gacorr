import 'package:flutter/material.dart';
import 'package:cafeite/kurir/navbar_kurir.dart';

class PengirimanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Pengiriman',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Nama Penerima: John Doe',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Alamat: Jl. Kebon Jeruk No. 123, Jakarta',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Nomor Telepon: 08123456789',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Status: Dalam Pengiriman',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Tambahkan aksi yang diinginkan di sini
              },
              child: Text('Update Status'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationKurir(),
    );
  }
}
