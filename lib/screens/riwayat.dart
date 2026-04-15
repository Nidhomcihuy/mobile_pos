import 'package:flutter/material.dart';

class Riwayat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 1280,
          height: 800,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: const Color(0xFFFFFDE3)),
          child: Stack(
            children: [
              Positioned(
                left: 86,
                top: 19,
                child: Text(
                  'POS TOSERBA',
                  style: TextStyle(
                    color: const Color(0xFFFFFEE4),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                left: 86,
                top: 47,
                child: Text(
                  'jl. indah no.15, Sidoarjo',
                  style: TextStyle(
                    color: const Color(0xFFFFFEE4),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              Positioned(
                left: 1109,
                top: 17,
                child: Text(
                  'Kasir: Dewi',
                  style: TextStyle(
                    color: const Color(0xFFFFFEE4),
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                left: 1128,
                top: 42,
                child: Text(
                  '30/02/2026',
                  style: TextStyle(
                    color: const Color(0xFFFFFEE4),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 23,
                top: 105,
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
                left: 50,
                top: 117,
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
                left: 209,
                top: 117,
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/kasir'),
                  child: Text(
                    'Kasir',
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
                left: 313,
                top: 117,
                child: Text(
                  'Riwayat ',
                  style: TextStyle(
                    color: const Color(0xFFFFFEE4),
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 447,
                top: 117,
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
              Positioned(
                left: 35,
                top: 174,
                child: Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                    color: const Color(0xFF676565),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 39,
                top: 242,
                child: Container(
                  width: 377,
                  height: 126,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFFEE4),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xFFD8B84B),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 154,
                top: 255,
                child: Text(
                  'Total Transaksi',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 201,
                top: 289,
                child: SizedBox(
                  width: 52,
                  height: 32,
                  child: Text(
                    '55',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 190,
                top: 331,
                child: Text(
                  'hari ini',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              Positioned(
                left: 501,
                top: 558,
                child: Text(
                  'Belum ada transaksi hari ini',
                  style: TextStyle(
                    color: const Color(0xFFBCB8B8),
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 451,
                top: 242,
                child: Container(
                  width: 377,
                  height: 126,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFFEE4),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xFFD8B84B),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 566,
                top: 255,
                child: Text(
                  'Total Transaksi',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 605,
                top: 289,
                child: SizedBox(
                  width: 70,
                  height: 30,
                  child: Text(
                    '333',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 592,
                top: 331,
                child: Text(
                  'Minggu ini',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              Positioned(
                left: 863,
                top: 242,
                child: Container(
                  width: 377,
                  height: 126,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFFEE4),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xFFD8B84B),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 978,
                top: 255,
                child: Text(
                  'Total Transaksi',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 1015,
                top: 289,
                child: SizedBox(
                  width: 99,
                  height: 30,
                  child: Text(
                    '1500',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1015,
                top: 331,
                child: Text(
                  'Bulan ini',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w300,
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