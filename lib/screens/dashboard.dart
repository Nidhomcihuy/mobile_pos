import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive_helper.dart';
import '../utils/api_service.dart';
import '../utils/app_config.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  List<Map<String, dynamic>> _products = [];
  List<String> _categories = [];
  bool _isLoading = true;

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
        ApiService.fetchProducts(includeZeroStock: true),
        ApiService.fetchCategories(),
      ]);
      setState(() {
        _products = results[0];
        _categories = results[1].map((c) => c['name'].toString()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _products = _localProducts;
        _categories = ['Makanan', 'Minuman', 'Snack', 'Obat', 'Sembako'];
        _isLoading = false;
      });
    }
  }

  final List<Map<String, dynamic>> _localProducts = [
    {
      'id': 1,
      'name': 'Indomie Soto',
      'price': 3500,
      'stock': 50,
      'image': 'assets/images/indsoto.png',
      'category': 'Makanan',
      'sku': 'IDM-001',
      'rak': 'A-12',
      'area': 'Makanan Instan',
      'masuk': '20/01/2024',
      'kadaluarsa': '20/01/2025',
    },
    {
      'id': 2,
      'name': 'Indomie Goreng',
      'price': 3500,
      'stock': 45,
      'image': 'assets/images/indogoreng.png',
      'category': 'Makanan',
      'sku': 'IDM-002',
      'rak': 'A-12',
      'area': 'Makanan Instan',
      'masuk': '21/01/2024',
      'kadaluarsa': '21/01/2025',
    },
  ];

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

  DateTime _parseExpiry(String? val) {
    if (val == null || val.isEmpty) return DateTime(9999);
    final parts = val.split('/');
    if (parts.length == 3) {
      try {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } catch (_) {}
    }
    try {
      return DateTime.parse(val);
    } catch (_) {}
    return DateTime(9999);
  }

  List<Map<String, dynamic>> get _groupedFilteredProducts {
    final Map<String, Map<String, dynamic>> groups = {};
    for (final p in _filteredProducts) {
      final name = (p['name'] ?? '').toString();
      final price = (p['price'] as num).toInt();
      final ukuran = (p['ukuran'] ?? '').toString();
      final satuan = (p['satuan'] ?? '').toString();
      final key = '${name}__${price}__${ukuran}__$satuan';
      if (!groups.containsKey(key)) {
        groups[key] = Map<String, dynamic>.from(p)..['stock'] = 0;
      }
      groups[key]!['stock'] =
          (groups[key]!['stock'] as int) + (p['stock'] as int);
      final existingExpiry = _parseExpiry(
        (groups[key]!['expires_at'] ?? groups[key]!['kadaluarsa']) as String?,
      );
      final newExpiry = _parseExpiry(
        (p['expires_at'] ?? p['kadaluarsa']) as String?,
      );
      if (newExpiry.isBefore(existingExpiry)) {
        if (p.containsKey('expires_at')) {
          groups[key]!['expires_at'] = p['expires_at'];
        }
        if (p.containsKey('kadaluarsa')) {
          groups[key]!['kadaluarsa'] = p['kadaluarsa'];
        }
      }
    }
    return groups.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
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
    );
  }

  Widget _buildHeader(Responsive r) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(r.space(20), r.space(52), r.space(20), r.space(24)),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  AppConfig.storeLogo,
                  width: r.icon(50),
                  height: r.icon(50),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: r.space(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConfig.storeName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: r.font(22),
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        AppConfig.cashierName,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: r.font(14),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppConfig.todayDate,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: r.font(12),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, Responsive r) {
    final navItems = ['Dashboard', 'Kasir', 'Riwayat'];
    const selectedIndex = 0;

    return Container(
      margin: EdgeInsets.fromLTRB(r.space(20), r.space(16), r.space(20), 0),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ...List.generate(navItems.length, (index) {
            final isSelected = index == selectedIndex;
            return Expanded(
              child: InkWell(
                onTap: () {
                  if (!isSelected) {
                    Navigator.pushReplacementNamed(
                      context,
                      '/${navItems[index].toLowerCase()}',
                    );
                  }
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: r.space(10)),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFC62828)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    navItems[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontSize: r.font(15),
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            );
          }),
          Container(
            width: 1,
            height: 24,
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
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

  Widget _buildSearchBar(Responsive r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: r.font(13),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
    final products = _groupedFilteredProducts;
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Produk tidak ditemukan', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.only(bottom: r.space(20)),
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
    final int stock = (product['stock'] as num? ?? 0).toInt();
    final int minStock = (product['min_stock'] as num? ?? 0).toInt();
    final bool isOutOfStock = stock == 0;
    final bool isLowStock = !isOutOfStock && stock <= minStock && minStock > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Hero(
                      tag: 'prod-${product['id']}',
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: () {
                          final localPath = product['image'] as String?;
                          final networkUrl = product['image_url'] as String?;
                          if (localPath != null && localPath.isNotEmpty) {
                            return Image.asset(localPath, fit: BoxFit.contain, errorBuilder: (_, __, ___) => _networkOrPlaceholder(networkUrl));
                          }
                          return _networkOrPlaceholder(networkUrl);
                        }(),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: r.font(14), fontFamily: 'Inter'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(product['price']),
                      style: TextStyle(color: const Color(0xFFC62828), fontWeight: FontWeight.w900, fontSize: r.font(15)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Stok: $stock', style: TextStyle(color: isOutOfStock ? Colors.red : isLowStock ? Colors.orange : Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w700)),
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, '/detail', arguments: product),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Color(0xFFC62828), shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isOutOfStock || isLowStock)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOutOfStock ? Colors.black87 : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOutOfStock ? 'HABIS' : 'LIMIT',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _networkOrPlaceholder(String? url) {
    if (url != null && url.isNotEmpty) {
      return Image.network(url, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey));
    }
    return const Icon(Icons.inventory_2_rounded, size: 40, color: Color(0xFFC62828));
  }
}
