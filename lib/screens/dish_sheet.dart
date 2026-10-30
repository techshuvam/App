import 'package:flutter/material.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

Future<void> showDishSheet(BuildContext context, Dish d) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF120E08).withValues(alpha: .5),
      transitionAnimationController: null,
      builder: (_) => _DishSheet(d),
    );

class _DishSheet extends StatefulWidget {
  final Dish d;
  const _DishSheet(this.d);
  @override
  State<_DishSheet> createState() => _DishSheetState();
}

class _DishSheetState extends State<_DishSheet> {
  late int _qty = app.qty(widget.d.id) == 0 ? 1 : app.qty(widget.d.id);
  final _heroKey = GlobalKey();

  String get _label {
    final inCart = app.qty(widget.d.id) > 0;
    if (_qty == 0) return 'Remove from order';
    return '${inCart ? 'Update order' : 'Add to order'} · ${inr(widget.d.price * _qty)}';
  }

  Future<void> _commit() async {
    final d = widget.d;
    if (app.conflicts(d)) {
      final ok = await confirmReplace(context, d);
      if (!ok || !mounted) return;
      app.clearCart();
    }
    final had = app.qty(d.id);
    app.setQty(d.id, _qty);
    if (_qty > had && mounted) {
      final box = _heroKey.currentContext!.findRenderObject() as RenderBox;
      flyToCart(context, d.img, (box.localToGlobal(Offset.zero) & box.size).deflate(60));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.d, r = restIndex[d.rid]!;
    final h = MediaQuery.sizeOf(context).height, bottom = MediaQuery.paddingOf(context).bottom;
    final pairs = ([...r.menu.where((x) => x.id != d.id && app.qty(x.id) == 0)]..sort((a, b) => (a.cat == d.cat ? 1 : 0) - (b.cat == d.cat ? 1 : 0))).take(3).toList();
    return Container(
      constraints: BoxConstraints(maxHeight: h * .9),
      decoration: const BoxDecoration(color: C.paper, borderRadius: BorderRadius.vertical(top: Radius.circular(34))),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          height: 290,
          child: Stack(fit: StackFit.expand, children: [
            TweenAnimationBuilder<double>(
              key: _heroKey,
              tween: Tween(begin: 1.14, end: 1),
              duration: const Duration(milliseconds: 1400),
              curve: curve,
              builder: (_, s, child) => Transform.scale(scale: s, child: child),
              child: FoodImage(d.img, align: d.align, cache: 1000),
            ),
            Positioned(left: 0, right: 0, bottom: 0, height: 90, child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [C.paper, C.paper.withValues(alpha: 0)])))),
            Positioned(top: 18, right: 18, child: RoundBtn(Icons.close_rounded, glass: true, size: 42, onTap: () => Navigator.pop(context))),
            Positioned(top: 10, left: 0, right: 0, child: Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .8), borderRadius: BorderRadius.circular(2))))),
          ]),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [VegDot(d.veg), if (d.tag != null) ...[const SizedBox(width: 8), TagChip(d.tag!)], if (d.hot) ...[const SizedBox(width: 8), const TagChip('Spicy', spicy: true)]]),
              const SizedBox(height: 10),
              Text(d.name, style: serif(29, height: 1.08, ls: -.6)),
              const SizedBox(height: 10),
              Row(children: [
                const StarIcon(),
                const SizedBox(width: 4),
                Text((4.4 + (d.price % 7) / 10).toStringAsFixed(1), style: sans(12.5, w: FontWeight.w700, color: C.ink2)),
                const SizedBox(width: 12),
                MetaItem(Icons.schedule_rounded, '${r.time} min'),
                const SizedBox(width: 12),
                Flexible(child: Text(r.name, overflow: TextOverflow.ellipsis, style: sans(12.5, w: FontWeight.w600, color: C.mute))),
              ]),
              const SizedBox(height: 12),
              Text('${d.desc} Prepared fresh to order and packed to arrive warm.', style: sans(13.5, color: C.ink2, height: 1.65)),
              if (pairs.isNotEmpty) ...[
                const SizedBox(height: 22),
                Text('PAIRS WELL WITH', style: sans(12, w: FontWeight.w800, color: C.mute, ls: 1.6)),
                const SizedBox(height: 10),
                Row(children: [
                  for (final (i, p) in pairs.indexed) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: Press(
                        onTap: () {
                          final nav = Navigator.of(context, rootNavigator: true);
                          nav.pop();
                          Future.delayed(const Duration(milliseconds: 350), () {
                            // ignore: use_build_context_synchronously
            if (nav.context.mounted) showDishSheet(nav.context, p);
                          });
                        },
                        scale: .95,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: card(r: 18),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SizedBox(height: 62, width: double.infinity, child: FoodImage(p.img, align: p.align, radius: BorderRadius.circular(12), cache: 260)),
                            const SizedBox(height: 7),
                            SizedBox(height: 28, child: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: sans(11.5, w: FontWeight.w700, height: 1.2))),
                            Text(inr(p.price), style: sans(12, w: FontWeight.w800, color: C.gold)),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ]),
              ],
              const SizedBox(height: 12),
            ]),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(22, 14, 22, 20 + bottom),
          child: Row(children: [
            QtyStepper(
              qty: _qty,
              light: true,
              height: 62,
              onInc: () => setState(() => _qty++),
              onDec: () => setState(() => _qty = (_qty - 1).clamp(app.qty(d.id) > 0 ? 0 : 1, 99)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Cta(_label, icon: _qty == 0 ? Icons.delete_outline_rounded : Icons.add_rounded, onTap: _commit)),
          ]),
        ),
      ]),
    );
  }
}
