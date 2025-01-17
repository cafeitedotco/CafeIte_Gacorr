import 'package:flutter/material.dart';
import 'package:cafeite/utils/model.dart';

class HistoryPage extends StatelessWidget {
  final List<PesananModel> completedOrders;

  HistoryPage({required this.completedOrders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pengiriman'),
      ),
      body: ListView.builder(
        itemCount: completedOrders.length,
        itemBuilder: (context, index) {
          final item = completedOrders[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nama Penerima: ${item.userid}',
                        style: TextStyle(fontSize: 14),
                      ),
                      Icon(Icons.check_circle),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Alamat: ${item.alamat}',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}