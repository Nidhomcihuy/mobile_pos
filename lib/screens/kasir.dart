import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
    setState(() {
      _isLoading = true;
    });
    try {
      final results = await Future.wait([
        ApiService.fetchProducts(),
        ApiService.fetchCategories(),
      ]);
      setState(() {
        _products = results[0];
        _categories = results[1].map((c) => c['name'].toString()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
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
    return 'Rp. $result';
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((product) {
      final matchCategory =
          _selectedCategory == 'Semua' ||
          product['category'] == _selectedCategory;
      final matchSearch =
          _searchQuery.isEmpty ||
          (product['name'] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchCategory && matchSearch;
    }).toList();
  }

  DateTime _parseExpiry(String ddMmYyyy) {
    final p = ddMmYyyy.split('/');
    if (p.length != 3) return DateTime(9999);
    return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
  }

  /// Mengelompokkan produk berdasarkan nama + harga yang sama menjadi satu kartu.
  /// Batch diurutkan FIFO: expires_at paling dekat duluan (null = paling akhir).
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
          'batches': <Map<String, dynamic>>[],
        };
      }
      (groups[key]!['batches'] as List<Map<String, dynamic>>).add({
        'id': p['id'],
        'stock': p['stock'] as int,
        'expires_at': p['expires_at'],
      });
      groups[key]!['totalStock'] =
          (groups[key]!['totalStock'] as int) + (p['stock'] as int);
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
    }
    return groups.values.toList();
  }

  /// Tambah 1 qty ke cart untuk group: isi batch FIFO (expired terdekat dulu).
  void _addGroupToCart(Map<String, dynamic> group) {
    final key = group['groupKey'] as String;
    final batches = group['batches'] as List<Map<String, dynamic>>;
    if (!_cart.containsKey(key)) {
      _cart[key] = {
        'groupKey': key,
        'name': group['name'],
        'price': group['price'],
        'quantity': 0,
        'batches': batches
            .map(
              (b) => {
                'id': b['id'],
                'stock': b['stock'] as int,
                'qty': 0,
                'expires_at': b['expires_at'],
              },
            )
            .toList(),
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

  /// Kurangi 1 qty dari cart: kurangi dari batch paling belakang (undo FIFO).
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
    if ((_cart[key]!['quantity'] as int) <= 0) {
      _cart.remove(key);
    }
  }

  int get _totalItems {
    return _cart.values.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
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
                      SizedBox(height: r.space(16)),
                      _buildSearchBar(r),
                      SizedBox(height: r.space(14)),
                      _buildCategoryFilters(r),
                      SizedBox(height: r.space(18)),
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
              child: FloatingActionButton.extended(
                onPressed: () {
                  // Flatten grouped cart ke list item per batch untuk pembayaran
                  final pembayaranItems = <Map<String, dynamic>>[];
                  for (final entry in _cart.values) {
                    final cartBatches =
                        entry['batches'] as List<Map<String, dynamic>>;
                    final activeBatches = cartBatches
                        .where((b) => (b['qty'] as int) > 0)
                        .map((b) => Map<String, dynamic>.from(b))
                        .toList();
                    if (activeBatches.isEmpty) continue;
                    final totalQty = activeBatches.fold(
                      0,
                      (s, b) => s + (b['qty'] as int),
                    );
                    pembayaranItems.add({
                      'name': entry['name'],
                      'price': entry['price'],
                      'quantity': totalQty,
                      'batches': activeBatches,
                    });
                  }
                  Navigator.pushNamed(
                    context,
                    '/pembayaran',
                    arguments: pembayaranItems,
                  );
                },
                backgroundColor: const Color(0xFFB71C1C),
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  'Keranjang ($_totalItems)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
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
    const selectedIndex = 1;

    return Container(
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

  Future<void> _openScanner() async {
    final scanned = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _BarcodeScannerScreen()),
    );
    if (scanned == null || scanned.isEmpty) return;

    // Cari produk berdasarkan SKU atau nama
    final found = _products.firstWhere(
      (p) =>
          (p['sku'] as String?)?.toLowerCase() == scanned.toLowerCase() ||
          (p['name'] as String).toLowerCase().contains(scanned.toLowerCase()),
      orElse: () => {},
    );

    if (found.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk "$scanned" tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final name = found['name'] as String;
    final price = found['price'] as int;
    final ukuran = (found['ukuran'] ?? '').toString();
    final satuan = (found['satuan'] ?? '').toString();
    final groupKey = '${name}__${price}__${ukuran}__$satuan';
    // Kumpulkan semua batch produk dengan nama+harga+ukuran+satuan sama, urutkan FIFO
    final groupBatches =
        _products
            .where(
              (p) =>
                  (p['name'] ?? '') == name &&
                  (p['price'] as int) == price &&
                  (p['ukuran'] ?? '') == ukuran &&
                  (p['satuan'] ?? '') == satuan,
            )
            .map(
              (p) => {
                'id': p['id'],
                'stock': p['stock'] as int,
                'expires_at': p['expires_at'],
              },
            )
            .toList()
          ..sort((a, b) {
            final ea = a['expires_at'] as String?;
            final eb = b['expires_at'] as String?;
            if (ea == null && eb == null) return 0;
            if (ea == null) return 1;
            if (eb == null) return -1;
            return _parseExpiry(ea).compareTo(_parseExpiry(eb));
          });
    setState(() {
      _addGroupToCart({
        'groupKey': groupKey,
        'name': name,
        'price': price,
        'ukuran': ukuran,
        'satuan': satuan,
        'batches': groupBatches,
      });
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$name" ditambahkan ke keranjang'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildSearchBar(Responsive r) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD9D9D9), width: 2),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(fontSize: r.font(16), fontFamily: 'Inter'),
              decoration: InputDecoration(
                hintText: 'cari produk',
                hintStyle: TextStyle(
                  color: const Color(0xFF696969),
                  fontSize: r.font(16),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color(0xFF696969),
                  size: r.icon(24),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: r.space(16),
                  vertical: r.space(12),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: r.space(10)),
        // Tombol scan barcode
        InkWell(
          onTap: _openScanner,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(r.space(12)),
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: r.icon(24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters(Responsive r) {
    final allItems = ['Semua', ..._categories];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: allItems.map((name) {
          final isSelected = _selectedCategory == name;
          return Padding(
            padding: EdgeInsets.only(right: r.space(10)),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = name),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.space(16),
                  vertical: r.space(10),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFB71C1C)
                      : const Color(0xFFB71C1C).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontSize: r.font(14),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGrid(Responsive r) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFC62828)),
      );
    }
    final groups = _groupedProducts;
    return GridView.builder(
      padding: EdgeInsets.only(bottom: r.space(80)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: r.gridColumns,
        mainAxisSpacing: r.space(16),
        crossAxisSpacing: r.space(16),
        childAspectRatio: 0.72,
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) => _buildProductCard(groups[index], r),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> group, Responsive r) {
    final String productName = group['name'] as String;
    final String ukuran = (group['ukuran'] ?? '').toString();
    final String satuan = (group['satuan'] ?? '').toString();
    final String subtitle = [
      ukuran,
      satuan,
    ].where((s) => s.isNotEmpty).join(' ');
    final String groupKey = group['groupKey'] as String;
    final int totalStock = group['totalStock'] as int;
    final int quantity = _cart[groupKey]?['quantity'] as int? ?? 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE53935).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(r.space(12)),
              child: group['image_url'] != null
                  ? Image.network(
                      group['image_url'] as String,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFC62828),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.inventory_2,
                        size: 48,
                        color: Color(0xFFC62828),
                      ),
                    )
                  : const Icon(
                      Icons.inventory_2,
                      size: 48,
                      color: Color(0xFFC62828),
                    ),
            ),
          ),
          Text(
            productName,
            style: TextStyle(
              color: Colors.black,
              fontSize: r.font(13),
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(
                color: const Color(0xFF888888),
                fontSize: r.font(11),
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          Text(
            _formatPrice(group['price'] as int),
            style: TextStyle(
              color: const Color(0xFF1D1B1B),
              fontSize: r.font(12),
              fontFamily: 'Inter',
            ),
          ),
          Text(
            'Stok: $totalStock',
            style: TextStyle(
              color: const Color(0xFF1D1B1B),
              fontSize: r.font(12),
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: r.space(6)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.space(16)),
            child: quantity == 0
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _addGroupToCart(group);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(vertical: r.space(8)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Tambah',
                        style: TextStyle(
                          fontSize: r.font(12),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: r.space(2)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _removeGroupFromCart(groupKey);
                            });
                          },
                        ),
                        Text(
                          quantity.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: r.font(14),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              if (quantity < totalStock) {
                                _addGroupToCart(group);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
          ),
          SizedBox(height: r.space(10)),
        ],
      ),
    );
  }
}

// ── Barcode Scanner Screen ─────────────────────────────────────────────────
class _BarcodeScannerScreen extends StatefulWidget {
  const _BarcodeScannerScreen();

  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  bool _scanned = false;
  final MobileScannerController _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
        title: const Text(
          'Scan Barcode Produk',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Flash',
            onPressed: () => _ctrl.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            tooltip: 'Ganti Kamera',
            onPressed: () => _ctrl.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _ctrl,
            onDetect: (capture) {
              if (_scanned) return;
              final barcode = capture.barcodes.firstOrNull;
              final raw = barcode?.rawValue;
              if (raw == null || raw.isEmpty) return;
              _scanned = true;
              Navigator.pop(context, raw);
            },
          ),
          // Overlay viewfinder
          Center(
            child: Container(
              width: 260,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE53935), width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: const Text(
              'Arahkan kamera ke barcode produk',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
