import 'dart:convert';
import 'package:cafeite/config.dart';
import 'package:flutter/material.dart';
import 'package:cafeite/kurir/pages/navbar_kurir.dart';
import 'package:cafeite/utils/model.dart';
import 'package:cafeite/utils/restapi_pesanan.dart';
import 'package:cafeite/kurir/pages/detail_pesanan_kurir.dart';

class PengirimanPage extends StatefulWidget {
  @override
  _PengirimanPageState createState() => _PengirimanPageState();
}

class _PengirimanPageState extends State<PengirimanPage> {
  final searchKeyword = TextEditingController();
  bool searchStatus = false;

  DataService ds = DataService();

  List data = [];
  List<PesananModel> cafeite = [];
  List<PesananModel> completedOrders = [];

  List<PesananModel> search_data = [];
  List<PesananModel> search_data_pre = [];

  selectAll() async {
    data = jsonDecode(await ds.selectAll(token, project, 'pesanan', appid));

    cafeite = data.map((e) => PesananModel.fromJson(e)).toList();

    setState(() {
      cafeite = cafeite;
    });
  }

  void filterPesanan(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      search_data = data.map((e) => PesananModel.fromJson(e)).toList();
    } else {
      search_data_pre = data.map((e) => PesananModel.fromJson(e)).toList();
      search_data = search_data_pre
          .where((user) =>
              user.alamat.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      cafeite = search_data;
    });
  }

  @override
  void initState() {
    selectAll();
    super.initState();
  }

  void removeItem(int index) {
    setState(() {
      cafeite.removeAt(index);
    });
  }

  void acceptItem(int index) {
    setState(() {
      final item = cafeite.removeAt(index);
      completedOrders.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF4A261),
        title: Container(
          width: double.infinity,
          height: 40,
          child: searchField(),
        ),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pesanan Masuk',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: cafeite.length,
                itemBuilder: (context, index) {
                  final item = cafeite[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nama:  ${item.userid}',
                                style: TextStyle(fontSize: 12),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        cafeite.removeAt(index);
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.cancel),
                                        SizedBox(width: 4),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Notification'),
                                            content: Text(
                                                'Pesanan dari ${item.userid} diterima'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  setState(() {
                                                    final item =
                                                        cafeite.removeAt(index);
                                                    completedOrders.add(item);
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle),
                                        SizedBox(width: 4),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Alamat: ${item.alamat}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'List Pesanan',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: completedOrders.length,
                itemBuilder: (context, index) {
                  final item = completedOrders[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nama: ${item.userid}',
                                style: TextStyle(fontSize: 12),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPesananKurir(
                                        item: item,
                                      ),
                                    ),
                                  );
                                },
                                label: Text('Detail'),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Alamat: ${item.alamat}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationKurir(),
    );
  }

  Widget searchField() {
    return TextField(
      controller: searchKeyword,
      autofocus: true,
      cursorColor: Colors.black54,
      style: const TextStyle(color: Colors.black54, fontSize: 14),
      textInputAction: TextInputAction.search,
      onChanged: (value) => filterPesanan(value),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Enter to Search',
        hintStyle: TextStyle(
          color: Colors.black54,
          fontSize: 14,
        ),
        prefixIcon: Icon(Icons.search, color: Colors.black54),
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
