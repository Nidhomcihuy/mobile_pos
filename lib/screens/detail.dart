import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class Detail extends StatefulWidget {
  const Detail({super.key});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  int _qty = 1;

  void _increment() => setState(() => _qty++);
  void _decrement() {
    if (_qty > 1) setState(() => _qty--);
  }

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
    const int unitPrice = 3500;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE3),
      body: Column(
        children: [
          _buildHeader(r),
          // Detail content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(r.space(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title bar
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: r.space(20), vertical: r.space(14)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBDB76B),
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
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: r.space(20), vertical: r.space(10)),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6D2A0),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF919191)),
                            ),
                            child: Text(
                              'Kembali',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: r.font(20),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Side-by-side on wider screens, stacked on narrow
                        if (constraints.maxWidth > 600) {
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left: product image + name
                                _buildProductImageSection(r, constraints.maxWidth * 0.35),
                                // Right: info cards + actions
                                Expanded(child: _buildInfoSection(r, unitPrice)),
                              ],
                            ),
                          );
                        } else {
                          return Column(
                            children: [
                              _buildProductImageSection(r, double.infinity),
                              _buildInfoSection(r, unitPrice),
                            ],
                          );
                        }
                      },
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

  Widget _buildProductImageSection(Responsive r, double width) {
    return Container(
      width: width == double.infinity ? null : width,
      padding: EdgeInsets.all(r.space(24)),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5D8),
        border: Border(right: BorderSide(color: const Color(0x7FD8B84B), width: 2)),
        borderRadius: width != double.infinity
            ? const BorderRadius.only(bottomLeft: Radius.circular(25))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Product image placeholder
          Container(
            width: r.space(200),
            height: r.space(200),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE8D0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.image_outlined, size: r.icon(80), color: Colors.grey[400]),
          ),
          SizedBox(height: r.space(16)),
          Text(
            'Indomie goreng',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: r.font(28),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: r.space(4)),
          Text(
            'SKU: IDM-001',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF898989),
              fontSize: r.font(22),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Responsive r, int unitPrice) {
    return Padding(
      padding: EdgeInsets.all(r.space(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info cards row
          Row(
            children: [
              _buildInfoCard('Harga', _formatPrice(unitPrice), r),
              SizedBox(width: r.space(12)),
              _buildInfoCard('Stok Tersisa', '50 pcs', r),
              SizedBox(width: r.space(12)),
              _buildInfoCard('Kategori', 'Mie Instan', r),
            ],
          ),
          SizedBox(height: r.space(24)),
          // Add to transaction section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(r.space(20)),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF5D8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x7FD8B84B), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Ke Transaksi',
                  style: TextStyle(
                    color: const Color(0xFF898989),
                    fontSize: r.font(20),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: r.space(16)),
                Row(
                  children: [
                    // Qty controls
                    _qtyButton(Icons.remove, _decrement, r),
                    Container(
                      width: r.space(60),
                      height: r.space(48),
                      margin: EdgeInsets.symmetric(horizontal: r.space(8)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0xFF939393)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$_qty',
                        style: TextStyle(fontSize: r.font(20), fontWeight: FontWeight.w500),
                      ),
                    ),
                    _qtyButton(Icons.add, _increment, r),
                    const Spacer(),
                    // Subtotal
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Subtotal:',
                          style: TextStyle(
                            color: const Color(0xFF898989),
                            fontSize: r.font(18),
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatPrice(unitPrice * _qty),
                          style: TextStyle(
                            color: const Color(0xFF1D1B1B),
                            fontSize: r.font(24),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: r.space(24)),
          // Action buttons
          Row(
            children: [
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    height: r.space(48),
                    decoration: BoxDecoration(
                      color: const Color(0xADA1862D),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, color: Colors.white, size: r.icon(22)),
                        SizedBox(width: r.space(8)),
                        Text(
                          'Tambah Ke Kasir',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: r.font(18),
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: r.space(12)),
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    height: r.space(48),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6D2A0),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: r.font(18),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Responsive r) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: r.space(16), horizontal: r.space(12)),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF5D8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x7FD8B84B), width: 2),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF898989),
                fontSize: r.font(16),
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: r.space(6)),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: const Color(0xFF1D1B1B),
                  fontSize: r.font(28),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap, Responsive r) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: r.space(52),
        height: r.space(48),
        decoration: BoxDecoration(
          color: const Color(0xADA1862D),
          borderRadius: BorderRadius.circular(5),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: r.icon(24)),
      ),
    );
  }

  // ────────────────────────────────────────
  //  HEADER
  // ────────────────────────────────────────
  Widget _buildHeader(Responsive r) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: r.space(20), vertical: r.space(14)),
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
            Container(
              width: r.icon(48),
              height: r.icon(48),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.store, color: Colors.white, size: r.icon(28)),
            ),
            SizedBox(width: r.space(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('POS TOSERBA',
                      style: TextStyle(color: const Color(0xFFFFFEE4), fontSize: r.font(22), fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                  Text('jl. indah no.15, Sidoarjo',
                      style: TextStyle(color: const Color(0xFFFFFEE4), fontSize: r.font(14), fontFamily: 'Inter'),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Kasir: Dewi',
                    style: TextStyle(color: const Color(0xFFFFFEE4), fontSize: r.font(18), fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                Text('30/02/2026',
                    style: TextStyle(color: const Color(0xFFFFFEE4), fontSize: r.font(14), fontFamily: 'Inter')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}