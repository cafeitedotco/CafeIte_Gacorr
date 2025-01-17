// lib/screens/my_orders_page.dart

import 'package:cafeite/cust/navigation_bar_user.dart';
import 'package:cafeite/cust/pages/checkout_page.dart';
import 'package:cafeite/cust/pages/home_user.dart';
import 'package:cafeite/cust/pages/tracking.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PesananSaya extends StatefulWidget {
  const PesananSaya({super.key});

  @override
  _PesananSayaState createState() => _PesananSayaState();
}

class _PesananSayaState extends State<PesananSaya>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Makanan Sedang Dibuat':
        return Colors.blue.shade600;
      case 'Makanan Sedang Diantar':
        return Colors.orange.shade600;
      case 'Kurir Telah Sampai':
        return Colors.green.shade600;
      case 'Orderan Selesai':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildOrderCard(DocumentSnapshot order) {
    final status = order['status_pesanan'] ?? 'Pending';
    final timestamp = order['tanggal'] is Timestamp
        ? (order['tanggal'] as Timestamp).toDate()
        : null;
    final total = double.parse(order['total'] ?? '0');
    final statusColor = _getStatusColor(status);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToOrderTracking(order),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Order Date

                    // Status Badge
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Order Items
                Text(
                  order['pesanan_yang_di_pesan'] ?? 'Tidak ada detail pesanan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),
                // Total and Detail Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Rp ${total.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8B0000),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _navigateToOrderTracking(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B0000),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Lihat Detail',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToOrderTracking(DocumentSnapshot order) {
    List<Map<String, dynamic>> orderItems = [];
    try {
      String pesananStr = order['pesanan_yang_di_pesan'];
      List<String> items = pesananStr.split(',');

      for (String item in items) {
        final parts = item.trim().split(' (');
        String name = parts[0];
        String quantity = '1';
        if (parts.length > 1) {
          quantity = parts[1].replaceAll('x)', '');
        }

        orderItems.add({
          'name': name,
          'quantity': int.parse(quantity),
          'image': '', // You might want to store image URLs in your order data
          'note': ''
        });
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderTrackingPage(
            orders: orderItems,
            subtotal: double.parse(order['subtotal'] ?? '0'),
            shippingFee: 10000, // Default shipping fee
            total: double.parse(order['subtotal'] ?? '0') + 10000,
            address: order['alamat'] ?? '',
          ),
        ),
      );
    } catch (e) {
      print('Error navigating to tracking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka detail pesanan')),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7EED3),
      appBar: AppBar(
        title: Text(
          'Pesanan Saya',
          style: TextStyle(
            color: Colors.brown.shade900,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFF7EED3),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined,
                color: Colors.brown.shade700),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20.0,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _tabController.animateTo(0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _tabController.index == 0
                            ? Color(0xFFCD853F)
                            : Color(0xFFF7EED3),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (_tabController.index != 0)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Proses',
                          style: TextStyle(
                            color: _tabController.index == 0
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _tabController.animateTo(1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _tabController.index == 1
                            ? Color(0xFFCD853F)
                            : Color(0xFFF7EED3),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (_tabController.index != 1)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Riwayat',
                          style: TextStyle(
                            color: _tabController.index == 1
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _tabController.animateTo(2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _tabController.index == 2
                            ? Color(0xFFCD853F)
                            : Color(0xFFF7EED3),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (_tabController.index != 2)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: _tabController.index == 2
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('Proses'),
                _buildTabContent('Riwayat'),
                _buildTabContent('Batal'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationUser(),
    );
  }

  Future<List<DocumentSnapshot>> _fetchOrdersByStatus(String status) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot ordersSnapshot;

        if (status == 'Proses') {
          // Pesanan yang sedang dalam proses (belum selesai)
          ordersSnapshot = await _firestore
              .collection('orders')
              .where('userid', isEqualTo: user.uid)
              .where('status_pesanan', whereIn: [
                'Menunggu Konfirmasi',
                'Diproses', // Tambahkan status 'Diproses'
                'Makanan Sedang Dibuat',
                'Makanan Sedang Diantar',
                'Kurir Telah Sampai',
                'Masuk'
              ])
              .orderBy('tanggal', descending: true)
              .get();
        } else if (status == 'Riwayat') {
          // Pesanan yang sudah selesai
          ordersSnapshot = await _firestore
              .collection('orders')
              .where('userid', isEqualTo: user.uid)
              .where('status_pesanan', isEqualTo: 'Orderan Selesai')
              .orderBy('tanggal', descending: true)
              .get();
        } else {
          // Pesanan yang dibatalkan
          ordersSnapshot = await _firestore
              .collection('orders')
              .where('userid', isEqualTo: user.uid)
              .where('status_pesanan', isEqualTo: 'Dibatalkan')
              .orderBy('tanggal', descending: true)
              .get();
        }

        return ordersSnapshot.docs;
      }
      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Widget _buildTabContent(String status) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchOrdersByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCD853F)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                SizedBox(height: 16),
                Text(
                  'Terjadi kesalahan',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Colors.brown.shade200,
                ),
                SizedBox(height: 16),
                Text(
                  'Belum ada pesanan',
                  style: TextStyle(
                    color: Colors.brown.shade400,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(top: 8, bottom: 16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(snapshot.data![index]);
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _convertPesananToOrderItems(String pesananStr) {
    List<Map<String, dynamic>> orderItems = [];
    List<String> items = pesananStr.split(',');

    for (String item in items) {
      final parts = item.trim().split(' (');
      String name = parts[0];
      String quantity = '1';
      if (parts.length > 1) {
        quantity = parts[1].replaceAll('x)', '');
      }

      orderItems.add({
        'name': name,
        'quantity': int.parse(quantity),
        'image':
            'https://via.placeholder.com/80', // Replace with actual image URL
        'note': '',
        'price':
            '0' // You might want to store the price in your Firestore document
      });
    }

    return orderItems;
  }

  Widget _buildOrderItem(DocumentSnapshot order, bool showBuyAgain) {
    // Extract order details safely
    final String pesanan =
        order['pesanan_yang_di_pesan'] ?? 'Tidak ada detail pesanan';
    final String total = order['total']?.toString() ?? '0';
    final dynamic tanggal = order['tanggal'];

    // Convert pesanan string to order items list
    List<Map<String, dynamic>> orderItems =
        _convertPesananToOrderItems(pesanan);
    final double subtotal = double.tryParse(order['subtotal'] ?? '0') ?? 0.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://via.placeholder.com/80',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(Icons.fastfood, color: Colors.grey),
                  );
                },
              ),
            ),
            SizedBox(width: 12),

            // Order Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    pesanan,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rp $total',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    formatOrderDate(tanggal),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity and Action Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _extractQuantity(pesanan),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (showBuyAgain) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                            orders: orderItems,
                            subtotal: subtotal,
                            shippingFee: 10000, // Default shipping fee
                          ),
                        ),
                      );
                    } else {
                      _navigateToOrderTracking(order);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF8B4513),
                    elevation: 0,
                    side: BorderSide(color: Color(0xFF8B4513)),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    showBuyAgain ? 'Beli Lagi' : 'Lihat',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatOrderDate(dynamic timestamp) {
    try {
      DateTime dateTime;

      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'Tanggal tidak tersedia';
      }

      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    } catch (e) {
      print('Error formatting date: $e');
      return 'Tanggal tidak tersedia';
    }
  }

  String _extractQuantity(String pesanan) {
    try {
      final RegExp quantityRegex = RegExp(r'\((\d+)x\)');
      final match = quantityRegex.firstMatch(pesanan);
      if (match != null && match.groupCount >= 1) {
        return '${match.group(1)}x';
      }
      return '1x';
    } catch (e) {
      return '1x';
    }
  }
}