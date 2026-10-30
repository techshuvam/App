import 'package:flutter/material.dart';

class C {
  static const bg = Color(0xFFF7F3EC);
  static const paper = Color(0xFFFBF8F3);
  static const ink = Color(0xFF17140F);
  static const ink2 = Color(0xFF4A443B);
  static const mute = Color(0xFF8A8275);
  static const line = Color(0xFFECE5D8);
  static const line2 = Color(0xFFE2D9C8);
  static const forest = Color(0xFF1D3A2F);
  static const forest2 = Color(0xFF2A5042);
  static const forestDeep = Color(0xFF142A21);
  static const gold = Color(0xFFB58A3C);
  static const gold2 = Color(0xFFD9B26A);
  static const goldSoft = Color(0xFFF3E6C8);
  static const cream = Color(0xFFF6EFE0);
  static const rose = Color(0xFFB04A3A);
  static const ok = Color(0xFF2F7A4F);
}

const curve = Cubic(.22, .9, .25, 1);

TextStyle serif(double size, {FontWeight w = FontWeight.w400, Color color = C.ink, double? height, double ls = -0.4, FontStyle? style}) =>
    TextStyle(fontFamily: 'Fraunces', fontSize: size, fontWeight: w, color: color, height: height, letterSpacing: ls, fontStyle: style);

TextStyle sans(double size, {FontWeight w = FontWeight.w500, Color color = C.ink, double? height, double ls = 0, TextDecoration? deco}) =>
    TextStyle(fontFamily: 'Manrope', fontSize: size, fontWeight: w, color: color, height: height, letterSpacing: ls, decoration: deco);

final cardShadow = [BoxShadow(color: const Color(0xFF3C2D0F).withValues(alpha: .13), blurRadius: 26, offset: const Offset(0, 14), spreadRadius: -12)];
final softRing = Border.all(color: C.line);

BoxDecoration card({double r = 24, Color color = Colors.white, bool shadow = false, Color? ring}) => BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(r),
      border: Border.all(color: ring ?? C.line),
      boxShadow: shadow ? cardShadow : null,
    );

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      fontFamily: 'Manrope',
      scaffoldBackgroundColor: C.paper,
      colorScheme: ColorScheme.fromSeed(seedColor: C.forest, surface: C.paper),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(),
    );

String inr(num n) {
  final s = n.round().toString();
  if (s.length <= 3) return '₹$s';
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '₹${parts.join(',')},$last3';
}
