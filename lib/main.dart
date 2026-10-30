import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/shell.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark, systemNavigationBarColor: Colors.transparent));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const FoodEXApp());
}

class FoodEXApp extends StatelessWidget {
  const FoodEXApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'FoodEX',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        scrollBehavior: const _Scroll(),
        builder: (context, child) => _DesktopFrame(child: child!),
        home: const Shell(),
      );
}

class _Scroll extends MaterialScrollBehavior {
  const _Scroll();
  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad, PointerDeviceKind.stylus};
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}

/// On phones the app fills the screen. On a desktop window it is shown inside a phone-sized frame
/// so the layout is always judged at real mobile proportions.
class _DesktopFrame extends StatelessWidget {
  final Widget child;
  const _DesktopFrame({required this.child});
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (mq.size.width < 600) return child;
    const w = 390.0, h = 844.0;
    final scale = math.min(1.0, (mq.size.height - 40) / h);
    return ColoredBox(
      color: C.bg,
      child: Center(
        child: SizedBox(
          width: w * scale,
          height: h * scale,
          child: FittedBox(
            child: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(52), boxShadow: [BoxShadow(color: const Color(0xFF3C2D0F).withValues(alpha: .35), blurRadius: 80, offset: const Offset(0, 50), spreadRadius: -20)]),
              foregroundDecoration: BoxDecoration(borderRadius: BorderRadius.circular(52), border: Border.all(color: const Color(0xFF151514), width: 9)),
              clipBehavior: Clip.antiAlias,
              child: MediaQuery(data: mq.copyWith(size: const Size(w, h), padding: const EdgeInsets.only(top: 46, bottom: 14), viewPadding: const EdgeInsets.only(top: 46, bottom: 14)), child: child),
            ),
          ),
        ),
      ),
    );
  }
}
