import 'package:flutter/material.dart';
import '../cards.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'payment.dart';

class ScreenTop extends StatelessWidget {
  final String title;
  const ScreenTop(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
        RoundBtn(Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
        const SizedBox(width: 14),
        Text(title, style: serif(29, ls: -.7)),
      ]);
}

class Dock extends StatelessWidget {
  final List<Widget> children;
  const Dock({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(20, 26, 20, 16 + MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [C.paper.withValues(alpha: 0), C.paper, C.paper], stops: const [0, .35, 1])),
        child: Column(mainAxisSize: MainAxisSize.min, children: [for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 10), children[i]]]),
      );
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.paper,
        body: ListenableBuilder(
          listenable: app,
          builder: (context, _) {
            final lines = app.lines, r = app.cartRestaurant, t = app.totals;
            return Column(children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(22, MediaQuery.paddingOf(context).top + 16, 22, 30),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const Reveal(child: ScreenTop('Your order')),
                    const SizedBox(height: 22),
                    if (lines.isEmpty || r == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Column(children: [
                          const Icon(Icons.shopping_bag_outlined, size: 40, color: C.mute),
                          const SizedBox(height: 12),
                          Text('Your order is empty', style: serif(22, w: FontWeight.w500)),
                          const SizedBox(height: 6),
                          Text('Add something delicious from a restaurant near you.', textAlign: TextAlign.center, style: sans(13, color: C.mute)),
                        ]),
                      )
                    else ...[
                      Reveal(
                        index: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
                          decoration: card(r: 22),
                          child: Row(children: [
                            ClipOval(child: SizedBox(width: 40, height: 40, child: FoodImage(r.thumb, cache: 120))),
                            const SizedBox(width: 12),
                            Expanded(child: Text(r.name, style: sans(14.5, w: FontWeight.w800))),
                            MetaItem(Icons.schedule_rounded, '${r.time} min'),
                          ]),
                        ),
                      ),
                      for (final (i, l) in lines.indexed) _CartLine(key: ValueKey(l.key.id), d: l.key, qty: l.value, index: i + 2),
                      const SizedBox(height: 14),
                      const _PromoField(),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => app.set(skipCutlery: !app.skipCutlery),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: card(r: 22),
                          child: Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Skip cutlery', style: sans(13, w: FontWeight.w700)), const SizedBox(height: 2), Text('Reduce plastic, we’ll leave it out', style: sans(11.5, color: C.mute))])),
                            _Toggle(app.skipCutlery),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 14),
                      BillCard(t, rows: [('Subtotal', t.sub), ('Delivery fee', t.fee), ('Service fee', t.svc), ('Taxes (5%)', t.tax)], totalLabel: 'Total', total: t.total),
                      Builder(builder: (context) {
                        final sug = r.menu.where((d) => app.qty(d.id) == 0).take(6).toList();
                        if (sug.isEmpty) return const SizedBox();
                        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const SectionHeader('Complete your meal', top: 26),
                          SizedBox(height: 246, child: ListView.separated(scrollDirection: Axis.horizontal, clipBehavior: Clip.none, physics: const BouncingScrollPhysics(), itemCount: sug.length, separatorBuilder: (_, __) => const SizedBox(width: 14), itemBuilder: (_, i) => DishTile(sug[i], index: i))),
                        ]);
                      }),
                    ],
                  ],
                ),
              ),
              if (lines.isNotEmpty) Dock(children: [Cta('Continue to payment', onTap: () => Navigator.of(context).push(softRoute(const PaymentScreen())))]),
            ]);
          },
        ),
      );
}

class BillCard extends StatelessWidget {
  final Totals t;
  final List<(String, int)> rows;
  final String totalLabel;
  final int total;
  const BillCard(this.t, {super.key, required this.rows, required this.totalLabel, required this.total});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        decoration: card(r: 26),
        child: Column(children: [
          for (final r in rows) _BillRow(r.$1, r.$2),
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: curve,
            child: t.disc > 0 ? _BillRow('Promo discount', -t.disc, green: true) : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 10),
          const _Dashed(),
          const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Expanded(child: Text(totalLabel, style: sans(14, w: FontWeight.w700))),
            AnimatedMoney(total, style: serif(30, w: FontWeight.w500, ls: -.5)),
          ]),
        ]),
      );
}

class _BillRow extends StatelessWidget {
  final String label;
  final int amount;
  final bool green;
  const _BillRow(this.label, this.amount, {this.green = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Expanded(child: Text(label, style: sans(13.5, color: green ? C.ok : C.ink2))),
          amount < 0 ? Text('−${inr(-amount)}', style: sans(13.5, w: FontWeight.w700, color: C.ok)) : AnimatedMoney(amount, style: sans(13.5, w: FontWeight.w700)),
        ]),
      );
}

