import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive_helper.dart';
import '../utils/api_service.dart';
import '../utils/app_config.dart';
import '../utils/printer_service.dart';

class Riwayat extends StatefulWidget {
  const Riwayat({super.key});

  @override
  State<Riwayat> createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _printingId; 

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final data = await ApiService.fetchTransactions();
      setState(() { _transactions = data; _isLoading = false; });
    } catch (e) {
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
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

  String _todayString() {
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    final y = now.year.toString();
    return '$d/$m/$y';
  }

  void _showTransactionDetail(BuildContext context, Map<String, dynamic> data, Responsive r) {
    final items = data['items'] as List<dynamic>? ?? [];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(24),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: Color(0xFFC62828)),
            const SizedBox(width: 12),
            Expanded(child: Text('Detail Transaksi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Inter'))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(data['invoice_number'] ?? '#${data['id']}', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
            const Divider(height: 32),
            ...items.map((item) {
              final i = item as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${i['product_name']} x${i['quantity']}', style: const TextStyle(fontSize: 13, fontFamily: 'Inter'))),
                    Text(_formatPrice((i['subtotal'] as num).toInt()), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                  ],
                ),
              );
            }),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL BAYAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Inter')),
                Text(_formatPrice((data['total_amount'] as num).toInt()), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFC62828), fontFamily: 'Inter')),
              ],
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('TUTUP', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reprintReceipt(Map<String, dynamic> data) async {
    final invoiceId = (data['invoice_number'] ?? '#${data['id']}').toString();
    setState(() => _printingId = invoiceId);
    try {
      DateTime dateTime;
      try {
        final rawDate = (data['created_at'] ?? '').toString();
        final parts = rawDate.split(' ');
        final dateParts = parts[0].split('/');
        final timeParts = parts.length > 1 ? parts[1].split(':') : ['0', '0'];
        dateTime = DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]), int.parse(dateParts[0]), int.parse(timeParts[0]), int.parse(timeParts[1]));
      } catch (_) { dateTime = DateTime.now(); }

      final rawItems = data['items'] as List<dynamic>? ?? [];
      final items = rawItems.map((e) {
        final i = e as Map<String, dynamic>;
        final qty = (i['quantity'] as num).toInt();
        final subtotalVal = (i['subtotal'] as num).toDouble();
        return <String, dynamic>{ 'name': i['product_name'] as String? ?? '', 'qty': qty, 'price': qty > 0 ? subtotalVal / qty : 0.0, 'subtotal': subtotalVal };
      }).toList();

      final total = (data['total_amount'] as num).toDouble();
      final paid = (data['paid_amount'] as num?)?.toDouble() ?? total;
      final change = (data['change'] as num?)?.toDouble() ?? 0.0;

      final result = await PrinterService.printReceiptWithDiag(
        storeName: AppConfig.storeName, cashierName: AppConfig.cashierName, transactionId: invoiceId, dateTime: dateTime,
        items: items, subtotal: total, tax: 0, total: total, paid: paid, change: change, storeAddress: AppConfig.storeAddress,
      );

      if (mounted && result.ok) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil dicetak ulang'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _printingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final today = _todayString();
    final todayTx = _transactions.where((t) => ((t['created_at'] ?? '') as String).startsWith(today)).toList();
    final totalPemasukanHariIni = todayTx.fold<int>(0, (sum, t) => sum + ((t['total_amount'] as num?)?.toInt() ?? 0));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildHeader(r),
          _buildNavBar(context, r),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(r.space(20)),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatSection(totalPemasukanHariIni, todayTx.length, r),
                  const SizedBox(height: 24),
                  const Text('Daftar Transaksi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Inter')),
                  const SizedBox(height: 16),
                  _buildTransactionList(r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Responsive r) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(r.space(20), r.space(52), r.space(20), r.space(24)),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.history_rounded, color: Colors.white, size: 28),
          ),
          SizedBox(width: r.space(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Riwayat Penjualan', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Inter')),
                Text(AppConfig.storeName, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, Responsive r) {
    final navItems = ['Dashboard', 'Kasir', 'Riwayat'];
    const selectedIndex = 2;
    return Container(
      margin: EdgeInsets.fromLTRB(r.space(20), r.space(16), r.space(20), 0),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: List.generate(navItems.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: InkWell(
              onTap: () { if (!isSelected) Navigator.pushReplacementNamed(context, '/${navItems[index].toLowerCase()}'); },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: r.space(10)),
                decoration: BoxDecoration(color: isSelected ? const Color(0xFFC62828) : Colors.transparent, borderRadius: BorderRadius.circular(15)),
                alignment: Alignment.center,
                child: Text(navItems[index], style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontSize: r.font(15), fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, fontFamily: 'Inter')),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatSection(int pemasukan, int count, Responsive r) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C1E),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PEMASUKAN HARI INI', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text('$count Transaksi', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          Text(_formatPrice(pemasukan), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildTransactionList(Responsive r) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFC62828)));
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    if (_transactions.isEmpty) return Center(child: Column(children: [const SizedBox(height: 40), Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey[300]), const SizedBox(height: 16), const Text('Belum ada transaksi', style: TextStyle(color: Colors.grey))]));
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final data = _transactions[index];
        final method = (data['payment_method'] ?? '-').toString().toUpperCase();
        final createdAt = (data['created_at'] ?? '') as String;
        final timePart = createdAt.contains(' ') ? createdAt.split(' ').last : createdAt;
        final invoiceId = (data['invoice_number'] ?? '#${data['id']}').toString();
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: method == 'QRIS' ? Colors.blue[50] : Colors.green[50], borderRadius: BorderRadius.circular(16)),
                child: Icon(method == 'QRIS' ? Icons.qr_code_rounded : Icons.payments_rounded, color: method == 'QRIS' ? Colors.blue[700] : Colors.green[700]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invoiceId, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    Text(timePart, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_formatPrice((data['total_amount'] as num).toInt()), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFFC62828))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _actionButton(Icons.visibility_rounded, Colors.grey[100]!, Colors.black54, () => _showTransactionDetail(context, data, r)),
                      const SizedBox(width: 8),
                      _actionButton(Icons.print_rounded, const Color(0xFFFFEBEE), const Color(0xFFC62828), _printingId != null ? null : () => _reprintReceipt(data), isPrinting: _printingId == invoiceId),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton(IconData icon, Color bg, Color iconColor, VoidCallback? onTap, {bool isPrinting = false}) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: isPrinting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC62828))) : Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}
