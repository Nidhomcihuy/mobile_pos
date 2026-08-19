import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'screens/kasir.dart';
import 'screens/riwayat.dart';
import 'screens/main_screen.dart';
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
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const Login(),
        '/dashboard': (context) => const MainScreen(initialIndex: 0),
        '/kasir': (context) => const MainScreen(initialIndex: 1),
        '/riwayat': (context) => const MainScreen(initialIndex: 2),
        '/detail': (context) => const Detail(),
        '/pembayaran': (context) => const Pembayaran(),
        '/stok': (context) => const Stok(),
        '/printer': (context) => const PrinterScreen(),
      },
    );
  }
}
