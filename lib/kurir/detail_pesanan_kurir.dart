import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cafeite/utils/restapi_pesanan.dart';
import 'package:cafeite/utils/model.dart';
import 'package:cafeite/config.dart';
import 'package:cafeite/kurir/registerpage_kurir.dart';

class DetailPesananKurir extends StatefulWidget {
  final PesananModel item;

  DetailPesananKurir({required this.item});

  @override
  _DetailPesananKurirState createState() => _DetailPesananKurirState();
}

class _DetailPesananKurirState extends State<DetailPesananKurir> {
  String username = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pesanan"),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              title: Text(username),
              subtitle: const Text(
                "Nama",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(widget.item.pesanan_yang_di_pesan ?? 'Unknown Order'),
              subtitle: const Text(
                "Pesanan",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(widget.item.alamat ?? 'Unknown Address'),
              subtitle: const Text(
                "Alamat",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(widget.item.pembayaran ?? 'Unknown Payment'),
              subtitle: const Text(
                "Metode pembayaran",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(widget.item.status_pesanan ?? 'Unknown Status'),
              subtitle: const Text(
                "Status Pesanan",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
