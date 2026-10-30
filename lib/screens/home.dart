import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../cards.dart';
import '../models.dart';
import '../nav.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _q = TextEditingController();
  final _scroll = ScrollController();
  final _allKey = GlobalKey();

  List<Restaurant> get _filtered {
    final c = cravings.firstWhere((x) => x.id == app.craving, orElse: () => cravings.first);
    return c.match == null ? restaurants : restaurants.where((r) => c.match!.contains(r.cuisine)).toList();
  }

  List<Dish> get _trending {
    final out = <Dish>[];
    for (final r in _filtered) {
      out.addAll(r.menu.where((d) => d.tag == 'Bestseller' || d.tag == 'Chef’s pick' || d.tag == 'Popular'));
    }
    return out.take(10).toList();
  }

  @override
  void dispose() {
    _q.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final q = _q.text.trim().toLowerCase();
        return ListView(
          controller: _scroll,
          padding: EdgeInsets.fromLTRB(22, top + 14, 22, 190),
          physics: const BouncingScrollPhysics(),
          children: [
            Reveal(
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Text('DELIVER TO', style: sans(11.5, w: FontWeight.w700, color: C.mute, ls: .5)), const SizedBox(width: 3), const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: C.mute)]),
                    const SizedBox(height: 3),
                    Text.rich(TextSpan(children: [
                      TextSpan(text: addresses[app.addr].$1, style: sans(15.5, w: FontWeight.w700)),
                      TextSpan(text: ' · ${addresses[app.addr].$2.split('· ')[1].split(',')[0]}', style: sans(15.5, w: FontWeight.w600, color: C.mute)),
                    ])),
                  ]),
                ),
                RoundBtn(Icons.notifications_none_rounded, dot: true, onTap: () => toast(context, 'You’re all caught up')),
              ]),
            ),
            const SizedBox(height: 26),
            Reveal(
              index: 1,
              child: Text.rich(TextSpan(children: [
                TextSpan(text: 'What are you\n', style: serif(35, height: 1.08, ls: -.9)),
                TextSpan(text: 'craving?', style: serif(35, height: 1.08, ls: -.9, color: C.forest2, style: FontStyle.italic)),
              ])),
            ),
            const SizedBox(height: 20),
            Reveal(
              index: 2,
              child: Row(children: [
                Expanded(
                  child: Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(27), border: Border.all(color: C.line), boxShadow: cardShadow),
                    child: Row(children: [
                      const Icon(Icons.search_rounded, size: 21, color: C.mute),
                      const SizedBox(width: 11),
                      Expanded(
                        child: TextField(
                          controller: _q,
                          onChanged: (_) => setState(() {}),
                          cursorColor: C.gold,
                          style: sans(14, w: FontWeight.w500),
                          decoration: InputDecoration.collapsed(hintText: 'Search dishes, restaurants', hintStyle: sans(14, color: C.mute)),
                        ),
                      ),
                      if (q.isNotEmpty) GestureDetector(onTap: () => setState(_q.clear), child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: C.line, shape: BoxShape.circle), child: const Icon(Icons.close_rounded, size: 12))),
                    ]),
                  ),
                ),
                const SizedBox(width: 10),
                Press(
                  onTap: () => toast(context, 'Filters: veg · rating · delivery time', icon: Icons.tune_rounded),
                  scale: .9,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(color: C.forest, shape: BoxShape.circle, boxShadow: [BoxShadow(color: C.forest.withValues(alpha: .8), blurRadius: 24, offset: const Offset(0, 14), spreadRadius: -12)]),
                    child: const Icon(Icons.tune_rounded, size: 21, color: C.gold2),
                  ),
                ),
              ]),
            ),
            if (q.isEmpty) ...[
              const SizedBox(height: 20),
              Reveal(
                index: 3,
                child: SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: cravings.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 9),
                    itemBuilder: (_, i) => _Chip(cravings[i].label, app.craving == cravings[i].id, () => app.set(craving: cravings[i].id)),
                  ),
                ),
              ),
            ],
            if (q.isNotEmpty) ..._results(q) else ..._browse(context),
          ],
        );
      },
    );
  }

  List<Widget> _results(String q) {
    final ds = [for (final r in restaurants) ...r.menu].where((d) => '${d.name} ${d.desc} ${d.cat} ${restIndex[d.rid]!.cuisine}'.toLowerCase().contains(q)).toList();
    final rs = restaurants.where((r) => '${r.name} ${r.sub} ${r.cuisine}'.toLowerCase().contains(q)).toList();
    if (ds.isEmpty && rs.isEmpty) {
      return [
        const SizedBox(height: 60),
        Center(child: Column(children: [
          const Icon(Icons.search_off_rounded, size: 34, color: C.mute),
          const SizedBox(height: 10),
          Text('No matches for “${_q.text.trim()}”', style: serif(20, w: FontWeight.w500)),
          const SizedBox(height: 6),
          Text('Try pizza, sushi, burger or dessert.', style: sans(13, color: C.mute)),
        ])),
      ];
    }
    return [
      if (rs.isNotEmpty) ...[const SectionHeader('Restaurants'), for (var i = 0; i < rs.length; i++) RestRow(rs[i], index: i)],
      if (ds.isNotEmpty) ...[const SectionHeader('Dishes'), for (var i = 0; i < math.min(ds.length, 12); i++) DishRow(ds[i], index: i)],
    ];
  }

  List<Widget> _browse(BuildContext context) {
    final rs = _filtered;
    final top = ([...rs]..sort((a, b) => b.rating.compareTo(a.rating))).take(6).toList();
    final tr = _trending;
    return [
      const SizedBox(height: 24),
      Reveal(index: 4, child: _PickCard(dish: dishIndex['oro2']!)),
      SectionHeader('Popular near you', action: 'See all', onAction: () => Scrollable.ensureVisible(_allKey.currentContext!, duration: const Duration(milliseconds: 700), curve: curve, alignment: .05)),
      _rail(height: 248, children: [for (var i = 0; i < top.length; i++) RestCard(top[i], index: i)]),
      const SectionHeader('Trending dishes', top: 6),
      _rail(height: 246, children: [for (var i = 0; i < tr.length; i++) DishTile(tr[i], index: i)]),
      Padding(key: _allKey, padding: EdgeInsets.zero, child: SectionHeader('All restaurants', action: '${rs.length} places')),
      for (var i = 0; i < rs.length; i++) RestRow(rs[i], index: i),
    ];
  }

  Widget _rail({required double height, required List<Widget> children}) => SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.only(bottom: 18),
          physics: const BouncingScrollPhysics(),
          itemCount: children.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, i) => children[i],
        ),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;
  const _Chip(this.label, this.on, this.onTap);
  @override
  Widget build(BuildContext context) => Press(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: curve,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? C.forest : Colors.white,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: on ? C.forest : C.line),
            boxShadow: on ? [BoxShadow(color: C.forest.withValues(alpha: .7), blurRadius: 16, offset: const Offset(0, 8), spreadRadius: -8)] : null,
          ),
          child: Text(label, style: sans(13, w: FontWeight.w600, color: on ? C.cream : C.ink2)),
        ),
      );
}

