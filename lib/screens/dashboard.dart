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
    // Makanan
    {'name': 'Indomie Soto', 'price': 3500, 'stock': 50, 'image': 'assets/images/indsoto.png', 'category': 'Makanan', 'sku': 'IDM-001', 'rak': 'A-12', 'area': 'Makanan Instan (Lorong 1)', 'masuk': '20/01/2024', 'kadaluarsa': '20/01/2025'},
    {'name': 'Indomie Goreng', 'price': 3500, 'stock': 45, 'image': 'assets/images/indogoreng.png', 'category': 'Makanan', 'sku': 'IDM-002', 'rak': 'A-12', 'area': 'Makanan Instan (Lorong 1)', 'masuk': '21/01/2024', 'kadaluarsa': '21/01/2025'},
    {'name': 'Kanzler Singles', 'price': 9000, 'stock': 20, 'image': 'assets/images/sosisknzlr.png', 'category': 'Makanan', 'sku': 'KNZ-001', 'rak': 'B-05', 'area': 'Frozen Food (Lorong 2)', 'masuk': '15/02/2024', 'kadaluarsa': '15/05/2024'},
    {'name': 'Mie Sedap Cup', 'price': 5000, 'stock': 25, 'image': 'assets/images/sedapcup.png', 'category': 'Makanan', 'sku': 'MSD-001', 'rak': 'A-13', 'area': 'Makanan Instan (Lorong 1)', 'masuk': '10/01/2024', 'kadaluarsa': '10/01/2025'},
    {'name': 'Pop Mie Ayam', 'price': 5500, 'stock': 30, 'image': 'assets/images/popmie.png', 'category': 'Makanan', 'sku': 'POP-001', 'rak': 'A-13', 'area': 'Makanan Instan (Lorong 1)', 'masuk': '12/01/2024', 'kadaluarsa': '12/01/2025'},
    {'name': 'Sosis So Nice', 'price': 1000, 'stock': 100, 'image': 'assets/images/sonicesosis.png', 'category': 'Makanan', 'sku': 'SON-001', 'rak': 'B-06', 'area': 'Snack Basah (Lorong 2)', 'masuk': '01/02/2024', 'kadaluarsa': '01/08/2024'},
    
    // Minuman
    {'name': 'UHT Frisian Flag', 'price': 5500, 'stock': 40, 'image': 'assets/images/uhtfrisian.png', 'category': 'Minuman', 'sku': 'UHT-001', 'rak': 'C-01', 'area': 'Minuman Susu (Lorong 3)', 'masuk': '05/02/2024', 'kadaluarsa': '05/08/2024'},
    {'name': 'UHT Cimory', 'price': 6000, 'stock': 35, 'image': 'assets/images/uhtcimory.png', 'category': 'Minuman', 'sku': 'UHT-002', 'rak': 'C-01', 'area': 'Minuman Susu (Lorong 3)', 'masuk': '06/02/2024', 'kadaluarsa': '06/08/2024'},
    {'name': 'Cimory Yoghurt', 'price': 9500, 'stock': 15, 'image': 'assets/images/cimoryyoghurt.png', 'category': 'Minuman', 'sku': 'YOG-001', 'rak': 'C-02', 'area': 'Minuman Dingin (Chiller)', 'masuk': '10/02/2024', 'kadaluarsa': '10/04/2024'},
    {'name': 'Aqua 600ml', 'price': 3500, 'stock': 100, 'image': 'assets/images/aqua600.png', 'category': 'Minuman', 'sku': 'AQ-001', 'rak': 'C-03', 'area': 'Air Mineral (Lorong 3)', 'masuk': '01/01/2024', 'kadaluarsa': '01/01/2026'},
    {'name': 'Teh Pucuk Harum', 'price': 4000, 'stock': 60, 'image': 'assets/images/pucukharum.png', 'category': 'Minuman', 'sku': 'TPH-001', 'rak': 'C-04', 'area': 'Teh Kemasan (Lorong 3)', 'masuk': '15/01/2024', 'kadaluarsa': '15/01/2025'},
    {'name': 'Coca Cola 250ml', 'price': 5000, 'stock': 24, 'image': 'assets/images/cocacola.png', 'category': 'Minuman', 'sku': 'CC-001', 'rak': 'C-05', 'area': 'Minuman Soda (Lorong 3)', 'masuk': '20/01/2024', 'kadaluarsa': '20/01/2025'},
    {'name': 'Pocari Sweat', 'price': 7000, 'stock': 30, 'image': 'assets/images/pocari.png', 'category': 'Minuman', 'sku': 'PS-001', 'rak': 'C-05', 'area': 'Minuman Isotonik (Lorong 3)', 'masuk': '25/01/2024', 'kadaluarsa': '25/01/2026'},
    
    // Snack
    {'name': 'Sari Roti Sandwich', 'price': 5000, 'stock': 20, 'image': 'assets/images/sarirotisand.png', 'category': 'Snack', 'sku': 'ROT-001', 'rak': 'D-01', 'area': 'Roti & Bakery (Lorong 4)', 'masuk': '28/02/2024', 'kadaluarsa': '05/03/2024'},
    {'name': 'Chitato Sapi Panggang', 'price': 12000, 'stock': 15, 'image': 'assets/images/chitatosapi.png', 'category': 'Snack', 'sku': 'CHT-001', 'rak': 'D-02', 'area': 'Makanan Ringan (Lorong 4)', 'masuk': '10/02/2024', 'kadaluarsa': '10/02/2025'},
    {'name': 'Qtela Singkong', 'price': 8000, 'stock': 25, 'image': 'assets/images/qtela.png', 'category': 'Snack', 'sku': 'QTL-001', 'rak': 'D-02', 'area': 'Makanan Ringan (Lorong 4)', 'masuk': '12/02/2024', 'kadaluarsa': '12/02/2025'},
    {'name': 'Oreo Vanilla', 'price': 9000, 'stock': 30, 'image': 'assets/images/oreovnl.png', 'category': 'Snack', 'sku': 'ORO-001', 'rak': 'D-03', 'area': 'Biskuit (Lorong 4)', 'masuk': '05/01/2024', 'kadaluarsa': '05/01/2025'},
    {'name': 'Silverqueen 62g', 'price': 15000, 'stock': 10, 'image': 'assets/images/silverqueen.png', 'category': 'Snack', 'sku': 'SQ-001', 'rak': 'D-04', 'area': 'Cokelat (Lorong 4)', 'masuk': '01/02/2024', 'kadaluarsa': '01/02/2025'},
    {'name': 'Beng-Beng', 'price': 2500, 'stock': 50, 'image': 'assets/images/bengbeng.png', 'category': 'Snack', 'sku': 'BB-001', 'rak': 'D-04', 'area': 'Cokelat (Lorong 4)', 'masuk': '02/02/2024', 'kadaluarsa': '02/02/2025'},
    
    // Obat
    {'name': 'Panadol Extra', 'price': 12000, 'stock': 20, 'image': 'assets/images/panadolextra.png', 'category': 'Obat', 'sku': 'OBT-001', 'rak': 'E-01', 'area': 'Farmasi (Lorong 5)', 'masuk': '01/01/2024', 'kadaluarsa': '01/01/2027'},
    {'name': 'Paramex', 'price': 3000, 'stock': 40, 'image': 'assets/images/paramex.png', 'category': 'Obat', 'sku': 'OBT-002', 'rak': 'E-01', 'area': 'Farmasi (Lorong 5)', 'masuk': '02/01/2024', 'kadaluarsa': '02/01/2027'},
    {'name': 'Tolak Angin Cair', 'price': 4500, 'stock': 100, 'image': 'assets/images/tolakangin.png', 'category': 'Obat', 'sku': 'OBT-003', 'rak': 'E-01', 'area': 'Farmasi (Lorong 5)', 'masuk': '10/01/2024', 'kadaluarsa': '10/01/2026'},
    {'name': 'Betadine 5ml', 'price': 18000, 'stock': 10, 'image': 'assets/images/btdn.png', 'category': 'Obat', 'sku': 'OBT-004', 'rak': 'E-02', 'area': 'Farmasi (Lorong 5)', 'masuk': '15/01/2024', 'kadaluarsa': '15/01/2028'},
    
    // Sembako
    {'name': 'Beras Maknyuss 5kg', 'price': 78000, 'stock': 10, 'image': 'assets/images/berasmkys.png', 'category': 'Sembako', 'sku': 'SMB-001', 'rak': 'F-01', 'area': 'Kebutuhan Pokok (Lorong 6)', 'masuk': '20/02/2024', 'kadaluarsa': '20/02/2025'},
    {'name': 'Gulaku 1kg', 'price': 18000, 'stock': 20, 'image': 'assets/images/gulaku.png', 'category': 'Sembako', 'sku': 'SMB-002', 'rak': 'F-02', 'area': 'Kebutuhan Pokok (Lorong 6)', 'masuk': '21/02/2024', 'kadaluarsa': '21/02/2026'},
    {'name': 'Tepung Segitiga Biru', 'price': 12000, 'stock': 15, 'image': 'assets/images/tepungsb.png', 'category': 'Sembako', 'sku': 'SMB-003', 'rak': 'F-02', 'area': 'Kebutuhan Pokok (Lorong 6)', 'masuk': '22/02/2024', 'kadaluarsa': '22/02/2025'},
    {'name': 'Minyak Goreng 2L', 'price': 35000, 'stock': 12, 'image': 'assets/images/minyak.png', 'category': 'Sembako', 'sku': 'SMB-004', 'rak': 'F-03', 'area': 'Kebutuhan Pokok (Lorong 6)', 'masuk': '23/02/2024', 'kadaluarsa': '23/02/2025'},
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
                  Text('POS TOSERBA', style: TextStyle(color: const Color(0xFFFFFEE4), fontSize: r.font(22), fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                  Text('jl. indah no.15, Sidoarjo', style: TextStyle(color: const Color(0xFFFFFEE4), fontSize: r.font(14), fontFamily: 'Inter'), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Kasir: Dewi', style: TextStyle(color: const Color(0xFFFFFEE4), fontSize: r.font(18), fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                Text('30/02/2026', style: TextStyle(color: const Color(0xFFFFFEE4), fontSize: r.font(14), fontFamily: 'Inter')),
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
      decoration: BoxDecoration(color: const Color(0xFFBDB76B), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: List.generate(navItems.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: r.space(4)),
            child: InkWell(
              onTap: () { if (!isSelected) Navigator.pushReplacementNamed(context, navRoutes[index]); },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: r.space(20), vertical: r.space(10)),
                decoration: BoxDecoration(color: isSelected ? const Color(0xFFFFFEE4).withOpacity(0.25) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                child: Text(navItems[index], style: TextStyle(color: isSelected ? const Color(0xFFFFFEE4) : Colors.black87, fontSize: r.font(16), fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, fontFamily: 'Inter')),
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
            decoration: BoxDecoration(color: const Color(0xFFFFFEE4), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFD9D9D9), width: 2)),
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
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: r.space(22), vertical: r.space(12)),
            decoration: BoxDecoration(color: const Color(0xFFCE8947), borderRadius: BorderRadius.circular(10)),
            child: Text('cari', style: TextStyle(color: Colors.white, fontSize: r.font(16), fontWeight: FontWeight.w500, fontFamily: 'Inter')),
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
            child: Container(
              padding: EdgeInsets.all(r.space(10)),
              decoration: BoxDecoration(color: _selectedCategory == 'Semua' ? const Color(0xFFCE8947) : const Color(0xFFCE8947).withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
              child: Image.asset('assets/icons/Conversion.png', width: r.icon(24), height: r.icon(24), color: const Color(0xFFFFFEE4)),
            ),
          ),
          SizedBox(width: r.space(10)),
          ..._categories.map((cat) {
            final isSelected = _selectedCategory == cat['name'];
            return Padding(
              padding: EdgeInsets.only(right: r.space(10)),
              child: InkWell(
                onTap: () => setState(() => _selectedCategory = cat['name']),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: r.space(16), vertical: r.space(10)),
                  decoration: BoxDecoration(color: isSelected ? const Color(0xFFCE8947) : const Color(0xFFCE8947).withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Text(cat['name'], style: TextStyle(color: const Color(0xFFFFFEE4), fontSize: r.font(14), fontFamily: 'Inter')),
                      SizedBox(width: r.space(8)),
                      Image.asset(cat['icon'], width: r.icon(20), height: r.icon(20), color: const Color(0xFFFFFEE4)),
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

  Widget _buildProductGrid(Responsive r) {
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
        border: Border.all(color: const Color(0xFFD8B84B).withOpacity(0.4), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFFD8B84B).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 3, child: Padding(padding: EdgeInsets.all(r.space(12)), child: Image.asset(product['image'], fit: BoxFit.contain))),
          Text(product['name'], style: TextStyle(color: Colors.black, fontSize: r.font(13), fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(_formatPrice(product['price']), style: TextStyle(color: const Color(0xFF1D1B1B), fontSize: r.font(12))),
          Text('Stok: ${product['stock']}', style: TextStyle(color: const Color(0xFF1D1B1B), fontSize: r.font(12))),
          SizedBox(height: r.space(8)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.space(12)),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/detail', arguments: product),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD8B84B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: Text('Lihat', style: TextStyle(fontSize: r.font(12), color: Colors.white)),
              ),
            ),
          ),
          SizedBox(height: r.space(10)),
        ],
      ),
    );
  }
}
