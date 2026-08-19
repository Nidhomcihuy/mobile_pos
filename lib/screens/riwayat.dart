import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC62828).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFC62828)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Detail Transaksi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, fontFamily: 'Inter', color: Color(0xFF0F172A))),
                            Text(data['invoice_number'] ?? '#${data['id']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Rincian Belanja', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF475569), fontFamily: 'Inter')),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: items.map((item) {
                        final i = item as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${i['product_name']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: Color(0xFF1E293B))),
                                    const SizedBox(height: 4),
                                    Text('${i['quantity']} x ${_formatPrice((i['unit_price'] as num).toInt())}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Inter')),
                                  ],
                                ),
                              ),
                              Text(_formatPrice((i['subtotal'] as num).toInt()), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Inter', color: Color(0xFFC62828))),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontFamily: 'Inter')),
                            Text(_formatPrice(((data['total_amount'] as num) + (data['discount_amount'] as num? ?? 0)).toInt()), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Inter')),
                          ],
                        ),
                        if ((data['discount_amount'] as num? ?? 0) > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Diskon', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontFamily: 'Inter')),
                              Text('-${_formatPrice((data['discount_amount'] as num).toInt())}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF10B981), fontFamily: 'Inter')),
                            ],
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFE2E8F0)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, fontFamily: 'Inter', color: Color(0xFF0F172A))),
                            Text(_formatPrice((data['total_amount'] as num).toInt()), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFFC62828), fontFamily: 'Inter')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Dibayar', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontFamily: 'Inter')),
                            Text(_formatPrice((data['paid_amount'] as num).toInt()), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Inter')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Kembalian', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontFamily: 'Inter')),
                            Text(_formatPrice((data['change'] as num).toInt()), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Inter')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Metode', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontFamily: 'Inter')),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC62828).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                (data['payment_method'] ?? 'cash').toString().toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFFC62828), fontFamily: 'Inter'),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(r),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFC62828)))
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _transactions.isEmpty
                          ? _buildEmptyState()
                          : _buildTransactionList(r),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Responsive r) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.space(20), vertical: r.space(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFC62828).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(CupertinoIcons.clock_fill, color: Color(0xFFC62828), size: 24),
          ),
          SizedBox(width: r.space(12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Riwayat Transaksi',
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontSize: r.font(18),
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '50 transaksi terakhir',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: r.font(12),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.exclamationmark_triangle, color: Color(0xFFEF4444), size: 48),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTransactions,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Coba Lagi'),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.doc_text, size: 64, color: const Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          const Text('Belum ada transaksi hari ini', style: TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTransactionList(Responsive r) {
    int pemasukan = 0;
    final today = _todayString();
    for (final t in _transactions) {
      final date = t['created_at']?.split(' ')[0] ?? '';
      if (date == today) {
        pemasukan += (t['total_amount'] as num? ?? 0).toInt();
      }
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.space(20), vertical: r.space(8)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFC62828), Color(0xFFB71C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: const Color(0xFFC62828).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pemasukan Hari Ini', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                const SizedBox(height: 8),
                Text(_formatPrice(pemasukan), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'Inter')),
              ],
            ),
          ),
        ),
        SizedBox(height: r.space(8)),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(r.space(20), r.space(8), r.space(20), r.space(20)),
            itemCount: _transactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = _transactions[index];
              final invoiceId = (data['invoice_number'] ?? '#${data['id']}').toString();
              final isPrinting = _printingId == invoiceId;
              
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _showTransactionDetail(context, data, r),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(CupertinoIcons.bag_fill, color: Color(0xFF64748B), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(data['created_at'] ?? '-', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Inter')),
                                    Text(invoiceId, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatPrice((data['total_amount'] as num).toInt()), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                                    if (isPrinting)
                                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC62828)))
                                    else
                                      IconButton(
                                        icon: const Icon(CupertinoIcons.printer),
                                        color: const Color(0xFFC62828),
                                        iconSize: 20,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        onPressed: () => _reprintReceipt(data),
                                        tooltip: 'Cetak Ulang',
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
