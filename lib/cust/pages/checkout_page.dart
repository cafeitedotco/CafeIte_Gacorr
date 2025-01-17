import 'package:cafeite/cust/pages/tracking.dart';
import 'package:cafeite/config.dart';
import 'package:cafeite/utils/model.dart';
import 'package:cafeite/utils/restapi_pesanan.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> orders;
  final double subtotal;
  final double shippingFee;

  const CheckoutPage({
    super.key,
    required this.orders,
    required this.subtotal,
    required this.shippingFee,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController addressController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isDelivery = true;
  String paymentMethod = "Cash";
  String? userId;
  String? userEmail;
  String? userName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      userId = currentUser.uid;
      userEmail = currentUser.email;

      // Fetch user data from Firestore
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          setState(() {
            userName = userData['username'] ?? 'Unknown User';
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> _submitOrder() async {
    if (isDelivery && addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mohon isi alamat pengiriman")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Create order details string with quantity
      String orderDetails = widget.orders.map((order) {
        return "${order['name']} (${order['quantity']}x)";
      }).join(', ');

      // Prepare order data
      final orderData = {
        'appid': '67766d01f853312de5509d18',
        'pesanan_yang_di_pesan': orderDetails,
        'alamat':
            isDelivery ? addressController.text : '', // Set address if delivery
        'pengiriman': isDelivery ? "Delivery" : "Pick Up",
        'pembayaran': paymentMethod,
        'subtotal': widget.subtotal.toString(),
        'status_pesanan': "Masuk",
        'userid': userId,
        'username': userName,
        'email': userEmail,
        'tanggal': DateTime.now().toIso8601String(),
        'total': (widget.subtotal + (isDelivery ? widget.shippingFee : 0))
            .toString(),
      };

      // Insert order using DataService
      DataService ds = DataService();
      final response = await ds.insertPesanan(
        orderData['appid']!,
        orderData['pesanan_yang_di_pesan']!,
        orderData['alamat']!,
        orderData['pengiriman']!,
        orderData['pembayaran']!,
        orderData['subtotal']!,
        orderData['status_pesanan']!,
        orderData['userid']!,
      );

      var decodedResponse = jsonDecode(response);

      if (decodedResponse.isNotEmpty && decodedResponse[0]['_id'] != null) {
        // Store additional order details in Firestore
        await _firestore
            .collection('orders')
            .doc(decodedResponse[0]['_id'])
            .set({
          ...orderData,
          'order_id': decodedResponse[0]['_id'],
        });

        // Navigate to tracking page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingPage(
              orders: widget.orders,
              subtotal: widget.subtotal,
              shippingFee: widget.shippingFee,
              total: widget.subtotal + (isDelivery ? widget.shippingFee : 0),
              address: addressController.text,
            ),
          ),
        );
      } else {
        throw Exception('Failed to save order');
      }
    } catch (e) {
      print('Error submitting order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pesanan. Silakan coba lagi!')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.subtotal + (isDelivery ? widget.shippingFee : 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Check Out",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFF7EED3),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pesanan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                // Order list items
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.orders.length,
                  itemBuilder: (context, index) {
                    final order = widget.orders[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              order['image'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.error),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (order['note']?.isNotEmpty ?? false) ...[
                                  SizedBox(height: 5),
                                  Text(
                                    "Catatan: ${order['note']}",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                                SizedBox(height: 5),
                                Text(
                                  "Rp ${(parseHarga(order['price'].toString()) * order['quantity']).toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "${order['quantity']}x",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                // Address Field - only shown if delivery is selected
                if (isDelivery) ...[
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: "Alamat Pengiriman",
                      filled: true,
                      fillColor: Color(0xFFF7EED3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 20),
                ],
                // Delivery Options
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF7EED3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      RadioListTile(
                        title: Text("Pick Up"),
                        value: false,
                        groupValue: isDelivery,
                        onChanged: (value) {
                          setState(() => isDelivery = value as bool);
                        },
                        activeColor: Color(0xFF8B0000),
                      ),
                      RadioListTile(
                        title: Text("Delivery"),
                        value: true,
                        groupValue: isDelivery,
                        onChanged: (value) {
                          setState(() => isDelivery = value as bool);
                        },
                        activeColor: Color(0xFF8B0000),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Payment Method
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF7EED3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Metode Pembayaran"),
                      DropdownButton<String>(
                        value: paymentMethod,
                        items: ["Cash", "Qris"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => paymentMethod = value!);
                        },
                        underline: Container(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Order Summary
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF7EED3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Subtotal Produk"),
                          Text("Rp ${widget.subtotal.toStringAsFixed(0)}"),
                        ],
                      ),
                      if (isDelivery) ...[
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Biaya Pengiriman"),
                            Text("Rp ${widget.shippingFee.toStringAsFixed(0)}"),
                          ],
                        ),
                      ],
                      Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Pembayaran",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Rp ${total.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B0000),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Order Button
                ElevatedButton(
                  onPressed: isLoading ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B0000),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isLoading ? "Memproses..." : "Pesan Sekarang",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B0000)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double parseHarga(String harga) {
    try {
      return double.parse(harga);
    } catch (e) {
      print('Error parsing harga: $e');
      return 0.0; // Nilai default jika parsing gagal
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }
}
