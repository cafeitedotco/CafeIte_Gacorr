import 'package:cafeite/admin/pages/home_admin.dart';
import 'package:cafeite/admin/pages/profile_admin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cafeite/utils/restapi.dart';

class BottomNavigationAdmin extends StatelessWidget {
  const BottomNavigationAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home Button
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.home, size: 30),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePageAdmin()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              const Text(
                "Home",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),

          // Pesanan Saya Button
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_basket, size: 30),
                onPressed: () {
                  // Uncomment and replace with your PesananSayaScreen
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => PesananSayaScreen()),
                  //   (Route<dynamic> route) => false,
                  // );
                },
              ),
              const Text(
                "Pesanan Saya",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),

          // Profile Button
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.person, size: 30),
                onPressed: () {
                  // Uncomment and replace with your ProfileScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileScreenAdmin()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              const Text(
                "Profile",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Function to show the insert dialog
Future<bool?> showInsertDialog(BuildContext context, String appid) {
  final nama = TextEditingController();
  final harga = TextEditingController();
  final deskripsi = TextEditingController();
  final image = TextEditingController();
  final kategori = TextEditingController();

  DataService ds = DataService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('Insert Makanan'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nama,
                  decoration: InputDecoration(labelText: 'Nama'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null; // Valid
                  },
                ),
                TextFormField(
                  controller: harga,
                  decoration: InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    return null; // Valid
                  },
                ),
                TextFormField(
                  controller: deskripsi,
                  decoration: InputDecoration(labelText: 'Deskripsi'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null; // Valid
                  },
                ),
                TextFormField(
                  controller: image,
                  decoration: InputDecoration(labelText: 'ImageUrl'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'URL gambar tidak boleh kosong';
                    }
                    return null; // Valid
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false), // Cancel
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() == true) {
                // If form is valid, close dialog and return true
                try {
                  String responseString = await ds.insertMakananberat(
                    appid,
                    nama.text,
                    harga.text,
                    deskripsi.text,
                    image.text,
                    kategori.text,
                    //satu lgi?
                  );

                  print('Response: $responseString'); // Log the full response

                  // Decode response
                  List<dynamic> response = jsonDecode(responseString);
                  // Check for success
                  if (response.isNotEmpty && response[0]['success'] == true) {
                    // Navigate back to HomePageAdmin and wait for result
                    await Navigator.pushAndRemoveUntil(
                      dialogContext,
                      MaterialPageRoute(builder: (context) => HomePageAdmin()),
                      (Route<dynamic> route) => false,
                    );
                  } else {
                    print("Response content: $response");
                    Navigator.of(dialogContext).pop(false); // Return false
                  }
                } catch (e) {
                  print("Error while decoding response: $e");
                  Navigator.of(dialogContext).pop(false); // Return false
                }
              }
            },
            child: Text('Tambah'),
          ),
        ],
      );
    },
  );
}
