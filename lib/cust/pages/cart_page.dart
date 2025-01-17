import 'package:cafeite/cust/pages/cart_provider.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:cafeite/cust/pages/checkout_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;

  CartPage({super.key, required this.cartItems}) {
    // Ketika widget dibuat, load data dari storage
    _loadCartItems();
  }

  static Future<List> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString('cart_items');
    if (cartData != null) {
      final List<dynamic> decodedData = json.decode(cartData);
      return decodedData.map((item) => CartItem.fromJson(item)).toList();
    }
    return [];
  }

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Menambahkan method untuk menyimpan data cart ke storage
  Future<void> _saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      widget.cartItems.map((item) => item.toJson()).toList(),
    );
    await prefs.setString('cart_items', encodedData);
  }

  double calculateTotalPrice() {
    return widget.cartItems.fold(0, (sum, item) {
      if (item.isSelected) {
        return sum +
            (double.parse(
                    item.harga.replaceAll("Rp ", "").replaceAll(".", "")) *
                item.quantity);
      }
      return sum;
    });
  }

  void updateQuantity(int index, int change) {
    setState(() {
      widget.cartItems[index].quantity += change;
      if (widget.cartItems[index].quantity <= 0) {
        widget.cartItems.removeAt(index);
      }
      _saveCartItems(); // Simpan perubahan ke storage
    });
  }

  void toggleSelection(int index) {
    setState(() {
      widget.cartItems[index].isSelected = !widget.cartItems[index].isSelected;
      _saveCartItems(); // Simpan perubahan ke storage
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Keranjang"),
            backgroundColor: Color(0xFFF7EED3),
            centerTitle: true,
          ),
          body: cartProvider.isEmpty
              ? Center(
                  child: Text("Keranjang kosong"),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartProvider.items.length,
                        itemBuilder: (context, index) {
                          final cartItem = cartProvider.items[index];
                          return Card(
                            margin: EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: Checkbox(
                                value: cartItem.isSelected,
                                onChanged: (value) {
                                  cartProvider.toggleSelection(index);
                                },
                              ),
                              title: Text(cartItem.nama),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cartItem.harga),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          cartProvider.updateQuantity(
                                              index, -1);
                                        },
                                      ),
                                      Text("${cartItem.quantity}"),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          cartProvider.updateQuantity(index, 1);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: SizedBox(
                                width: 80,
                                height: 80,
                                child: Image.network(
                                  cartItem.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "TOTAL",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Rp ${cartProvider.calculateTotal().toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutPage(
                                    orders: cartProvider.items
                                        .where((item) => item.isSelected)
                                        .map((item) => {
                                              'name': item.nama,
                                              'note': item.note,
                                              'image': item.image,
                                              'quantity': item.quantity,
                                              'price': item
                                                  .harga, // Memastikan harga terkirim
                                            })
                                        .toList(),
                                    subtotal: cartProvider.calculateTotal(),
                                    shippingFee: 3000,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B0000),
                              minimumSize: const Size(double.infinity, 50),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Proses Pesanan"),
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
}
