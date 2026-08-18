import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../utils/app_config.dart';

class Detail extends StatelessWidget {
  const Detail({super.key});

  String _formatPrice(int price) {
    String priceStr = price.toString();
    String result = '';
    int count = 0;
    for (int i = priceStr.length - 1; i >= 0; i--) {
      result = priceStr[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final Map<String, dynamic> product =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
        {
          'name': 'Produk Tidak Ditemukan',
          'price': 0,
          'stock': 0,
          'image_url': '',
          'category': '-',
        };

    final int stock = (product['stock'] as num? ?? 0).toInt();
    final int minStock = (product['min_stock'] as num? ?? 0).toInt();
    final bool isLow = stock <= minStock && minStock > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildHeader(r, context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(r.space(20)),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildMainImageCard(r, product, isLow),
                  const SizedBox(height: 20),
                  _buildPriceAndStockGrid(r, product, stock, minStock, isLow),
                  const SizedBox(height: 20),
                  _buildStatusBanner(r, stock, minStock, isLow),
                  const SizedBox(height: 20),
                  _buildDetailedInfoList(r, product),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Responsive r, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(r.space(20), r.space(52), r.space(20), r.space(24)),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Detail Produk',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Inter'),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildMainImageCard(Responsive r, Map<String, dynamic> product, bool isLow) {
    final imageUrl = (product['image_url'] ?? '').toString();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Container(
            height: r.space(220),
            padding: const EdgeInsets.all(32),
            child: Hero(
              tag: 'prod-${product['id']}',
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_rounded, size: 80, color: Color(0xFFC62828)))
                  : const Icon(Icons.inventory_2_rounded, size: 80, color: Color(0xFFC62828)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                Text(
                  product['name'] ?? '-',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Inter'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFC62828).withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    product['category'] ?? '-',
                    style: const TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndStockGrid(Responsive r, Map<String, dynamic> product, int stock, int minStock, bool isLow) {
    return Row(
      children: [
        _infoBox(r, 'Harga Jual', _formatPrice((product['price'] as num? ?? 0).toInt()), Icons.payments_rounded, const Color(0xFFC62828)),
        const SizedBox(width: 12),
        _infoBox(r, 'Stok Saat Ini', '$stock Pcs', Icons.inventory_2_rounded, isLow ? Colors.orange : Colors.green),
        const SizedBox(width: 12),
        _infoBox(r, 'Min. Stok', '$minStock Pcs', Icons.low_priority_rounded, Colors.blueGrey),
      ],
    );
  }

  Widget _infoBox(Responsive r, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            FittedBox(child: Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color))),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(Responsive r, int stock, int minStock, bool isLow) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLow ? Colors.orange[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isLow ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(isLow ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded, color: isLow ? Colors.orange[800] : Colors.green[800], size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isLow ? 'Stok Perlu Ditambah' : 'Kondisi Stok Aman', style: TextStyle(fontWeight: FontWeight.w900, color: isLow ? Colors.orange[900] : Colors.green[900])),
                Text(
                  isLow ? 'Stok di bawah batas minimum $minStock pcs.' : 'Jumlah stok mencukupi untuk transaksi.',
                  style: TextStyle(fontSize: 12, color: isLow ? Colors.orange[700] : Colors.green[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfoList(Responsive r, Map<String, dynamic> product) {
    final expiresAt = (product['expires_at'] ?? product['kadaluarsa'] ?? '').toString();
    final sku = (product['sku'] ?? '-').toString();
    final barcode = (product['barcode'] ?? '-').toString();
    final ukuran = (product['ukuran'] ?? '').toString();
    final satuan = (product['satuan'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFFC62828), size: 18),
              SizedBox(width: 8),
              Text('Informasi Inventaris', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 24),
          _infoRow('SKU Produk', sku),
          _infoRow('Barcode', barcode),
          _infoRow('Kemasan', [ukuran, satuan].where((s) => s.isNotEmpty).join(' ')),
          _infoRow('Tgl Kadaluarsa', expiresAt, isLast: true, color: _isNearExpiry(expiresAt) ? Colors.red : null),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isLast = false, Color? color}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600, fontSize: 13)),
            Text(value.isEmpty ? '-' : value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color ?? Colors.black87)),
          ],
        ),
        if (!isLast) Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.grey[100])),
      ],
    );
  }

  bool _isNearExpiry(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final d = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        return d.isBefore(DateTime.now().add(const Duration(days: 30)));
      }
      return false;
    } catch (_) { return false; }
  }
}
