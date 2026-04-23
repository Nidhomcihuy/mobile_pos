import 'package:flutter/material.dart';
import 'screens/dashboard.dart';
import 'screens/kasir.dart';
import 'screens/riwayat.dart';
import 'screens/detail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Toserba',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFBDB76B)),
        fontFamily: 'Inter',
      ),
      initialRoute: '/dashboard',
      routes: {
        '/dashboard': (context) => const Dashboard(),
        '/kasir': (context) => const Kasir(),
        '/riwayat': (context) => const Riwayat(),
        '/detail': (context) => const Detail(),
      },
    );
  }
}
