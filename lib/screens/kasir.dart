import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class Kasir extends StatefulWidget {
  const Kasir({super.key});

  @override
  State<Kasir> createState() => _KasirState();
}

class _KasirState extends State<Kasir> {
  final List<Map<String, dynamic>> _cartItems = [
    {'name': 'Indomie Soto', 'price': 3500, 'qty': 2},
    {'name': 'Indomie Goreng Pedas', 'price': 3900, 'qty': 2},
  ];

  final TextEditingController _bayarController = TextEditingController();

  int get _subtotal =>
      _cartItems.fold(0, (sum, item) => sum + (item['price'] as int) * (item['qty'] as int));
  int get _diskon => 0;
  int get _total => _subtotal - _diskon;
  int get _totalItems => _cartItems.fold(0, (sum, item) => sum + (item['qty'] as int));

  @override
  void dispose() {
    _bayarController.dispose();
    super.dispose();
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
    return 'Rp $result';
  }

  void _incrementQty(int index) {
    setState(() => _cartItems[index]['qty']++);
  }

  void _decrementQty(int index) {
    setState(() {
      if (_cartItems[index]['qty'] > 1) {
        _cartItems[index]['qty']--;
      } else {
        _cartItems.removeAt(index);
      }
    });
  }

  // ────────────────────────────────────────
  //  PAYMENT DIALOG
  // ────────────────────────────────────────
  void _showPaymentDialog(Responsive r) {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Keranjang kosong!', style: TextStyle(fontSize: r.font(16))),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    _bayarController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            final bayarText = _bayarController.text.replaceAll('.', '').replaceAll(',', '');
            final int uangBayar = int.tryParse(bayarText) ?? 0;
            final int kembalian = uangBayar - _total;
            final bool cukup = uangBayar >= _total;

            return Dialog(
              backgroundColor: const Color(0xFFFFFDE3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: EdgeInsets.symmetric(horizontal: r.space(24), vertical: r.space(24)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: r.space(460),
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(r.space(28)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Row(
                      children: [
                        Icon(Icons.payment_rounded, color: const Color(0xFFD8B84B), size: r.icon(28)),
                        SizedBox(width: r.space(10)),
                        Text(
                          'Pembayaran',
                          style: TextStyle(
                            fontSize: r.font(24),
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: r.space(20)),

                    // Total display
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(r.space(16)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6D2A1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: r.font(16),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                              color: const Color(0xFF555555),
                            ),
                          ),
                          SizedBox(height: r.space(4)),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatPrice(_total),
                              style: TextStyle(
                                fontSize: r.font(32),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: r.space(20)),

                    // Uang bayar input
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Uang Bayar',
                        style: TextStyle(
                          fontSize: r.font(16),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    SizedBox(height: r.space(8)),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD8B84B), width: 2),
                      ),
                      child: TextField(
                        controller: _bayarController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        style: TextStyle(fontSize: r.font(22), fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: 'Masukkan nominal',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: r.font(18)),
                          prefixText: 'Rp ',
                          prefixStyle: TextStyle(fontSize: r.font(22), fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: r.space(16), vertical: r.space(14)),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                    ),
                    SizedBox(height: r.space(20)),

                    // Quick amount buttons
                    Wrap(
                      spacing: r.space(8),
                      runSpacing: r.space(8),
                      children: [_total, 10000, 20000, 50000, 100000]
                          .map((amount) => InkWell(
                                onTap: () {
                                  _bayarController.text = amount.toString();
                                  setDialogState(() {});
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: r.space(14), vertical: r.space(8)),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD8B84B).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFD8B84B)),
                                  ),
                                  child: Text(
                                    amount == _total ? 'Uang Pas' : _formatPrice(amount),
                                    style: TextStyle(
                                      fontSize: r.font(14),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                      color: const Color(0xFF6B5B00),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    SizedBox(height: r.space(20)),

                    // Kembalian display
                    if (uangBayar > 0)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(r.space(16)),
                        decoration: BoxDecoration(
                          color: cukup ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cukup ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              cukup ? 'KEMBALIAN' : 'KURANG',
                              style: TextStyle(
                                fontSize: r.font(16),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                                color: cukup ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                              ),
                            ),
                            SizedBox(height: r.space(4)),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                cukup ? _formatPrice(kembalian) : _formatPrice(kembalian.abs()),
                                style: TextStyle(
                                  fontSize: r.font(28),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                  color: cukup ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: r.space(20)),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(dialogContext),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: r.space(50),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD6D2A1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black26),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'BATAL',
                                style: TextStyle(
                                  fontSize: r.font(18),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: r.space(12)),
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: cukup && uangBayar > 0
                                ? () {
                                    Navigator.pop(dialogContext);
                                    _showReceiptDialog(r, uangBayar, kembalian);
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: r.space(50),
                              decoration: BoxDecoration(
                                color: cukup && uangBayar > 0
                                    ? const Color(0xFFD8B84B)
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'KONFIRMASI BAYAR',
                                style: TextStyle(
                                  fontSize: r.font(18),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                  color: cukup && uangBayar > 0 ? Colors.white : Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            );
          },
        );
      },
    );
  }

  // ────────────────────────────────────────
  //  RECEIPT / SUCCESS DIALOG
  // ────────────────────────────────────────
  void _showReceiptDialog(Responsive r, int uangBayar, int kembalian) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFFFFFDE3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: r.space(400),
            padding: EdgeInsets.all(r.space(28)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: r.icon(72),
                  height: r.icon(72),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded, color: const Color(0xFF4CAF50), size: r.icon(44)),
                ),
                SizedBox(height: r.space(16)),
                Text(
                  'Pembayaran Berhasil!',
                  style: TextStyle(
                    fontSize: r.font(22),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: r.space(20)),

                // Receipt details
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(r.space(16)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6D2A1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _receiptRow('Total Belanja', _formatPrice(_total), r),
                      SizedBox(height: r.space(8)),
                      _receiptRow('Uang Bayar', _formatPrice(uangBayar), r),
                      Divider(color: Colors.black38, height: r.space(20)),
                      _receiptRow('Kembalian', _formatPrice(kembalian), r, isBold: true),
                    ],
                  ),
                ),

