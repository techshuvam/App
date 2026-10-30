import 'package:flutter/material.dart';
import '../cards.dart';
import '../nav.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'tracking.dart';

EdgeInsets _pad(BuildContext c) => EdgeInsets.fromLTRB(22, MediaQuery.paddingOf(c).top + 16, 22, 190);

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});
  @override
  Widget build(BuildContext context) {
    final tiles = cravings.skip(1).toList();
    final top = ([...restaurants]..sort((a, b) => b.rating.compareTo(a.rating))).take(5).toList();
    return ListView(
      padding: _pad(context),
      physics: const BouncingScrollPhysics(),
      children: [
        Reveal(child: Text('Explore', style: serif(31, ls: -.8))),
        const SizedBox(height: 6),
        Reveal(index: 1, child: Text('Cuisines you’ll love, curated for tonight.', style: sans(13.5, color: C.mute))),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.7,
          children: [
            for (var i = 0; i < tiles.length; i++)
              Reveal(
                index: i + 2,
                child: Press(
                  onTap: () => app.set(craving: tiles[i].id, tab: 0),
                  scale: .96,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(fit: StackFit.expand, children: [
                      FoodImage(restaurants.firstWhere((r) => tiles[i].match!.contains(r.cuisine)).cover, cache: 520),
                      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center, colors: [Color(0xB30F0C06), Color(0x000F0C06)]))),
                      Positioned(left: 14, bottom: 11, child: Text(tiles[i].label, style: serif(18, w: FontWeight.w500, color: Colors.white, ls: 0))),
                    ]),
                  ),
                ),
              ),
          ],
        ),
        const SectionHeader('Top rated'),
        for (var i = 0; i < top.length; i++) RestRow(top[i], index: i),
      ],
    );
  }
}

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});
  static final _past = [
    ('smoke', 'Sat, 24 Oct', {'smk1': 1, 'smk9': 1, 'smk10': 1}),
    ('nori', 'Tue, 20 Oct', {'nor2': 1, 'nor8': 1, 'nor1': 1}),
    ('saffron', 'Sun, 11 Oct', {'saf1': 1, 'saf6': 2, 'saf4': 1}),
  ];
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final p = app.placed;
          return ListView(
            padding: _pad(context),
            physics: const BouncingScrollPhysics(),
            children: [
              Reveal(child: Text('Your orders', style: serif(31, ls: -.8))),
              const SizedBox(height: 18),
              if (p != null)
                Reveal(
                  index: 1,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: card(r: 26, ring: C.gold, shadow: true),
                    child: Column(children: [
                      Row(children: [
                        SizedBox(width: 48, height: 48, child: FoodImage(restIndex[p.restaurantId]!.thumb, radius: BorderRadius.circular(16), cache: 200)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(restIndex[p.restaurantId]!.name, style: sans(14.5, w: FontWeight.w800)), Text('Order ${p.id} · On the way', style: sans(12, color: C.mute))])),
                        const _LiveDot(),
                      ]),
                      const SizedBox(height: 12),
                      Container(height: 1, color: C.line),
                      const SizedBox(height: 12),
                      Row(children: [
                        Text('${p.itemsLabel} · ', style: sans(12.5, color: C.mute)),
                        Text(inr(p.pay), style: sans(14, w: FontWeight.w800)),
                        const Spacer(),
                        _SmallBtn('Track', () => Navigator.of(context).push(softRoute(const TrackingScreen(fresh: false)))),
                      ]),
                    ]),
                  ),
                ),
              SectionHeader('Past orders', top: p != null ? 24 : 0),
              for (var i = 0; i < _past.length; i++)
                Reveal(
                  index: i + 2,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: card(r: 26),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        SizedBox(width: 48, height: 48, child: FoodImage(restIndex[_past[i].$1]!.thumb, radius: BorderRadius.circular(16), cache: 200)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(restIndex[_past[i].$1]!.name, style: sans(14.5, w: FontWeight.w800)), Text('${_past[i].$2} · Delivered', style: sans(12, color: C.mute))])),
                      ]),
                      const SizedBox(height: 10),
                      Text(_past[i].$3.entries.map((e) => '${e.value}× ${dishIndex[e.key]!.name}').join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: sans(12.5, color: C.mute)),
                      const SizedBox(height: 10),
                      Row(children: [
                        Text(inr(_past[i].$3.entries.fold<int>(0, (a, e) => a + dishIndex[e.key]!.price * e.value)), style: sans(14, w: FontWeight.w800)),
                        const Spacer(),
                        _SmallBtn('Reorder', () {
                          app.cart
                            ..clear()
                            ..addAll(_past[i].$3);
                          app.set();
                          openCart(context);
                        }),
                      ]),
                    ]),
                  ),
                ),
            ],
          );
        },
      );
}

