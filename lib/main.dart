//992024008 - Nurmei Sarrah
//992024007 - Zilfany
//992024006 - Masyitah Nanda Yassril
//162022030 - Gilang Ramadhan

import 'package:cafeit_gacor/user/pages/home.dart';
import 'package:cafeit_gacor/admin/pages/home_admin.dart';
import 'package:cafeit_gacor/pages/login.dart';

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
      home: HomePage(),
      routes: {
        'home_admin': (contect) => HomePageAdmin(),
        // 'login_page': (contect) => LoginPage(),
      },
    );
  }
}
