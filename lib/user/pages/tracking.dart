import 'package:flutter/material.dart';

import 'package:cafeite/user/navigation_bar_user.dart';

class OrderTrackingPage extends StatefulWidget {
  final List<Map<String, dynamic>> orders;
  final double subtotal;
  final double shippingFee;
  final double total;
  final String address;

  OrderTrackingPage({
    required this.orders,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.address,
  });

  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  int _currentStatus = 1;
  bool isDelivery = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Tracking"),
        backgroundColor: Color(0xFFF7EED3),
        centerTitle: true,
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
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Image.network(order['image'], width: 50),
                      title: Text(order['name']),
                      subtitle: Text("Catatan: ${order['note']}"),
                      trailing: Text("${order['quantity']}x"),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status Pesanan", style: TextStyle(fontSize: 18)),
                RadioListTile(
                  value: 1,
                  groupValue: _currentStatus,
                  onChanged: (value) {
                    setState(() {
                      _currentStatus = value as int;
                    });
                  },
                  title: Text("Makanan Sedang Dibuat"),
                ),
                RadioListTile(
                  value: 2,
                  groupValue: _currentStatus,
                  onChanged: (value) {
                    setState(() {
                      _currentStatus = value as int;
                    });
                  },
                  title: Text("Makanan Sedang Diantar"),
                ),
                RadioListTile(
                  value: 3,
                  groupValue: _currentStatus,
                  onChanged: (value) {
                    setState(() {
                      _currentStatus = value as int;
                    });
                  },
                  title: Text("Kurir Telah Sampai"),
                ),
                RadioListTile(
                  value: 4,
                  groupValue: _currentStatus,
                  onChanged: (value) {
                    setState(() {
                      _currentStatus = value as int;
                    });
                  },
                  title: Text("Makanan Telah Selesai"),
                ),
              ],
            ),
            Divider(thickness: 1),
            Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Pembayaran",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp ${widget.total.toStringAsFixed(0)}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationUser(),
    );
  }
}
