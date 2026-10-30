import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'state.dart';
import 'theme.dart';

/* ---------------- motion helpers ---------------- */

/// Fades and lifts its child in, staggered by [index].
class Reveal extends StatefulWidget {
  final int index;
  final Widget child;
  final double dy;
  const Reveal({super.key, this.index = 0, required this.child, this.dy = 22});
  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 70 * widget.index + 60), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = CurvedAnimation(parent: _c, curve: curve);
    return AnimatedBuilder(
      animation: a,
      builder: (_, child) => Opacity(opacity: a.value.clamp(0, 1), child: Transform.translate(offset: Offset(0, (1 - a.value) * widget.dy), child: child)),
      child: widget.child,
    );
  }
}

/// Subtle press-down scale for any tappable.
class Press extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const Press({super.key, required this.child, this.onTap, this.scale = .96});
  @override
  State<Press> createState() => _PressState();
}

class _PressState extends State<Press> {
  bool _down = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                widget.onTap!();
              },
        child: AnimatedScale(scale: _down ? widget.scale : 1, duration: const Duration(milliseconds: 160), curve: Curves.easeOut, child: widget.child),
      );
}

class AnimatedMoney extends StatelessWidget {
  final num value;
  final TextStyle style;
  final String prefix;
  const AnimatedMoney(this.value, {super.key, required this.style, this.prefix = ''});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(end: value.toDouble()),
        duration: const Duration(milliseconds: 600),
        curve: curve,
        builder: (_, v, __) => Text(prefix + inr(v), style: style),
      );
}

/* ---------------- atoms ---------------- */

class FoodImage extends StatelessWidget {
  final String path;
  final Alignment align;
  final double? width, height;
  final BorderRadius? radius;
  final int cache;
  const FoodImage(this.path, {super.key, this.align = Alignment.center, this.width, this.height, this.radius, this.cache = 720});
  @override
  Widget build(BuildContext context) {
    final img = Image.asset(path, fit: BoxFit.cover, alignment: align, width: width, height: height, cacheWidth: cache, filterQuality: FilterQuality.medium, gaplessPlayback: true);
    return radius == null ? img : ClipRRect(borderRadius: radius!, child: img);
  }
}

class RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool glass, dot;
  final double size;
  final Color? color, bg;
  const RoundBtn(this.icon, {super.key, this.onTap, this.glass = false, this.size = 44, this.color, this.dot = false, this.bg});
  @override
  Widget build(BuildContext context) {
    final inner = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg ?? (glass ? Colors.white.withValues(alpha: .74) : Colors.white),
        border: Border.all(color: glass ? Colors.white.withValues(alpha: .55) : C.line),
        boxShadow: [BoxShadow(color: const Color(0xFF3C2D0F).withValues(alpha: glass ? .25 : .12), blurRadius: 18, offset: const Offset(0, 8), spreadRadius: -8)],
      ),
      child: Stack(alignment: Alignment.center, children: [
        Icon(icon, size: size * .44, color: color ?? C.ink),
        if (dot) Positioned(top: size * .24, right: size * .26, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: C.gold, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.6)))),
      ]),
    );
    final w = glass ? ClipOval(child: BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: inner)) : inner;
    return Press(onTap: onTap, scale: .9, child: w);
  }
}

class VegDot extends StatelessWidget {
  final bool veg;
  const VegDot(this.veg, {super.key});
  @override
  Widget build(BuildContext context) {
    final c = veg ? C.ok : C.rose;
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(border: Border.all(color: c, width: 1.5), borderRadius: BorderRadius.circular(3)),
      child: Center(child: Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle))),
    );
  }
}

class TagChip extends StatelessWidget {
  final String text;
  final bool spicy;
  const TagChip(this.text, {super.key, this.spicy = false});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: spicy ? const Color(0xFFF6DCD5) : C.goldSoft, borderRadius: BorderRadius.circular(6)),
        child: Text(text.toUpperCase(), style: sans(10, w: FontWeight.w800, color: spicy ? const Color(0xFF8A3425) : const Color(0xFF7D5B1F), ls: .5)),
      );
}

class StarIcon extends StatelessWidget {
  final double size;
  const StarIcon({super.key, this.size = 14});
  @override
  Widget build(BuildContext context) => Icon(Icons.star_rounded, size: size, color: C.gold);
}

class MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const MetaItem(this.icon, this.text, {super.key});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: C.ink2),
        const SizedBox(width: 4),
        Text(text, style: sans(12, w: FontWeight.w700, color: C.ink2)),
      ]);
}

class Cta extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool ghost, busy;
  const Cta(this.label, {super.key, this.onTap, this.icon = Icons.arrow_forward_rounded, this.ghost = false, this.busy = false});
  @override
  State<Cta> createState() => _CtaState();
}

