import 'dart:convert';
import 'package:cafeite/config.dart';
import 'package:flutter/material.dart';
import 'package:cafeite/kurir/navbar_kurir.dart';
import 'package:cafeite/utils/model.dart';
import 'package:cafeite/utils/restapi_pesanan.dart';

class PengirimanPage extends StatefulWidget {
  const PengirimanPage({Key? key}) : super(key: key);

  @override
  PengirimanPageState createState() => PengirimanPageState();
}

class PengirimanPageState extends State<PengirimanPage> {
  final searchKeyword = TextEditingController();
  bool searchStatus = false;

  DataService ds = DataService();

  List data = [];
  List<PesananModel> cafeite = [];

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
      body: ListView.builder(
        itemCount: cafeite.length,
        itemBuilder: (context, index) {
          final item = cafeite[index];

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama Penerima: ${item.userid}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Alamat: ${item.alamat}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        },
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