class _Dashed extends StatelessWidget {
  const _Dashed();
  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, c) => Row(children: [for (var i = 0; i < (c.maxWidth / 8).floor(); i++) Expanded(child: Container(height: 1.2, margin: const EdgeInsets.only(right: 4), color: C.line2))]),
      );
}

class _Toggle extends StatelessWidget {
  final bool on;
  const _Toggle(this.on);
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: on ? C.forest : C.line2, borderRadius: BorderRadius.circular(14)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutBack,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(width: 22, height: 22, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .25), blurRadius: 5, offset: const Offset(0, 2))])),
        ),
      );
}

class _CartLine extends StatefulWidget {
  final Dish d;
  final int qty, index;
  const _CartLine({super.key, required this.d, required this.qty, required this.index});
  @override
  State<_CartLine> createState() => _CartLineState();
}

class _CartLineState extends State<_CartLine> {
  bool _gone = false;
  void _dec() {
    if (widget.qty > 1) {
      app.setQty(widget.d.id, widget.qty - 1);
    } else {
      setState(() => _gone = true);
      Future.delayed(const Duration(milliseconds: 380), () => app.setQty(widget.d.id, 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    return Reveal(
      index: widget.index,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 380),
        curve: curve,
        child: _gone
            ? const SizedBox(width: double.infinity)
            : Container(
                margin: const EdgeInsets.only(top: 11),
                padding: const EdgeInsets.all(11),
                decoration: card(r: 24),
                child: Row(children: [
                  SizedBox(width: 64, height: 64, child: FoodImage(d.img, align: d.align, radius: BorderRadius.circular(18), cache: 220)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: sans(14.5, w: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('${inr(d.price)} each', style: sans(11.5, color: C.mute)),
                      const SizedBox(height: 8),
                      QtyStepper(qty: widget.qty, light: true, onInc: () => app.setQty(d.id, widget.qty + 1), onDec: _dec),
                    ]),
                  ),
                  Align(alignment: Alignment.topRight, child: Padding(padding: const EdgeInsets.only(top: 4, right: 4), child: AnimatedMoney(d.price * widget.qty, style: sans(15, w: FontWeight.w800)))),
                ]),
              ),
      ),
    );
  }
}

class _PromoField extends StatefulWidget {
  const _PromoField();
  @override
  State<_PromoField> createState() => _PromoFieldState();
}

class _PromoFieldState extends State<_PromoField> with SingleTickerProviderStateMixin {
  final _c = TextEditingController();
  late final AnimationController _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  String _msg = 'Try FOODEX for 10% off';
  bool _bad = false;

  @override
  void dispose() {
    _c.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _apply() {
    if (app.promo != null) {
      app.set(clearPromo: true);
      _c.clear();
      setState(() {
        _msg = 'Try FOODEX for 10% off';
        _bad = false;
      });
      return;
    }
    final code = _c.text.trim().toUpperCase(), p = promos[code];
    if (p != null && p.calc(app.totals.sub) > 0) {
      FocusScope.of(context).unfocus();
      app.set(promo: code);
      toast(context, 'Promo applied', icon: Icons.local_offer_rounded);
    } else {
      _shake.forward(from: 0);
      setState(() {
        _bad = true;
        _msg = p != null ? 'Add a little more to use this code' : 'That code isn’t valid, try FOODEX';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ok = app.promo != null;
    if (ok && _c.text != app.promo) _c.text = app.promo!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedBuilder(
        animation: _shake,
        builder: (_, child) => Transform.translate(offset: Offset((_shake.isAnimating ? 1 : 0) * 8 * (1 - _shake.value) * ((_shake.value * 12).floor().isEven ? 1 : -1), 0), child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
          decoration: BoxDecoration(color: ok ? const Color(0xFFF3FAF5) : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: ok ? C.ok : C.line, width: ok ? 1.5 : 1)),
          child: Row(children: [
            const Icon(Icons.local_offer_outlined, size: 18, color: C.gold),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _c,
                readOnly: ok,
                textCapitalization: TextCapitalization.characters,
                cursorColor: C.gold,
                style: sans(13.5, w: FontWeight.w700, ls: .5),
                decoration: InputDecoration.collapsed(hintText: 'Add promo code', hintStyle: sans(13.5, color: C.mute)),
                onSubmitted: (_) => _apply(),
              ),
            ),
            Press(
              onTap: _apply,
              child: Container(height: 38, padding: const EdgeInsets.symmetric(horizontal: 18), alignment: Alignment.center, decoration: BoxDecoration(color: ok ? C.ok : C.forest, borderRadius: BorderRadius.circular(19)), child: Text(ok ? 'Remove' : 'Apply', style: sans(12.5, w: FontWeight.w700, color: C.cream))),
            ),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(6, 7, 6, 0),
        child: Text(ok ? '✓ ${promos[app.promo]!.label} applied' : _msg, style: sans(11.5, w: FontWeight.w700, color: ok ? C.ok : (_bad ? C.rose : C.mute))),
      ),
    ]);
  }
}
