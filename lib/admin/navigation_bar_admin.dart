import 'package:cafeite/admin/pages/home_admin.dart';
import 'package:cafeite/admin/pages/profile_admin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cafeite/utils/restapi.dart';
import 'package:cafeite/utils/model.dart';
import 'package:cafeite/admin/pages/pesanan.dart';
import 'package:cafeite/admin/pages/dashboard.dart';

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
                    MaterialPageRoute(builder: (context) => Dashboard()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              const Text(
                "Dashboard",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.fastfood_outlined, size: 30),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePageAdmin()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              const Text(
                "Makanan",
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PesananAdmin()));
                },
              ),
              const Text(
                "Pesanan",
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
Future<MakananberatModel?> showInsertDialog(
    BuildContext context, String appid) async {
  final nama = TextEditingController();
  final harga = TextEditingController();
  final deskripsi = TextEditingController();
  final image = TextEditingController();
  String kategori = 'Makanan'; // Nilai default untuk kategori

  DataService ds = DataService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  return showDialog<MakananberatModel?>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Insert Makanan'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nama,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Nama tidak boleh kosong' : null,
                ),
                TextFormField(
                  controller: harga,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty == true
                      ? 'Harga tidak boleh kosong'
                      : null,
                ),
                TextFormField(
                  controller: deskripsi,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  validator: (value) => value?.isEmpty == true
                      ? 'Deskripsi tidak boleh kosong'
                      : null,
                ),
                TextFormField(
                  controller: image,
                  decoration: const InputDecoration(labelText: 'ImageUrl'),
                  validator: (value) => value?.isEmpty == true
                      ? 'URL gambar tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  value: kategori,
                  onChanged: (String? newValue) =>
                      kategori = newValue ?? kategori,
                  items: <String>['Makanan', 'Minuman', 'Snack']
                      .map((String value) =>
                          DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(null), // Tutup dialog tanpa hasil
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() == true) {
                try {
                  String responseString = await ds.insertMakananberat(
                    appid,
                    nama.text,
                    harga.text,
                    deskripsi.text,
                    image.text,
                    kategori,
                  );

                  final response = jsonDecode(responseString);
                  if (response.isNotEmpty && response[0]['success'] == true) {
                    final newItem = MakananberatModel(
                      id: response[0]['id'],
                      nama: nama.text,
                      harga: harga.text,
                      deskripsi: deskripsi.text,
                      image: image.text,
                      kategori: kategori,
                    );

                    Navigator.of(dialogContext)
                        .pop(newItem); // Kembalikan objek baru
                  } else {
                    Navigator.of(dialogContext).pop(null);
                  }
                } catch (e) {
                  print("Error: $e");
                  Navigator.of(dialogContext).pop(null);
                }
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      );
    },
  );
}
