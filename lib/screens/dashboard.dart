import 'package:flutter/material.dart';
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
    {
      'id': 3,
      'name': 'Kanzler Singles',
      'price': 9000,
      'stock': 20,
      'image': 'assets/images/sosisknzlr.png',
      'category': 'Makanan',
      'sku': 'KNZ-001',
      'rak': 'B-05',
      'area': 'Frozen Food',
      'masuk': '15/02/2024',
      'kadaluarsa': '15/05/2024',
    },
    {
      'id': 10,
      'name': 'Aqua 600ml',
      'price': 3500,
      'stock': 100,
      'image': 'assets/images/aqua600.png',
      'category': 'Minuman',
      'sku': 'AQ-001',
      'rak': 'C-03',
      'area': 'Air Mineral',
      'masuk': '01/01/2024',
      'kadaluarsa': '01/01/2026',
    },
    {
      'id': 24,
      'name': 'Beras Maknyuss 5kg',
      'price': 78000,
      'stock': 10,
      'image': 'assets/images/berasmkys.png',
      'category': 'Sembako',
      'sku': 'SMB-001',
      'rak': 'F-01',
      'area': 'Kebutuhan Pokok',
      'masuk': '20/02/2024',
      'kadaluarsa': '20/02/2025',
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

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
      body: Column(
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
    const selectedIndex = 0;

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
                  if (!isSelected)
                    Navigator.pushReplacementNamed(
                      context,
                      '/${navItems[index].toLowerCase()}',
                    );
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
        InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.space(22),
              vertical: r.space(12),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'cari',
              style: TextStyle(
                color: Colors.white,
                fontSize: r.font(16),
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
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
    if (_isLoading)
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFC62828)),
      );
    final products = _filteredProducts;
    return GridView.builder(
      padding: EdgeInsets.only(bottom: r.space(20)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: r.gridColumns,
        mainAxisSpacing: r.space(16),
        crossAxisSpacing: r.space(16),
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index], r),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, Responsive r) {
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
              child: () {
                final localPath = product['image'] as String?;
                final networkUrl = product['image_url'] as String?;
                if (localPath != null && localPath.isNotEmpty) {
                  return Image.asset(
                    localPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        _networkOrPlaceholder(networkUrl),
                  );
                }
                return _networkOrPlaceholder(networkUrl);
              }(),
            ),
          ),
          Text(
            product['name'],
            style: TextStyle(
              color: Colors.black,
              fontSize: r.font(13),
              fontWeight: FontWeight.bold,
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
            ),
          ),
          Text(
            'Stok: ${product['stock']}',
            style: TextStyle(
              color: const Color(0xFF1D1B1B),
              fontSize: r.font(12),
            ),
          ),
          SizedBox(height: r.space(8)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.space(12)),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/detail', arguments: product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Lihat',
                  style: TextStyle(fontSize: r.font(12), color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: r.space(10)),
        ],
      ),
    );
  }

  Widget _networkOrPlaceholder(String? url) {
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
    return const Icon(Icons.inventory_2, size: 48, color: Color(0xFFC62828));
  }
}
