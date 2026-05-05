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
          'image': 'assets/icons/Soda.png',
          'category': '-',
          'sku': '-',
          'rak': '-',
          'area': '-',
          'masuk': '-',
          'kadaluarsa': '-',
        };

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE3),
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
                      color: Color(0xFFBDB76B),
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
                            color: const Color(0xFFFFFEE4),
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
                              color: const Color(0xFFD6D2A0),
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
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(product['image'], fit: BoxFit.contain),
            ),
          ),
          SizedBox(height: r.space(16)),
          Text(
            product['name'],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: r.font(24),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'SKU: ${product['sku']}',
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
          _buildInfoCard('Harga', _formatPrice(product['price']), r),
          SizedBox(width: r.space(12)),
          _buildInfoCard('Stok', '${product['stock']} pcs', r),
          SizedBox(width: r.space(12)),
          _buildInfoCard('Kategori', product['category'], r),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.space(24)),
      child: Container(
        margin: EdgeInsets.only(bottom: r.space(16)),
        padding: EdgeInsets.all(r.space(16)),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDE3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFD6D2A0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'TANGGAL MASUK',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: r.font(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: r.space(4)),
                  Text(
                    product['masuk'] ?? '-',
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
              color: const Color(0xFFD6D2A0),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'KADALUARSA',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: r.font(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: r.space(4)),
                  Text(
                    product['kadaluarsa'] ?? '-',
                    style: TextStyle(
                      fontSize: r.font(16),
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.space(24)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(r.space(16)),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.green, size: r.icon(32)),
            SizedBox(width: r.space(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LOKASI PRODUK',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: r.font(14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: r.space(4)),
                  Text(
                    'RAK NOMOR: ${product['rak']}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: r.font(20),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Area: ${product['area']}',
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
        color: Color(0xFFBDB76B),
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
                      color: Color(0xFFFFFEE4),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    AppConfig.storeAddress,
                    style: const TextStyle(color: Color(0xFFFFFEE4)),
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
