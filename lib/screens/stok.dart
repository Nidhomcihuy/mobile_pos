import 'package:flutter/material.dart';
import '../utils/api_service.dart';

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await ApiService.fetchProducts();
      setState(() {
        _produkList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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
    return 'Rp. $hasil';
  }

  List<Map<String, dynamic>> get _produkFiltered {
    if (_cariProduk.isEmpty) return _produkList;
    return _produkList
        .where(
          (p) => (p['name'] as String).toLowerCase().contains(
            _cariProduk.toLowerCase(),
          ),
        )
        .toList();
  }

  Color _warnaStok(int stok, int minStok) {
    if (stok == 0) return const Color(0xFFBE3A0A);
    if (stok <= minStok) return const Color(0xFFD8B84B);
    return const Color(0xFF0ABE10);
  }

  void _editStok(Map<String, dynamic> produk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stok ${produk['name']} dikelola melalui menu Inbound di web admin.'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE3),
      body: Column(
        children: [
          _buildHeader(),
          _buildNavBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // search bar
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  // list produk
                  Expanded(child: _buildListProduk()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ──
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.store, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POS TOSERBA',
                  style: TextStyle(
                    color: Color(0xFFFFFEE4),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'jl. indah no.15, Sidoarjo',
                  style: TextStyle(color: Color(0xFFFFFEE4), fontSize: 14),
                ),
              ],
            ),
            const Spacer(),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Kasir: Dewi',
                  style: TextStyle(
                    color: Color(0xFFFFFEE4),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '22/04/2026',
                  style: TextStyle(color: Color(0xFFFFFEE4), fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── NAV BAR ──
  Widget _buildNavBar() {
    final items = ['Dashboard', 'Kasir', 'Riwayat', 'Stok'];
    final routes = ['/dashboard', '/kasir', '/riwayat', '/stok'];
    const selected = 3; // Stok aktif

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFBDB76B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final aktif = i == selected;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                if (!aktif) {
                  Navigator.pushReplacementNamed(context, routes[i]);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: aktif
                      ? const Color(0xFFFFFEE4).withValues(alpha: 0.25)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  items[i],
                  style: TextStyle(
                    color: aktif ? const Color(0xFFFFFEE4) : Colors.black87,
                    fontSize: 16,
                    fontWeight: aktif ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── SEARCH BAR ──
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEE4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 2),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _cariProduk = val),
        style: const TextStyle(fontSize: 16),
        decoration: const InputDecoration(
          hintText: 'Cari produk...',
          hintStyle: TextStyle(color: Color(0xFF696969)),
          prefixIcon: Icon(Icons.search, color: Color(0xFF696969)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildListProduk() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFBDB76B)),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Gagal memuat data stok', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBDB76B)),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final filtered = _produkFiltered;

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'Produk tidak ditemukan',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildItemProduk(filtered[index]),
    );
  }

  Widget _buildItemProduk(Map<String, dynamic> produk) {
    final stok = produk['stock'] as int;
    final minStok = produk['min_stock'] as int? ?? 20;
    final persen = (stok / (minStok * 5)).clamp(0.0, 1.0);
    final warna = _warnaStok(stok, minStok);
    final imageUrl = produk['image_url'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEE4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD8B84B).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.inventory_2, color: Color(0xFFBDB76B)),
                  )
                : const Icon(Icons.inventory_2, color: Color(0xFFBDB76B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produk['name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  produk['category'] ?? '-',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF696969)),
                ),
                Text(
                  _formatHarga(produk['price'] as int),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF696969)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: LinearProgressIndicator(
                    value: persen,
                    backgroundColor: const Color(0xFFE8E8E8),
                    valueColor: AlwaysStoppedAnimation<Color>(warna),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$stok pcs',
                style: TextStyle(
                  fontSize: 13,
                  color: warna,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => _editStok(produk),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 14),
                  SizedBox(width: 4),
                  Text('Info', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
