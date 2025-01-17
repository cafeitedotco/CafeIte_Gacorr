// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:math';
import 'package:cafeite/config.dart';
import 'package:cafeite/cust/pages/cart_provider.dart';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cafeite/utils/model.dart'; // MODEL
import 'package:cafeite/utils/restapi.dart'; // API
import 'package:cafeite/cust/navigation_bar_user.dart';
import 'package:cafeite/cust/pages/cart_page.dart';

import 'package:provider/provider.dart';

class HomePageUser extends StatefulWidget {
  const HomePageUser({super.key});

  @override
  HomePageUserState createState() => HomePageUserState();
}

class HomePageUserState extends State<HomePageUser> {
  final searchKeyword = TextEditingController();
  DataService ds = DataService();
  List<MakananModel> makananberat = [];
  List<CartItem> cartItems = [];
  final List<String> list = ['Makanan', 'Snack', 'Minuman'];
  String dropdownValue = 'Makanan';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    selectAllMakananberat(kategori: 'Makanan');
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Load cart items first
      await Provider.of<CartProvider>(context, listen: false).loadCartItems();

      // Then load menu items
      await selectAllMakananberat();
    } catch (e) {
      print('Error initializing data: $e');
      // Optionally show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> addToCart(BuildContext context, CartItem item) async {
    try {
      await Provider.of<CartProvider>(context, listen: false).addItem(item);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error menambahkan item: $e')),
      );
    }
  }

  Future<void> selectAllMakananberat({String? kategori}) async {
    try {
      final response =
          await ds.selectAll(token, project, 'makananberat', appid);
      List data = jsonDecode(response);

      setState(() {
        if (kategori == null || kategori.isEmpty) {
          makananberat = data.map((e) => MakananModel.fromJson(e)).toList();
        } else {
          makananberat = data
              .map((e) => MakananModel.fromJson(e))
              .where((item) =>
                  item.kategori.toLowerCase() == kategori.toLowerCase())
              .toList();
        }
      });
    } catch (e) {
      print('Error loading makananberat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading menu: $e')),
      );
    }
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

  Widget _buildMenuCard(MakananModel item) {
    return Card(
      elevation: 3,
      color: Color(0xFFF7EED3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container with Margin
          Padding(
            padding: const EdgeInsets.all(
                8.0), // Menambahkan margin di sekitar gambar
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio:
                    16 / 12, // Mengubah rasio gambar agar lebih persegi
                child: Image.network(
                  item.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.restaurant_menu, size: 40),
                    );
                  },
                ),
              ),
            ),
          ),

          // Content Container
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Menu Name
                Text(
                  item.nama.isNotEmpty ? item.nama : 'Tanpa Nama',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Price and Add Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Price
                    Text(
                      'Rp ${item.harga}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),

                    // Add to Cart Button
                    Material(
                      color: const Color(0xFF8B0000),
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () => addToCart(
                          context,
                          CartItem(
                            nama: item.nama,
                            harga: item.harga,
                            image: item.image,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuDetail(MakananModel item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image with Padding
              Padding(
                padding: const EdgeInsets.all(
                    8.0), // Margin antara gambar dan tepi card
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.nama,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'Rp ${item.harga}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      item.deskripsi.isNotEmpty
                          ? item.deskripsi
                          : 'Tidak ada deskripsi.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Tutup',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            addToCart(
                              context,
                              CartItem(
                                nama: item.nama,
                                harga: item.harga,
                                image: item.image,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B0000),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.shopping_cart,
                              color: Colors.white),
                          label: const Text(
                            'Tambah ke Keranjang',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFFF7EED3),
            title: const Text(
              "CafeITe's Menu",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B0000),
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: badges.Badge(
                  position: badges.BadgePosition.topEnd(top: 0, end: 3),
                  badgeContent: Text(
                    '${cartProvider.itemCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: Color(0xFF8B0000),
                    padding: EdgeInsets.all(5),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart,
                        color: Color(0xFF8B0000)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartPage(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search and Filter Section
              // Ganti bagian Search and Filter Section dengan kode berikut
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EED3),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Search Field
                    Expanded(
                      child: Container(
                        height: 40, // Mengecilkan tinggi search field
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: searchKeyword,
                          onChanged: filterMakananberat,
                          decoration: const InputDecoration(
                            hintText: 'Cari menu...',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF8B0000),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Filter Button
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF8B0000),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        offset: const Offset(0, 40),
                        onSelected: (String value) {
                          setState(() {
                            dropdownValue = value;
                            selectAllMakananberat(kategori: 'Makanan');
                            // Tambahkan logika filter berdasarkan kategori di sini
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return list.map((String value) {
                            return PopupMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8B0000),
                                ),
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Grid
              Expanded(
                child: makananberat.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_menu,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada menu tersedia',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: makananberat.length,
                        itemBuilder: (context, index) {
                          final item = makananberat[index];
                          return GestureDetector(
                            onTap: () => _showMenuDetail(item),
                            child: _buildMenuCard(item),
                          );
                        },
                      ),
              ),
            ],
          ),
          bottomNavigationBar: const BottomNavigationUser(),
        );
      },
    );
  }
}

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({super.key});

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  final List<String> list = ['Makanan', 'Snack', 'Minuman'];
  String dropdownValue = 'Makanan'; // Default value

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8B0000)),
      elevation: 16,
      style: const TextStyle(color: Color(0xFF8B0000)),
      underline: Container(), // Remove default underline
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
