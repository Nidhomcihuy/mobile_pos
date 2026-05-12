import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti dengan domain Niagahoster kamu
  static const String _baseUrl = 'https://bukitshangrillaasri2.com/api/mobile';

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

  // ─── Settings ────────────────────────────────────────────────────────────────

  static Future<Map<String, String>> fetchSettings() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/settings'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }
    throw Exception('Gagal memuat pengaturan (${response.statusCode})');
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
  /// [proofImagePath] path lokal foto bukti bayar Non Tunai (opsional)
  static Future<Map<String, dynamic>> createTransaction({
    required List<Map<String, dynamic>> items,
    required int paidAmount,
    required String paymentMethod,
    String? proofImagePath,
  }) async {
    if (proofImagePath != null) {
      // Multipart request ketika ada foto bukti bayar
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/transactions'),
      );
      request.headers['Accept'] = 'application/json';
      request.fields['items'] = jsonEncode(items);
      request.fields['paid_amount'] = paidAmount.toString();
      request.fields['payment_method'] = paymentMethod;
      request.files.add(
        await http.MultipartFile.fromPath('payment_proof', proofImagePath),
      );
      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body);
      if (response.statusCode == 201) return body as Map<String, dynamic>;
      throw Exception(
        body['message'] ?? 'Transaksi gagal (${response.statusCode})',
      );
    } else {
      // JSON biasa tanpa foto
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

  // ─── Auth ─────────────────────────────────────────────────────────────────

  /// Login kasir. Mengembalikan map dengan key `token` dan `user`.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['success'] == true) {
      return body;
    }
    throw Exception(body['message'] ?? 'Login gagal (${response.statusCode})');
  }

  /// Logout — hapus token di server.
  static Future<void> logout(String token) async {
    await http
        .post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));
  }
}
