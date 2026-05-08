import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../utils/app_config.dart';
import '../utils/api_service.dart';
import '../utils/printer_service.dart';

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
  List<Map<String, dynamic>> _items = [];
  bool _itemsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_itemsInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments
              as List<Map<String, dynamic>>?;
      if (args != null) {
        // deep copy agar tidak mengubah data asli di kasir
        _items = args
            .map((e) => Map<String, dynamic>.from(e))
            .where((e) => (e['quantity'] as int? ?? 0) > 0)
            .toList();
      }
      _itemsInitialized = true;
    }
  }

  int get _subtotal {
    int s = 0;
    for (var item in _items) {
      s += (item['price'] as int) * (item['quantity'] as int);
    }
    return s;
  }

  void _changeQty(int index, int delta) {
    setState(() {
      final newQty = (_items[index]['quantity'] as int) + delta;
      if (newQty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index]['quantity'] = newQty;
      }
      // reset metode bayar jika total berubah
      _isCashMode = false;
      _isQRMode = false;
      _cashController.clear();
      _change = 0;
    });
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
                  color: Color(0xFFB71C1C),
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
    bool isPrinting = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
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
                    children: [
                      const Text('KEMBALI'),
                      Text(_formatPrice(change)),
                    ],
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
                SizedBox(height: r.space(12)),
                // Tombol Cetak Struk ke Printer Thermal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isPrinting
                        ? null
                        : () async {
                            setDialogState(() => isPrinting = true);

                            final printItems = items
                                .map(
                                  (item) => {
                                    'name': item['name'] as String,
                                    'qty': item['quantity'] as int,
                                    'price': (item['price'] as int).toDouble(),
                                    'subtotal':
                                        ((item['price'] as int) *
                                                (item['quantity'] as int))
                                            .toDouble(),
                                  },
                                )
                                .toList();

                            final result =
                                await PrinterService.printReceiptWithDiag(
                                  storeName: AppConfig.storeName,
                                  cashierName: 'Kasir',
                                  transactionId: invoiceNumber.isNotEmpty
                                      ? invoiceNumber
                                      : 'TRX-${DateTime.now().millisecondsSinceEpoch}',
                                  dateTime: DateTime.now(),
                                  items: printItems,
                                  subtotal: subtotal.toDouble(),
                                  tax: 0.0,
                                  total: subtotal.toDouble(),
                                  paid: cash > 0
                                      ? cash.toDouble()
                                      : subtotal.toDouble(),
                                  change: change.toDouble(),
                                );

                            setDialogState(() => isPrinting = false);

                            if (mounted) {
                              if (result.ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Struk berhasil dicetak!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Row(
                                      children: [
                                        Icon(
                                          Icons.print_disabled,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Gagal Cetak'),
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(result.error),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Buka menu Printer untuk mengatur koneksi.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pushNamed(
                                            context,
                                            '/printer',
                                          );
                                        },
                                        child: const Text('Pengaturan Printer'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                    icon: isPrinting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.print),
                    label: Text(isPrinting ? 'Mencetak...' : 'Cetak Struk'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: r.space(8)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      dialogContext,
                      '/dashboard',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text('SELESAI'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final int subtotal = _subtotal;

    if (_items.isEmpty && _itemsInitialized) {
      // Semua item dihapus, kembali ke kasir
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/kasir');
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
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
                        color: const Color(0xFFFFFFFF),
                        border: Border.all(color: const Color(0xFF818080)),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildTransactionHeader(_items.length, r),
                          Expanded(child: _buildItemsList(r)),
                          if (_isCashMode) _buildCashInput(subtotal, r),
                          if (_isQRMode) _buildQRView(r),
                          _buildSummarySection(subtotal, r),
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

  Widget _buildTitleBar(BuildContext context, Responsive r) {
    return Container(
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
            'Pembayaran',
            style: TextStyle(
              color: const Color(0xFFFFFFFF),
              fontSize: r.font(20),
              fontWeight: FontWeight.w800,
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF9A9A),
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
      color: const Color(0xFFEF9A9A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [const Text('Transaksi #123'), Text('$count item')],
      ),
    );
  }

  Widget _buildItemsList(Responsive r) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final qty = item['quantity'] as int;
        final price = item['price'] as int;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              // Nama produk (kiri)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      style: TextStyle(
                        fontSize: r.font(13),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatPrice(price),
                      style: TextStyle(
                        fontSize: r.font(11),
                        color: Colors.grey[600],
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              // Kontrol qty (tengah)
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _changeQty(index, -1),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Icon(
                              qty == 1 ? Icons.delete_outline : Icons.remove,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        Text(
                          '$qty',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: r.font(13),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        InkWell(
                          onTap: () => _changeQty(index, 1),
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(16),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Subtotal item (kanan)
              Expanded(
                flex: 2,
                child: Text(
                  _formatPrice(price * qty),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: r.font(12),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB71C1C),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
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
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              labelText: 'UANG DIBAYAR (CASH)',
              labelStyle: const TextStyle(color: Color(0xFFC62828)),
              prefixText: 'Rp ',
              prefixStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              filled: true,
              fillColor: const Color(0xFFFFF8F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEF9A9A)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEF9A9A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFC62828),
                  width: 2,
                ),
              ),
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
              backgroundColor: const Color(0xFFB71C1C),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(int subtotal, Responsive r) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFFFEBEE),
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
                  onPressed: _items.isEmpty
                      ? null
                      : () {
                          if (!_isCashMode && !_isQRMode) {
                            _showPaymentOptions(subtotal, r);
                          } else if (!_isProcessing) {
                            final cash =
                                int.tryParse(
                                  _cashController.text.replaceAll('.', ''),
                                ) ??
                                0;
                            _processPayment(_items, subtotal, cash, r);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
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
