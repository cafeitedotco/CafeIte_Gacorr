import 'package:flutter/material.dart';
import 'package:cafeite/kurir/navbar_kurir.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePageKurir(),
    );
  }
}

class HomePageKurir extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kurir Home Page'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Kurir Home Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavigationKurir(),
    );
  }
}
