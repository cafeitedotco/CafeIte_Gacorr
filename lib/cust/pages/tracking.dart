import 'package:flutter/material.dart';
import 'package:cafeite/cust/navigation_bar_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class OrderTrackingPage extends StatefulWidget {
  final List<Map<String, dynamic>> orders;
  final double subtotal;
  final double shippingFee;
  final double total;
  final String address;

  const OrderTrackingPage({
    super.key,
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
  String _currentStatus = 'Menunggu Konfirmasi';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _orderSubscription;
  String? orderId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupOrderTracking();
  }

  Future<void> _setupOrderTracking() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final orderQuery = await _firestore
            .collection('orders')
            .where('userid', isEqualTo: user.uid)
            .orderBy('tanggal', descending: true)
            .limit(1)
            .get();

        if (orderQuery.docs.isNotEmpty) {
          orderId = orderQuery.docs.first.id;

          // Debug prints untuk membantu investigasi
          print('Order ID: $orderId');
          print(
              'Initial status: ${orderQuery.docs.first.data()['status_pesanan']}');

          _orderSubscription = _firestore
              .collection('orders')
              .doc(orderId)
              .snapshots()
              .listen((snapshot) {
            if (snapshot.exists) {
              final status = snapshot.data()?['status_pesanan'];
              print('Raw status from Firebase: $status'); // Debug print

              if (status != null && statusOrder.contains(status)) {
                setState(() {
                  _currentStatus = status;
                });
                print('Status updated to: $_currentStatus');
              } else {
                print('Invalid status received: $status');
              }
            }
          });
        }
      }
    } catch (e) {
      print('Error setting up tracking: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshStatus() async {
    await _setupOrderTracking();
  }

  final List<String> statusOrder = [
    'Menunggu Konfirmasi',
    'Makanan Sedang Dibuat',
    'Makanan Sedang Diantar',
    'Kurir Telah Sampai',
    'Orderan Selesai'
  ];

  bool _isStatusCompleted(String status) {
    final currentStatusIndex = statusOrder.indexOf(_currentStatus);
    final checkStatusIndex = statusOrder.indexOf(status);
    return checkStatusIndex <= currentStatusIndex;
  }

  final Map<String, Color> statusColorMap = {
    'Menunggu Konfirmasi': Color(0xFF8B0000),
    'Makanan Sedang Dibuat': Color(0xFF8B0000),
    'Makanan Sedang Diantar': Color(0xFF8B0000),
    'Kurir Telah Sampai': Color(0xFF8B0000),
    'Orderan Selesai': Color(0xFF8B0000),
  };

  Widget _buildStatusStep(Map<String, dynamic> statusInfo) {
    final String status = statusInfo['status'] as String;
    final bool isCompleted = _isStatusCompleted(status);
    final bool isCurrent = status == _currentStatus;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Status Icon Container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? Color(0xFF8B0000) : Colors.grey[200],
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(color: Color(0xFF8B0000), width: 2)
                  : null,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: Color(0xFF8B0000).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Icon(
              statusInfo['icon'],
              color: isCompleted ? Colors.white : Colors.grey[400],
              size: 20,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? Color(0xFF8B0000) : Colors.black87,
                  ),
                ),
                if (isCurrent)
                  Text(
                    'Status saat ini',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8B0000),
                    ),
                  ),
              ],
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check_circle,
              color: Color(0xFF8B0000),
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statusList = [
      {
        'status': 'Menunggu Konfirmasi',
        'icon': Icons.receipt_long,
      },
      {
        'status': 'Makanan Sedang Dibuat',
        'icon': Icons.restaurant,
      },
      {
        'status': 'Makanan Sedang Diantar',
        'icon': Icons.delivery_dining,
      },
      {
        'status': 'Kurir Telah Sampai',
        'icon': Icons.location_on,
      },
      {
        'status': 'Orderan Selesai',
        'icon': Icons.check_circle,
      },
    ];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: Color(0xFF8B0000)),
              SizedBox(width: 10),
              Text(
                "Status Pesanan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...statusList.asMap().entries.map((entry) {
            final index = entry.key;
            final statusInfo = entry.value;
            final widget = _buildStatusStep(statusInfo);

            if (index < statusList.length - 1) {
              return Column(
                children: [
                  widget,
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    height: 30,
                    width: 2,
                    color: _isStatusCompleted(statusInfo['status'] as String)
                        ? Color(0xFF8B0000)
                        : Colors.grey[300],
                  ),
                ],
              );
            }
            return widget;
          }),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt, color: Color(0xFF8B0000)),
              SizedBox(width: 10),
              Text(
                "Detail Pesanan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...widget.orders.map((order) => _buildOrderItem(order)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(thickness: 1),
          ),
          _buildPaymentSummary(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF7EED3).withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              order['image'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: Icon(Icons.fastfood, color: Color(0xFF8B0000)),
                );
              },
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (order['note']?.isNotEmpty ?? false)
                  Text(
                    'Catatan: ${order['note']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Color(0xFF8B0000),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '${order['quantity']}x',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ringkasan Pembayaran",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B0000),
          ),
        ),
        SizedBox(height: 15),
        _buildPaymentRow("Subtotal Produk", widget.subtotal),
        SizedBox(height: 8),
        _buildPaymentRow("Biaya Pengiriman", widget.shippingFee),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(thickness: 1),
        ),
        _buildPaymentRow(
          "Total Pembayaran",
          widget.total,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Color(0xFF8B0000) : Colors.black87,
          ),
        ),
        Text(
          "Rp ${amount.toStringAsFixed(0)}",
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Color(0xFF8B0000) : Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          "Tracking Pesanan",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFF7EED3),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStatus,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else
                  _buildStatusTimeline(),
                _buildOrderDetails(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationUser(),
    );
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
}