/// "Tonight's pick" hero with real 3D tilt: follows pointer, sways when idle.
class _PickCard extends StatefulWidget {
  final Dish dish;
  const _PickCard({required this.dish});
  @override
  State<_PickCard> createState() => _PickCardState();
}

class _PickCardState extends State<_PickCard> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat();
  Offset _cur = Offset.zero;
  Offset? _pointer;

  @override
  void initState() {
    super.initState();
    _t.addListener(_step);
  }

  void _step() {
    final ph = _t.value * math.pi * 2;
    final target = _pointer ?? Offset(math.sin(ph) * .42, math.cos(ph * 1.0) * .22);
    setState(() => _cur += (target - _cur) * .09);
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  void _move(Offset p, Size s) => _pointer = Offset((p.dx / s.width - .5) * 2, (p.dy / s.height - .5) * 2);

  @override
  Widget build(BuildContext context) {
    final d = widget.dish;
    final ph = _t.value * math.pi * 2;
    return LayoutBuilder(builder: (context, c) {
      final size = Size(c.maxWidth, 206);
      return MouseRegion(
        onHover: (e) => _move(e.localPosition, size),
        onExit: (_) => _pointer = null,
        child: Listener(
          onPointerMove: (e) => _move(e.localPosition, size),
          onPointerUp: (_) => _pointer = null,
          onPointerCancel: (_) => _pointer = null,
          child: Press(
            onTap: () => openDish(context, d),
            scale: .985,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, .0012)
                ..rotateY(_cur.dx * .16)
                ..rotateX(-_cur.dy * .16),
              child: Container(
                height: 206,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(colors: [Color(0xFF21443A), C.forestDeep, Color(0xFF0F2119)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [BoxShadow(color: C.forestDeep.withValues(alpha: .85), blurRadius: 40, offset: Offset(_cur.dx * -10, 26 + _cur.dy * -6), spreadRadius: -20)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Stack(children: [
                    Positioned(right: -60 + _cur.dx * -10, top: -70, child: Container(width: 260, height: 260, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [C.gold2.withValues(alpha: .32), C.gold2.withValues(alpha: 0)])))),
                    Positioned.fill(child: CustomPaint(painter: _HatchPainter())),
                    Positioned(
                      left: 22 + _cur.dx * 4,
                      top: 20,
                      bottom: 20,
                      width: c.maxWidth * .52,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: .16))),
                          child: Text('TONIGHT’S PICK', style: sans(10.5, w: FontWeight.w700, color: C.gold2, ls: 1.2)),
                        ),
                        const SizedBox(height: 13),
                        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('Truffle\nMushroom Pizza', style: serif(26, color: C.cream, height: 1.05, ls: -.6))),
                        const SizedBox(height: 6),
                        Text('Oro Pizzeria · 25 min', style: sans(12, color: C.cream.withValues(alpha: .62))),
                        const Spacer(),
                        Row(children: [
                          Text(inr(d.price), style: serif(25, w: FontWeight.w500, color: C.cream, ls: 0)),
                          const SizedBox(width: 12),
                          Container(width: 38, height: 38, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [C.gold2, C.gold])), child: const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF1B1407))),
                        ]),
                      ]),
                    ),
                    Positioned(
                      right: -46 + _cur.dx * -14,
                      top: 103 - 108 + math.sin(ph * 2) * 6 + _cur.dy * -6,
                      child: Transform.rotate(
                        angle: _cur.dx * .25 + ph * .0,
                        child: Container(
                          width: 216,
                          height: 216,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: C.gold2.withValues(alpha: .4), width: 1),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .6), blurRadius: 36, offset: const Offset(0, 30), spreadRadius: -10), BoxShadow(color: Colors.white.withValues(alpha: .06), spreadRadius: 7)],
                          ),
                          child: ClipOval(child: Transform.scale(scale: 1.22, child: Image.asset(d.img, fit: BoxFit.cover, cacheWidth: 600))),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: .025)
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width; x += 14) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height * .47, 0), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
