import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../utils/api_service.dart';
import '../utils/app_config.dart';

class Stok extends StatefulWidget {
  const Stok({super.key});

  @override
  State<Stok> createState() => _StokState();
}

class _StokState extends State<Stok> {
  String _cariProduk = '';
  List<Map<String, dynamic>> _produkList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final data = await ApiService.fetchProducts();
      setState(() { _produkList = data; _isLoading = false; });
    } catch (e) {
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  String _formatHarga(int harga) {
    String s = harga.toString();
    String hasil = '';
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      hasil = s[i] + hasil;
      c++;
      if (c % 3 == 0 && i != 0) hasil = '.$hasil';
    }
    return 'Rp $hasil';
  }

  List<Map<String, dynamic>> get _produkFiltered {
    if (_cariProduk.isEmpty) return _produkList;
    return _produkList.where((p) => (p['name'] as String).toLowerCase().contains(_cariProduk.toLowerCase())).toList();
  }

  Color _warnaStok(int stok, int minStok) {
    if (stok == 0) return Colors.black87;
    if (stok <= minStok) return const Color(0xFFE53935);
    return Colors.green;
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
                  SizedBox(height: r.space(20)),
                  Expanded(child: _buildListProduk(r)),
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
        gradient: LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 28),
          ),
          SizedBox(width: r.space(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Manajemen Stok', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Inter')),
                Text(AppConfig.storeName, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, Responsive r) {
    final items = ['Dashboard', 'Kasir', 'Riwayat', 'Stok'];
    final routes = ['/dashboard', '/kasir', '/riwayat', '/stok'];
    const selected = 3;
    return Container(
      margin: EdgeInsets.fromLTRB(r.space(20), r.space(16), r.space(20), 0),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: List.generate(items.length, (i) {
          final aktif = i == selected;
          return Expanded(
            child: InkWell(
              onTap: () { if (!aktif) Navigator.pushReplacementNamed(context, routes[i]); },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: r.space(10)),
                decoration: BoxDecoration(color: aktif ? const Color(0xFFC62828) : Colors.transparent, borderRadius: BorderRadius.circular(15)),
                alignment: Alignment.center,
                child: Text(items[i], style: TextStyle(color: aktif ? Colors.white : Colors.grey[600], fontSize: r.font(14), fontWeight: aktif ? FontWeight.w800 : FontWeight.w600, fontFamily: 'Inter')),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar(Responsive r) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: TextField(
        onChanged: (val) => setState(() => _cariProduk = val),
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

  Widget _buildListProduk(Responsive r) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFC62828)));
    if (_errorMessage != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 48, color: Colors.grey), const SizedBox(height: 16), const Text('Gagal memuat data'), const SizedBox(height: 8), TextButton(onPressed: _loadProducts, child: const Text('Coba Lagi'))]));
    final filtered = _produkFiltered;
    if (filtered.isEmpty) return Center(child: Text('Produk tidak ditemukan', style: TextStyle(color: Colors.grey[500])));
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildItemProduk(filtered[index], r),
    );
  }

  Widget _buildItemProduk(Map<String, dynamic> produk, Responsive r) {
    final stok = produk['stock'] as int;
    final minStok = produk['min_stock'] as int? ?? 20;
    final warna = _warnaStok(stok, minStok);
    final imageUrl = produk['image_url'] as String?;
    final persen = (stok / (minStok * 3)).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(
            width: 60, height: 60, padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(16)),
            child: imageUrl != null && imageUrl.isNotEmpty ? Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_rounded, color: Color(0xFFC62828))) : const Icon(Icons.inventory_2_rounded, color: Color(0xFFC62828)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(produk['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                Text(produk['category'] ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Text(_formatHarga(produk['price'] as int), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFC62828))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 80, height: 6,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: persen, child: Container(decoration: BoxDecoration(color: warna, borderRadius: BorderRadius.circular(10)))),
              ),
              const SizedBox(height: 6),
              Text('$stok Pcs', style: TextStyle(fontSize: 14, color: warna, fontWeight: FontWeight.w900, fontFamily: 'Inter')),
              if (stok <= minStok && stok > 0) Text('Limit Stok', style: TextStyle(fontSize: 9, color: Colors.red[700], fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}
