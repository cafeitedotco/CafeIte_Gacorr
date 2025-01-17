//992024006 - Masyitah Nanda Yassril
//992024008 - Nurmei Sarrah
//992024007 - Zilfany
//162022030 - Gilang Ramadhan

// ignore_for_file: unused_import

import 'package:cafeite/user/pages/home_user.dart';
import 'package:cafeite/admin/pages/home_admin.dart';
import 'package:cafeite/kurir/home_kurir.dart';
import 'package:cafeite/home.dart';
import 'package:cafeite/pages/login.dart';
import 'package:device_preview/device_preview.dart';
import 'package:cafeite/kurir/loginpage_kurir.dart';
import 'package:cafeite/kurir/registerpage_kurir.dart';
import 'package:cafeite/kurir/pengiriman.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFF4A261)),
        useMaterial3: true,
      ),
      home:
          HomePageKurir(), //it should be the first route for each user to loggin' in
      routes: {
        'home_admin': (contect) => HomePageAdmin(),
        'loginpage_kurir': (contect) => LoginPageKurir(),
        'pengiriman': (contect) => PengirimanPage(),
        'home_user': (contect) => HomePageUser(),
        'home_kurir': (context) => HomePageKurir(),
        'login_page': (contect) => LoginPage(),
      },
    );
  }
}
