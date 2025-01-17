import 'package:cafeite/utils/model.dart';
import 'package:cafeite/utils/restapi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPesananAdmin extends StatefulWidget {
  final PesananModel pesanan;

  const DetailPesananAdmin({
    super.key,
    required this.pesanan,
  });

  @override
  _DetailPesananAdminState createState() => _DetailPesananAdminState();
}

class _DetailPesananAdminState extends State<DetailPesananAdmin> {
  final DataService _dataService = DataService();
  bool isLoading = false;
  late Map<String, dynamic> orderDetails;

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    orderDetails = {
      'nama_pemesan': widget.pesanan.username,
      'pesanan': widget.pesanan.pesanan_yang_di_pesan,
      'no_wa': '', // Will be fetched from Firestore
      'alamat': widget.pesanan.alamat,
      'pembayaran': widget.pesanan.pembayaran,
      'pengiriman': widget.pesanan.pengiriman,
      'subtotal_produk': widget.pesanan.subtotal,
      'subtotal_pengiriman': '10000', // Default shipping cost
      'total_pembayaran':
          (double.parse(widget.pesanan.subtotal) + 10000).toString(),
    };
    _fetchAdditionalDetails();
  }

  Future<void> _fetchAdditionalDetails() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.pesanan.userid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          // Gunakan null-aware operator untuk menangani field yang mungkin tidak ada
          orderDetails['no_wa'] = userData['phone'] ??
              userData['phoneNumber'] ?? // cek alternatif field name
              userData['no_telp'] ?? // cek alternatif field name
              'No. WA tidak tersedia';
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
      setState(() {
        orderDetails['no_wa'] = 'No. WA tidak tersedia';
      });
    }
  }

  Widget _buildStatusButton(
      String status, String currentStatus, VoidCallback onPressed) {
    bool isActive = status == currentStatus;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Color(0xFF8B0000) : Colors.white,
          foregroundColor: isActive ? Colors.white : Color(0xFF8B0000),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Color(0xFF8B0000),
              width: 1,
            ),
          ),
          elevation: isActive ? 4 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive) ...[
              Icon(
                Icons.check_circle,
                size: 18,
                color: Colors.white,
              ),
              SizedBox(width: 8),
            ],
            Text(
              status,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFFF7EED3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.update, color: Color(0xFF8B0000)),
                SizedBox(width: 8),
                Text(
                  'Status Pesanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B0000),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Color(0xFFF7EED3)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _buildStatusButton(
                  "Makanan Sedang Dibuat",
                  widget.pesanan.status_pesanan,
                  () => _updateOrderStatus("Makanan Sedang Dibuat"),
                ),
                _buildStatusButton(
                  "Makanan Sedang Diantar",
                  widget.pesanan.status_pesanan,
                  () => _updateOrderStatus("Makanan Sedang Diantar"),
                ),
                _buildStatusButton(
                  "Kurir Telah Sampai",
                  widget.pesanan.status_pesanan,
                  () => _updateOrderStatus("Kurir Telah Sampai"),
                ),
                _buildStatusButton(
                  "Orderan Selesai",
                  widget.pesanan.status_pesanan,
                  () => _showConfirmationDialog(
                    "Selesaikan Pesanan",
                    "Apakah Anda yakin ingin menyelesaikan pesanan ini?",
                    () => _updateOrderStatus("Orderan Selesai"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() => isLoading = true);
    try {
      // Print debugging info
      print('Updating status for:');
      print('Document ID: ${widget.pesanan.id}');
      print('Order ID: ${widget.pesanan.order_id}');
      print('New Status: $newStatus');

      // Gunakan order_id untuk referensi dokumen
      final docRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.pesanan.order_id);

      // Update di Firebase
      await docRef.update({
        'status_pesanan': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
        'updated_by': FirebaseAuth.instance.currentUser?.uid,
      });

      // Update di REST API
      final bool success = await _dataService.updateOrderStatus(
        widget.pesanan.order_id,
        newStatus,
      );

      if (!success) {
        print('Warning: REST API update failed, but Firebase update succeeded');
      }

      // Update local state
      setState(() {
        widget.pesanan.status_pesanan = newStatus;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diperbarui ke "$newStatus"'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating status: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF8B0000), size: 24),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B0000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {IconData? icon}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFFF7EED3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Color(0xFF8B0000), size: 20),
              SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPesananItem(String name, String note, String quantity) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFFF7EED3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(0xFFF7EED3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.restaurant_menu, color: Color(0xFF8B0000)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (note.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Catatan: $note',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF8B0000),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${quantity}x',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFFF7EED3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal Produk',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'Rp ${orderDetails['subtotal_produk']}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Biaya Pengiriman',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Rp ${orderDetails['subtotal_pengiriman']}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Divider(color: Color(0xFFF7EED3)),
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF8B0000),
                    ),
                  ),
                  Text(
                    'Rp ${orderDetails['total_pembayaran']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF8B0000),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> parsedPesanan =
        widget.pesanan.pesanan_yang_di_pesan.split(',').map((item) {
      final parts = item.trim().split(' (');
      final quantity = parts.length > 1 ? parts[1].replaceAll('x)', '') : '1';
      return {
        'name': parts[0],
        'quantity': quantity,
        'note': '',
      };
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Detail Pesanan',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFF7EED3),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Section di awal
                _buildStatusSection(),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Information Section
                      _buildSectionHeader('Informasi Pelanggan', Icons.person),
                      _buildDetailItem(
                          'Nama Pemesan', orderDetails['nama_pemesan'],
                          icon: Icons.account_circle),
                      SizedBox(height: 8),
                      _buildDetailItem('No WA', orderDetails['no_wa'],
                          icon: Icons.phone),
                      SizedBox(height: 8),
                      _buildDetailItem('Alamat', orderDetails['alamat'],
                          icon: Icons.location_on),

                      // Order Information Section
                      _buildSectionHeader(
                          'Informasi Pesanan', Icons.receipt_long),
                      ...parsedPesanan.map((item) => _buildPesananItem(
                            item['name']!,
                            item['note']!,
                            item['quantity']!,
                          )),

                      // Payment Information Section
                      _buildSectionHeader(
                          'Informasi Pembayaran', Icons.payment),
                      _buildDetailItem(
                          'Metode Pembayaran', orderDetails['pembayaran'],
                          icon: Icons.account_balance_wallet),
                      SizedBox(height: 8),
                      _buildDetailItem(
                          'Metode Pengiriman', orderDetails['pengiriman'],
                          icon: Icons.delivery_dining),
                      SizedBox(height: 16),
                      _buildPaymentSummary(),

                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
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
            child: Text('Batal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Ya'),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
          ),
        ],
      ),
    );
  }
}
