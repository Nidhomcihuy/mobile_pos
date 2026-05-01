import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti dengan domain Niagahoster kamu
  static const String _baseUrl =
      'https://bukitshangrillaasri2.com/api/mobile';

  // ─── Products ───────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchProducts() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/products'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(body['data']);
    }
    throw Exception('Gagal memuat produk (${response.statusCode})');
  }

  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/categories'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(body['data']);
    }
    throw Exception('Gagal memuat kategori (${response.statusCode})');
  }

  // ─── Transactions ────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/transactions'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(body['data']);
    }
    throw Exception('Gagal memuat riwayat transaksi (${response.statusCode})');
  }

  /// [items] contoh: [{'id': 1, 'qty': 2}, {'id': 5, 'qty': 1}]
  static Future<Map<String, dynamic>> createTransaction({
    required List<Map<String, dynamic>> items,
    required int paidAmount,
    required String paymentMethod,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/transactions'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'items': items,
            'paid_amount': paidAmount,
            'payment_method': paymentMethod,
          }),
        )
        .timeout(const Duration(seconds: 20));

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return body as Map<String, dynamic>;
    }
    throw Exception(
      body['message'] ?? 'Transaksi gagal (${response.statusCode})',
    );
  }
}
