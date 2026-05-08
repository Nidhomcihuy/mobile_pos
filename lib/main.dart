import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
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

  // Cek token tersimpan — jika ada, langsung ke dashboard
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token') ?? '';
  final initialRoute = token.isNotEmpty ? '/dashboard' : '/login';

  // Restore nama kasir jika sudah login sebelumnya
  AppConfig.cashierName = prefs.getString('user_name') ?? '';

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Toserba',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC62828)),
        fontFamily: 'Inter',
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const Login(),
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
