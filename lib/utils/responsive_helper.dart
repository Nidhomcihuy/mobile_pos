import 'package:flutter/widgets.dart';

/// Responsive helper that scales sizes relative to a 1280-wide reference.
class Responsive {
  final double screenWidth;
  final double screenHeight;

  Responsive(this.screenWidth, this.screenHeight);

  factory Responsive.of(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Responsive(size.width, size.height);
  }

  // ── Reference design width ──
  static const double _refWidth = 1280;

  /// Scale factor relative to the reference width, clamped to avoid extremes.
  double get _scale => (screenWidth / _refWidth).clamp(0.55, 1.4);

  /// Scale a font size.
  double font(double base) => (base * _scale).roundToDouble();

  /// Scale a spacing / padding value.
  double space(double base) => (base * _scale).roundToDouble();

  /// Scale an icon size.
  double icon(double base) => (base * _scale).roundToDouble();

  /// How many columns a product grid should show.
  int get gridColumns {
    if (screenWidth >= 1200) return 5;
    if (screenWidth >= 900) return 4;
    if (screenWidth >= 650) return 3;
    return 2;
  }

  /// Breakpoint helpers
  bool get isSmallTablet => screenWidth < 700;
  bool get isMediumTablet => screenWidth >= 700 && screenWidth < 1024;
  bool get isLargeTablet => screenWidth >= 1024;
}
