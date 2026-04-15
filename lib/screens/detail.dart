import 'package:flutter/material.dart';


class Detail extends StatelessWidget {
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
                left: 44,
                top: 140,
                child: Container(
                  width: 1196,
                  height: 607,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFBDB76B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1033,
                top: 159,
                child: Container(
                  width: 174,
                  height: 44,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD6D2A0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xFF919191),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1097,
                top: 168,
                child: SizedBox(
                  width: 93,
                  height: 26,
                  child: Text(
                    'Kembali',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 85,
                top: 166,
                child: Text(
                  'Detail Produk',
                  style: TextStyle(
                    color: const Color(0xFFFFFEE4),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                left: 44,
                top: 217,
                child: Container(
                  width: 1196,
                  height: 530,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xFF818080),
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 463,
                top: 259,
                child: Container(
                  width: 224,
                  height: 110,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFDF5D8),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0x7FD8B84B),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 482,
                top: 306,
                child: Text(
                  'Rp. 3.500',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF1D1B1B),
                    fontSize: 32,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 463,
                top: 276,
                child: SizedBox(
                  width: 93,
                  height: 24,
                  child: Text(
                    'Harga',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF898989),
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 991,
                top: 259,
                child: Container(
                  width: 224,
                  height: 110,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFDF5D8),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0x7FD8B84B),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 727,
                top: 259,
                child: Container(
                  width: 224,
                  height: 110,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFDF5D8),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0x7FD8B84B),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 44,
                top: 217,
                child: Container(
                  width: 378.97,
                  height: 530,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFDF5D8),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0x7FD8B84B),
                      ),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25)),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 109,
                top: 276,
                child: Container(
                  width: 248.61,
                  height: 248.61,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/249x249"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 108,
                top: 525,
                child: SizedBox(
                  width: 250,
                  height: 41,
                  child: Text(
                    'Indomie goreng',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 134,
                top: 566,
                child: SizedBox(
                  width: 198,
                  height: 29,
                  child: Text(
                    'SKU: IDM-001',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF898989),
                      fontSize: 28,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1090.55,
                top: 203.02,
                child: Container(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(3.13),
                  width: 41.02,
                  height: 41.02,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/41x41"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 727,
                top: 276,
                child: SizedBox(
                  width: 147,
                  height: 24,
                  child: Text(
                    'Stok Tersisa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF898989),
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 748,
                top: 306,
                child: Text(
                  '50 pcs',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF1D1B1B),
                    fontSize: 32,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 989,
                top: 276,
                child: SizedBox(
                  width: 120,
                  height: 24,
                  child: Text(
                    'Kategori',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF898989),
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1012,
                top: 306,
                child: Text(
                  'Mie Instan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF1D1B1B),
                    fontSize: 32,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 463,
                top: 414,
                child: Container(
                  width: 752,
                  height: 141,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFDF5D8),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0x7FD8B84B),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 482,
                top: 444,
                child: SizedBox(
                  width: 205,
                  height: 24,
                  child: Text(
                    'Tambah Ke Transaksi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF898989),
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 490,
                top: 482,
                child: Container(
                  width: 58,
                  height: 51,
                  decoration: ShapeDecoration(
                    color: const Color(0xADA1862D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ),
              Positioned(
                left: 561,
                top: 482,
                child: Container(
                  width: 69,
                  height: 50,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xFF939393),
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 643,
                top: 482,
                child: Container(
                  width: 58,
                  height: 51,
                  decoration: ShapeDecoration(
                    color: const Color(0xADA1862D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ),
              Positioned(
                left: 660,
                top: 494,
                child: Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/27x27"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 897,
                top: 486,
                child: SizedBox(
                  width: 115,
                  height: 24,
                  child: Text(
                    'Subtotal: ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF898989),
                      fontSize: 24,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1012,
                top: 480,
                child: Text(
                  'Rp. 3.500',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF1D1B1B),
                    fontSize: 28,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 463,
                top: 592,
                child: Container(
                  width: 238,
                  height: 43,
                  decoration: ShapeDecoration(
                    color: const Color(0xADA1862D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ),
              Positioned(
                left: 482,
                top: 600,
                child: Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/27x27"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 509,
                top: 603,
                child: SizedBox(
                  width: 178,
                  height: 24,
                  child: Text(
                    'Tambah Ke Kasir',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1060,
                top: 592,
                child: Container(
                  width: 155,
                  height: 43,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD6D2A0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ),
              Positioned(
                left: 1104,
                top: 603,
                child: SizedBox(
                  width: 75,
                  height: 24,
                  child: Text(
                    'Batal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
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