class _CtaState extends State<Cta> with SingleTickerProviderStateMixin {
  late final AnimationController _shine = AnimationController(vsync: this, duration: const Duration(milliseconds: 4600))..repeat();
  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ghost) {
      return Press(
        onTap: widget.onTap,
        child: Container(
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(31), border: Border.all(color: C.line2)),
          child: Text(widget.label, style: sans(15.5, w: FontWeight.w700)),
        ),
      );
    }
    return Press(
      onTap: widget.busy ? null : widget.onTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(31),
          gradient: const LinearGradient(colors: [Color(0xFF25473A), C.forestDeep], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: C.forest.withValues(alpha: .6), blurRadius: 30, offset: const Offset(0, 18), spreadRadius: -14)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(31),
          child: Stack(children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _shine,
                builder: (_, __) {
                  final t = (_shine.value * 1.7 - .35);
                  return Transform.translate(
                    offset: Offset(MediaQuery.sizeOf(context).width * (t * 1.3 - .3), 0),
                    child: Transform(
                      transform: Matrix4.skewX(-.35),
                      child: FractionallySizedBox(
                        widthFactor: .2,
                        alignment: Alignment.centerLeft,
                        child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: .16), Colors.white.withValues(alpha: 0)]))),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 9, 0),
              child: Row(children: [
                Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(widget.label, maxLines: 1, style: sans(15.5, w: FontWeight.w700, color: C.cream, ls: .1)))),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [C.gold2, C.gold], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: widget.busy
                      ? const Padding(padding: EdgeInsets.all(11), child: CircularProgressIndicator(strokeWidth: 2.6, color: Color(0xFF1B1407)))
                      : Icon(widget.icon, size: 20, color: const Color(0xFF1B1407)),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/* ---------------- quantity controls ---------------- */

class QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onInc, onDec;
  final bool light;
  final double height;
  const QtyStepper({super.key, required this.qty, required this.onInc, required this.onDec, this.light = false, this.height = 34});
  @override
  Widget build(BuildContext context) {
    final fg = light ? C.ink : C.cream;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: light ? Colors.white : C.forest,
        borderRadius: BorderRadius.circular(height / 2),
        border: light ? Border.all(color: C.line2) : null,
        boxShadow: light ? null : [BoxShadow(color: C.forest.withValues(alpha: .7), blurRadius: 16, offset: const Offset(0, 8), spreadRadius: -8)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Press(onTap: onDec, scale: .8, child: SizedBox(width: height * .95, height: height, child: Icon(Icons.remove_rounded, size: 16, color: light ? C.mute : fg))),
        SizedBox(width: 20, child: AnimatedSwitcher(duration: const Duration(milliseconds: 220), transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c), child: Text('$qty', key: ValueKey(qty), textAlign: TextAlign.center, style: sans(13, w: FontWeight.w800, color: fg)))),
        Press(onTap: onInc, scale: .8, child: SizedBox(width: height * .95, height: height, child: Icon(Icons.add_rounded, size: 16, color: light ? C.gold : C.gold2))),
      ]),
    );
  }
}

/// Add button that morphs into a stepper once the dish is in the cart.
class DishControl extends StatelessWidget {
  final Dish dish;
  final bool square, light;
  const DishControl(this.dish, {super.key, this.square = false, this.light = false});

  Rect _rect(BuildContext c) {
    final box = c.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final q = app.qty(dish.id);
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutBack,
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: c)),
            child: q == 0
                ? Builder(
                    key: const ValueKey('add'),
                    builder: (bc) => Press(
                      onTap: () => addDish(bc, dish, from: _rect(bc)),
                      scale: .88,
                      child: square
                          ? Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [C.gold2, C.gold]), boxShadow: [BoxShadow(color: const Color(0xFF785000).withValues(alpha: .5), blurRadius: 14, offset: const Offset(0, 8), spreadRadius: -6)]),
                              child: const Icon(Icons.add_rounded, size: 18, color: Color(0xFF1B1407)),
                            )
                          : Container(
                              height: 34,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: C.line2), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .18), blurRadius: 14, offset: const Offset(0, 8), spreadRadius: -8)]),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Add', style: sans(12.5, w: FontWeight.w800, color: C.forest)), const SizedBox(width: 4), const Icon(Icons.add_rounded, size: 15, color: C.forest)]),
                            ),
                    ),
                  )
                : QtyStepper(key: const ValueKey('step'), qty: q, onInc: () => addDish(context, dish), onDec: () => app.setQty(dish.id, q - 1), light: light),
          );
        },
      );
}

Future<void> addDish(BuildContext context, Dish d, {Rect? from, int by = 1}) async {
  if (app.conflicts(d)) {
    final ok = await confirmReplace(context, d);
    if (!ok) return;
    app.clearCart();
  }
  app.setQty(d.id, app.qty(d.id) + by);
  if (from != null && context.mounted) flyToCart(context, d.img, from);
}

