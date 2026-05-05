import 'api_service.dart';

/// Singleton yang menyimpan informasi toko dari API.
/// Panggil [AppConfig.init()] sekali di main.dart sebelum runApp.
class AppConfig {
  AppConfig._();

  static String storeName = 'POS';
  static String storeAddress = '';
  static String cashierName = '';

  static String get todayDate {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
  }

  static Future<void> init() async {
    try {
      final settings = await ApiService.fetchSettings();
      storeName = settings['store_name'] ?? storeName;
      storeAddress = settings['store_address'] ?? storeAddress;
      cashierName = settings['cashier_name'] ?? cashierName;
    } catch (_) {
      // Tetap pakai nilai default jika tidak ada koneksi
    }
  }
}
