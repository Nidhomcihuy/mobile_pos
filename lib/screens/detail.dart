import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../utils/responsive_helper.dart';

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

  bool _isNearExpiry(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final d = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        return d.isBefore(DateTime.now().add(const Duration(days: 30)));
      }
      return false;
    } catch (_) {
      return false;
    }
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
    final imageUrl = (product['image_url'] ?? '').toString();

    final expiresAt = (product['expires_at'] ?? product['kadaluarsa'] ?? '').toString();
    final sku = (product['sku'] ?? '-').toString();
    final barcode = (product['barcode'] ?? '-').toString();
    final ukuran = (product['ukuran'] ?? '').toString();
    final satuan = (product['satuan'] ?? '').toString();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: r.space(350),
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.white.withOpacity(0.8),
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.back, color: Color(0xFF0F172A)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFF8FAFC),
                child: Hero(
                  tag: 'prod-${product['id']}',
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(CupertinoIcons.cube_box, size: 80, color: Color(0xFFCBD5E1)),
                          ),
                        )
                      : const Center(
                          child: Icon(CupertinoIcons.cube_box, size: 80, color: Color(0xFFCBD5E1)),
                        ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(r.space(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product['name'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF0F172A),
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _formatPrice((product['price'] as num? ?? 0).toInt()),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFC62828),
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildPill(product['category'] ?? '-', CupertinoIcons.tag_fill, const Color(0xFFF1F5F9), const Color(0xFF475569)),
                            const SizedBox(width: 12),
                            _buildPill('$stock Tersedia', CupertinoIcons.cube_box_fill, isLow ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5), isLow ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(color: const Color(0xFFF1F5F9), thickness: 8, height: 8),
                  Padding(
                    padding: EdgeInsets.all(r.space(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detail Produk',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Inter', color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow('SKU', sku),
                        _buildDetailRow('Barcode', barcode),
                        _buildDetailRow('Kemasan', [ukuran, satuan].where((s) => s.isNotEmpty).join(' ')),
                        _buildDetailRow('Minimal Stok', '$minStock'),
                        _buildDetailRow(
                          'Kadaluarsa',
                          expiresAt.isEmpty ? '-' : expiresAt,
                          valueColor: _isNearExpiry(expiresAt) ? const Color(0xFFEF4444) : null,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  if (isLow)
                    Container(
                      margin: EdgeInsets.all(r.space(24)),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Color(0xFFEF4444), size: 24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Stok Menipis', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF991B1B), fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('Sisa stok berada di bawah batas minimum ($minStock). Segera lakukan *restock*.', style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: r.space(40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String label, IconData icon, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false, Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? const Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
