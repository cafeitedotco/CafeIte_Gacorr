// lib/screens/pesanan_admin.dart

import 'dart:async';

import 'package:cafeite/adminSemua/admin_snack/pages/detail_pemesanan.dart';
import 'package:cafeite/adminSemua/admin_snack/navigation_bar_admin.dart';
import 'package:cafeite/utils/model.dart';
import 'package:cafeite/utils/restapi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PesananAdmin extends StatefulWidget {
  const PesananAdmin({super.key});

  @override
  _PesananAdminState createState() => _PesananAdminState();
}

class _PesananAdminState extends State<PesananAdmin>
    with TickerProviderStateMixin {
  final DataService _dataService = DataService();
  final TextEditingController _searchController = TextEditingController();
  List<PesananModel> pesananMasuk = [];
  List<PesananModel> pesananDiproses = [];
  bool isLoading = true;
  StreamSubscription? _ordersSubscription;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _setupOrdersListener();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _setupOrdersListener() {
    _ordersSubscription =
        FirebaseFirestore.instance.collection('orders').snapshots().listen((_) {
      // Refresh data setiap kali ada perubahan di collection orders
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);
    try {
      print('Loading orders...'); // Debug print
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('tanggal', descending: true)
          .get();

      final List<PesananModel> allOrders = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['order_id'] = doc.id; // Use document ID as order_id if not present
        print(
            'Processing order: ${doc.id} with status: ${data['status_pesanan']}'); // Debug print
        return PesananModel.fromJson(data);
      }).toList();

      setState(() {
        pesananMasuk = allOrders
            .where((order) => order.status_pesanan == 'Masuk')
            .toList();

        pesananDiproses = allOrders
            .where((order) =>
                order.status_pesanan != 'Masuk' &&
                order.status_pesanan != 'Orderan Selesai')
            .toList();

        isLoading = false;
      });

      print('Loaded ${allOrders.length} orders'); // Debug print
      print(
          'Masuk: ${pesananMasuk.length}, Diproses: ${pesananDiproses.length}'); // Debug print
    } catch (e) {
      print('Error loading orders: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleOrderAction(PesananModel order, String action) async {
    try {
      setState(() => isLoading = true);

      if (action == 'accept') {
        print('Processing order: ${order.order_id}'); // Debug print

        // Update di Firestore
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(order.order_id)
            .update({
          'status_pesanan': 'Diproses',
          'updated_at': FieldValue.serverTimestamp(),
        });

        print('Firestore update successful'); // Debug print

        // Update di REST API
        bool success = await _dataService.updateOrderStatus(
          order.order_id,
          'Diproses',
        );

        print('REST API update: $success'); // Debug print

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Pesanan berhasil diterima dan masuk ke List Pesanan'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh data
          await _loadOrders();
        } else {
          throw Exception('Gagal mengupdate status pesanan di REST API');
        }
      }

      setState(() => isLoading = false);
    } catch (e) {
      print('Error handling order action: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      _loadOrders();
      return;
    }

    try {
      final searchResults = await _dataService.searchOrders(query);
      setState(() {
        pesananMasuk = searchResults
            .where((order) => order.status_pesanan == 'Masuk')
            .toList();

        pesananDiproses = searchResults
            .where((order) =>
                order.status_pesanan != 'Masuk' &&
                order.status_pesanan != 'Orderan Selesai')
            .toList();
      });
    } catch (e) {
      print('Error searching orders: $e');
    }
  }

  Widget _buildOrderCard(PesananModel order, bool isIncoming) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: const Color(0xFFF7EED3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order ID: ${order.order_id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isIncoming)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B0000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status_pesanan,
                      style: const TextStyle(
                        color: Color(0xFF8B0000),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.pesanan_yang_di_pesan,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: Rp ${order.total}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B0000),
                  ),
                ),
                if (isIncoming)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        color: Colors.green,
                        onPressed: () => _showConfirmationDialog(
                          'Terima Pesanan',
                          'Apakah Anda yakin ingin menerima pesanan ini?',
                          () => _handleOrderAction(order, 'accept'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined),
                        color: Colors.red,
                        onPressed: () => _showConfirmationDialog(
                          'Tolak Pesanan',
                          'Apakah Anda yakin ingin menolak pesanan ini?',
                          () => _handleOrderAction(order, 'reject'),
                        ),
                      ),
                    ],
                  )
                else
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPesananAdmin(pesanan: order),
                        ),
                      ).then((_) => _loadOrders());
                    },
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Detail'),
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF8B0000),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(
      String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Ya'),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pesanan Customer',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7EED3),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF8B0000),
          labelColor: const Color(0xFF8B0000),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Pesanan Masuk'),
            Tab(text: 'List Pesanan'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearch,
              decoration: InputDecoration(
                hintText: 'Cari pesanan...',
                filled: true,
                fillColor: const Color(0xFFF7EED3).withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Pesanan Masuk
                RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : pesananMasuk.isEmpty
                          ? const Center(child: Text('Tidak ada pesanan masuk'))
                          : ListView.builder(
                              itemCount: pesananMasuk.length,
                              itemBuilder: (context, index) =>
                                  _buildOrderCard(pesananMasuk[index], true),
                            ),
                ),
                // Tab List Pesanan
                RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : pesananDiproses.isEmpty
                          ? const Center(
                              child: Text('Tidak ada pesanan diproses'))
                          : ListView.builder(
                              itemCount: pesananDiproses.length,
                              itemBuilder: (context, index) => _buildOrderCard(
                                  pesananDiproses[index], false),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationAdminSnack(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _ordersSubscription?.cancel();

    super.dispose();
  }
}
