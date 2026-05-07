import 'package:flutter/material.dart';
import 'screens/dashboard.dart';
import 'screens/kasir.dart';
import 'screens/riwayat.dart';
import 'screens/stok.dart';
import 'screens/detail.dart';
import 'screens/pembayaran.dart';
import 'screens/printer_screen.dart';
import 'utils/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC62828)),
        fontFamily: 'Inter',
      ),
      initialRoute: '/dashboard',
      routes: {
        '/dashboard': (context) => const Dashboard(),
        '/kasir': (context) => const Kasir(),
        '/riwayat': (context) => const Riwayat(),
        '/detail': (context) => const Detail(),
        '/pembayaran': (context) => const Pembayaran(),
        '/stok': (context) => const Stok(),
        '/printer': (context) => const PrinterScreen(),
      },
    );
  }
}
