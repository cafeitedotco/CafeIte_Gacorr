import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafeit_gacor/utils/fire_auth.dart';
import 'package:cafeit_gacor/config.dart'; //CONFIG
import 'package:cafeit_gacor/utils/model.dart'; //MODEL
import 'package:cafeit_gacor/utils/restapi.dart'; //API

import 'package:cafeit_gacor/user/navigation_bar.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final searchKeyword = TextEditingController();
  bool searchStatus = false;

  DataService ds = DataService();

  List data = [];
  List<MakananberatModel> makananberat = [];

  List<MakananberatModel> search_data = [];
  List<MakananberatModel> search_data_pre = [];

  selectAllMakananberat() async {
    data =
        jsonDecode(await ds.selectAll(token, project, 'makananberat', appid));
    makananberat = data.map((e) => MakananberatModel.fromJson(e)).toList();

    //refresh the UI
    setState(() {
      makananberat = makananberat;
    });
  }

  //SEARCHING FUNCTION
  void filterMakananberat(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      search_data = data.map((e) => MakananberatModel.fromJson(e)).toList();
    } else {
      search_data_pre = data.map((e) => MakananberatModel.fromJson(e)).toList();
      search_data = search_data_pre
          .where((user) =>
              user.nama.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    //refresh the UI
    setState(() {
      makananberat = search_data;
    });
  }

  //future reload data makananberat
  Future reloadDataMakananberat(dynamic value) async {
    setState(() {
      selectAllMakananberat();
    });
  }

  @override
  void initState() {
    selectAllMakananberat(); // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF7EED3),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Text(
              "CafeITe's Menu",
              style: TextStyle(fontSize: 20),
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => CartPage(
                //               cartItems: cartItems,
                //             )));
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchKeyword,
              onChanged: (value) => filterMakananberat(value),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF7EED3),
                hintText: 'Mau makan apa niiiih?',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Filter Makanan Berat
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.fastfood,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Makanan Berat",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Filter Snack
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Snack"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 13,
                mainAxisSpacing: 8.0,
              ),
              itemCount: makananberat.length,
              itemBuilder: (context, index) {
                final item = makananberat[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nama,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.harga,
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            onPressed: () {
                              // Add to cart functionality
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationUser(),
    );
  }
}
