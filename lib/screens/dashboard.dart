import 'package:flutter/material.dart';

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
    {
      'name': 'Indomie Soto',
      'price': 3500,
      'stock': 50,
      'image': 'assets/icons/Hamburger.png',
      'category': 'Makanan',
    },
    {
      'name': 'Beras Maknyuss',
      'price': 78000,
      'stock': 50,
      'image': 'assets/icons/Grains Of Rice.png',
      'category': 'Sembako',
    },
    {
      'name': 'Sari Roti Sandwich',
      'price': 5000,
      'stock': 50,
      'image': 'assets/icons/Doughnut.png',
      'category': 'Snack',
    },
    {
      'name': 'Indomie Goreng',
      'price': 3500,
      'stock': 50,
      'image': 'assets/icons/Hamburger.png',
      'category': 'Makanan',
    },
    {
      'name': 'Tepung Segitiga Biru',
      'price': 12000,
      'stock': 50,
      'image': 'assets/icons/Grains Of Rice.png',
      'category': 'Sembako',
    },
    {
      'name': 'Gulaku',
      'price': 18000,
      'stock': 50,
      'image': 'assets/icons/Grains Of Rice.png',
      'category': 'Sembako',
    },
    {
      'name': 'Indomie Pedas',
      'price': 3500,
      'stock': 50,
      'image': 'assets/icons/Hamburger.png',
      'category': 'Makanan',
    },
    {
      'name': 'UHT Frisian Flag',
      'price': 5500,
      'stock': 50,
      'image': 'assets/icons/Soda.png',
      'category': 'Minuman',
    },
    {
      'name': 'Santan Sasa',
      'price': 8000,
      'stock': 50,
      'image': 'assets/icons/Soda.png',
      'category': 'Minuman',
    },
    {
      'name': 'UHT Cimory',
      'price': 6000,
      'stock': 50,
      'image': 'assets/icons/Soda.png',
      'category': 'Minuman',
    },
    {
      'name': 'Kanzler Singles',
      'price': 9000,
      'stock': 50,
      'image': 'assets/icons/Hamburger.png',
      'category': 'Makanan',
    },
    {
      'name': 'Cimory Yoghurt',
      'price': 9500,
      'stock': 50,
      'image': 'assets/icons/Soda.png',
      'category': 'Minuman',
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
          _selectedCategory == 'Semua' || product['category'] == _selectedCategory;
      final matchSearch =
          _searchQuery.isEmpty ||
          (product['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE3),
      body: Column(
        children: [
          // ===== HEADER =====
          _buildHeader(),
          // ===== NAV BAR =====
          _buildNavBar(),
          // ===== CONTENT =====
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                  const SizedBox(height: 14),
                  _buildCategoryFilters(),
                  const SizedBox(height: 18),
                  Expanded(child: _buildProductGrid()),
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
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
            // Logo placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.store, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            // Store info
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POS TOSERBA',
                  style: TextStyle(
                    color: Color(0xFFFFFEE4),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  'jl. indah no.15, Sidoarjo',
                  style: TextStyle(
                    color: Color(0xFFFFFEE4),
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Kasir info
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Kasir: Dewi',
                  style: TextStyle(
                    color: Color(0xFFFFFEE4),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  '30/02/2026',
                  style: TextStyle(
                    color: Color(0xFFFFFEE4),
                    fontSize: 14,
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
  Widget _buildNavBar() {
    final navItems = ['Dashboard', 'Kasir', 'Riwayat', 'Stok'];
    final navRoutes = ['/dashboard', '/kasir', '/riwayat', '/stok'];
    const selectedIndex = 0; // Dashboard is active

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFBDB76B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(navItems.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                if (!isSelected) {
                  Navigator.pushReplacementNamed(context, navRoutes[index]);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFFEE4).withOpacity(0.25) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  navItems[index],
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFFFFEE4) : Colors.black87,
                    fontSize: 16,
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
  Widget _buildSearchBar() {
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
              style: const TextStyle(fontSize: 16, fontFamily: 'Inter'),
              decoration: const InputDecoration(
                hintText: 'cari produk',
                hintStyle: TextStyle(color: Color(0xFF696969), fontSize: 16),
                prefixIcon: Icon(Icons.search, color: Color(0xFF696969)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFCE8947),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'cari',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
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
  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Filter icon button
          InkWell(
            onTap: () => setState(() => _selectedCategory = 'Semua'),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedCategory == 'Semua'
                    ? const Color(0xFFCE8947)
                    : const Color(0xFFCE8947).withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/icons/Conversion.png',
                width: 24,
                height: 24,
                color: const Color(0xFFFFFEE4),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Category pills
          ..._categories.map((cat) {
            final isSelected = _selectedCategory == cat['name'];
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: () => setState(() => _selectedCategory = cat['name']),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        style: const TextStyle(
                          color: Color(0xFFFFFEE4),
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        cat['icon'],
                        width: 20,
                        height: 20,
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
  Widget _buildProductGrid() {
    final products = _filteredProducts;

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
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
          const SizedBox(height: 10),
          // Product image
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Image.asset(
                product['image'],
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Product name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              product['name'],
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          // Price
          Text(
            _formatPrice(product['price']),
            style: const TextStyle(
              color: Color(0xFF1D1B1B),
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          // Stock
          Text(
            'Stok: ${product['stock']}',
            style: const TextStyle(
              color: Color(0xFF1D1B1B),
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          // Add button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD8B84B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 0,
                ),
                child: const Text(
                  'Tambah',
                  style: TextStyle(fontSize: 12, fontFamily: 'Inter'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}