Future<bool> confirmReplace(BuildContext context, Dish d) async {
  final cur = app.cartRestaurant!;
  final r = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0xFF120E08).withValues(alpha: .5),
    builder: (c) => Dialog(
      backgroundColor: C.paper,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Start a new order?', style: serif(22, w: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Your cart has items from ${cur.name}. Adding from ${restIndex[d.rid]!.name} will clear it.', textAlign: TextAlign.center, style: sans(13, color: C.mute, height: 1.5)),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: Cta('Keep cart', ghost: true, onTap: () => Navigator.pop(c, false))),
            const SizedBox(width: 10),
            Expanded(child: Cta('Start new', icon: null, onTap: () => Navigator.pop(c, true))),
          ]),
        ]),
      ),
    ),
  );
  return r ?? false;
}

/* ---------------- overlays ---------------- */

void flyToCart(BuildContext context, String asset, Rect from) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  final size = MediaQuery.sizeOf(context);
  final to = Offset(size.width - 70, size.height - 70);
  late OverlayEntry entry;
  entry = OverlayEntry(builder: (_) => _Flyer(asset: asset, from: from.center, to: to, onDone: () => entry.remove()));
  overlay.insert(entry);
}

class _Flyer extends StatefulWidget {
  final String asset;
  final Offset from, to;
  final VoidCallback onDone;
  const _Flyer({required this.asset, required this.from, required this.to, required this.onDone});
  @override
  State<_Flyer> createState() => _FlyerState();
}

class _FlyerState extends State<_Flyer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 760))..forward().whenComplete(widget.onDone);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = CurvedAnimation(parent: _c, curve: const Cubic(.5, 0, .3, 1));
    final ctrl = Offset((widget.from.dx + widget.to.dx) / 2, math.min(widget.from.dy, widget.to.dy) - 120);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: a,
        builder: (_, __) {
          final t = a.value, u = 1 - t;
          final p = widget.from * (u * u) + ctrl * (2 * u * t) + widget.to * (t * t);
          final s = ui.lerpDouble(1.5, .35, t)!;
          return Stack(children: [
            Positioned(
              left: p.dx - 22,
              top: p.dy - 22,
              child: Opacity(
                opacity: (1 - t * t).clamp(.15, 1),
                child: Transform.scale(
                  scale: s,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .4), blurRadius: 18, offset: const Offset(0, 10))]),
                    child: ClipOval(child: Image.asset(widget.asset, fit: BoxFit.cover, cacheWidth: 120)),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

void toast(BuildContext context, String msg, {IconData icon = Icons.check_rounded}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  late OverlayEntry e;
  e = OverlayEntry(builder: (_) => _Toast(msg: msg, icon: icon, onDone: () => e.remove()));
  overlay.insert(e);
}

class _Toast extends StatefulWidget {
  final String msg;
  final IconData icon;
  final VoidCallback onDone;
  const _Toast({required this.msg, required this.icon, required this.onDone});
  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520), reverseDuration: const Duration(milliseconds: 300));
  @override
  void initState() {
    super.initState();
    _c.forward();
    Future.delayed(const Duration(milliseconds: 2100), () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = CurvedAnimation(parent: _c, curve: Curves.easeOutBack, reverseCurve: Curves.easeIn);
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 14,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: a,
          builder: (_, __) => Opacity(
            opacity: a.value.clamp(0, 1),
            child: Transform.translate(
              offset: Offset(0, (1 - a.value) * -30),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(color: C.ink, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .45), blurRadius: 28, offset: const Offset(0, 16), spreadRadius: -10)]),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(widget.icon, size: 16, color: C.gold2), const SizedBox(width: 8), Text(widget.msg, style: sans(13, w: FontWeight.w700, color: Colors.white))]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------- routes ---------------- */

Route<T> softRoute<T>(Widget page, {bool fade = false}) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 520),
      reverseTransitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, sec, child) {
        final c = CurvedAnimation(parent: a, curve: curve, reverseCurve: Curves.easeIn);
        final out = CurvedAnimation(parent: sec, curve: curve);
        return AnimatedBuilder(
          animation: Listenable.merge([c, out]),
          builder: (_, __) => Opacity(
            opacity: (1 - out.value * .45).clamp(0, 1),
            child: Transform.translate(
              offset: Offset(fade ? 0 : -70 * out.value, 0),
              child: FadeTransition(opacity: c, child: Transform.translate(offset: Offset(fade ? 0 : 44 * (1 - c.value), fade ? 14 * (1 - c.value) : 0), child: child)),
            ),
          ),
        );
      },
    );

/* ---------------- section header ---------------- */

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final double top;
  const SectionHeader(this.title, {super.key, this.action, this.onAction, this.top = 30});
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: top, bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Expanded(child: Text(title, style: serif(21, w: FontWeight.w500, ls: -.3))),
          if (action != null) GestureDetector(onTap: onAction, child: Text('$action  →', style: sans(12.5, w: FontWeight.w800, color: C.gold))),
        ]),
      );
}

class DashedLine extends StatelessWidget {
  const DashedLine({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, c) => Row(children: [for (var i = 0; i < (c.maxWidth / 8).floor(); i++) Expanded(child: Container(height: 1.4, margin: const EdgeInsets.only(right: 4), color: C.line2))]),
      );
}
