//992024008 - Nurmei Sarrah
//992024007 - Zilfany
//992024006 - Masyitah Nanda Yassril
//162022030 - Gilang Ramadhan

// ignore_for_file: unused_import, duplicate_import

import 'package:cafeite/cust/pages/cart_provider.dart';
import 'package:cafeite/cust/pages/home_user.dart';
import 'package:cafeite/adminSemua/admin_makanan/pages/home_admin.dart';
import 'package:cafeite/adminSemua/admin_snack/pages/home_admin.dart';
import 'package:cafeite/adminSemua/admin_minuman/pages/home_admin.dart';

import 'package:cafeite/cust/pages/login.dart';
import 'package:cafeite/cust/pages/register.dart';
import 'package:cafeite/home.dart';
import 'package:cafeite/kurir/pages/home_kurir.dart';
import 'package:cafeite/pages/landingpage.dart';
import 'package:cafeite/kurir/pages/pengiriman.dart';
import 'package:device_preview/device_preview.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
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
      home: WelcomeScreen(),
      routes: {
        'home_kurir': (context) => HomePageKurir(),
        'home_admin': (context) => HomePageAdminSnack(),
        'home_admin': (context) => HomePageAdminMinuman(),
        'home_admin': (context) => HomePageAdminMakanan(),
        'home_user': (context) => HomePageUser(),
        'pengirimanpage': (context) => PengirimanPage(),
        'home': (contexxt) => HomePage(),
        'landingpage': (context) => WelcomeScreen(),
      },
    );
  }
}
