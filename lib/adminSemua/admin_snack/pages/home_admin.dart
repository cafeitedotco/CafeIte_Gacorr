import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cafeite/utils/restapi.dart'; // API
import 'package:cafeite/utils/model.dart'; // MODEL
import 'package:cafeite/config.dart'; // CONFIG
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeite/adminSemua/admin_snack/navigation_bar_admin.dart';

class HomePageAdminSnack extends StatefulWidget {
  const HomePageAdminSnack({super.key});

  @override
  HomePageAdminSnackState createState() => HomePageAdminSnackState();
}

class HomePageAdminSnackState extends State<HomePageAdminSnack> {
  final searchKeyword = TextEditingController();
  DataService ds = DataService();
  List<MakananModel> makananberat = [];

  String loggedInUserEmail = "tenant3@gmail.com";

  @override
  void initState() {
    super.initState();
    selectAllMakananberat(); // Fetch data on initialization
  }

  Future<void> loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInUserEmail = prefs.getString('userEmail') ?? '';
    });
  }

  Future<void> selectAllMakananberat() async {
    final response = await ds.selectAll(token, project, 'makananberat', appid);
    List data = jsonDecode(response);

    setState(() {
      if (loggedInUserEmail == 'tenant3@gmail.com') {
        // Filter kategori 'makanan' jika pengguna adalah tenant1@gmail.com
        makananberat = data
            .map((e) => MakananModel.fromJson(e))
            .where((item) => item.kategori.toLowerCase() == 'snack')
            .toList();
      }
    });

    print("Data refreshed: ${makananberat.length} items loaded.");
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
              onPressed: () {
                showInsertDialog(context, appid, ds);
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
                crossAxisCount: 2, // Two items per row
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 0.75, // Adjust the aspect ratio for height
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
                    elevation: 4.0,
                    margin: const EdgeInsets.all(8.0),
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
                            "Stock: ${item.stock}",
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(), // Pushes the stock status text to the bottom
                          Align(
                            alignment: Alignment
                                .bottomRight, // Align text to the bottom right
                            child: Text(
                              (int.tryParse(item.stock) ?? 0) > 0
                                  ? 'Tersedia'
                                  : 'Habis', // Check stock availability
                              style: TextStyle(
                                color: (int.tryParse(item.stock) ?? 0) > 0
                                    ? Colors.green
                                    : Colors
                                        .red, // Set text color based on stock
                                fontWeight:
                                    FontWeight.bold, // Optional: make it bold
                              ),
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
      bottomNavigationBar: const BottomNavigationAdminSnack(),
    );
  }

  void showInsertDialog(BuildContext context, String appid, DataService ds) {
    final nama = TextEditingController();
    final harga = TextEditingController();
    final deskripsi = TextEditingController();
    final image = TextEditingController();
    final stock = TextEditingController(); // New stock controller
    String kategori = 'Makanan';

    showDialog(
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
                  TextFormField(
                    controller: stock, // New stock input field
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (nama.text.isNotEmpty &&
                    harga.text.isNotEmpty &&
                    deskripsi.text.isNotEmpty &&
                    image.text.isNotEmpty &&
                    stock.text.isNotEmpty) {
                  // Check stock field
                  try {
                    String responseString = await ds.insertMakananberat(
                      appid,
                      nama.text,
                      harga.text,
                      deskripsi.text,
                      image.text,
                      kategori,
                      stock.text, // Pass stock to the API
                    );

                    final response = jsonDecode(responseString);
                    if (response.isNotEmpty && response[0]['success'] == true) {
                      // Close the dialog
                      Navigator.of(dialogContext).pop();

                      // Refresh the entire list after adding the new item
                      await selectAllMakananberat();

                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Berhasil"),
                            content:
                                const Text("Makanan berhasil ditambahkan!"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Navigator.of(dialogContext).pop();
                    }
                  } catch (e) {
                    print("Error: $e");
                    Navigator.of(dialogContext).pop();
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

  void _showDetailDialog(BuildContext context, MakananModel item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.nama,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Harga: RP. ${item.harga}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.deskripsi,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pop(); // Close detail dialog
                showEditDialog(context, item); // Call edit dialog
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Navigator.of(context).pop();
                showDeleteConfirmationDialog(
                    context, item); // Call delete confirmation dialog
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, MakananModel item) {
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

  Future<void> showEditDialog(BuildContext context, MakananModel item) async {
    final TextEditingController namaController =
        TextEditingController(text: item.nama);
    final TextEditingController hargaController =
        TextEditingController(text: item.harga);
    final TextEditingController deskripsiController =
        TextEditingController(text: item.deskripsi);
    final TextEditingController imageController =
        TextEditingController(text: item.image);
    String? selectedKategori = item.kategori;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Makanan"),
          content: SizedBox(
            height: 300,
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
}
