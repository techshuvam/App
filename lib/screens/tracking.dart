import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

const _steps = ['Confirmed', 'Preparing', 'On the way', 'Delivered'];

class TrackingScreen extends StatefulWidget {
  /// true when coming straight from payment (full timeline), false when reopened from Orders.
  final bool fresh;
  const TrackingScreen({super.key, this.fresh = false});
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with TickerProviderStateMixin {
  late final AnimationController _ride;
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();
  final _timers = <Timer>[];
  late final double _ps = widget.fresh ? 0 : .3;
  int _step = 0;
  int? _eta = 28;
  bool _arrived = false;

  @override
  void initState() {
    super.initState();
    _ride = AnimationController(vsync: this, duration: Duration(milliseconds: (42000 * (1 - _ps)).round()))..addListener(_tick);
    if (widget.fresh) {
      _step = 0;
      _eta = 28;
      _timers.add(Timer(const Duration(milliseconds: 2600), () => _set(1, 20)));
      _timers.add(Timer(const Duration(milliseconds: 6200), _go));
    } else {
      _timers.add(Timer(const Duration(milliseconds: 500), _go));
      _step = 2;
      _eta = 12;
    }
  }

  void _set(int s, int? eta) {
    if (!mounted) return;
    setState(() {
      _step = s;
      _eta = eta;
    });
  }

  void _go() {
    if (!mounted) return;
    _set(2, 12);
    HapticFeedback.mediumImpact();
    _ride.forward().whenComplete(() {
      if (!mounted) return;
      _set(3, null);
      _arrived = true;
      HapticFeedback.heavyImpact();
      toast(context, 'Your order has arrived. Enjoy!', icon: Icons.celebration_outlined);
    });
  }

  void _tick() {
    final m = (12 * (1 - _ride.value)).ceil();
    if (_step == 2 && m != _eta && !_arrived) setState(() => _eta = m);
  }

  double get _p => _ps + (1 - _ps) * _ride.value;

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _ride.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pl = app.placed ?? const PlacedOrder(id: 'FX-4821', restaurantId: 'oro', items: {'oro1': 1, 'oro2': 1, 'oro9': 1}, pay: 1429, method: 'UPI');
    final r = restIndex[pl.restaurantId]!;
    final top = MediaQuery.paddingOf(context).top;
    final thumbs = pl.items.keys.take(3).map((id) => dishIndex[id]!).toList();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFE8DA),
        body: Stack(children: [
          Positioned.fill(bottom: 380, child: RepaintBoundary(child: CustomPaint(painter: _StaticMapPainter()))),
          Positioned.fill(
            bottom: 380,
            child: AnimatedBuilder(animation: Listenable.merge([_ride, _pulse]), builder: (_, __) => CustomPaint(painter: _RoutePainter(_p, _pulse.value, _step))),
          ),
          Positioned(
            top: top + 12,
            left: 18,
            right: 18,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              RoundBtn(Icons.arrow_back_rounded, glass: true, onTap: () => Navigator.pop(context)),
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), color: Colors.white.withValues(alpha: .85), child: Text('Order ${pl.id}', style: sans(13.5, w: FontWeight.w800))),
                ),
              ),
              RoundBtn(Icons.help_outline_rounded, glass: true, onTap: () => toast(context, 'Support is on its way', icon: Icons.support_agent_rounded)),
            ]),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: curve,
              builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 60 * (1 - v)), child: child)),
              child: _Sheet(
                step: _step,
                eta: _eta,
                pl: pl,
                r: r,
                thumbs: thumbs,
                bottom: MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  final int step;
  final int? eta;
  final PlacedOrder pl;
  final Restaurant r;
  final List<Dish> thumbs;
  final double bottom;
  const _Sheet({required this.step, required this.eta, required this.pl, required this.r, required this.thumbs, required this.bottom});
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
        decoration: BoxDecoration(color: C.paper, borderRadius: const BorderRadius.vertical(top: Radius.circular(34)), boxShadow: [BoxShadow(color: const Color(0xFF3C2D0F).withValues(alpha: .5), blurRadius: 46, offset: const Offset(0, -24), spreadRadius: -24)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 42, height: 4, decoration: BoxDecoration(color: C.line2, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ESTIMATED ARRIVAL', style: sans(11.5, w: FontWeight.w700, color: C.mute, ls: 1.6)),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (c, a) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0, .25), end: Offset.zero).animate(a), child: c)),
                  child: Row(key: ValueKey(eta), crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, mainAxisSize: MainAxisSize.min, children: [
                    Text(eta == null ? 'Arrived' : '$eta', style: serif(46, height: 1, ls: -1.4)),
                    if (eta != null) Padding(padding: const EdgeInsets.only(left: 5), child: Text('min', style: sans(18, w: FontWeight.w700))),
                  ]),
                ),
              ]),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: C.goldSoft, borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const _PulseDot(),
                const SizedBox(width: 8),
                AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: Text(['Confirmed', 'Preparing', 'On the way', 'Delivered'][step], key: ValueKey(step), style: sans(12.5, w: FontWeight.w800, color: const Color(0xFF6D4E17)))),
              ]),
            ),
          ]),
          const SizedBox(height: 24),
          _Progress(step),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            decoration: card(r: 26),
            child: Row(children: [
              Container(width: 46, height: 46, alignment: Alignment.center, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF2C5446), C.forestDeep])), child: Text('AK', style: sans(14, w: FontWeight.w800, color: C.gold2, ls: .6))),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Arjun K.', style: sans(14.5, w: FontWeight.w800)), Row(children: [Text('Your rider · 4.9 ', style: sans(12, w: FontWeight.w600, color: C.mute)), const StarIcon(size: 12)])])),
              RoundBtn(Icons.chat_bubble_outline_rounded, size: 42, onTap: () => toast(context, 'Message sent to Arjun', icon: Icons.chat_bubble_outline_rounded)),
              const SizedBox(width: 8),
              RoundBtn(Icons.call_rounded, size: 42, bg: C.gold, color: const Color(0xFF1B1407), onTap: () => toast(context, 'Calling Arjun K…', icon: Icons.call_rounded)),
            ]),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 11, 16, 11),
            decoration: card(r: 24),
            child: Row(children: [
              SizedBox(
                width: 34.0 + (thumbs.length - 1) * 24,
                height: 34,
                child: Stack(children: [
                  for (final (i, d) in thumbs.indexed) Positioned(left: i * 24.0, child: Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)), child: ClipOval(child: FoodImage(d.img, cache: 100)))),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${r.name} · ${pl.itemsLabel}', style: sans(13.5, w: FontWeight.w800)), Text('${inr(pl.pay)} paid with ${pl.method}', style: sans(12, color: C.mute))])),
              const Icon(Icons.chevron_right_rounded, size: 20, color: C.mute),
            ]),
          ),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.place_rounded, size: 14, color: C.gold),
            const SizedBox(width: 6),
            Flexible(child: Text('Delivering to ${addresses[app.addr].$2}', overflow: TextOverflow.ellipsis, style: sans(12.5, w: FontWeight.w600, color: C.mute))),
          ]),
        ]),
      );
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: _c, builder: (_, __) => Container(width: 7, height: 7, decoration: BoxDecoration(color: C.gold, shape: BoxShape.circle, boxShadow: [BoxShadow(color: C.gold.withValues(alpha: .6 * (1 - _c.value)), spreadRadius: 9 * _c.value)])));
}

