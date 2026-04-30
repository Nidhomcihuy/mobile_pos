import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class Kasir extends StatefulWidget {
  const Kasir({super.key});

  @override
  State<Kasir> createState() => _KasirState();
}

class _KasirState extends State<Kasir> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  final Map<String, Map<String, dynamic>> _cart = {};

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Makanan', 'icon': 'assets/icons/Hamburger.png'},
    {'name': 'Minuman', 'icon': 'assets/icons/Soda.png'},
    {'name': 'Snack', 'icon': 'assets/icons/Doughnut.png'},
    {'name': 'Obat', 'icon': 'assets/icons/Pill.png'},
    {'name': 'Sembako', 'icon': 'assets/icons/Grains Of Rice.png'},
  ];

  final List<Map<String, dynamic>> _products = [
    // Makanan
    {'name': 'Indomie Soto', 'price': 3500, 'stock': 50, 'image': 'assets/images/indsoto.png', 'category': 'Makanan'},
    {'name': 'Indomie Goreng', 'price': 3500, 'stock': 45, 'image': 'assets/images/indogoreng.png', 'category': 'Makanan'},
    {'name': 'Kanzler Singles', 'price': 9000, 'stock': 20, 'image': 'assets/images/sosisknzlr.png', 'category': 'Makanan'},
    {'name': 'Mie Sedap Cup', 'price': 5000, 'stock': 25, 'image': 'assets/images/sedapcup.png', 'category': 'Makanan'},
    {'name': 'Pop Mie Ayam', 'price': 5500, 'stock': 30, 'image': 'assets/images/popmie.png', 'category': 'Makanan'},
    {'name': 'Sosis So Nice', 'price': 1000, 'stock': 100, 'image': 'assets/images/sonicesosis.png', 'category': 'Makanan'},
    
    // Minuman
    {'name': 'UHT Frisian Flag', 'price': 5500, 'stock': 40, 'image': 'assets/images/uhtfrisian.png', 'category': 'Minuman'},
    {'name': 'UHT Cimory', 'price': 6000, 'stock': 35, 'image': 'assets/images/uhtcimory.png', 'category': 'Minuman'},
    {'name': 'Cimory Yoghurt', 'price': 9500, 'stock': 15, 'image': 'assets/images/cimoryyoghurt.png', 'category': 'Minuman'},
    {'name': 'Aqua 600ml', 'price': 3500, 'stock': 100, 'image': 'assets/images/aqua600.png', 'category': 'Minuman'},
    {'name': 'Teh Pucuk Harum', 'price': 4000, 'stock': 60, 'image': 'assets/images/pucukharum.png', 'category': 'Minuman'},
    {'name': 'Coca Cola 250ml', 'price': 5000, 'stock': 24, 'image': 'assets/images/cocacola.png', 'category': 'Minuman'},
    {'name': 'Pocari Sweat', 'price': 7000, 'stock': 30, 'image': 'assets/images/pocari.png', 'category': 'Minuman'},
    
    // Snack
    {'name': 'Sari Roti Sandwich', 'price': 5000, 'stock': 20, 'image': 'assets/images/sarirotisand.png', 'category': 'Snack'},
    {'name': 'Chitato Sapi Panggang', 'price': 12000, 'stock': 15, 'image': 'assets/images/chitatosapi.png', 'category': 'Snack'},
    {'name': 'Qtela Singkong', 'price': 8000, 'stock': 25, 'image': 'assets/images/qtela.png', 'category': 'Snack'},
    {'name': 'Oreo Vanilla', 'price': 9000, 'stock': 30, 'image': 'assets/images/oreovnl.png', 'category': 'Snack'},
    {'name': 'Silverqueen 62g', 'price': 15000, 'stock': 10, 'image': 'assets/images/silverqueen.png', 'category': 'Snack'},
    {'name': 'Beng-Beng', 'price': 2500, 'stock': 50, 'image': 'assets/images/bengbeng.png', 'category': 'Snack'},
    
    // Obat
    {'name': 'Panadol Extra', 'price': 12000, 'stock': 20, 'image': 'assets/images/panadolextra.png', 'category': 'Obat'},
    {'name': 'Paramex', 'price': 3000, 'stock': 40, 'image': 'assets/images/paramex.png', 'category': 'Obat'},
    {'name': 'Tolak Angin Cair', 'price': 4500, 'stock': 100, 'image': 'assets/images/tolakangin.png', 'category': 'Obat'},
    {'name': 'Betadine 5ml', 'price': 18000, 'stock': 10, 'image': 'assets/images/btdn.png', 'category': 'Obat'},

    // Sembako
    {'name': 'Beras Maknyuss 5kg', 'price': 78000, 'stock': 10, 'image': 'assets/images/berasmkys.png', 'category': 'Sembako'},
    {'name': 'Gulaku 1kg', 'price': 18000, 'stock': 20, 'image': 'assets/images/gulaku.png', 'category': 'Sembako'},
    {'name': 'Tepung Segitiga Biru', 'price': 12000, 'stock': 15, 'image': 'assets/images/tepungsb.png', 'category': 'Sembako'},
    {'name': 'Minyak Goreng 2L', 'price': 35000, 'stock': 12, 'image': 'assets/images/minyak.png', 'category': 'Sembako'},
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

  int get _totalItems {
    return _cart.values.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE3),
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
                backgroundColor: const Color(0xFFCE8947),
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
  Widget _buildNavBar(BuildContext context, Responsive r) {
    final navItems = ['Dashboard', 'Kasir', 'Riwayat'];
    final navRoutes = ['/dashboard', '/kasir', '/riwayat'];
    const selectedIndex = 1;

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
          padding: EdgeInsets.only(bottom: r.space(80)), // Space for FAB
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
    final String productName = product['name'];
    final int quantity = _cart[productName]?['quantity'] ?? 0;

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
              productName,
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
            child: quantity == 0
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _cart[productName] = {
                            'name': product['name'],
                            'price': product['price'],
                            'quantity': 1,
                          };
                        });
                      },
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
                        'Tambah',
                        style: TextStyle(fontSize: r.font(12), fontFamily: 'Inter'),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8B84B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: r.space(2)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                          onPressed: () {
                            setState(() {
                              if (_cart[productName]!['quantity'] > 1) {
                                _cart[productName]!['quantity']--;
                              } else {
                                _cart.remove(productName);
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
                          icon: const Icon(Icons.add, color: Colors.white, size: 20),
                          onPressed: () {
                            setState(() {
                              if (_cart[productName]!['quantity'] < product['stock']) {
                                _cart[productName]!['quantity']++;
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