class _SmallBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SmallBtn(this.label, this.onTap);
  @override
  Widget build(BuildContext context) => Press(
        onTap: onTap,
        child: Container(height: 34, padding: const EdgeInsets.symmetric(horizontal: 18), alignment: Alignment.center, decoration: BoxDecoration(color: C.forest, borderRadius: BorderRadius.circular(17)), child: Text(label, style: sans(12.5, w: FontWeight.w700, color: C.cream))),
      );
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: C.goldSoft, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(animation: _c, builder: (_, __) => Container(width: 7, height: 7, decoration: BoxDecoration(color: C.gold, shape: BoxShape.circle, boxShadow: [BoxShadow(color: C.gold.withValues(alpha: .6 * (1 - _c.value)), spreadRadius: 8 * _c.value)]))),
          const SizedBox(width: 7),
          Text('Live', style: sans(12, w: FontWeight.w800, color: const Color(0xFF6D4E17))),
        ]),
      );
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) => ListView(
        padding: _pad(context),
        physics: const BouncingScrollPhysics(),
        children: [
          Reveal(
            child: Row(children: [
              Container(width: 70, height: 70, alignment: Alignment.center, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF2C5446), C.forestDeep])), child: Text('AM', style: serif(22, w: FontWeight.w500, color: C.gold2, ls: 1))),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Aarav Mehta', style: serif(26, w: FontWeight.w500)), Text('aarav@foodex.app', style: sans(13, color: C.mute))]),
            ]),
          ),
          const SizedBox(height: 22),
          Reveal(
            index: 1,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF25473A), Color(0xFF132A21)], begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: C.forestDeep.withValues(alpha: .9), blurRadius: 36, offset: const Offset(0, 26), spreadRadius: -22)]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('FOODEX WALLET', style: sans(11, w: FontWeight.w700, color: C.gold2, ls: 1.6)),
                const SizedBox(height: 6),
                Text('₹350.00', style: serif(34, color: C.cream, ls: -.5)),
                const SizedBox(height: 6),
                Text('Gold member · 240 points to your next reward', style: sans(12.5, color: C.cream.withValues(alpha: .65))),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Reveal(
            index: 2,
            child: Container(
              decoration: card(r: 26),
              child: Column(children: [
                for (final (i, e) in [
                  (Icons.place_outlined, 'Saved addresses', '2'),
                  (Icons.credit_card_rounded, 'Payment methods', 'UPI · Card'),
                  (Icons.local_offer_outlined, 'Offers & rewards', '3 new'),
                  (Icons.favorite_border_rounded, 'Favourites', '${app.favs.length}'),
                  (Icons.help_outline_rounded, 'Help & support', ''),
                  (Icons.settings_outlined, 'Settings', ''),
                ].indexed)
                  Press(
                    onTap: () => toast(context, 'Coming soon'),
                    scale: .98,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(border: i == 5 ? null : const Border(bottom: BorderSide(color: C.line))),
                      child: Row(children: [Icon(e.$1, size: 20, color: C.gold), const SizedBox(width: 14), Expanded(child: Text(e.$2, style: sans(14, w: FontWeight.w700))), Text(e.$3, style: sans(12, w: FontWeight.w600, color: C.mute))]),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      );
}
