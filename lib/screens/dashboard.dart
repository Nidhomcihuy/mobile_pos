import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    try { await ApiService.logout(token); } catch (_) {}
    await prefs.remove('auth_token');
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
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
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC62828), width: 2),
                ),
                child: CircleAvatar(
                  radius: r.icon(22),
                  backgroundColor: const Color(0xFFC62828).withOpacity(0.1),
                  child: const Icon(CupertinoIcons.person_fill, color: Color(0xFFC62828)),
                ),
              ),
              SizedBox(width: r.space(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${AppConfig.cashierName}',
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontSize: r.font(16),
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppConfig.storeName,
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
            onPressed: _logout,
            icon: const Icon(CupertinoIcons.power, color: Color(0xFFEF4444)),
            tooltip: 'Logout',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFEF2F2),
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
          hintText: 'Cari produk...',
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
    final products = _groupedFilteredProducts;
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
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
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: TextStyle(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        fontSize: r.font(14),
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(product['price']),
                      style: TextStyle(
                        color: const Color(0xFFC62828),
                        fontWeight: FontWeight.w900,
                        fontSize: r.font(15),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stok: $stock',
                          style: TextStyle(
                            color: isOutOfStock ? const Color(0xFFEF4444) : isLowStock ? const Color(0xFFF59E0B) : const Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, '/detail', arguments: product),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC62828).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(CupertinoIcons.right_chevron, color: Color(0xFFC62828), size: 14),
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
                  color: isOutOfStock ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOutOfStock ? 'HABIS' : 'LIMIT',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _networkOrPlaceholder(String? url) {
    if (url != null && url.isNotEmpty) {
      return Image.network(url, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(CupertinoIcons.photo, color: Color(0xFFCBD5E1)));
    }
    return const Icon(CupertinoIcons.cube_box, size: 40, color: Color(0xFFCBD5E1));
  }
}
