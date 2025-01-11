// ignore_for_file: unused_import

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cafeite/utils/restapi.dart'; // API
import 'package:cafeite/utils/model.dart'; // MODEL
import 'package:cafeite/config.dart'; // CONFIG
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
                final result = await showInsertDialog(context, appid, ds);
                if (result != null) {
                  setState(() {
                    makananberat.add(result); // Tambahkan langsung ke list
                  });
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
                hintText: 'Masukan Nama Makanan/Minuman/Snack?',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
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
                return GestureDetector(
                  onTap: () {
                    _showDetailDialog(context, item);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 6.0,
                    margin: const EdgeInsets.all(10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              item.image,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.nama,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.harga,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
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

  Future<MakananberatModel?> showInsertDialog(
      BuildContext context, String appid, DataService ds) async {
    final nama = TextEditingController();
    final harga = TextEditingController();
    final deskripsi = TextEditingController();
    final image = TextEditingController();
    String kategori = 'Makanan';

    return showDialog<MakananberatModel?>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Insert Makanan'),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                children: [
                  TextFormField(
                    controller: nama,
                    decoration: const InputDecoration(labelText: 'Nama'),
                  ),
                  TextFormField(
                    controller: harga,
                    decoration: const InputDecoration(labelText: 'Harga'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: deskripsi,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                  ),
                  TextFormField(
                    controller: image,
                    decoration: const InputDecoration(labelText: 'ImageUrl'),
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
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (nama.text.isNotEmpty &&
                    harga.text.isNotEmpty &&
                    deskripsi.text.isNotEmpty &&
                    image.text.isNotEmpty) {
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

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, MakananberatModel item) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Hapus"),
          content: Text("Apakah Anda yakin ingin menghapus ${item.nama}?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                // Aksi untuk menghapus makanan
                bool response = await ds.removeId(
                  token,
                  project,
                  'makananberat',
                  appid,
                  item.id, // ID makanan yang ingin dihapus
                );
                Navigator.of(context).pop(); // Tutup dialog konfirmasi

                if (response) {
                  await selectAllMakananberat(); // Reload data setelah penghapusan
                  showResultDialog(context, 'Data berhasil dihapus!');
                } else {
                  showResultDialog(context, 'Gagal menghapus data.');
                }
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  void showResultDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hasil"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> showEditDialog(
      BuildContext context, MakananberatModel item) async {
    final TextEditingController namaController =
        TextEditingController(text: item.nama);
    final TextEditingController hargaController =
        TextEditingController(text: item.harga);
    final TextEditingController deskripsiController =
        TextEditingController(text: item.deskripsi);
    final TextEditingController imageController =
        TextEditingController(text: item.image);
    String? selectedKategori =
        item.kategori; // Mengambil kategori yang ada dari item

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Makanan"),
          content: SizedBox(
            height: 300, // Atur tinggi sesuai kebutuhan
            child: Column(
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: "Nama Makanan"),
                ),
                TextField(
                  controller: hargaController,
                  decoration: const InputDecoration(labelText: "Harga"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: deskripsiController,
                  decoration: const InputDecoration(labelText: "Deskripsi"),
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: "URL Gambar"),
                ),
                DropdownButtonFormField<String>(
                  value: selectedKategori,
                  decoration: const InputDecoration(labelText: "Kategori"),
                  items: <String>['Makanan', 'Minuman', 'Snack']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    selectedKategori = newValue!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                // Aksi untuk menyimpan perubahan
                bool updateStatus = await ds.updateId(
                  'nama~harga~deskripsi~image~kategori',
                  '${namaController.text}~${hargaController.text}~${deskripsiController.text}~${imageController.text}~$selectedKategori',
                  token,
                  project,
                  'makananberat',
                  appid,
                  item.id, // ID makanan yang ingin diupdate
                );

                Navigator.of(context).pop(); // Tutup dialog

                if (updateStatus) {
                  await selectAllMakananberat(); // Reload data setelah pembaruan
                  showResultDialog(context, 'Data berhasil diperbarui!');
                } else {
                  showResultDialog(context, 'Gagal memperbarui data.');
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  void _showDetailDialog(BuildContext context, MakananberatModel item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.nama),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 150, // Atur lebar sesuai kebutuhan
                height: 100, // Atur tinggi sesuai kebutuhan
                child: Image.network(
                  item.image,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text("Harga: ${item.harga}"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              color: const Color.fromARGB(255, 0, 0, 0),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog detail
                showEditDialog(context, item); // Panggil showEditDialog
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDeleteConfirmationDialog(
                    context, item); // Panggil dialog konfirmasi hapus
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }
}
