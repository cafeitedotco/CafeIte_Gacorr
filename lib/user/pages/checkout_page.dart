import 'package:cafeite/user/pages/tracking.dart';
import 'package:cafeite/config.dart';
import 'package:cafeite/utils/model.dart';
import 'package:cafeite/utils/restapi_pesanan.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> orders;
  final double subtotal;
  final double shippingFee;

  CheckoutPage({
    required this.orders,
    required this.subtotal,
    required this.shippingFee,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController addressController = TextEditingController();
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Declare the FirebaseAuth instance
  bool isDelivery = true;
  String paymentMethod = "Cash";
  String? userId; // Declare userId variable

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid; // Get the user ID in initState
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pesanan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
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
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
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
                              SizedBox(height: 5),
                              Text(
                                "Catatan: ${order['note']}",
                                style: TextStyle(fontSize: 12),
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
            ),
            SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: "Alamat",
                filled: true,
                fillColor: Color(0xFFF7EED3),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    activeColor: Color(0xFF8B0000),
                    title: Text("Pick Up"),
                    value: !isDelivery,
                    onChanged: (value) {
                      setState(() {
                        isDelivery = false; // If Pick Up is selected
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    activeColor: Color(0xFF8B0000),
                    title: Text("Delivery"),
                    value: isDelivery,
                    onChanged: (value) {
                      setState(() {
                        isDelivery = true; // If Delivery is selected
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
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
                    setState(() {
                      paymentMethod = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Subtotal Produk"),
                Text("Rp ${widget.subtotal.toStringAsFixed(0)}"),
              ],
            ),
            SizedBox(height: 5),
            if (isDelivery) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Subtotal Pengiriman"),
                  Text("Rp ${widget.shippingFee.toStringAsFixed(0)}"),
                ],
              ),
              SizedBox(height: 5),
            ],
            Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Pembayaran",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp ${total.toStringAsFixed(0)}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String appid = '67766d01f853312de5509d18';
                String pesananYangDipesan =
                    widget.orders.map((order) => order['name']).join(', ');
                String alamat = addressController.text;
                String pengiriman = isDelivery ? "Delivery" : "Pick Up";
                String pembayaran = paymentMethod;
                String subtotal = widget.subtotal.toString();
                String statusPesanan = "Pending";

                try {
                  DataService ds = DataService();
                  final response = await ds.insertPesanan(
                    appid,
                    pesananYangDipesan,
                    alamat,
                    pengiriman,
                    pembayaran,
                    subtotal,
                    statusPesanan,
                    userId!, // Pass the user ID
                  );

                  var decodedResponse = jsonDecode(response);

                  if (decodedResponse.isNotEmpty &&
                      decodedResponse[0]['_id'] != null) {
                    print("Pesanan berhasil disimpan: $decodedResponse");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderTrackingPage(
                          orders: widget.orders,
                          subtotal: widget.subtotal,
                          shippingFee: widget.shippingFee,
                          total: total,
                          address: addressController.text,
                        ),
                      ),
                    );
                  } else {
                    print("Gagal menyimpan pesanan: $decodedResponse");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Gagal menyimpan pesanan. Coba lagi!")),
                    );
                  }
                } catch (e) {
                  print("Terjadi kesalahan: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Terjadi kesalahan. Coba lagi!")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000),
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: Colors.white,
              ),
              child: const Text("Pesan"),
            ),
          ],
        ),
      ),
    );
  }
}
