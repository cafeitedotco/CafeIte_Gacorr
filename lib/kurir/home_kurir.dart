import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kurir Home Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
    );
  }
}
