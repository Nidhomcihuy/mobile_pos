import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _qrProofImage;
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

  int _discountForItem(Map<String, dynamic> item) {
    final price = item['price'] as int;
    final batches = item['batches'] as List<Map<String, dynamic>>?;
    if (batches != null && batches.isNotEmpty) {
      int total = 0;
      for (final b in batches) {
        final promo = b['promo'] as Map<String, dynamic>?;
        if (promo == null) continue;
        final qty = b['qty'] as int;
        final type = promo['type'] as String? ?? '';
        final value = (promo['discount_value'] as num?)?.toDouble() ?? 0.0;
        if (type == 'percent') {
          total += ((price * qty) * value / 100).round();
        } else if (type == 'fixed') {
          total += (value * qty).round().clamp(0, price * qty);
        }
      }
      return total;
    }
    final promo = item['promo'] as Map<String, dynamic>?;
    if (promo == null) return 0;
    final type = promo['type'] as String? ?? '';
    final value = (promo['discount_value'] as num?)?.toDouble() ?? 0.0;
    final qty = item['quantity'] as int;
    if (type == 'percent') {
      return ((price * qty) * value / 100).round();
    } else if (type == 'fixed') {
      return (value * qty).round().clamp(0, price * qty);
    }
    return 0;
  }

  int get _totalDiscount {
    return _items.fold(0, (sum, item) => sum + _discountForItem(item));
  }

  int get _grandTotal => _subtotal - _totalDiscount;

  void _changeQty(int index, int delta) {
    setState(() {
      final item = _items[index];
      final batches = item['batches'] as List<Map<String, dynamic>>?;
      if (batches != null && batches.length > 1) {
        if (delta > 0) {
          for (final b in batches) {
            if ((b['qty'] as int) < (b['stock'] as int)) {
              b['qty'] = (b['qty'] as int) + 1;
              item['quantity'] = (item['quantity'] as int) + 1;
              break;
            }
          }
        } else {
          for (int i = batches.length - 1; i >= 0; i--) {
            if ((batches[i]['qty'] as int) > 0) {
              batches[i]['qty'] = (batches[i]['qty'] as int) - 1;
              item['quantity'] = (item['quantity'] as int) - 1;
              break;
            }
          }
          if ((item['quantity'] as int) <= 0) {
            _items.removeAt(index);
          }
        }
      } else {
        final newQty = (item['quantity'] as int) + delta;
        if (newQty <= 0) {
          _items.removeAt(index);
        } else {
          item['quantity'] = newQty;
          if (batches != null && batches.isNotEmpty) {
            batches[0]['qty'] = newQty;
          }
        }
      }
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

  void _calculateChange(int grandTotal) {
    int cash = int.tryParse(_cashController.text.replaceAll('.', '')) ?? 0;
    setState(() {
      _change = cash - grandTotal;
    });
  }

  void _showPaymentOptions(int grandTotal, Responsive r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.fromLTRB(r.space(24), r.space(16), r.space(24), r.space(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              SizedBox(height: r.space(24)),
              Text(
                'Metode Pembayaran',
                style: TextStyle(fontSize: r.font(22), fontWeight: FontWeight.w900, fontFamily: 'Inter'),
              ),
              SizedBox(height: r.space(24)),
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentOptionCard(
                      icon: Icons.qr_code_scanner,
                      label: 'QRIS',
                      color: const Color(0xFFC62828),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() { _isQRMode = true; _isCashMode = false; _qrProofImage = null; });
                      },
                      r: r,
                    ),
                  ),
                  SizedBox(width: r.space(16)),
                  Expanded(
                    child: _buildPaymentOptionCard(
                      icon: Icons.payments_rounded,
                      label: 'Tunai',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() { _isCashMode = true; _isQRMode = false; _qrProofImage = null; });
                      },
                      r: r,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOptionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required Responsive r,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: r.space(24)),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 16, fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(
    List<Map<String, dynamic>> items,
    int grandTotal,
    int cash,
    int discountAmount,
    Responsive r,
  ) async {
    setState(() => _isProcessing = true);
    final apiItems = <Map<String, dynamic>>[];
    for (final item in items) {
      final batches = item['batches'] as List<Map<String, dynamic>>?;
      if (batches != null && batches.isNotEmpty) {
        for (final b in batches) {
          if ((b['qty'] as int) > 0) apiItems.add({'id': b['id'], 'qty': b['qty'] as int});
        }
      } else {
        apiItems.add({'id': item['id'], 'qty': item['quantity'] as int});
      }
    }
    final paymentMethod = _isQRMode ? 'qris' : 'cash';
    try {
      final result = await ApiService.createTransaction(
        items: apiItems,
        paidAmount: _isQRMode ? grandTotal : cash,
        paymentMethod: paymentMethod,
        proofImagePath: _isQRMode ? _qrProofImage?.path : null,
        discountAmount: discountAmount,
      );
      if (!mounted) return;
      _showReceipt(items, result['total_amount'] as int? ?? grandTotal, result['paid_amount'] as int? ?? cash, result['change'] as int? ?? (cash - grandTotal), result['invoice_number']?.toString() ?? '', discountAmount, r);
    } catch (e) {
      if (!mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${e.toString()}'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showReceipt(List<Map<String, dynamic>> items, int grandTotal, int cash, int change, String invoiceNumber, int discountAmount, Responsive r) {
    bool isPrinting = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('Pembayaran Berhasil!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Inter')),
              Text(invoiceNumber, style: const TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Inter')),
              const Divider(height: 32),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("${item['name']} x${item['quantity']}", style: const TextStyle(fontSize: 13, fontFamily: 'Inter'))),
                    Text(_formatPrice(item['price'] * (item['quantity'] as int)), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                  ],
                ),
              )),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Tagihan', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                  Text(_formatPrice(grandTotal), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFC62828), fontSize: 16, fontFamily: 'Inter')),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isPrinting ? null : () async {
                    setDialogState(() => isPrinting = true);
                    try {
                      final printItems = items.map((i) => {
                        'name': i['name'] as String,
                        'qty': i['quantity'] as int,
                        'price': (i['price'] as int).toDouble(),
                        'subtotal': ((i['price'] as int) * (i['quantity'] as int)).toDouble(),
                      }).toList();
                      await PrinterService.printReceiptWithDiag(
                        storeName: AppConfig.storeName,
                        cashierName: 'Kasir',
                        transactionId: invoiceNumber,
                        dateTime: DateTime.now(),
                        items: printItems,
                        subtotal: (grandTotal + discountAmount).toDouble(),
                        tax: 0.0,
                        total: grandTotal.toDouble(),
                        paid: _isQRMode ? grandTotal.toDouble() : cash.toDouble(),
                        change: _isQRMode ? 0.0 : change.toDouble(),
                        note: _isQRMode ? 'NON TUNAI' : null,
                        storeAddress: AppConfig.storeAddress,
                      );
                    } catch (_) {}
                    finally { if (dialogContext.mounted) setDialogState(() => isPrinting = false); }
                  },
                  icon: isPrinting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : const Icon(Icons.print_rounded),
                  label: Text(isPrinting ? 'Mencetak...' : 'Cetak Struk', style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(dialogContext, '/dashboard'),
                child: const Text('Selesai', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 15)),
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
    final int subtotal = _subtotal;
    final int discount = _totalDiscount;
    final int grandTotal = _grandTotal;

    if (_items.isEmpty && _itemsInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) Navigator.pushReplacementNamed(context, '/kasir'); });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(r),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: r.space(20), vertical: r.space(16)),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildOrderSection(r),
                  const SizedBox(height: 20),
                  if (_isCashMode) _buildCashCard(grandTotal, r),
                  if (_isQRMode) _buildQRCard(r),
                  const SizedBox(height: 20),
                  _buildSummaryCard(subtotal, discount, grandTotal, r),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildStickyBottom(grandTotal, discount, r),
        ],
      ),
    );
  }

  Widget _buildHeader(Responsive r) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.space(20), vertical: r.space(16)).copyWith(top: r.space(52)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFC62828).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(CupertinoIcons.creditcard_fill, color: Color(0xFFC62828), size: 24),
          ),
          SizedBox(width: r.space(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembayaran',
                  style: TextStyle(
                    color: const Color(0xFF1E293B),
                    fontSize: r.font(18),
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Konfirmasi pesanan & bayar',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: r.font(12),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(CupertinoIcons.xmark, color: Color(0xFF64748B)),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOrderSection(Responsive r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.bag_fill, color: Color(0xFFC62828), size: 20),
              const SizedBox(width: 8),
              const Text('Rincian Belanja', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, fontFamily: 'Inter', color: Color(0xFF0F172A))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final item = _items[index];
              final qty = item['quantity'] as int;
              final price = item['price'] as int;
              final itemDisc = _discountForItem(item);
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(_formatPrice(price), style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _qtyButton(CupertinoIcons.minus, () => _changeQty(index, -1), isDelete: qty == 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
                      ),
                      _qtyButton(CupertinoIcons.plus, () => _changeQty(index, 1)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_formatPrice(price * qty - itemDisc), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFC62828), fontSize: 14)),
                      if (itemDisc > 0)
                        Text('Disc. ${_formatPrice(itemDisc)}', style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap, {bool isDelete = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDelete ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(isDelete ? CupertinoIcons.trash : icon, size: 16, color: isDelete ? const Color(0xFFEF4444) : const Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildCashCard(int grandTotal, Responsive r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.green.withOpacity(0.2), width: 2),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            controller: _cashController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'TUNAI DIBAYARKAN',
              labelStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
              prefixText: 'Rp ',
              filled: true,
              fillColor: Colors.green.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
            onChanged: (_) => _calculateChange(grandTotal),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_change < 0 ? 'Kurang Bayar' : 'Kembalian', style: TextStyle(color: _change < 0 ? Colors.red : Colors.grey[600], fontWeight: FontWeight.bold)),
              Text(_formatPrice(_change.abs()), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _change < 0 ? Colors.red : Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRCard(Responsive r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFC62828).withOpacity(0.2), width: 2),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_2_rounded, color: Color(0xFFC62828)),
              const SizedBox(width: 8),
              const Text('Bukti Pembayaran QRIS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          if (_qrProofImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.file(File(_qrProofImage!.path), height: 160, width: double.infinity, fit: BoxFit.cover),
                  Positioned(
                    top: 8, right: 8,
                    child: IconButton.filled(
                      onPressed: () => setState(() => _qrProofImage = null),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      style: IconButton.styleFrom(backgroundColor: Colors.black45),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(child: _photoAction(Icons.camera_alt_rounded, 'Kamera', () => _pickProofImage(ImageSource.camera))),
                const SizedBox(width: 12),
                Expanded(child: _photoAction(Icons.image_rounded, 'Galeri', () => _pickProofImage(ImageSource.gallery))),
              ],
            ),
        ],
      ),
    );
  }

  Widget _photoAction(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFC62828),
        side: const BorderSide(color: Color(0xFFC62828)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildSummaryCard(int subtotal, int discount, int grandTotal, Responsive r) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC62828), Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFFC62828).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          _rowSummary('Subtotal', _formatPrice(subtotal), Colors.white70),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _rowSummary('Diskon Promo', '- ${_formatPrice(discount)}', const Color(0xFF6EE7B7)),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white24, thickness: 1),
          ),
          _rowSummary('TOTAL TAGIHAN', _formatPrice(grandTotal), Colors.white, isGrand: true),
        ],
      ),
    );
  }

  Widget _rowSummary(String label, String value, Color color, {bool isGrand = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: isGrand ? FontWeight.w900 : FontWeight.w500, fontSize: isGrand ? 16 : 14, fontFamily: 'Inter')),
        Text(value, style: TextStyle(color: color, fontWeight: isGrand ? FontWeight.w900 : FontWeight.w700, fontSize: isGrand ? 20 : 14, fontFamily: 'Inter')),
      ],
    );
  }

  Widget _buildStickyBottom(int grandTotal, int discount, Responsive r) {
    final bool canFinish = !_isCashMode || _change >= 0;
    return Container(
      padding: EdgeInsets.fromLTRB(r.space(20), r.space(16), r.space(20), r.space(36)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () {
                  if (!_isCashMode && !_isQRMode) _showPaymentOptions(grandTotal, r);
                  else if (canFinish) {
                    final cashVal = int.tryParse(_cashController.text.replaceAll('.', '')) ?? 0;
                    _processPayment(_items, grandTotal, _isCashMode ? cashVal : 0, discount, r);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: canFinish ? const Color(0xFFC62828) : Colors.grey[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isCashMode || _isQRMode ? 'KONFIRMASI BAYAR' : 'PILIH METODE BAYAR',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Inter'),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 60,
            width: 60,
            child: IconButton.filled(
              onPressed: () => Navigator.pushReplacementNamed(context, '/kasir'),
              icon: const Icon(Icons.close_rounded),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF5F5F7),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProofImage(ImageSource src) async {
    final file = await _imagePicker.pickImage(source: src, imageQuality: 70);
    if (file != null) setState(() => _qrProofImage = file);
  }
}
