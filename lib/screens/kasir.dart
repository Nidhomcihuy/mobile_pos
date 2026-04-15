import 'package:flutter/material.dart';

class Kasir extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 1280,
          height: 800,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: const Color(0xFFFFFEE4)),
          child: Stack(
            children: [
              Positioned(
                left: 92,
                top: 19,
                child: Text(
                  'POS TOSERBA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                left: 92,
                top: 50,
                child: Text(
                  'jl. indah no.15, Sidoarjo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              Positioned(
                left: 1120,
                top: 16,
                child: Text(
                  'Kasir: Dewi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                left: 1118,
                top: 52,
                child: Text(
                  '30/02/2026',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 88,
                child: Container(
                  width: 1280,
                  height: 39,
                  decoration: BoxDecoration(color: const Color(0xFFFFFEE4)),
                ),
              ),
              Positioned(
                left: 0,
                top: 166,
                child: Container(
                  width: 1280,
                  height: 50,
                  decoration: BoxDecoration(color: const Color(0xFFD6D2A0)),
                ),
              ),
              Positioned(
                left: 26,
                top: 179,
                child: Text(
                  'Transaksi 1',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 1148,
                top: 175,
                child: Container(
                  width: 77,
                  height: 33,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD6D2A0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1157,
                top: 180,
                child: Text(
                  '2 item',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 26,
                top: 246,
                child: Text(
                  'Nama Produk',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                left: 540,
                top: 246,
                child: Text(
                  'Jumlah',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                left: 1049,
                top: 246,
                child: Text(
                  'Harga',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                left: 31,
                top: 307,
                child: Text(
                  'Indomie Soto',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 30,
                top: 368,
                child: Text(
                  'Indomie Goreng Pedas ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 575,
                top: 307,
                child: Text(
                  '2',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 575,
                top: 368,
                child: Text(
                  '5',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 1032,
                top: 307,
                child: Text(
                  'Rp 3.500',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 1032,
                top: 362,
                child: Text(
                  'Rp 3.900',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 13,
                top: 593,
                child: Container(
                  width: 943,
                  height: 176,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD6D2A1),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 36.76,
                top: 616,
                child: SizedBox(
                  width: 237.59,
                  child: Text(
                    'SUBTOTAL',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 36.76,
                top: 660,
                child: SizedBox(
                  width: 198.50,
                  child: Text(
                    'DISKON',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 36.76,
                top: 715,
                child: SizedBox(
                  width: 203.10,
                  child: Text(
                    'TOTAL',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 649.12,
                top: 616,
                child: SizedBox(
                  width: 255.21,
                  child: Text(
                    'Rp 26.500',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 672.88,
                top: 715,
                child: SizedBox(
                  width: 231.45,
                  child: Text(
                    'Rp 26.500',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 700.47,
                top: 660,
                child: SizedBox(
                  width: 203.86,
                  child: Text(
                    'Rp 0',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                top: 708,
                child: Container(
                  width: 941,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 970,
                top: 593,
                child: Container(
                  width: 142.88,
                  height: 90,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD8B84B),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xFF183152),
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 985,
                top: 618,
                child: SizedBox(
                  width: 112.98,
                  child: Text(
                    'TUNAI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 984,
                top: 714,
                child: Container(
                  width: 270.88,
                  height: 54.89,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 984,
                top: 714,
                child: Container(
                  width: 270.88,
                  height: 54.89,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD6D2A1),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1011.30,
                top: 722.08,
                child: SizedBox(
                  width: 214.19,
                  height: 23.79,
                  child: Text(
                    'BATALKAN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1124,
                top: 593,
                child: Container(
                  width: 142.88,
                  height: 90,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD6D2A1),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1138.40,
                top: 621,
                child: SizedBox(
                  width: 112.98,
                  child: Text(
                    'QRIS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 21,
                top: 104,
                child: Container(
                  width: 537,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFBDB76B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 48,
                top: 116,
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                  child: Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 207,
                top: 116,
                child: Text(
                  'Kasir',
                  style: TextStyle(
                    color: const Color(0xFFFFFEE4),
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 311,
                top: 116,
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/riwayat'),
                  child: Text(
                    'Riwayat ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 445,
                top: 116,
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/stok'),
                  child: Text(
                    'Stok',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}