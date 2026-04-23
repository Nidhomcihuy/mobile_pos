import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Makanan', 'icon': 'assets/icons/Hamburger.png'},
    {'name': 'Minuman', 'icon': 'assets/icons/Soda.png'},
    {'name': 'Snack', 'icon': 'assets/icons/Doughnut.png'},
    {'name': 'Obat', 'icon': 'assets/icons/Pill.png'},
    {'name': 'Sembako', 'icon': 'assets/icons/Grains Of Rice.png'},
  ];

  final List<Map<String, dynamic>> _products = [
    {'name': 'Indomie Soto', 'price': 3500, 'stock': 50, 'image': 'assets/icons/Hamburger.png', 'category': 'Makanan'},
    {'name': 'Beras Maknyuss', 'price': 78000, 'stock': 50, 'image': 'assets/icons/Grains Of Rice.png', 'category': 'Sembako'},
    {'name': 'Sari Roti Sandwich', 'price': 5000, 'stock': 50, 'image': 'assets/icons/Doughnut.png', 'category': 'Snack'},
    {'name': 'Indomie Goreng', 'price': 3500, 'stock': 50, 'image': 'assets/icons/Hamburger.png', 'category': 'Makanan'},
    {'name': 'Tepung Segitiga Biru', 'price': 12000, 'stock': 50, 'image': 'assets/icons/Grains Of Rice.png', 'category': 'Sembako'},
    {'name': 'Gulaku', 'price': 18000, 'stock': 50, 'image': 'assets/icons/Grains Of Rice.png', 'category': 'Sembako'},
    {'name': 'Indomie Pedas', 'price': 3500, 'stock': 50, 'image': 'assets/icons/Hamburger.png', 'category': 'Makanan'},
    {'name': 'UHT Frisian Flag', 'price': 5500, 'stock': 50, 'image': 'assets/icons/Soda.png', 'category': 'Minuman'},
    {'name': 'Santan Sasa', 'price': 8000, 'stock': 50, 'image': 'assets/icons/Soda.png', 'category': 'Minuman'},
    {'name': 'UHT Cimory', 'price': 6000, 'stock': 50, 'image': 'assets/icons/Soda.png', 'category': 'Minuman'},
    {'name': 'Kanzler Singles', 'price': 9000, 'stock': 50, 'image': 'assets/icons/Hamburger.png', 'category': 'Makanan'},
    {'name': 'Cimory Yoghurt', 'price': 9500, 'stock': 50, 'image': 'assets/icons/Soda.png', 'category': 'Minuman'},
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
          _selectedCategory == 'Semua' || product['category'] == _selectedCategory;
      final matchSearch =
          _searchQuery.isEmpty ||
          (product['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE3),
      body: Column(
        children: [
          _buildHeader(r),
          _buildNavBar(r),
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

  // ────────────────────────────────────────
  //  HEADER
  // ────────────────────────────────────────
  Widget _buildHeader(Responsive r) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: r.space(20), vertical: r.space(14)),
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
            Container(
              width: r.icon(48),
              height: r.icon(48),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.store, color: Colors.white, size: r.icon(28)),
            ),
            SizedBox(width: r.space(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'POS TOSERBA',
                    style: TextStyle(
                      color: const Color(0xFFFFFEE4),
                      fontSize: r.font(22),
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    'jl. indah no.15, Sidoarjo',
                    style: TextStyle(
                      color: const Color(0xFFFFFEE4),
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
                  'Kasir: Dewi',
                  style: TextStyle(
                    color: const Color(0xFFFFFEE4),
                    fontSize: r.font(18),
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  '30/02/2026',
                  style: TextStyle(
                    color: const Color(0xFFFFFEE4),
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

  // ────────────────────────────────────────
  //  NAVIGATION BAR
  // ────────────────────────────────────────
  Widget _buildNavBar(Responsive r) {
    final navItems = ['Dashboard', 'Kasir', 'Riwayat'];
    final navRoutes = ['/dashboard', '/kasir', '/riwayat'];
    const selectedIndex = 0;

    return Container(
      margin: EdgeInsets.only(left: r.space(20), right: r.space(20), top: r.space(12)),
      padding: EdgeInsets.symmetric(horizontal: r.space(8), vertical: r.space(6)),
      decoration: BoxDecoration(
        color: const Color(0xFFBDB76B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(navItems.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: r.space(4)),
            child: InkWell(
              onTap: () {
                if (!isSelected) {
                  Navigator.pushReplacementNamed(context, navRoutes[index]);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: r.space(20), vertical: r.space(10)),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFFEE4).withOpacity(0.25) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  navItems[index],
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFFFFEE4) : Colors.black87,
                    fontSize: r.font(16),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ────────────────────────────────────────
  //  SEARCH BAR
  // ────────────────────────────────────────
  Widget _buildSearchBar(Responsive r) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFEE4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD9D9D9), width: 2),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(fontSize: r.font(16), fontFamily: 'Inter'),
              decoration: InputDecoration(
                hintText: 'cari produk',
                hintStyle: TextStyle(color: const Color(0xFF696969), fontSize: r.font(16)),
                prefixIcon: Icon(Icons.search, color: const Color(0xFF696969), size: r.icon(24)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: r.space(16), vertical: r.space(12)),
              ),
            ),
          ),
        ),
        SizedBox(width: r.space(10)),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: r.space(22), vertical: r.space(12)),
            decoration: BoxDecoration(
              color: const Color(0xFFCE8947),
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

  // ────────────────────────────────────────
  //  CATEGORY FILTERS
  // ────────────────────────────────────────
  Widget _buildCategoryFilters(Responsive r) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          InkWell(
            onTap: () => setState(() => _selectedCategory = 'Semua'),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: EdgeInsets.all(r.space(10)),
              decoration: BoxDecoration(
                color: _selectedCategory == 'Semua'
                    ? const Color(0xFFCE8947)
                    : const Color(0xFFCE8947).withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/icons/Conversion.png',
                width: r.icon(24),
                height: r.icon(24),
                color: const Color(0xFFFFFEE4),
              ),
            ),
          ),
          SizedBox(width: r.space(10)),
          ..._categories.map((cat) {
            final isSelected = _selectedCategory == cat['name'];
            return Padding(
              padding: EdgeInsets.only(right: r.space(10)),
              child: InkWell(
                onTap: () => setState(() => _selectedCategory = cat['name']),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: r.space(16), vertical: r.space(10)),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFCE8947)
                        : const Color(0xFFCE8947).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cat['name'],
                        style: TextStyle(
                          color: const Color(0xFFFFFEE4),
                          fontSize: r.font(14),
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(width: r.space(8)),
                      Image.asset(
                        cat['icon'],
                        width: r.icon(20),
                        height: r.icon(20),
                        color: const Color(0xFFFFFEE4),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ────────────────────────────────────────
  //  PRODUCT GRID
  // ────────────────────────────────────────
  Widget _buildProductGrid(Responsive r) {
    final products = _filteredProducts;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = r.gridColumns;
        final spacing = r.space(16);
        final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final itemHeight = itemWidth / 0.72;

        return GridView.builder(
          padding: EdgeInsets.only(bottom: r.space(20)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: itemWidth / itemHeight,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => _buildProductCard(products[index], r),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, Responsive r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD8B84B).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD8B84B).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: r.space(10)),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: r.space(16)),
              child: Image.asset(
                product['image'],
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: r.space(6)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.space(8)),
            child: Text(
              product['name'],
              style: TextStyle(
                color: Colors.black,
                fontSize: r.font(13),
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: r.space(2)),
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/detail'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD8B84B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: r.space(8)),
                  elevation: 0,
                ),
                child: Text(
                  'Lihat',
                  style: TextStyle(fontSize: r.font(12), fontFamily: 'Inter'),
                ),
              ),
            ),
          ),
          SizedBox(height: r.space(10)),
        ],
      ),
    );
  }
}