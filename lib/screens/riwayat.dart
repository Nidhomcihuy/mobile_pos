import 'package:flutter/material.dart';
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
  String? _printingId; // invoice_number sedang dicetak ulang

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await ApiService.fetchTransactions();
      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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

  void _showTransactionDetail(
    BuildContext context,
    Map<String, dynamic> data,
    Responsive r,
  ) {
    final items = data['items'] as List<dynamic>? ?? [];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: Color(0xFFB71C1C)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Invoice ${data['invoice_number'] ?? data['id']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Waktu', data['created_at'] ?? '-'),
              _detailRow(
                'Metode',
                (data['payment_method'] ?? '-').toString().toUpperCase(),
              ),
              _detailRow(
                'Status',
                (data['status'] ?? '-').toString().toUpperCase(),
              ),
              const Divider(height: 30),
              const Text(
                'Daftar Produk:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              ...items.map((item) {
                final i = item as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${i['product_name']} x${i['quantity']}'),
                      ),
                      Text(_formatPrice((i['subtotal'] as num).toInt())),
                    ],
                  ),
                );
              }),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL BAYAR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatPrice((data['total_amount'] as num).toInt()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFFB71C1C),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'TUTUP',
              style: TextStyle(
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reprintReceipt(Map<String, dynamic> data) async {
    final invoiceId = (data['invoice_number'] ?? '#${data['id']}').toString();
    setState(() => _printingId = invoiceId);

    try {
      // Parse tanggal
      DateTime dateTime;
      try {
        dateTime = DateTime.parse(
          (data['created_at'] ?? '').toString().replaceFirst(' ', 'T'),
        );
      } catch (_) {
        dateTime = DateTime.now();
      }

      // Map items ke format printer
      final rawItems = data['items'] as List<dynamic>? ?? [];
      final items = rawItems.map((e) {
        final i = e as Map<String, dynamic>;
        final qty = (i['quantity'] as num).toInt();
        final subtotalVal = (i['subtotal'] as num).toDouble();
        final price = qty > 0 ? subtotalVal / qty : 0.0;
        return <String, dynamic>{
          'name': i['product_name'] as String? ?? '',
          'qty': qty,
          'price': price,
          'subtotal': subtotalVal,
        };
      }).toList();

      final total = (data['total_amount'] as num).toDouble();
      final paid = (data['paid_amount'] as num?)?.toDouble() ?? total;
      final change = (data['change'] as num?)?.toDouble() ?? 0.0;

      final result = await PrinterService.printReceiptWithDiag(
        storeName: AppConfig.storeName,
        cashierName: AppConfig.cashierName,
        transactionId: invoiceId,
        dateTime: dateTime,
        items: items,
        subtotal: total,
        tax: 0,
        total: total,
        paid: paid,
        change: change,
        storeAddress: AppConfig.storeAddress,
      );

      if (!mounted) return;

      if (result.ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Struk berhasil dicetak ulang'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Gagal Cetak Ulang'),
            content: Text(result.error),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/printer');
                },
                child: const Text('Pengaturan Printer'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'TUTUP',
                  style: TextStyle(color: Color(0xFFB71C1C)),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _printingId = null);
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    final today = _todayString();
    final todayTx = _transactions.where((t) {
      final createdAt = (t['created_at'] ?? '') as String;
      return createdAt.startsWith(today);
    }).toList();
    final totalPemasukanHariIni = todayTx.fold<int>(
      0,
      (sum, t) => sum + ((t['total_amount'] as num?)?.toInt() ?? 0),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(r),
          _buildNavBar(context, r),
          Padding(
            padding: EdgeInsets.fromLTRB(
              r.space(24),
              r.space(16),
              r.space(24),
              r.space(8),
            ),
            child: Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: r.font(22),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF555555),
                fontFamily: 'Inter',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.space(24)),
            child: Column(
              children: [
                _buildStatCard(
                  'TOTAL PEMASUKAN HARI INI',
                  _formatPrice(totalPemasukanHariIni),
                  'Berdasarkan data hari ini',
                  r,
                  isHighlight: true,
                ),
                SizedBox(height: r.space(12)),
                Row(
                  children: [
                    _buildStatCard(
                      'Transaksi',
                      '${todayTx.length}',
                      'Hari Ini',
                      r,
                    ),
                    SizedBox(width: r.space(12)),
                    _buildStatCard('Transaksi', '85', 'Minggu Ini', r),
                    SizedBox(width: r.space(12)),
                    _buildStatCard('Transaksi', '342', 'Bulan Ini', r),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: r.space(20)),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: r.space(24)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFEF9A9A)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFC62828),
                      ),
                    )
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                    const Color(
                                      0xFFC62828,
                                    ).withValues(alpha: 0.2),
                                  ),
                                  columnSpacing: r.space(35),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'INVOICE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'JAM',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'METODE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'TOTAL',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'AKSI',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: _transactions.map((data) {
                                    final method =
                                        (data['payment_method'] ?? '-')
                                            .toString()
                                            .toUpperCase();
                                    final createdAt =
                                        (data['created_at'] ?? '') as String;
                                    final timePart = createdAt.contains(' ')
                                        ? createdAt.split(' ').last
                                        : createdAt;
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            (data['invoice_number'] ??
                                                    '#${data['id']}')
                                                .toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(timePart)),
                                        DataCell(
                                          Text(
                                            method,
                                            style: TextStyle(
                                              color: method == 'QRIS'
                                                  ? Colors.blue
                                                  : Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _formatPrice(
                                              (data['total_amount'] as num)
                                                  .toInt(),
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.visibility,
                                                  color: Color(0xFFB71C1C),
                                                ),
                                                tooltip: 'Lihat Detail',
                                                onPressed: () =>
                                                    _showTransactionDetail(
                                                      context,
                                                      data,
                                                      r,
                                                    ),
                                              ),
                                              Builder(
                                                builder: (context) {
                                                  final id =
                                                      (data['invoice_number'] ??
                                                              '#${data['id']}')
                                                          .toString();
                                                  final isPrinting =
                                                      _printingId == id;
                                                  return isPrinting
                                                      ? const SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: Color(
                                                                  0xFFC62828,
                                                                ),
                                                              ),
                                                        )
                                                      : IconButton(
                                                          icon: const Icon(
                                                            Icons.print,
                                                            color: Color(
                                                              0xFF6B9E6B,
                                                            ),
                                                          ),
                                                          tooltip:
                                                              'Cetak Ulang Struk',
                                                          onPressed:
                                                              _printingId !=
                                                                  null
                                                              ? null
                                                              : () =>
                                                                    _reprintReceipt(
                                                                      data,
                                                                    ),
                                                        );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
          SizedBox(height: r.space(20)),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String period,
    Responsive r, {
    bool isHighlight = false,
  }) {
    return Expanded(
      flex: isHighlight ? 0 : 1,
      child: Container(
        width: isHighlight ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          vertical: r.space(14),
          horizontal: r.space(16),
        ),
        decoration: BoxDecoration(
          color: isHighlight ? const Color(0xFFB71C1C) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlight ? Colors.transparent : const Color(0xFFEF9A9A),
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: r.font(10),
                fontWeight: FontWeight.bold,
                color: isHighlight ? Colors.white70 : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: r.font(isHighlight ? 24 : 18),
                  fontWeight: FontWeight.w900,
                  color: isHighlight ? Colors.white : Colors.black,
                ),
              ),
            ),
            Text(
              period,
              style: TextStyle(
                fontSize: r.font(9),
                color: isHighlight ? Colors.white60 : Colors.black45,
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
            Container(
              width: r.icon(52),
              height: r.icon(52),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(AppConfig.storeLogo, fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: r.space(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConfig.storeName,
                    style: TextStyle(
                      color: const Color(0xFFFFFFFF),
                      fontSize: r.font(22),
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    AppConfig.storeAddress,
                    style: TextStyle(
                      color: const Color(0xFFFFFFFF),
                      fontSize: r.font(14),
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Kasir: ${AppConfig.cashierName}',
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontSize: r.font(18),
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  AppConfig.todayDate,
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontSize: r.font(14),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, Responsive r) {
    final navItems = ['Dashboard', 'Kasir', 'Riwayat'];
    const selectedIndex = 2;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        left: r.space(20),
        right: r.space(20),
        top: r.space(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFC62828),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(navItems.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () {
                  if (!isSelected) {
                    Navigator.pushReplacementNamed(
                      context,
                      '/${navItems[index].toLowerCase()}',
                    );
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: r.space(10)),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFFFFF).withValues(alpha: 0.25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    navItems[index],
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFFFFFFF)
                          : Colors.black87,
                      fontSize: r.font(16),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontFamily: 'Inter',
                    ),
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
