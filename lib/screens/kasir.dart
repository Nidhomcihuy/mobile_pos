import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/responsive_helper.dart';
import '../utils/api_service.dart';

class Kasir extends StatefulWidget {
  const Kasir({super.key});

  @override
  State<Kasir> createState() => _KasirState();
}

class _KasirState extends State<Kasir> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  final Map<String, Map<String, dynamic>> _cart = {};

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    try {
      final results = await Future.wait([
        ApiService.fetchProducts(includeZeroStock: true),
        ApiService.fetchCategories(),
      ]);
      setState(() {
        _products = results[0];
        _categories = results[1].map((c) => c['name'].toString()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
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

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((product) {
      final matchCategory = _selectedCategory == 'Semua' || product['category'] == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty || (product['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  DateTime _parseExpiry(String ddMmYyyy) {
    final p = ddMmYyyy.split('/');
    if (p.length != 3) return DateTime(9999);
    return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
  }

  List<Map<String, dynamic>> get _groupedProducts {
    final Map<String, Map<String, dynamic>> groups = {};
    for (final p in _filteredProducts) {
      final name = (p['name'] ?? '').toString();
      final price = p['price'] as int;
      final ukuran = (p['ukuran'] ?? '').toString();
      final satuan = (p['satuan'] ?? '').toString();
      final key = '${name}__${price}__${ukuran}__$satuan';
      if (!groups.containsKey(key)) {
        groups[key] = {
          'groupKey': key,
          'name': name,
          'price': price,
          'ukuran': ukuran,
          'satuan': satuan,
          'totalStock': 0,
          'category': p['category'],
          'image_url': p['image_url'],
          'promo': p['promo'],
          'batches': <Map<String, dynamic>>[],
        };
      }
      (groups[key]!['batches'] as List<Map<String, dynamic>>).add({
        'id': p['id'], 'stock': p['stock'] as int, 'expires_at': p['expires_at'], 'promo': p['promo'],
      });
      groups[key]!['totalStock'] = (groups[key]!['totalStock'] as int) + (p['stock'] as int);
    }
    for (final group in groups.values) {
      (group['batches'] as List<Map<String, dynamic>>).sort((a, b) {
        final ea = a['expires_at'] as String?;
        final eb = b['expires_at'] as String?;
        if (ea == null && eb == null) return 0;
        if (ea == null) return 1;
        if (eb == null) return -1;
        return _parseExpiry(ea).compareTo(_parseExpiry(eb));
      });
      final sortedBatches = group['batches'] as List<Map<String, dynamic>>;
      group['promo'] = sortedBatches.isNotEmpty ? sortedBatches.first['promo'] : null;
    }
    return groups.values.toList();
  }

  void _addGroupToCart(Map<String, dynamic> group) {
    final key = group['groupKey'] as String;
    final batches = group['batches'] as List<Map<String, dynamic>>;
    if (!_cart.containsKey(key)) {
      _cart[key] = {
        'groupKey': key, 'name': group['name'], 'price': group['price'], 'promo': group['promo'], 'quantity': 0,
        'batches': batches.map((b) => { 'id': b['id'], 'stock': b['stock'] as int, 'qty': 0, 'expires_at': b['expires_at'], 'promo': b['promo'], }).toList(),
      };
    }
    final cartBatches = _cart[key]!['batches'] as List<Map<String, dynamic>>;
    for (final b in cartBatches) {
      if ((b['qty'] as int) < (b['stock'] as int)) {
        b['qty'] = (b['qty'] as int) + 1;
        _cart[key]!['quantity'] = (_cart[key]!['quantity'] as int) + 1;
        break;
      }
    }
  }

  void _removeGroupFromCart(String key) {
    if (!_cart.containsKey(key)) return;
    final cartBatches = _cart[key]!['batches'] as List<Map<String, dynamic>>;
    for (int i = cartBatches.length - 1; i >= 0; i--) {
      if ((cartBatches[i]['qty'] as int) > 0) {
        cartBatches[i]['qty'] = (cartBatches[i]['qty'] as int) - 1;
        _cart[key]!['quantity'] = (_cart[key]!['quantity'] as int) - 1;
        break;
      }
    }
    if ((_cart[key]!['quantity'] as int) <= 0) { _cart.remove(key); }
  }

  int get _totalItems { return _cart.values.fold(0, (sum, item) => sum + (item['quantity'] as int)); }

  int get _totalPrice {
    return _cart.values.fold(0, (sum, item) {
      final qty = item['quantity'] as int;
      final promo = item['promo'];
      final price = promo != null ? (promo['discounted_price'] as num).toInt() : (item['price'] as int);
      return sum + (price * qty);
    });
  }

  void _scanBarcode() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final String? barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Scan Barcode', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)), backgroundColor: const Color(0xFFC62828), foregroundColor: Colors.white),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  Navigator.pop(context, barcode.rawValue);
                  return;
                }
              }
            },
          ),
        ),
      ),
    );

    if (barcode != null && barcode.isNotEmpty) {
      final found = _products.firstWhere((p) => p['barcode'] == barcode || p['sku'] == barcode, orElse: () => {});
      if (found.isNotEmpty) {
        final name = (found['name'] ?? '').toString();
        final price = found['price'] as int;
        final ukuran = (found['ukuran'] ?? '').toString();
        final satuan = (found['satuan'] ?? '').toString();
        final groupKey = '${name}__${price}__${ukuran}__$satuan';
        final groupBatches = _products.where((p) => (p['name'] ?? '') == name && (p['price'] as int) == price && (p['ukuran'] ?? '') == ukuran && (p['satuan'] ?? '') == satuan).map((p) => { 'id': p['id'], 'stock': p['stock'] as int, 'expires_at': p['expires_at'], }).toList();
        
        setState(() { _addGroupToCart({ 'groupKey': groupKey, 'name': name, 'price': price, 'ukuran': ukuran, 'satuan': satuan, 'promo': found['promo'], 'batches': groupBatches, }); });
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Produk ditambahkan: $name', style: const TextStyle(fontFamily: 'Inter')), backgroundColor: Colors.green, duration: const Duration(seconds: 1)));
      } else {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Produk tidak ditemukan untuk barcode: $barcode', style: const TextStyle(fontFamily: 'Inter')), backgroundColor: const Color(0xFFEF4444)));
      }
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: r.space(20)),
                child: Column(
                  children: [
                    SizedBox(height: r.space(16)),
                    _buildSearchBar(r),
                    SizedBox(height: r.space(20)),
                    _buildCategoryFilters(r),
                    SizedBox(height: r.space(20)),
                    Expanded(child: _buildProductGrid(r)),
                  ],
                ),
              ),
            ),
            if (_totalItems > 0) _buildStickyCart(r),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Responsive r) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.space(20), vertical: r.space(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFC62828).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(CupertinoIcons.cart_fill, color: Color(0xFFC62828), size: 24),
              ),
              SizedBox(width: r.space(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Point of Sale',
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontSize: r.font(18),
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pilih produk untuk transaksi',
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
          IconButton(
            onPressed: _scanBarcode,
            icon: const Icon(CupertinoIcons.barcode_viewfinder, color: Color(0xFFC62828)),
            tooltip: 'Scan Barcode',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFC62828).withOpacity(0.08),
              padding: const EdgeInsets.all(12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar(Responsive r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(fontSize: r.font(14), color: const Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: 'Cari produk kasir...',
          hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: r.font(14)),
          prefixIcon: Icon(CupertinoIcons.search, color: const Color(0xFFC62828), size: r.icon(20)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: r.space(16), vertical: r.space(16)),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(Responsive r) {
    final allItems = ['Semua', ..._categories];
    return SizedBox(
      height: r.space(38),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final name = allItems[index];
          final isSelected = _selectedCategory == name;
          return InkWell(
            onTap: () => setState(() => _selectedCategory = name),
            borderRadius: BorderRadius.circular(100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: r.space(20)),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFC62828) : Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected ? const Color(0xFFC62828) : const Color(0xFFE2E8F0),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontSize: r.font(13),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(Responsive r) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFC62828)));
    }
    final products = _groupedProducts;
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.cube_box, size: 64, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text('Produk tidak ditemukan', style: TextStyle(color: const Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.only(bottom: r.space(30)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: r.gridColumns,
        mainAxisSpacing: r.space(16),
        crossAxisSpacing: r.space(16),
        childAspectRatio: 0.65,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index], r),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> group, Responsive r) {
    final int stock = group['totalStock'] as int;
    final bool isOutOfStock = stock == 0;
    final cartItem = _cart[group['groupKey'] as String];
    final int cartQty = cartItem != null ? cartItem['quantity'] as int : 0;
    
    final promo = group['promo'];
    final int displayPrice = promo != null ? (promo['discounted_price'] as num).toInt() : (group['price'] as int);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cartQty > 0 ? const Color(0xFFC62828) : const Color(0xFFF1F5F9), width: cartQty > 0 ? 2 : 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(cartQty > 0 ? 0.08 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: () {
                        final networkUrl = group['image_url'] as String?;
                        if (networkUrl != null && networkUrl.isNotEmpty) {
                          return Image.network(networkUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(CupertinoIcons.photo, color: Color(0xFFCBD5E1)));
                        }
                        return const Icon(CupertinoIcons.cube_box, size: 40, color: Color(0xFFCBD5E1));
                      }(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group['name'],
                      style: TextStyle(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        fontSize: r.font(13),
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (promo != null)
                      Text(_formatPrice(group['price'] as int), style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 10, decoration: TextDecoration.lineThrough, fontFamily: 'Inter')),
                    Text(
                      _formatPrice(displayPrice),
                      style: TextStyle(
                        color: const Color(0xFFC62828),
                        fontWeight: FontWeight.w900,
                        fontSize: r.font(14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCartControls(group, stock, cartQty, isOutOfStock, r),
                  ],
                ),
              ),
            ],
          ),
          if (promo != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(6)),
                child: Text(promo['label'] ?? 'Promo', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
              ),
            ),
          if (isOutOfStock)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(8)),
                child: const Text('HABIS', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartControls(Map<String, dynamic> group, int stock, int cartQty, bool isOutOfStock, Responsive r) {
    if (isOutOfStock) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: const Text('Stok Kosong', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
      );
    }

    if (cartQty == 0) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => setState(() => _addGroupToCart(group)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC62828),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Tambah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFC62828).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => setState(() => _removeGroupFromCart(group['groupKey'] as String)),
            icon: const Icon(CupertinoIcons.minus, size: 16),
            color: const Color(0xFFC62828),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Text(
            '$cartQty',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFC62828)),
          ),
          IconButton(
            onPressed: cartQty < stock ? () => setState(() => _addGroupToCart(group)) : null,
            icon: const Icon(CupertinoIcons.plus, size: 16),
            color: cartQty < stock ? const Color(0xFFC62828) : const Color(0xFFCBD5E1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyCart(Responsive r) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.space(20), vertical: r.space(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Belanja ($_totalItems Item)', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                const SizedBox(height: 2),
                Text(
                  _formatPrice(_totalPrice),
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Inter'),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final pembayaranItems = <Map<String, dynamic>>[];
              for (final entry in _cart.values) {
                final cartBatches = entry['batches'] as List<Map<String, dynamic>>;
                final activeBatches = cartBatches.where((b) => (b['qty'] as int) > 0).map((b) => Map<String, dynamic>.from(b)).toList();
                if (activeBatches.isEmpty) continue;
                final totalQty = activeBatches.fold(0, (s, b) => s + (b['qty'] as int));
                pembayaranItems.add({
                  'name': entry['name'], 'price': entry['price'], 'promo': entry['promo'], 'quantity': totalQty, 'batches': activeBatches,
                });
              }
              Navigator.pushNamed(context, '/pembayaran', arguments: pembayaranItems).then((cleared) {
                if (cleared == true) setState(() { _cart.clear(); _loadData(); });
              });
            },
            icon: const Icon(CupertinoIcons.arrow_right, size: 18),
            label: const Text('Bayar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          )
        ],
      ),
    );
  }
}
