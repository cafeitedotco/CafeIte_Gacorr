import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cafeite/utils/restapi.dart'; // API
import 'package:cafeite/utils/model.dart'; // MODEL
import 'package:cafeite/config.dart'; // CONFIG
import 'package:cafeite/adminSemua/admin_makanan/navigation_bar_admin.dart';
import 'package:pie_chart/pie_chart.dart';

class DashboardMakanan extends StatefulWidget {
  const DashboardMakanan({Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<DashboardMakanan> {
  final DataService ds = DataService();

  // Placeholder for counts
  int incomingOrders = 0;
  int ordersCancle = 0;
  int completedOrders = 0;
  List<dynamic> allPesanan = [];
  Map<String, double> dataMap = {};

  @override
  void initState() {
    super.initState();
    fetchAllOrderData();
  }

  Future<void> fetchAllOrderData() async {
    try {
      // Fetch all orders for the dashboard
      List<dynamic> allOrders = await fetchOrders();
      setState(() {
        allPesanan = allOrders;
        incomingOrders = _countOrdersByStatus(allOrders, 'Masuk');
        ordersCancle = _countOrdersByStatus(allOrders, 'Dibatalkan');
        completedOrders = _countOrdersByStatus(allOrders, 'Orderan Selesai');

        // Update Pie Chart data
        dataMap = {
          "Masuk": incomingOrders.toDouble(),
          "Batal": ordersCancle.toDouble(),
          "Selesai": completedOrders.toDouble(),
        };
      });
    } catch (e) {
      // Error handling
      print("Error fetching orders: $e");
    }
  }

  Future<List<dynamic>> fetchOrders() async {
    // Fetch all orders from the API
    final response = await ds.selectAll(token, project, 'pesanan', appid);
    return jsonDecode(response);
  }

  int _countOrdersByStatus(List<dynamic> orders, String status) {
    // Count orders based on their status
    return orders
        .where((order) =>
            order['status_pesanan'] != null &&
            order['status_pesanan'] == status)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF7EED3),
        title: const Text(
          "CafeITe's Dashboard",
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Order status summary cards
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusCard("Total Pesanan", allPesanan.length),
                _buildStatusCard("Orderan Ditbatalkan", ordersCancle),
                _buildStatusCard("Orderan Selesai", completedOrders),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Pie Chart
          Expanded(
            child: dataMap.isNotEmpty
                ? PieChart(
                    dataMap: dataMap,
                    animationDuration: const Duration(milliseconds: 800),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 3.2,
                    colorList: [
                      Colors.blue,
                      const Color.fromARGB(255, 255, 0, 0),
                      Colors.green,
                    ],
                    chartType: ChartType.ring,
                    centerText: "Pesanan",
                    legendOptions: const LegendOptions(
                      showLegends: true,
                      legendPosition: LegendPosition.right,
                      legendShape: BoxShape.circle,
                      legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      decimalPlaces: 1,
                    ),
                  )
                : const Center(child: Text("Tidak ada data untuk ditampilkan")),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationAdminMakanan(),
    );
  }

  Widget _buildStatusCard(String title, int count) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$count",
                style:
                    const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
