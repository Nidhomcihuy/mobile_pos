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
                  Navigator.pushNamed(
                    context,
                    '/pembayaran',
                    arguments: _cart.values.toList(),
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
    final String scannedKey = found['id']?.toString() ?? name;
    setState(() {
      if (_cart.containsKey(scannedKey)) {
        _cart[scannedKey]!['quantity'] =
            (_cart[scannedKey]!['quantity'] as int) + 1;
      } else {
        _cart[scannedKey] = {
          'id': found['id'],
          'name': name,
          'price': found['price'],
          'quantity': 1,
        };
      }
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
    final products = _filteredProducts;
    return GridView.builder(
      padding: EdgeInsets.only(bottom: r.space(80)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: r.gridColumns,
        mainAxisSpacing: r.space(16),
        crossAxisSpacing: r.space(16),
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index], r),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, Responsive r) {
    final String productName = (product['name'] ?? '').toString();
    final String cartKey = product['id']?.toString() ?? '';
    final int quantity = cartKey.isEmpty
        ? 0
        : (_cart[cartKey]?['quantity'] ?? 0);
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
              child: product['image_url'] != null
                  ? Image.network(
                      product['image_url'] as String,
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
          Text(
            _formatPrice(product['price']),
            style: TextStyle(
              color: const Color(0xFF1D1B1B),
              fontSize: r.font(12),
              fontFamily: 'Inter',
            ),
          ),
          Text(
            'Stok: ${product['stock']}',
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
                          _cart[cartKey] = {
                            'id': product['id'],
                            'name': product['name'],
                            'price': product['price'],
                            'quantity': 1,
                          };
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
                              if (_cart[cartKey]!['quantity'] > 1) {
                                _cart[cartKey]!['quantity']--;
                              } else {
                                _cart.remove(cartKey);
                              }
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
                              if (_cart[cartKey]!['quantity'] <
                                  product['stock']) {
                                _cart[cartKey]!['quantity']++;
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
