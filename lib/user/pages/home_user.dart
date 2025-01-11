import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafeite/utils/fire_auth.dart';
import 'package:cafeite/config.dart'; // CONFIG
import 'package:cafeite/utils/model.dart'; // MODEL
import 'package:cafeite/utils/restapi.dart'; // API
import 'package:cafeite/user/navigation_bar_user.dart';
import 'package:cafeite/user/pages/cart_page.dart';

class HomePageUser extends StatefulWidget {
  const HomePageUser({Key? key}) : super(key: key);

  @override
  HomePageUserState createState() => HomePageUserState();
}

class HomePageUserState extends State<HomePageUser> {
  final searchKeyword = TextEditingController();
  DataService ds = DataService();
  List<MakananberatModel> makananberat = [];
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    selectAllMakananberat();
  }

  void addToCart(String nama, String harga, String image) {
    setState(() {
      cartItems.add(CartItem(nama: nama, harga: harga, image: image));
    });
    print("$nama berhasil ditambah ke keranjang");
  }

  Future<void> selectAllMakananberat() async {
    final response = await ds.selectAll(token, project, 'makananberat', appid);
    List data = jsonDecode(response);

    setState(() {
      makananberat = data.map((e) => MakananberatModel.fromJson(e)).toList();
    });
  }

  void filterMakananberat(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      selectAllMakananberat();
    } else {
      setState(() {
        makananberat = makananberat
            .where((item) =>
                item.nama.toLowerCase().contains(enteredKeyword.toLowerCase()))
            .toList();
      });
    }
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
            Text(
              "CafeITe's Menu",
              style: TextStyle(fontSize: 20),
            ),
            IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CartPage(
                                cartItems: cartItems,
                              )));
                }),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
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
                const SizedBox(width: 10),
                DropdownButtonExample(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: GridView.builder(
                shrinkWrap: true, // Important to prevent overflow
                physics:
                    NeverScrollableScrollPhysics(), // Disable GridView's scrolling
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 2,
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
                          Image.network(
                            item.image,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
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
                                showAddToCartDialog(context, () {
                                  addToCart(item.nama, item.harga, item.image);
                                });
                              },
                              icon: Icon(
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
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationUser(),
    );
  }
}

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({super.key});

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  final List<String> list = ['Makanan Berat', 'Snack', 'Minuman'];
  String dropdownValue = 'Makanan Berat'; // Default value

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
