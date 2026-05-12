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
    return 'Rp. $result';
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
      backgroundColor: const Color(0xFFFFEBEE),
      body: Column(
        children: [
          _buildHeader(r, context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                r.space(16),
                r.space(16),
                r.space(16),
                r.space(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImageCard(r, product, isLow),
                  SizedBox(height: r.space(14)),
                  _buildStatRow(r, product, isLow, stock, minStock),
                  SizedBox(height: r.space(14)),
                  _buildStockStatus(r, stock, minStock, isLow),
                  SizedBox(height: r.space(14)),
                  _buildInfoGrid(r, product),
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
      padding: EdgeInsets.symmetric(
        horizontal: r.space(20),
        vertical: r.space(14),
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFC62828),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.space(14),
                  vertical: r.space(8),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: r.space(4)),
                    Text(
                      'Kembali',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: r.font(14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: r.space(12)),
            Expanded(
              child: Text(
                'Detail Produk',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: r.font(20),
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppConfig.storeName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: r.font(13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  AppConfig.todayDate,
                  style: TextStyle(color: Colors.white70, fontSize: r.font(11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(
    Responsive r,
    Map<String, dynamic> product,
    bool isLow,
  ) {
    final imageUrl = (product['image_url'] ?? '').toString();
    final name = (product['name'] ?? '-').toString();
    final category = (product['category'] ?? '-').toString();
    final sku = (product['sku'] ?? '').toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLow
              ? Colors.orange.withValues(alpha: 0.6)
              : const Color(0xFFEF9A9A).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isLow)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: r.space(8)),
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: r.space(6)),
                  Text(
                    'STOK MENIPIS — Segera Restock',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: r.font(13),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.all(r.space(20)),
            child: Row(
              children: [
                Container(
                  width: r.space(120),
                  height: r.space(120),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEF9A9A)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, e, _) => const Icon(
                              Icons.inventory_2,
                              size: 48,
                              color: Color(0xFFC62828),
                            ),
                          )
                        : const Icon(
                            Icons.inventory_2,
                            size: 48,
                            color: Color(0xFFC62828),
                          ),
                  ),
                ),
                SizedBox(width: r.space(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: r.font(18),
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: r.space(4)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.space(10),
                          vertical: r.space(4),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC62828).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: r.font(12),
                            color: const Color(0xFFC62828),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (sku.isNotEmpty) ...[
                        SizedBox(height: r.space(8)),
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code,
                              size: r.icon(14),
                              color: Colors.grey,
                            ),
                            SizedBox(width: r.space(4)),
                            Text(
                              'SKU: $sku',
                              style: TextStyle(
                                fontSize: r.font(12),
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    Responsive r,
    Map<String, dynamic> product,
    bool isLow,
    int stock,
    int minStock,
  ) {
    return Row(
      children: [
        _buildStatCard(
          r,
          label: 'Harga',
          value: _formatPrice((product['price'] as num? ?? 0).toInt()),
          icon: Icons.payments,
          iconColor: const Color(0xFFC62828),
        ),
        SizedBox(width: r.space(10)),
        _buildStatCard(
          r,
          label: 'Stok',
          value: '$stock pcs',
          icon: Icons.inventory_2_outlined,
          iconColor: isLow ? Colors.orange : Colors.green,
          valueColor: isLow ? Colors.orange.shade700 : Colors.green.shade700,
        ),
        SizedBox(width: r.space(10)),
        _buildStatCard(
          r,
          label: 'Min Stok',
          value: '$minStock pcs',
          icon: Icons.low_priority,
          iconColor: Colors.blueGrey,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    Responsive r, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    Color? valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: r.space(12),
          horizontal: r.space(8),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEF9A9A).withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: r.icon(22)),
            SizedBox(height: r.space(4)),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey,
                fontSize: r.font(10),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: r.space(2)),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.black87,
                  fontSize: r.font(13),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatus(Responsive r, int stock, int minStock, bool isLow) {
    return Container(
      padding: EdgeInsets.all(r.space(16)),
      decoration: BoxDecoration(
        color: isLow
            ? Colors.orange.withValues(alpha: 0.08)
            : Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLow ? Colors.orange.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.space(10)),
            decoration: BoxDecoration(
              color: isLow
                  ? Colors.orange.withValues(alpha: 0.15)
                  : Colors.green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLow ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: isLow ? Colors.orange : Colors.green,
              size: r.icon(28),
            ),
          ),
          SizedBox(width: r.space(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLow ? 'Stok Menipis' : 'Stok Aman',
                  style: TextStyle(
                    color: isLow
                        ? Colors.orange.shade800
                        : Colors.green.shade800,
                    fontSize: r.font(15),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: r.space(2)),
                Text(
                  isLow
                      ? 'Stok saat ini ($stock pcs) ≤ batas minimum ($minStock pcs)'
                      : 'Stok saat ini ($stock pcs) di atas batas minimum ($minStock pcs)',
                  style: TextStyle(color: Colors.black54, fontSize: r.font(12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(Responsive r, Map<String, dynamic> product) {
    final expiresAt = (product['expires_at'] ?? product['kadaluarsa'] ?? '')
        .toString();
    final barcode = (product['barcode'] ?? '').toString();
    final sku = (product['sku'] ?? '').toString();
    final ukuran = (product['ukuran'] ?? '').toString();
    final satuan = (product['satuan'] ?? '').toString();

    final rows = <_InfoRow>[
      if (expiresAt.isNotEmpty)
        _InfoRow(
          Icons.event,
          'Kadaluarsa',
          expiresAt,
          _isNearExpiry(expiresAt) ? Colors.red : Colors.black87,
        ),
      if (ukuran.isNotEmpty || satuan.isNotEmpty)
        _InfoRow(
          Icons.straighten,
          'Kemasan',
          [ukuran, satuan].where((s) => s.isNotEmpty).join(' '),
          Colors.black87,
        ),
      if (sku.isNotEmpty) _InfoRow(Icons.tag, 'SKU', sku, Colors.black87),
      if (barcode.isNotEmpty)
        _InfoRow(Icons.qr_code_2, 'Barcode', barcode, Colors.black87),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEF9A9A).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              r.space(16),
              r.space(12),
              r.space(16),
              r.space(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFFC62828),
                  size: r.icon(18),
                ),
                SizedBox(width: r.space(8)),
                Text(
                  'Informasi Lainnya',
                  style: TextStyle(
                    fontSize: r.font(14),
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEF9A9A)),
          ...rows.asMap().entries.map((entry) {
            final row = entry.value;
            final isLast = entry.key == rows.length - 1;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.space(16),
                    vertical: r.space(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        row.icon,
                        size: r.icon(18),
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: r.space(12)),
                      Expanded(
                        child: Text(
                          row.label,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: r.font(13),
                          ),
                        ),
                      ),
                      Text(
                        row.value,
                        style: TextStyle(
                          color: row.valueColor,
                          fontSize: r.font(13),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: r.space(46),
                    color: Colors.grey.shade100,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  bool _isNearExpiry(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final d = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        return d.isBefore(DateTime.now().add(const Duration(days: 30)));
      }
      final d = DateTime.parse(dateStr);
      return d.isBefore(DateTime.now().add(const Duration(days: 30)));
    } catch (_) {
      return false;
    }
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  const _InfoRow(this.icon, this.label, this.value, this.valueColor);
}
