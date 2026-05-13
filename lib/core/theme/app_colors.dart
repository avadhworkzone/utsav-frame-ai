import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFF6C63FF);
  static const primary2 = Color(0xFF7B61FF);
  static const primary3 = Color(0xFF8B5CF6);
  static const cyan = Color(0xFF22D3EE);

  // Dark surfaces
  static const dark0 = Color(0xFF0F172A);
  static const dark1 = Color(0xFF111827);
  static const dark2 = Color(0xFF1E293B);

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  static LinearGradient brandGradient({double opacity = 1}) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primary.withOpacity(opacity),
          primary3.withOpacity(opacity),
          cyan.withOpacity(opacity),
        ],
      );
}
