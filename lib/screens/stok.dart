import 'package:flutter/material.dart';

class Stok extends StatelessWidget {
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
                left: 447,
                top: 117,
                child: Text(
                  'Stok',
                  style: TextStyle(
                    color: const Color(0xFFFFFEE4),
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 34,
                top: 209,
                child: Container(
                  width: 1222,
                  height: 82,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFFEE4),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0x7FD8B84B),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 218,
                child: Text(
                  'Indomie all variant',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 239,
                child: Text(
                  'makanan',
                  style: TextStyle(
                    color: const Color(0xFF696969),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 256,
                child: Text(
                  'Rp. 3.500',
                  style: TextStyle(
                    color: const Color(0xFF696969),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 1146,
                top: 230,
                child: Container(
                  width: 90,
                  height: 37,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE2E2E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1160,
                top: 245,
                child: Container(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                  width: 9,
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
                left: 1156,
                top: 250,
                child: Container(
                  width: 9,
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
                left: 1179,
                top: 240,
                child: Text(
                  'Stok',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 1022,
                top: 243,
                child: Container(
                  width: 117,
                  height: 12,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE8E8E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1022,
                top: 243,
                child: Container(
                  width: 100,
                  height: 12,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF0ABE10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1081,
                top: 258,
                child: Text(
                  '402 pcs',
                  style: TextStyle(
                    color: const Color(0xFF0ABE10),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 34,
                top: 302,
                child: Container(
                  width: 1222,
                  height: 82,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFFEE4),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0x7FD8B84B),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 311,
                child: Text(
                  'Aqua',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 332,
                child: Text(
                  'minuman',
                  style: TextStyle(
                    color: const Color(0xFF696969),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 349,
                child: Text(
                  'Rp. 3.500',
                  style: TextStyle(
                    color: const Color(0xFF696969),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 1146,
                top: 323,
                child: Container(
                  width: 90,
                  height: 37,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE2E2E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1160,
                top: 338,
                child: Container(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                  width: 9,
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
                left: 1156,
                top: 343,
                child: Container(
                  width: 9,
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
                left: 1179,
                top: 333,
                child: Text(
                  'Stok',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 1022,
                top: 336,
                child: Container(
                  width: 117,
                  height: 12,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE8E8E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1022,
                top: 336,
                child: Container(
                  width: 30,
                  height: 12,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF0ABE10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1086,
                top: 351,
                child: Text(
                  '32 pcs',
                  style: TextStyle(
                    color: const Color(0xFF0ABE10),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 34,
                top: 395,
                child: Container(
                  width: 1222,
                  height: 82,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFFEE4),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0x7FD8B84B),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 404,
                child: Text(
                  'paramex',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 425,
                child: Text(
                  'obat',
                  style: TextStyle(
                    color: const Color(0xFF696969),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 442,
                child: Text(
                  'Rp. 3.500',
                  style: TextStyle(
                    color: const Color(0xFF696969),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 1146,
                top: 416,
                child: Container(
                  width: 90,
                  height: 37,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE2E2E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1160,
                top: 431,
                child: Container(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                  width: 9,
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
                left: 1156,
                top: 436,
                child: Container(
                  width: 9,
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
                left: 1179,
                top: 426,
                child: Text(
                  'Stok',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 1022,
                top: 429,
                child: Container(
                  width: 117,
                  height: 12,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE8E8E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1022,
                top: 429,
                child: Container(
                  width: 10,
                  height: 12,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFBE3A0A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1086,
                top: 444,
                child: Text(
                  '5 pcs',
                  style: TextStyle(
                    color: const Color(0xFFBE3A0A),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 34,
                top: 488,
                child: Container(
                  width: 1222,
                  height: 82,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFFEE4),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0x7FD8B84B),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 497,
                child: Text(
                  'so nice',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 518,
                child: Text(
                  'snack',
                  style: TextStyle(
                    color: const Color(0xFF696969),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 535,
                child: Text(
                  'Rp. 3.500',
                  style: TextStyle(
                    color: const Color(0xFF696969),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 1146,
                top: 509,
                child: Container(
                  width: 90,
                  height: 37,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE2E2E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1160,
                top: 524,
                child: Container(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                  width: 9,
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
                left: 1156,
                top: 529,
                child: Container(
                  width: 9,
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
                left: 1179,
                top: 519,
                child: Text(
                  'Stok',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 1022,
                top: 522,
                child: Container(
                  width: 117,
                  height: 12,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE8E8E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1022,
                top: 522,
                child: Container(
                  width: 57,
                  height: 12,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF0ABE10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1086,
                top: 537,
                child: Text(
                  '42 pcs',
                  style: TextStyle(
                    color: const Color(0xFF0ABE10),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 34,
                top: 581,
                child: Container(
                  width: 1222,
                  height: 82,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFFEE4),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0x7FD8B84B),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 590,
                child: Text(
                  'beras',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 611,
                child: Text(
                  'sembako',
                  style: TextStyle(
                    color: const Color(0xFF696969),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 628,
                child: Text(
                  'Rp. 3.500',
                  style: TextStyle(
                    color: const Color(0xFF696969),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 1146,
                top: 602,
                child: Container(
                  width: 90,
                  height: 37,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE2E2E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1160,
                top: 617,
                child: Container(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                  width: 9,
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
                left: 1156,
                top: 622,
                child: Container(
                  width: 9,
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
                left: 1179,
                top: 612,
                child: Text(
                  'Stok',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 1022,
                top: 615,
                child: Container(
                  width: 117,
                  height: 12,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE8E8E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1022,
                top: 615,
                child: Container(
                  width: 41,
                  height: 12,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF0ABE10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1086,
                top: 630,
                child: Text(
                  '42 pcs',
                  style: TextStyle(
                    color: const Color(0xFF0ABE10),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 34,
                top: 680,
                child: Container(
                  width: 1222,
                  height: 82,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFFEE4),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0x7FD8B84B),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 689,
                child: Text(
                  'pocari sweet',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 710,
                child: Text(
                  'minuman',
                  style: TextStyle(
                    color: const Color(0xFF696969),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 125,
                top: 727,
                child: Text(
                  'Rp. 3.500',
                  style: TextStyle(
                    color: const Color(0xFF696969),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 1146,
                top: 701,
                child: Container(
                  width: 90,
                  height: 37,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE2E2E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1160,
                top: 716,
                child: Container(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                  width: 9,
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
                left: 1156,
                top: 721,
                child: Container(
                  width: 9,
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
                left: 1179,
                top: 711,
                child: Text(
                  'Stok',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 1022,
                top: 714,
                child: Container(
                  width: 117,
                  height: 12,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE8E8E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1022,
                top: 714,
                child: Container(
                  width: 41,
                  height: 12,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF0ABE10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1086,
                top: 729,
                child: Text(
                  '42 pcs',
                  style: TextStyle(
                    color: const Color(0xFF0ABE10),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
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