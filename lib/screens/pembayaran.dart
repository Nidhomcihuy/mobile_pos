import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../utils/app_config.dart';
import '../utils/api_service.dart';

class Pembayaran extends StatefulWidget {
  const Pembayaran({super.key});

  @override
  State<Pembayaran> createState() => _PembayaranState();
}

class _PembayaranState extends State<Pembayaran> {
  final TextEditingController _cashController = TextEditingController();
  int _change = 0;
  bool _isCashMode = false;
  bool _isQRMode = false;
  bool _isProcessing = false;

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

  void _calculateChange(int subtotal) {
    int cash = int.tryParse(_cashController.text.replaceAll('.', '')) ?? 0;
    setState(() {
      _change = cash - subtotal;
    });
  }

  void _showPaymentOptions(int subtotal, Responsive r) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(r.space(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Metode Pembayaran',
                style: TextStyle(
                  fontSize: r.font(20),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: r.space(20)),
              ListTile(
                leading: const Icon(
                  Icons.qr_code_scanner,
                  color: Color(0xFFCE8947),
                ),
                title: const Text(
                  'QRIS',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _isQRMode = true;
                    _isCashMode = false;
                  });
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.money, color: Colors.green),
                title: const Text(
                  'CASH',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _isCashMode = true;
                    _isQRMode = false;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processPayment(
    List<Map<String, dynamic>> items,
    int subtotal,
    int cash,
    Responsive r,
  ) async {
    setState(() => _isProcessing = true);

    final apiItems = items
        .map((item) => {'id': item['id'], 'qty': item['quantity'] as int})
        .toList();

    final paymentMethod = _isQRMode ? 'qris' : 'cash';

    try {
      final result = await ApiService.createTransaction(
        items: apiItems,
        paidAmount: cash,
        paymentMethod: paymentMethod,
      );
      if (!mounted) return;
      _showReceipt(
        items,
        result['total_amount'] as int? ?? subtotal,
        result['paid_amount'] as int? ?? cash,
        result['change'] as int? ?? (cash - subtotal),
        result['invoice_number']?.toString() ?? '',
        r,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showReceipt(
    List<Map<String, dynamic>> items,
    int subtotal,
    int cash,
    int change,
    String invoiceNumber,
    Responsive r,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              if (invoiceNumber.isNotEmpty)
                Text(
                  invoiceNumber,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              const Text(
                'STRUK PEMBAYARAN',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...items.map(
                (item) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${item['name']} x${item['quantity']}"),
                    Text(
                      _formatPrice(item['price'] * (item['quantity'] as int)),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const Text('TOTAL'), Text(_formatPrice(subtotal))],
              ),
              if (cash > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('BAYAR'), Text(_formatPrice(cash))],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('KEMBALI'), Text(_formatPrice(change))],
                ),
              ] else if (_isQRMode) ...[
                const Text(
                  'METODE: QRIS (LUNAS)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
              SizedBox(height: r.space(20)),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/dashboard'),
                child: const Text('SELESAI'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final List<Map<String, dynamic>> items =
        (ModalRoute.of(context)?.settings.arguments
            as List<Map<String, dynamic>>?) ??
        [];

    int subtotal = 0;
    for (var item in items) {
      subtotal += (item['price'] as int) * (item['quantity'] as int);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE3),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          _buildHeader(r),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(r.space(24)),
              child: Column(
                children: [
                  _buildTitleBar(context, r),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFEE4),
                        border: Border.all(color: const Color(0xFF818080)),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildTransactionHeader(items.length, r),
                          Expanded(child: _buildItemsList(items, r)),
                          if (_isCashMode) _buildCashInput(subtotal, r),
                          if (_isQRMode) _buildQRView(r),
                          _buildSummarySection(subtotal, items, r),
                        ],
                      ),
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

  Widget _buildTitleBar(BuildContext context, Responsive r) {
    return Container(
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
            'Pembayaran',
            style: TextStyle(
              color: const Color(0xFFFFFEE4),
              fontSize: r.font(20),
              fontWeight: FontWeight.w800,
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD6D2A0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Kembali'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHeader(int count, Responsive r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFD6D2A0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [const Text('Transaksi #123'), Text('$count item')],
      ),
    );
  }

  Widget _buildItemsList(List<Map<String, dynamic>> items, Responsive r) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${item['name']} x${item['quantity']}"),
              Text(_formatPrice(item['price'] * (item['quantity'] as int))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCashInput(int subtotal, Responsive r) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _cashController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'UANG DIBAYAR (CASH)',
              prefixText: 'Rp ',
            ),
            onChanged: (_) => _calculateChange(subtotal),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('KEMBALIAN:'),
              Text(
                _formatPrice(_change),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRView(Responsive r) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: [
          Text(
            'METODE PEMBAYARAN: QRIS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: r.font(16)),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Membuka Kamera untuk Bukti Bayar...'),
                ),
              );
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Foto Bukti Bayar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCE8947),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
    int subtotal,
    List<Map<String, dynamic>> items,
    Responsive r,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFD6D2A1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL'),
              Text(
                _formatPrice(subtotal),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_isCashMode && !_isQRMode) {
                      _showPaymentOptions(subtotal, r);
                    } else if (!_isProcessing) {
                      final cash =
                          int.tryParse(
                            _cashController.text.replaceAll('.', ''),
                          ) ??
                          0;
                      _processPayment(items, subtotal, cash, r);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD8B84B),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isCashMode || _isQRMode ? 'CETAK STRUK' : 'BAYAR',
                        ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/kasir'),
                  child: const Text('BATAL'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
