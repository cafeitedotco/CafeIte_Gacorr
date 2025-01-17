import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cafeite/utils/model.dart';
import 'package:cafeite/utils/restapi.dart';
import 'package:cafeite/config.dart';
import 'package:cafeite/admin/navigation_bar_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PesananAdmin extends StatefulWidget {
  const PesananAdmin({Key? key}) : super(key: key);

  @override
  _PesananAdminState createState() => _PesananAdminState();
}

class _PesananAdminState extends State<PesananAdmin> {
  List<PesananModel> pesananMasuk = [];
  List<PesananModel> pesananDiproses = [];
  DataService ds = DataService();

  @override
  void initState() {
    super.initState();
    fetchAllPesananDiproses();
    fetchAllPesananMasuk();
  }

  Future<void> fetchAllPesananDiproses() async {
    try {
      // Use selectWhere to fetch only orders where status_pesanan is "Diproses"
      String response = await ds.selectWhere(
        token,
        project,
        'pesanan',
        appid,
        'status_pesanan',
        'Makanan Sedang Dibuat',
      );
      List data = jsonDecode(response);

      List<PesananModel> orders = [];
      for (var orderData in data) {
        PesananModel order = PesananModel.fromJson(orderData);
        orders.add(order);
      }

      setState(() {
        pesananDiproses = orders; // Store only processed orders
      });
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  Future<void> fetchAllPesananMasuk() async {
    try {
      // Use selectWhere to fetch only orders where status_pesanan is "masuk"
      String response = await ds.selectWhere(
        token,
        project,
        'pesanan',
        appid,
        'status_pesanan',
        'Masuk',
      );
      List data = jsonDecode(response);

      List<PesananModel> orders = [];
      for (var orderData in data) {
        PesananModel order = PesananModel.fromJson(orderData);
        orders.add(order);
      }

      setState(() {
        pesananMasuk = orders; // Store only incoming orders
      });
    } catch (e) {
      print("Error fetching incoming orders: $e");
    }
  }

  Future<String> updatePesananStatus(String id, String newStatus) async {
    try {
      String response = await ds.updateId(
        'status_pesanan',
        newStatus,
        token,
        project,
        'pesanan',
        appid,
        id,
      );

      if (response.isEmpty) {
        return "Status berhasil diperbarui";
      } else {
        return "Gagal memperbarui status";
      }
    } catch (e) {
      print("Error updating order status: $e");
      return "Terjadi kesalahan";
    }
  }

  Future<Map<String, String>> fetchUserInfo(String userId) async {
    String username = "Pengguna Tidak Diketahui"; // Default username
    String status = "Status Tidak Diketahui"; // Default status
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;
        username = userData?['username'] ?? "Pengguna Tidak Diketahui";
        status = userData?['status'] ?? "Status Tidak Diketahui";
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
    return {'username': username, 'status': status};
  }

  void showConfirmationDialog(
      String action, PesananModel order, Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi $action"),
          content: Text(
              "Apakah Anda yakin ingin $action pesanan '${order.pesanan_yang_di_pesan}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              child: const Text("Ya"),
            ),
          ],
        );
      },
    );
  }

  Widget buildIncomingOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Pesanan Masuk",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...pesananMasuk.map((order) {
          return FutureBuilder<Map<String, String>>(
            future: fetchUserInfo(order.userid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error fetching user info");
              } else {
                String username =
                    snapshot.data?['username'] ?? "Pengguna Tidak Diketahui";
                String status =
                    snapshot.data?['status'] ?? "Status Tidak Diketahui";
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: const Color(0xFFEFE5D2),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(username,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(status, style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Text(order.pesanan_yang_di_pesan),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            showConfirmationDialog("menghapus", order, () {
                              setState(() {
                                pesananMasuk.remove(order);
                              });
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            showConfirmationDialog("memproses", order,
                                () async {
                              if (order.id.isNotEmpty) {
                                String success = await updatePesananStatus(
                                    order.id, "Diproses");
                                setState(() {
                                  pesananDiproses.add(order);
                                  pesananMasuk.remove(order);
                                });
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        }).toList(),
      ],
    );
  }

  Widget buildProcessedOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("List Pesanan Diproses",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        // Display only processed orders
        ...pesananDiproses.map((order) {
          return FutureBuilder<Map<String, String>>(
            future: fetchUserInfo(order.userid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error fetching user info");
              } else {
                String username =
                    snapshot.data?['username'] ?? "Pengguna Tidak Diketahui";
                String status =
                    snapshot.data?['status'] ?? "Status Tidak Diketahui";
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(username,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(status, style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Text(order.pesanan_yang_di_pesan),
                        // Display the status_pesanan below pesanan_yang_di_pesan
                        Text("Status: ${order.status_pesanan}",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    trailing:
                        Text("Detail", style: TextStyle(color: Colors.blue)),
                    onTap: () {
                      // Navigate to order detail page
                    },
                  ),
                );
              }
            },
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan Customer"),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7EED3),
      ),
      body: Column(
        children: [
          Expanded(
            child: pesananMasuk.isEmpty && pesananDiproses.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      buildIncomingOrders(),
                      const SizedBox(height: 20),
                      buildProcessedOrders(),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationAdmin(),
    );
  }
}
