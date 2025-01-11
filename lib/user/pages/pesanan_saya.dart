import 'package:cafeite/user/pages/tracking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:cafeite/user/navigation_bar_user.dart';
import 'package:cafeite/utils/restapi_pesanan.dart';
import 'package:cafeite/utils/model.dart';
import 'package:cafeite/config.dart';

class PesananSaya extends StatefulWidget {
  const PesananSaya({Key? key}) : super(key: key);

  @override
  _PesananSayaState createState() => _PesananSayaState();
}

class _PesananSayaState extends State<PesananSaya> {
  List<PesananModel> pesanan = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DataService ds = DataService(); // Firebase Auth instance

  @override
  void initState() {
    super.initState();
    selectAllPesanan(); // Fetch orders when the widget is initialized
  }

  Future<void> selectAllPesanan() async {
    String? userId = _auth.currentUser?.uid; // Get the current user ID

    if (userId != null) {
      // Fetch orders for the specific user
      String response = await ds.selectAll(token, project, 'pesanan', appid);
      List data = jsonDecode(response);

      // Filter orders for the current user
      pesanan = data
          .where((pesanan) =>
              pesanan['userId'] ==
              userId) // Assuming userId is stored in each order
          .map((e) => PesananModel.fromJson(e))
          .toList();

      // Refresh the UI
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF7EED3),
        title: const Text("Pesanan Saya"),
      ),
      bottomNavigationBar: BottomNavigationUser(),
      body: pesanan.isEmpty
          ? Center(child: Text("Tidak ada pesanan."))
          : ListView.builder(
              itemCount: pesanan.length,
              itemBuilder: (context, index) {
                final order = pesanan[index];
                return buildOrderCard(order.pesanan_yang_di_pesan,
                    order.subtotal, order.pembayaran);
              },
            ),
    );
  }
}

Widget buildOrderCard(
    String pesanan_yang_di_pesan, String subtotal, String image) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 4,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  image,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pesanan_yang_di_pesan,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subtotal,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              // Handle button press action
              print("Button pressed for $pesanan_yang_di_pesan!");
            },
            child: Text("Detail"),
          ),
        ),
      ],
    ),
  );
}
