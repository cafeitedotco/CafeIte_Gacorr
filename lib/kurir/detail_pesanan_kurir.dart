import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cafeite/utils/restapi_pesanan.dart';
import 'package:cafeite/utils/model.dart';
import 'package:cafeite/config.dart';
import 'package:cafeite/kurir/pengiriman.dart';

class DetailPesananKurir extends StatefulWidget {
  const DetailPesananKurir({Key? key}) : super(key: key);

  @override
  DetailPesananKurirState createState() => DetailPesananKurirState();
}

class DetailPesananKurirState extends State<DetailPesananKurir> {
  DataService ds = DataService();

  late ValueNotifier<int> _notifier;

  List<PesananModel> pesanan = [];
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _notifier = ValueNotifier<int>(0);
  }

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as List<String>;
      _future = reloadDataPesanan(args[0]);
      _isInitialized = true;
    }
  }

  selectIdPesanan(String id) async {
    print("Fetching data for id: $id");
    List data =
        jsonDecode(await ds.selectId(token, project, 'pesanan', appid, id));
    print("Data fetched: $data");
    pesanan = data.map((e) => PesananModel.fromJson(e)).toList();
  }

  Future reloadDataPesanan(dynamic value) async {
    final args = ModalRoute.of(context)?.settings.arguments as List<String>;
    List data = jsonDecode(
        await ds.selectId(token, project, 'pesanan', appid, args[0]));
    setState(() {
      pesanan = data.map((e) => PesananModel.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan"),
        elevation: 0,
        actions: <Widget>[],
      ),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Text('None');
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              return const Text("Active");
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text(
                  '${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                );
              } else {
                if (pesanan.isEmpty) {
                  return const Center(child: Text('No data found.'));
                }
                return ListView(
                  children: [
                    // Bagian Header Gambar
                    Card(
                      child: ListTile(
                        title: Text(pesanan[0].userid),
                        subtitle: const Text(
                          "id user",
                          style: TextStyle(color: Colors.black54),
                        ),
                        leading: IconButton(
                          icon: const Icon(
                            Icons.tips_and_updates_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Text(pesanan[0].alamat),
                        subtitle: const Text(
                          "Alamat",
                          style: TextStyle(color: Colors.black54),
                        ),
                        leading: IconButton(
                          icon: const Icon(
                            Icons.filter_vintage_sharp,
                            color: Colors.grey,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Text(pesanan[0].pembayaran),
                      ),
                    ),
                  ],
                );
              }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }
}