class _Progress extends StatelessWidget {
  final int step;
  const _Progress(this.step);
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final col = c.maxWidth / 4;
        return SizedBox(
          height: 52,
          child: Stack(children: [
            Positioned(left: col / 2, right: col / 2, top: 12, child: Container(height: 2, color: C.line2)),
            Positioned(
              left: col / 2,
              top: 12,
              child: AnimatedContainer(duration: const Duration(milliseconds: 1200), curve: curve, height: 2, width: (c.maxWidth - col) * step / 3, decoration: const BoxDecoration(gradient: LinearGradient(colors: [C.forest, C.gold]))),
            ),
            Row(children: [
              for (var i = 0; i < 4; i++)
                Expanded(
                  child: Column(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < step ? C.forest : Colors.white,
                        border: Border.all(color: i < step ? C.forest : (i == step ? C.gold : C.line2), width: i == step ? 2 : 1.5),
                        boxShadow: i == step ? [BoxShadow(color: C.gold.withValues(alpha: .2), spreadRadius: 6)] : null,
                      ),
                      child: i < step
                          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                          : i == step
                              ? Center(child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: C.gold, shape: BoxShape.circle)))
                              : null,
                    ),
                    const SizedBox(height: 8),
                    Text(_steps[i], style: sans(11.5, w: FontWeight.w700, color: i <= step ? C.ink : C.mute)),
                  ]),
                ),
            ]),
          ]),
        );
      });
}

/* ------------------------------ map ------------------------------ */

Path _route() => Path()
  ..moveTo(92, 372)
  ..lineTo(92, 304)
  ..quadraticBezierTo(92, 282, 114, 282)
  ..lineTo(188, 282)
  ..quadraticBezierTo(210, 282, 210, 260)
  ..lineTo(210, 218)
  ..quadraticBezierTo(210, 196, 232, 196)
  ..lineTo(270, 196)
  ..quadraticBezierTo(292, 196, 292, 174)
  ..lineTo(292, 150);

/// Scales the 390x520 design canvas to cover the paint area.
void _fit(Canvas canvas, Size size) {
  final s = math.max(size.width / 390, size.height / 420);
  canvas.translate((size.width - 390 * s) / 2, 0);
  canvas.scale(s);
}