                // Big kembalian display
                if (kembalian > 0) ...[
                  SizedBox(height: r.space(16)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: r.space(16)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4CAF50)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'KEMBALIAN',
                          style: TextStyle(
                            fontSize: r.font(14),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E7D32),
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(height: r.space(4)),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: r.space(16)),
                            child: Text(
                              _formatPrice(kembalian),
                              style: TextStyle(
                                fontSize: r.font(36),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2E7D32),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: r.space(24)),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(dialogContext);
                      setState(() => _cartItems.clear());
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: r.space(50),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8B84B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'TRANSAKSI BARU',
                        style: TextStyle(
                          fontSize: r.font(18),
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _receiptRow(String label, String value, Responsive r, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: r.font(18),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: r.font(18),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE3),
      body: Column(
        children: [
          _buildHeader(r),
          _buildNavBar(r),
          // Transaction header
          Container(
            padding: EdgeInsets.symmetric(horizontal: r.space(24), vertical: r.space(14)),
            decoration: const BoxDecoration(color: Color(0xFFD6D2A0)),
            child: Row(
              children: [
                Text(
                  'Transaksi 1',
                  style: TextStyle(
                    fontSize: r.font(20),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: r.space(14), vertical: r.space(4)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black54),
                  ),
                  child: Text(
                    '$_totalItems item',
                    style: TextStyle(fontSize: r.font(16), fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
          ),
          // Table header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.space(24), vertical: r.space(16)),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text('Nama Produk',
                      style: TextStyle(fontSize: r.font(18), fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Jumlah',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: r.font(18), fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Harga',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: r.font(18), fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                ),
              ],
            ),
          ),
          // Cart items list
          Expanded(
            child: _cartItems.isEmpty
                ? Center(
                    child: Text(
                      'Keranjang kosong',
                      style: TextStyle(color: Colors.grey, fontSize: r.font(16)),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: r.space(24)),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: r.space(16)),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                item['name'],
                                style: TextStyle(fontSize: r.font(16), fontFamily: 'Inter'),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _qtyButton('-', () => _decrementQty(index), r),
                                  SizedBox(
                                    width: r.space(40),
                                    child: Center(
                                      child: Text(
                                        '${item['qty']}',
                                        style: TextStyle(fontSize: r.font(16), fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  _qtyButton('+', () => _incrementQty(index), r),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                _formatPrice(item['price']),
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: r.font(16), fontFamily: 'Inter'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Bottom summary
          _buildBottomSummary(r),
        ],
      ),
    );
  }

  Widget _qtyButton(String label, VoidCallback onTap, Responsive r) {
    final size = r.icon(32);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD8B84B), width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(fontSize: r.font(18), fontWeight: FontWeight.w600, color: const Color(0xFFD8B84B)),
        ),
      ),
    );
  }

  Widget _buildBottomSummary(Responsive r) {
    return Container(
      padding: EdgeInsets.all(r.space(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Subtotal / Diskon / Total
          Expanded(
            child: Container(
              padding: EdgeInsets.all(r.space(18)),
              decoration: BoxDecoration(
                color: const Color(0xFFD6D2A1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26),
              ),
              child: Column(
                children: [
                  _summaryRow('SUBTOTAL', _formatPrice(_subtotal), false, r),
                  SizedBox(height: r.space(6)),
                  _summaryRow('DISKON', _formatPrice(_diskon), false, r),
                  const Divider(color: Colors.black54, height: 20),
                  _summaryRow('TOTAL', _formatPrice(_total), true, r),
                ],
              ),
            ),
          ),
          SizedBox(width: r.space(12)),
          // Bayar + Batalkan buttons
          Column(
            children: [
              InkWell(
                onTap: () => _showPaymentDialog(r),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: r.space(140),
                  height: r.space(70),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8B84B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF183152)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'BAYAR',
                    style: TextStyle(
                      fontSize: r.font(24),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              SizedBox(height: r.space(10)),
              InkWell(
                onTap: () => setState(() => _cartItems.clear()),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: r.space(140),
                  height: r.space(48),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6D2A1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black54),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'BATALKAN',
                    style: TextStyle(
                      fontSize: r.font(20),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
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

  Widget _summaryRow(String label, String value, bool isBold, Responsive r) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: r.font(22),
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: r.font(22),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ],
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

  // ────────────────────────────────────────
  //  NAVIGATION BAR
  // ────────────────────────────────────────
  Widget _buildNavBar(Responsive r) {
    final navItems = ['Dashboard', 'Kasir', 'Riwayat'];
    final navRoutes = ['/dashboard', '/kasir', '/riwayat'];
    const selectedIndex = 1;

    return Container(
      margin: EdgeInsets.only(left: r.space(20), right: r.space(20), top: r.space(12)),
      padding: EdgeInsets.symmetric(horizontal: r.space(8), vertical: r.space(6)),
      decoration: BoxDecoration(
        color: const Color(0xFFBDB76B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(navItems.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: r.space(4)),
            child: InkWell(
              onTap: () {
                if (!isSelected) {
                  Navigator.pushReplacementNamed(context, navRoutes[index]);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: r.space(20), vertical: r.space(10)),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFFEE4).withOpacity(0.25) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  navItems[index],
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFFFFEE4) : Colors.black87,
                    fontSize: r.font(16),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}