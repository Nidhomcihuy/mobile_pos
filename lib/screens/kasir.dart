import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive_helper.dart';
import '../utils/api_service.dart';
import '../utils/app_config.dart';

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

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(r),
              _buildNavBar(context, r),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.space(20)),
                  child: Column(
                    children: [
                      SizedBox(height: r.space(20)),
                      _buildSearchBar(r),
                      SizedBox(height: r.space(16)),
                      _buildCategoryFilters(r),
                      SizedBox(height: r.space(20)),
                      Expanded(child: _buildProductGrid(r)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_totalItems > 0)
            Positioned(
              bottom: r.space(24),
              right: r.space(24),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFB71C1C).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: FloatingActionButton.extended(
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
                    Navigator.pushNamed(context, '/pembayaran', arguments: pembayaranItems);
                  },
                  backgroundColor: const Color(0xFFC62828),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  icon: const Icon(Icons.shopping_basket_rounded, color: Colors.white),
                  label: Text('Bayar ($_totalItems)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Inter', fontSize: 16)),
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
      child: SafeArea(
        top: false, bottom: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(AppConfig.storeLogo, width: r.icon(50), height: r.icon(50), fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: r.space(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppConfig.storeName, style: TextStyle(color: Colors.white, fontSize: r.font(22), fontWeight: FontWeight.w900, fontFamily: 'Inter')),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(AppConfig.cashierName, style: TextStyle(color: Colors.white70, fontSize: r.font(14), fontFamily: 'Inter')),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(AppConfig.todayDate, style: TextStyle(color: Colors.white, fontSize: r.font(12), fontWeight: FontWeight.bold, fontFamily: 'Inter')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, Responsive r) {
    final navItems = ['Dashboard', 'Kasir', 'Riwayat'];
    const selectedIndex = 1;
    return Container(
      margin: EdgeInsets.fromLTRB(r.space(20), r.space(16), r.space(20), 0),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ...List.generate(navItems.length, (index) {
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
          Container(width: 1, height: 24, color: Colors.grey[200], margin: const EdgeInsets.symmetric(horizontal: 4)),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: Colors.red[700]),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('auth_token') ?? '';
              try { await ApiService.logout(token); } catch (_) {}
              await prefs.remove('auth_token');
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openScanner() async {
    final scanned = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const _BarcodeScannerScreen()));
    if (scanned == null || scanned.isEmpty) return;
    final found = _products.firstWhere(
      (p) => (p['barcode'] as String?)?.toLowerCase() == scanned.toLowerCase() || (p['sku'] as String?)?.toLowerCase() == scanned.toLowerCase() || (p['name'] as String).toLowerCase().contains(scanned.toLowerCase()),
      orElse: () => {},
    );
    if (found.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Produk "$scanned" tidak ditemukan'), backgroundColor: Colors.red));
      return;
    }
    final name = found['name'] as String;
    final price = found['price'] as int;
    final ukuran = (found['ukuran'] ?? '').toString();
    final satuan = (found['satuan'] ?? '').toString();
    final groupKey = '${name}__${price}__${ukuran}__$satuan';
    final groupBatches = _products.where((p) => (p['name'] ?? '') == name && (p['price'] as int) == price && (p['ukuran'] ?? '') == ukuran && (p['satuan'] ?? '') == satuan).map((p) => { 'id': p['id'], 'stock': p['stock'] as int, 'expires_at': p['expires_at'], }).toList()
      ..sort((a, b) {
        final ea = a['expires_at'] as String?; final eb = b['expires_at'] as String?;
        if (ea == null && eb == null) return 0;
        if (ea == null) return 1; if (eb == null) return -1;
        return _parseExpiry(ea).compareTo(_parseExpiry(eb));
      });
    setState(() { _addGroupToCart({ 'groupKey': groupKey, 'name': name, 'price': price, 'ukuran': ukuran, 'satuan': satuan, 'promo': found['promo'], 'batches': groupBatches, }); });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"$name" ditambahkan'), backgroundColor: Colors.green, duration: const Duration(seconds: 1)));
  }

  Widget _buildSearchBar(Responsive r) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: r.font(15)),
                prefixIcon: Icon(Icons.search_rounded, color: const Color(0xFFC62828), size: r.icon(22)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: r.space(16), vertical: r.space(14)),
              ),
            ),
          ),
        ),
        SizedBox(width: r.space(12)),
        InkWell(
          onTap: _openScanner,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(r.space(14)),
            decoration: BoxDecoration(color: const Color(0xFFC62828), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFFC62828).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]),
            child: Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: r.icon(22)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters(Responsive r) {
    final allItems = ['Semua', ..._categories];
    return SizedBox(
      height: r.space(40),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final name = allItems[index];
          final isSelected = _selectedCategory == name;
          return InkWell(
            onTap: () => setState(() => _selectedCategory = name),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: r.space(20)),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFC62828) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey[200]!),
              ),
              alignment: Alignment.center,
              child: Text(name, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[700], fontSize: r.font(13), fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, fontFamily: 'Inter')),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(Responsive r) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFC62828)));
    final groups = _groupedProducts;
    return GridView.builder(
      padding: EdgeInsets.only(bottom: r.space(80)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: r.gridColumns, mainAxisSpacing: r.space(16), crossAxisSpacing: r.space(16), childAspectRatio: 0.72),
      itemCount: groups.length,
      itemBuilder: (context, index) => _buildProductCard(groups[index], r),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> group, Responsive r) {
    final String productName = group['name'] as String;
    final String subtitle = [(group['ukuran'] ?? '').toString(), (group['satuan'] ?? '').toString()].where((s) => s.isNotEmpty).join(' ');
    final String groupKey = group['groupKey'] as String;
    final int totalStock = group['totalStock'] as int;
    final int quantity = _cart[groupKey]?['quantity'] as int? ?? 0;
    final promo = group['promo'] as Map<String, dynamic>?;
    final int displayPrice = promo != null ? (promo['discounted_price'] as num).toInt() : (group['price'] as int);

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity, margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(18)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: group['image_url'] != null ? Image.network(group['image_url'] as String, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_rounded, size: 40, color: Color(0xFFC62828))) : const Icon(Icons.inventory_2_rounded, size: 40, color: Color(0xFFC62828)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName, style: TextStyle(fontWeight: FontWeight.w800, fontSize: r.font(14), fontFamily: 'Inter'), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    const SizedBox(height: 4),
                    if (promo != null) ...[
                      Text(_formatPrice(group['price'] as int), style: TextStyle(color: Colors.grey[400], fontSize: 10, decoration: TextDecoration.lineThrough)),
                      Text(_formatPrice(displayPrice), style: TextStyle(color: const Color(0xFFC62828), fontWeight: FontWeight.w900, fontSize: r.font(15))),
                    ] else
                      Text(_formatPrice(group['price'] as int), style: TextStyle(color: const Color(0xFFC62828), fontWeight: FontWeight.w900, fontSize: r.font(15))),
                    const SizedBox(height: 8),
                    totalStock == 0 ? Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Stok Habis', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)))) : quantity == 0 ? SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() => _addGroupToCart(group)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 8)), child: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold)))) : Container(
                      decoration: BoxDecoration(color: const Color(0xFFC62828), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(icon: const Icon(Icons.remove, color: Colors.white, size: 18), onPressed: () => setState(() => _removeGroupFromCart(groupKey))),
                          Text('$quantity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 18), onPressed: () => setState(() => quantity < totalStock ? _addGroupToCart(group) : null)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (promo != null)
            Positioned(top: 14, left: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(8)), child: Text(promo['label'] as String, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)))),
        ],
      ),
    );
  }
}

class _BarcodeScannerScreen extends StatefulWidget {
  const _BarcodeScannerScreen();
  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}
class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  bool _scanned = false; final MobileScannerController _ctrl = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: const Color(0xFFC62828), foregroundColor: Colors.white, title: const Text('Scan Barcode', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700))),
      body: Stack(
        children: [
          MobileScanner(controller: _ctrl, onDetect: (capture) { if (_scanned) return; final barcode = capture.barcodes.firstOrNull; final raw = barcode?.rawValue; if (raw == null || raw.isEmpty) return; _scanned = true; Navigator.pop(context, raw); }),
          Center(child: Container(width: 260, height: 160, decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE53935), width: 3), borderRadius: BorderRadius.circular(12)))),
          const Positioned(bottom: 40, left: 0, right: 0, child: Text('Arahkan kamera ke barcode produk', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Inter'))),
        ],
      ),
    );
  }
}
