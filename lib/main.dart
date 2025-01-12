//992024008 - Nurmei Sarrah
//992024007 - Zilfany
//992024006 - Masyitah Nanda Yassril
//162022030 - Gilang Ramadhan

// ignore_for_file: unused_import

import 'package:cafeite/user/pages/home_user.dart';
import 'package:cafeite/admin/pages/home_admin.dart';
import 'package:cafeite/admin/pages/Dashboard.dart';
import 'package:cafeite/pages/login.dart';
import 'package:device_preview/device_preview.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'cafeITe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Dashboard(),
      routes: {
        'home_admin': (contect) => HomePageAdmin(),
        'home_user': (contect) => HomePageUser(),
        'login_page': (contect) => LoginPage(),
      },
    );
  }
}
