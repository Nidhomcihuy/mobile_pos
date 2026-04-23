import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class Riwayat extends StatelessWidget {
  const Riwayat({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE3),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(r),
          _buildNavBar(context, r),
          // Title
          Padding(
            padding: EdgeInsets.only(left: r.space(24), top: r.space(16), bottom: r.space(16)),
            child: Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: r.font(22),
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
                color: const Color(0xFF555555),
              ),
            ),
          ),
          // Stats cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.space(24)),
            child: Row(
              children: [
                _buildStatCard('Total Transaksi', '55', 'hari ini', r),
                SizedBox(width: r.space(16)),
                _buildStatCard('Total Transaksi', '333', 'Minggu ini', r),
                SizedBox(width: r.space(16)),
                _buildStatCard('Total Transaksi', '1500', 'Bulan ini', r),
              ],
            ),
          ),
          // Transaction list (empty state)
          Expanded(
            child: Center(
              child: Text(
                'Belum ada transaksi hari ini',
                style: TextStyle(
                  fontSize: r.font(16),
                  color: Colors.grey[400],
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String period, Responsive r) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: r.space(20), horizontal: r.space(16)),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDE3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD6D2A0), width: 2),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: r.font(16),
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: r.space(8)),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: r.font(36),
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            SizedBox(height: r.space(4)),
            Text(
              period,
              style: TextStyle(
                fontSize: r.font(14),
                fontFamily: 'Inter',
                color: const Color(0xFF555555),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
                  Text('POS TOSERBA',
                      style: TextStyle(color: const Color(0xFFFFFEE4), fontSize: r.font(22), fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                  Text('jl. indah no.15, Sidoarjo',
                      style: TextStyle(color: const Color(0xFFFFFEE4), fontSize: r.font(14), fontFamily: 'Inter'),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Kasir: Dewi',
                    style: TextStyle(color: const Color(0xFFFFFEE4), fontSize: r.font(18), fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                Text('30/02/2026',
                    style: TextStyle(color: const Color(0xFFFFFEE4), fontSize: r.font(14), fontFamily: 'Inter')),
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
    const selectedIndex = 2;

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
}