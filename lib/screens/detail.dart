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

    // Mengambil data produk yang dikirim dari Dashboard
    final Map<String, dynamic> product =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
        {
          'name': 'Produk Tidak Ditemukan',
          'price': 0,
          'stock': 0,
          'image_url': '',
          'category': '-',
        };

    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
      body: Column(
        children: [
          _buildHeader(r),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(r.space(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title bar
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: r.space(20),
                      vertical: r.space(14),
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC62828),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Detail Produk',
                          style: TextStyle(
                            color: const Color(0xFFFFFFFF),
                            fontSize: r.font(24),
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.space(20),
                              vertical: r.space(10),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF9A9A),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF919191),
                              ),
                            ),
                            child: Text(
                              'Kembali',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: r.font(16),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Body
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF818080)),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildProductImageSection(r, product),
                        _buildInfoSection(r, product),
                        _buildDateSection(
                          r,
                          product,
                        ), // Tambahkan Bagian Tanggal
                        _buildLocationSection(r, product),
                        SizedBox(height: r.space(24)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImageSection(Responsive r, Map<String, dynamic> product) {
    final imageUrl = (product['image_url'] ?? '').toString();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.space(24)),
      decoration: const BoxDecoration(
        color: Color(0xFFFDF5D8),
        border: Border(bottom: BorderSide(color: Color(0x7FD8B84B), width: 2)),
      ),
      child: Column(
        children: [
          Container(
            width: r.space(180),
            height: r.space(180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _e, __) => const Icon(
                        Icons.inventory_2,
                        size: 64,
                        color: Color(0xFFC62828),
                      ),
                    )
                  : const Icon(
                      Icons.inventory_2,
                      size: 64,
                      color: Color(0xFFC62828),
                    ),
            ),
          ),
          SizedBox(height: r.space(16)),
          Text(
            (product['name'] ?? '-').toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: r.font(24),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            (product['category'] ?? '-').toString(),
            style: TextStyle(color: Colors.grey, fontSize: r.font(16)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Responsive r, Map<String, dynamic> product) {
    return Padding(
      padding: EdgeInsets.all(r.space(24)),
      child: Row(
        children: [
          _buildInfoCard(
            'Harga',
            _formatPrice((product['price'] as num? ?? 0).toInt()),
            r,
          ),
          SizedBox(width: r.space(12)),
          _buildInfoCard('Stok', '${product['stock'] ?? 0} pcs', r),
          SizedBox(width: r.space(12)),
          _buildInfoCard('Min Stok', '${product['min_stock'] ?? 0} pcs', r),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Responsive r) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(r.space(12)),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF5D8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0x7FD8B84B)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey,
                fontSize: r.font(11),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: r.space(4)),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: r.font(15),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(Responsive r, Map<String, dynamic> product) {
    final category = (product['category'] ?? '-').toString();
    final minStock = (product['min_stock'] ?? 0).toString();
    final stock = (product['stock'] ?? 0) as num;
    final isLow = stock <= (product['min_stock'] ?? 0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.space(24)),
      child: Container(
        margin: EdgeInsets.only(bottom: r.space(16)),
        padding: EdgeInsets.all(r.space(16)),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFEF9A9A)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'KATEGORI',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: r.font(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: r.space(4)),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: r.font(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: r.space(40),
              color: const Color(0xFFEF9A9A),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'MIN STOK',
                    style: TextStyle(
                      color: isLow ? Colors.redAccent : Colors.grey,
                      fontSize: r.font(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: r.space(4)),
                  Text(
                    minStock,
                    style: TextStyle(
                      fontSize: r.font(16),
                      fontWeight: FontWeight.bold,
                      color: isLow ? Colors.red : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(Responsive r, Map<String, dynamic> product) {
    final stock = (product['stock'] ?? 0) as num;
    final minStock = (product['min_stock'] ?? 0) as num;
    final isLow = stock <= minStock;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.space(24)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(r.space(16)),
        decoration: BoxDecoration(
          color: isLow ? const Color(0xFFFFEBEE) : const Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isLow ? Colors.red.shade200 : Colors.green.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isLow ? Icons.warning_amber_rounded : Icons.check_circle,
              color: isLow ? Colors.red : Colors.green,
              size: r.icon(32),
            ),
            SizedBox(width: r.space(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLow ? 'STOK MENIPIS' : 'STOK AMAN',
                    style: TextStyle(
                      color: isLow
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                      fontSize: r.font(14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: r.space(4)),
                  Text(
                    'Sisa stok: $stock pcs',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: r.font(20),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Batas minimum: $minStock pcs',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: r.font(14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Responsive r) {
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
            const Icon(Icons.store, color: Colors.white, size: 28),
            SizedBox(width: r.space(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConfig.storeName,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    AppConfig.storeAddress,
                    style: const TextStyle(color: Color(0xFFFFFFFF)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