void _glyph(Canvas canvas, IconData icon, Offset c, double size, Color color) {
  final tp = TextPainter(text: TextSpan(text: String.fromCharCode(icon.codePoint), style: TextStyle(fontFamily: icon.fontFamily, fontSize: size, color: color)), textDirection: TextDirection.ltr)..layout();
  tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
}

class _StaticMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEFE8DA));
    canvas.save();
    _fit(canvas, size);
    // building footprints
    var seed = 7;
    double rnd() => (seed = (seed * 16807) % 2147483647) / 2147483647;
    for (var i = 0; i < 190; i++) {
      final x = rnd() * 420 - 15, y = rnd() * 640 - 20, w = 14 + rnd() * 30, h = 12 + rnd() * 26;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(3)), Paint()..color = i % 5 == 0 ? const Color(0xFFE2D8C4) : const Color(0xFFE8DFCD));
    }
    // water
    final water = Path()
      ..moveTo(-20, 120)
      ..cubicTo(60, 96, 110, 150, 190, 128)
      ..cubicTo(260, 108, 330, 56, 420, 86)
      ..lineTo(420, -60)
      ..lineTo(-20, -60)
      ..close();
    canvas.drawPath(water, Paint()..color = const Color(0xFFD2E0E3));
    canvas.drawPath(
        Path()
          ..moveTo(-20, 128)
          ..cubicTo(60, 106, 112, 160, 190, 138)
          ..cubicTo(260, 118, 330, 66, 420, 96),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFC3D5D9));
    // parks
    for (final p in [const Rect.fromLTWH(14, 196, 60, 70), const Rect.fromLTWH(236, 300, 130, 86), const Rect.fromLTWH(108, 320, 82, 42)]) {
      canvas.drawRRect(RRect.fromRectAndRadius(p, const Radius.circular(14)), Paint()..color = const Color(0xFFDCE6CF));
    }
    // roads
    void road(Offset a, Offset b, double w) => canvas.drawLine(
        a,
        b,
        Paint()
          ..color = const Color(0xFFFBF8F2)
          ..strokeWidth = w
          ..strokeCap = StrokeCap.round);
    road(const Offset(-10, 430), const Offset(400, 238), 17);
    road(const Offset(-10, 372), const Offset(400, 372), 12);
    road(const Offset(-10, 282), const Offset(400, 282), 12);
    road(const Offset(-10, 196), const Offset(400, 196), 12);
    road(const Offset(92, 130), const Offset(92, 640), 12);
    road(const Offset(210, 100), const Offset(210, 640), 12);
    road(const Offset(292, 90), const Offset(292, 330), 12);
    road(const Offset(350, 60), const Offset(350, 640), 8);
    road(const Offset(30, 150), const Offset(30, 640), 8);
    road(const Offset(150, 100), const Offset(150, 640), 7);
    // labels
    for (final (t, o) in [('PALM STREET', const Offset(122, 270)), ('ORCHARD AVE', const Offset(232, 184))]) {
      final tp = TextPainter(text: TextSpan(text: t, style: serif(9, color: const Color(0xFFB9AE98), ls: 2)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, o);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _RoutePainter extends CustomPainter {
  final double p, pulse;
  final int step;
  _RoutePainter(this.p, this.pulse, this.step);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    _fit(canvas, size);
    final path = _route(), m = path.computeMetrics().first;
    // dotted base
    final dot = Paint()..color = const Color(0xFFC9BCA2);
    for (double d = 0; d < m.length; d += 9) {
      canvas.drawCircle(m.getTangentForOffset(d)!.position, 2.1, dot);
    }
    // progress
    canvas.drawPath(
        m.extractPath(0, m.length * p),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = C.forest);
    // restaurant pin
    const rp = Offset(92, 372);
    canvas.drawCircle(rp, 22, Paint()..color = C.forest.withValues(alpha: .12));
    canvas.drawCircle(rp, 15, Paint()..color = C.forest);
    _glyph(canvas, Icons.storefront_rounded, rp, 16, C.cream);
    // home pin w/ pulse
    const hp = Offset(292, 150);
    canvas.drawCircle(hp, 16 + 18 * pulse, Paint()..color = C.gold.withValues(alpha: .3 * (1 - pulse)));
    canvas.drawCircle(hp, 16, Paint()..color = C.gold);
    _glyph(canvas, Icons.home_rounded, hp, 17, const Color(0xFF1B1407));
    // rider
    final pos = m.getTangentForOffset(m.length * p)!.position;
    canvas.drawCircle(pos, 18 + 14 * pulse, Paint()..color = C.gold.withValues(alpha: .22 * (1 - pulse)));
    canvas.drawShadow(Path()..addOval(Rect.fromCircle(center: pos, radius: 17)), Colors.black, 4, false);
    canvas.drawCircle(pos, 17, Paint()..color = Colors.white);
    canvas.drawCircle(
        pos,
        17,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = C.forest);
    _glyph(canvas, Icons.two_wheeler_rounded, pos, 19, C.forest);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) => old.p != p || old.pulse != pulse || old.step != step;
}
