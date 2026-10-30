import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'cart.dart';
import 'tracking.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});
  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with TickerProviderStateMixin {
  late final AnimationController _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
  late final AnimationController _ring = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat();

  @override
  void dispose() {
    _in.dispose();
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PlacedOrder pl = app.placed ??
        const PlacedOrder(id: 'FX-4821', restaurantId: 'oro', items: {'oro1': 1, 'oro2': 1, 'oro9': 1}, pay: 1429, method: 'UPI');
    final r = restIndex[pl.restaurantId]!;
    final time = r.time.contains('–') ? r.time : '${r.time}–${int.parse(r.time) + 5}';
    return Scaffold(
      backgroundColor: C.paper,
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 28, bottom: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(alignment: Alignment.center, children: [
                    AnimatedBuilder(animation: _ring, builder: (_, __) => CustomPaint(size: const Size(150, 150), painter: _RipplePainter(_ring.value))),
                    AnimatedBuilder(
                      animation: _in,
                      builder: (_, __) {
                        final s = Curves.elasticOut.transform((_in.value / .55).clamp(0, 1));
                        final draw = Curves.easeOutCubic.transform(((_in.value - .3) / .45).clamp(0, 1));
                        return Transform.scale(
                          scale: s,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(colors: [Color(0xFF2C5446), C.forestDeep], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              boxShadow: [BoxShadow(color: C.forest.withValues(alpha: .8), blurRadius: 34, offset: const Offset(0, 24), spreadRadius: -14), BoxShadow(color: C.forest.withValues(alpha: .08), spreadRadius: 8)],
                            ),
                            child: CustomPaint(painter: _CheckPainter(draw)),
                          ),
                        );
                      },
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              Reveal(index: 5, child: Center(child: Text('Payment successful', style: serif(33, ls: -.9)))),
              const SizedBox(height: 9),
              Reveal(index: 6, child: Center(child: SizedBox(width: 280, child: Text('Your order is confirmed. ${r.name} is preparing it now.', textAlign: TextAlign.center, style: sans(14, color: C.mute, height: 1.55))))),
              const SizedBox(height: 22),
              Reveal(
                index: 7,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Stack(clipBehavior: Clip.none, children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
                      decoration: card(r: 26, shadow: true),
                      child: Column(children: [
                        Row(children: [
                          ClipOval(child: SizedBox(width: 44, height: 44, child: FoodImage(r.thumb, cache: 140))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.name, style: sans(14.5, w: FontWeight.w800)), Text(pl.itemsLabel, style: sans(12, color: C.mute))])),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: C.goldSoft, borderRadius: BorderRadius.circular(20)), child: Text('Paid', style: sans(11.5, w: FontWeight.w800, color: const Color(0xFF6D4E17)))),
                        ]),
                        const SizedBox(height: 18),
                        const DashedLine(),
                        const SizedBox(height: 14),
                        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Expanded(child: Text('Amount paid', style: sans(13, color: C.mute))), Text(inr(pl.pay), style: serif(28, w: FontWeight.w500, ls: -.4))]),
                        _row('Paid via', pl.method),
                        _row('Order ID', pl.id),
                        _row('Arrives in', '$time min'),
                      ]),
                    ),
                    for (final left in [true, false])
                      Positioned(top: 76, left: left ? -10 : null, right: left ? null : -10, child: Container(width: 20, height: 20, decoration: BoxDecoration(color: C.paper, shape: BoxShape.circle, border: Border.all(color: C.line)))),
                  ]),
                ),
              ),
            ],
          ),
        ),
        Dock(children: [
          Cta('Back to home', ghost: true, onTap: () {
            app.set(tab: 0);
            Navigator.of(context).popUntil((r) => r.isFirst);
          }),
          Cta('Track your order', onTap: () => Navigator.of(context).push(softRoute(const TrackingScreen(fresh: true)))),
        ]),
      ]),
    );
  }

  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Expanded(child: Text(l, style: sans(13, color: C.mute))), Text(v, style: sans(13, w: FontWeight.w700))]));
}

class _CheckPainter extends CustomPainter {
  final double t;
  _CheckPainter(this.t);
  @override
  void paint(Canvas canvas, Size s) {
    final k = s.width / 24;
    final path = Path()
      ..moveTo(5.5 * k, 12.5 * k)
      ..lineTo(9.8 * k, 16.8 * k)
      ..lineTo(18.5 * k, 8 * k);
    final m = path.computeMetrics().first;
    canvas.drawPath(
      m.extractPath(0, m.length * t),
      Paint()
        ..color = C.gold2
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) => old.t != t;
}

class _RipplePainter extends CustomPainter {
  final double t;
  _RipplePainter(this.t);
  @override
  void paint(Canvas canvas, Size s) {
    for (var i = 0; i < 3; i++) {
      final k = (t + i / 3) % 1;
      final r = s.width / 2 * (.55 + 1.1 * k) * .62;
      final a = math.sin(k * math.pi).clamp(0, 1) * .55;
      canvas.drawCircle(s.center(Offset.zero), r + 20, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = C.gold.withValues(alpha: a.toDouble()));
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) => old.t != t;
}
