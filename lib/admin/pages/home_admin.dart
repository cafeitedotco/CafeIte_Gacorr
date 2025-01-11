// ignore_for_file: unused_import

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cafeite/utils/fire_auth.dart';
import 'package:cafeite/config.dart'; // CONFIG
import 'package:cafeite/utils/model.dart'; // MODEL
import 'package:cafeite/utils/restapi.dart'; // API
import 'package:cafeite/admin/navigation_bar_admin.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({Key? key}) : super(key: key);

  @override
  HomePageAdminState createState() => HomePageAdminState();
}

class HomePageAdminState extends State<HomePageAdmin> {
  final searchKeyword = TextEditingController();
  DataService ds = DataService();
  List<MakananberatModel> makananberat = [];

  @override
  void initState() {
    super.initState();
    selectAllMakananberat(); // Fetch data on initialization
  }

  Future<void> selectAllMakananberat() async {
    // Fetch all items and update the state
    final response = await ds.selectAll(token, project, 'makananberat', appid);
    List data = jsonDecode(response);

    setState(() {
      makananberat = data.map((e) => MakananberatModel.fromJson(e)).toList();
    });
  }

  void filterMakananberat(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      selectAllMakananberat(); // Reload all data when search is empty
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
              icon: Icon(Icons.add),
              onPressed: () async {
                // Show the insert dialog and wait for the result
                final result = await showInsertDialog(context, appid);

                // If the result is true, reload the data
                if (result == true) {
                  await selectAllMakananberat(); // Reload data
                }
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
              children: [],
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                // Add delete functionality
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                                width:
                                    8.0), // Add some space between the buttons
                            IconButton(
                              onPressed: () {
                                // Add edit functionality
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.black,
                              ),
                            ),
                          ],
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
      bottomNavigationBar: const BottomNavigationAdmin(),
    );
  }
}
