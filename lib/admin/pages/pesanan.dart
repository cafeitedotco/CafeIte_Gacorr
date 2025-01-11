import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cafeite/utils/model.dart';
import 'package:cafeite/utils/restapi.dart';
import 'package:cafeite/config.dart';

class PesananAdmin extends StatefulWidget {
  const PesananAdmin({Key? key}) : super(key: key);

  @override
  _PesananAdminState createState() => _PesananAdminState();
}

class _PesananAdminState extends State<PesananAdmin> {
  List<PesananModel> pesanan = [];
  DataService ds = DataService();

  @override
  void initState() {
    super.initState();
    fetchAllPesanan();
  }

  Future<void> fetchAllPesanan() async {
    try {
      String response = await ds.selectAll(token, project, 'pesanan', appid);
      List data = jsonDecode(response);

      setState(() {
        pesanan = data.map((e) => PesananModel.fromJson(e)).toList();
      });
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan Customer"),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7EED3),
      ),
      body: pesanan.isEmpty
          ? const Center(child: Text("Belum ada pesanan."))
          : ListView.builder(
              itemCount: pesanan.length,
              itemBuilder: (context, index) {
                final order = pesanan[index];
                return buildOrderCard(
                  order.pesanan_yang_di_pesan,
                  order.subtotal,
                  order.pembayaran,
                  order.status_pesanan,
                );
              },
            ),
    );
  }

  Widget buildOrderCard(
      String pesanan, String subtotal, String image, String status) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Column(
        children: [
          ListTile(
            leading: Image.network(image, height: 50, width: 50),
            title: Text(pesanan,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Subtotal: $subtotal\nStatus: $status"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  print("Lihat detail untuk $pesanan");
                },
                child: const Text("Detail"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
