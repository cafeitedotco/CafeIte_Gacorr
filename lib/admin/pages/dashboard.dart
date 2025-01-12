import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cafeite/utils/restapi.dart'; // API
import 'package:cafeite/utils/model.dart'; // MODEL
import 'package:cafeite/config.dart'; // CONFIG
import 'package:cafeite/admin/navigation_bar_admin.dart';
import 'package:pie_chart/pie_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  final searchKeyword = TextEditingController();
  DataService ds = DataService();
  List<MakananberatModel> makananberat = [];

  // Placeholder for counts
  int incomingOrders = 0;
  int ordersInProcess = 0;

  // Date selection variables
  DateTime? selectedDate;

  // Data map for Pie Chart
  Map<String, double> dataMap = {};

  @override
  void initState() {
    super.initState();
    fetchMakananberat(); // Fetch data on initialization
    fetchIncomingOrders(); // Fetch incoming orders
    fetchOrdersInProcess(); // Fetch orders in process
  }

  Future<void> fetchMakananberat() async {
    final response = await ds.selectAll(
        token, project, 'makananberat', appid); // Fetch all data

    // Print the raw response for debugging
    print("API Response: $response");

    List data = jsonDecode(response);
    print("Decoded data: $data"); // Check the structure of the decoded data

    setState(() {
      makananberat = data.map((e) => MakananberatModel.fromJson(e)).toList();

      // Print the fetched categories
      print(
          "Fetched categories: ${makananberat.map((e) => e.kategori).toList()}");

      // Build dataMap from makananberat
      dataMap = {};
      for (var item in makananberat) {
        // Count occurrences of each category
        dataMap[item.kategori] =
            (dataMap[item.kategori] ?? 0) + 1; // Count the categories
      }

      print("DataMap: $dataMap"); // Check the built dataMap
    });
  }

  Future<void> fetchIncomingOrders() async {
    final response = await ds.selectAll(token, project, 'pesanan', appid);
    List data = jsonDecode(response);

    setState(() {
      incomingOrders = data.length; // Use the length of the response
    });
  }

  Future<void> fetchOrdersInProcess() async {
    final response = await ds.selectAll(token, project, 'pesanan', appid);
    List data = jsonDecode(response);

    setState(() {
      ordersInProcess = data.length; // Use the length of the response
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF7EED3),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "CafeITe's Menu",
              style: TextStyle(fontSize: 20),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Implement your insert dialog here
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text("Hari/Tgl:"),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.white, // Set button background color
                  ),
                  child: Text(
                    selectedDate == null
                        ? 'Select Date'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    style: TextStyle(
                        color: Colors.black), // Change text color to black
                  ),
                ),
              ],
            ),
          ),
          // Row for three cards
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
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
                            "${makananberat.length}",
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "TOTAL PESANAN",
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
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
                            "$incomingOrders",
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "PESANAN MASUK",
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
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
                            "$ordersInProcess",
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "PESANAN DIPROSES",
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Pie Chart
          Expanded(
            child: dataMap.isNotEmpty
                ? PieChart(
                    dataMap: dataMap,
                    animationDuration: Duration(milliseconds: 800),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 3.2,
                    colorList: [
                      Colors.blue,
                      Colors.green,
                      Colors.red,
                      Colors.orange,
                    ],
                    chartType: ChartType.ring,
                    centerText: "Kategori makanan",
                    legendOptions: LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.right,
                      showLegends: true,
                      legendShape: BoxShape.circle,
                      legendTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: false,
                      showChartValuesOutside: false,
                      decimalPlaces: 1,
                    ),
                  )
                : Center(child: Text("No data available")),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationAdmin(),
    );
  }
}
