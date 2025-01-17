import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cafeite/cust/pages/cart_provider.dart';
import 'package:cafeite/cust/pages/checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    try {
      await Provider.of<CartProvider>(context, listen: false).loadCartItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cart: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Keranjang"),
            backgroundColor: const Color(0xFFF7EED3),
            centerTitle: true,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : cartProvider.isEmpty
                  ? const Center(child: Text("Keranjang kosong"))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: cartProvider.items.length,
                            itemBuilder: (context, index) {
                              final cartItem = cartProvider.items[index];
                              return Card(
                                margin: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: cartItem.isSelected,
                                    onChanged: (value) async {
                                      try {
                                        await cartProvider
                                            .toggleSelection(index);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    },
                                  ),
                                  title: Text(cartItem.nama),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(cartItem.harga),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed: () async {
                                              try {
                                                await cartProvider
                                                    .updateQuantity(index, -1);
                                              } catch (e) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content:
                                                          Text('Error: $e')),
                                                );
                                              }
                                            },
                                          ),
                                          Text("${cartItem.quantity}"),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () async {
                                              try {
                                                await cartProvider
                                                    .updateQuantity(index, 1);
                                              } catch (e) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content:
                                                          Text('Error: $e')),
                                                );
                                              }
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "TOTAL",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Rp ${cartProvider.calculateTotal().toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  final selectedItems = cartProvider.items
                                      .where((item) => item.isSelected)
                                      .toList();

                                  if (selectedItems.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Pilih minimal satu item'),
                                      ),
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CheckoutPage(
                                        orders: selectedItems
                                            .map((item) => {
                                                  'name': item.nama,
                                                  'note': item.note,
                                                  'image': item.image,
                                                  'quantity': item.quantity,
                                                  'price': item.harga,
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