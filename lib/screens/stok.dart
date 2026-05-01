import 'package:flutter/material.dart';

class Stok extends StatefulWidget {
  const Stok({super.key});

  @override
  State<Stok> createState() => _StokState();
}

class _StokState extends State<Stok> {
  String _cariProduk = '';

  // data stok produk — nanti bisa diganti dari database
  final List<Map<String, dynamic>> _produkList = [
    {
      'nama': 'Indomie all variant',
      'kategori': 'Makanan',
      'harga': 3500,
      'stok': 402,
      'maxStok': 500,
      'icon': 'assets/icons/Hamburger.png',
    },
    {
      'nama': 'Aqua',
      'kategori': 'Minuman',
      'harga': 3500,
      'stok': 32,
      'maxStok': 200,
      'icon': 'assets/icons/Soda.png',
    },
    {
      'nama': 'Paramex',
      'kategori': 'Obat',
      'harga': 3500,
      'stok': 5,
      'maxStok': 100,
      'icon': 'assets/icons/Pill.png',
    },
    {
      'nama': 'So Nice',
      'kategori': 'Snack',
      'harga': 3500,
      'stok': 42,
      'maxStok': 100,
      'icon': 'assets/icons/Doughnut.png',
    },
    {
      'nama': 'Beras Maknyuss',
      'kategori': 'Sembako',
      'harga': 78000,
      'stok': 42,
      'maxStok': 100,
      'icon': 'assets/icons/Grains Of Rice.png',
    },
    {
      'nama': 'Pocari Sweat',
      'kategori': 'Minuman',
      'harga': 7500,
      'stok': 67,
      'maxStok': 150,
      'icon': 'assets/icons/Soda.png',
    },
    {
      'nama': 'Gulaku',
      'kategori': 'Sembako',
      'harga': 18000,
      'stok': 15,
      'maxStok': 80,
      'icon': 'assets/icons/Grains Of Rice.png',
    },
  ];

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
          (p) => (p['nama'] as String).toLowerCase().contains(
            _cariProduk.toLowerCase(),
          ),
        )
        .toList();
  }

  // warna progress bar berdasarkan level stok
  Color _warnaStok(int stok, int maxStok) {
    double persen = stok / maxStok;
    if (persen > 0.4) return const Color(0xFF0ABE10); // hijau
    if (persen > 0.15) return const Color(0xFFD8B84B); // kuning
    return const Color(0xFFBE3A0A); // merah
  }

  void _editStok(int index) {
    final produk = _produkList[index];
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Stok - ${produk['nama']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stok sekarang: ${produk['stok']} pcs',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah stok baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD8B84B),
            ),
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val >= 0) {
                setState(() => _produkList[index]['stok'] = val);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Stok ${produk['nama']} diperbarui jadi $val pcs',
                    ),
                  ),
                );
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
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

  // ── LIST PRODUK ──
  Widget _buildListProduk() {
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
      itemBuilder: (context, index) {
        // cari index asli di _produkList buat edit
        final produk = filtered[index];
        final indexAsli = _produkList.indexOf(produk);
        return _buildItemProduk(produk, indexAsli);
      },
    );
  }

  Widget _buildItemProduk(Map<String, dynamic> produk, int indexAsli) {
    final stok = produk['stok'] as int;
    final maxStok = produk['maxStok'] as int;
    final persen = (stok / maxStok).clamp(0.0, 1.0);
    final warna = _warnaStok(stok, maxStok);

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
          // gambar produk
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(produk['icon'], fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          // info produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produk['nama'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  produk['kategori'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF696969),
                  ),
                ),
                Text(
                  _formatHarga(produk['harga']),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF696969),
                  ),
                ),
              ],
            ),
          ),
          // progress bar stok
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // progress bar
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
          // tombol edit stok
          InkWell(
            onTap: () => _editStok(indexAsli),
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
                  Icon(Icons.edit, size: 14),
                  SizedBox(width: 4),
                  Text('Stok', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
