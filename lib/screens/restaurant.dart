import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models.dart';
import '../nav.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant r;
  const RestaurantScreen(this.r, {super.key});
  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final _scroll = ScrollController();
  final _current = ValueNotifier<int>(0);
  final _collapsed = ValueNotifier<bool>(false);
  late final List<String> _cats = widget.r.cats.where((c) => widget.r.section(c).isNotEmpty).toList();
  late final List<GlobalKey> _keys = [for (final _ in _cats) GlobalKey()];
  static const _expanded = 330.0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  double _coverHeight(BuildContext c) => MediaQuery.paddingOf(c).top + kToolbarHeight + 52;

  void _onScroll() {
    _collapsed.value = _scroll.hasClients && _scroll.offset > _expanded - 120;
    final limit = _coverHeight(context) + 40;
    var cur = 0;
    for (var i = 0; i < _keys.length; i++) {
      final ctx = _keys[i].currentContext;
      if (ctx == null) continue;
      final dy = (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy;
      if (dy <= limit) cur = i;
    }
    if (_current.value != cur) _current.value = cur;
  }

  void _jump(int i) {
    final ctx = _keys[i].currentContext;
    if (ctx == null) return;
    final vh = MediaQuery.sizeOf(context).height;
    Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 650), curve: curve, alignment: (_coverHeight(context) + 6) / vh);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _current.dispose();
    _collapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ValueListenableBuilder<bool>(
      valueListenable: _collapsed,
      builder: (context, collapsed, child) => AnnotatedRegion<SystemUiOverlayStyle>(value: collapsed ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light, child: child!),
      child: Scaffold(
        backgroundColor: C.paper,
        body: Stack(children: [
          CustomScrollView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                stretch: true,
                expandedHeight: _expanded,
                backgroundColor: C.paper,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                leadingWidth: 70,
                leading: Padding(padding: const EdgeInsets.only(left: 18), child: Center(child: RoundBtn(Icons.arrow_back_rounded, glass: true, size: 42, onTap: () => Navigator.pop(context)))),
                title: ValueListenableBuilder<bool>(
                  valueListenable: _collapsed,
                  builder: (_, c, __) => AnimatedOpacity(opacity: c ? 1 : 0, duration: const Duration(milliseconds: 250), child: Text(r.name, style: serif(18, w: FontWeight.w500, ls: -.2))),
                ),
                centerTitle: true,
                actions: [
                  ListenableBuilder(
                    listenable: app,
                    builder: (c, _) {
                      final on = app.favs.contains(r.id);
                      return RoundBtn(on ? Icons.favorite_rounded : Icons.favorite_border_rounded, glass: true, size: 42, color: on ? C.rose : C.ink, onTap: () {
                        app.toggleFav(r.id);
                        toast(context, on ? 'Removed from favourites' : 'Saved to favourites', icon: Icons.favorite_rounded);
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  RoundBtn(Icons.ios_share_rounded, glass: true, size: 42, onTap: () => toast(context, 'Link copied', icon: Icons.link_rounded)),
                  const SizedBox(width: 18),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(fit: StackFit.expand, children: [
                    FoodImage(r.cover, cache: 1000),
                    const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x80100C06), Color(0x00100C06), Color(0x47100C06)], stops: [0, .38, 1]))),
                  ]),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(24),
                  child: Container(height: 24, decoration: const BoxDecoration(color: C.paper, borderRadius: BorderRadius.vertical(top: Radius.circular(28)))),
                ),
              ),
              SliverToBoxAdapter(child: _Info(r)),
              SliverPersistentHeader(pinned: true, delegate: _TabsDelegate(_cats, _current, _jump)),
              for (var i = 0; i < _cats.length; i++)
                SliverToBoxAdapter(
                  child: Padding(
                    key: _keys[i],
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(padding: const EdgeInsets.only(top: 22, bottom: 4), child: Text(_cats[i], style: serif(20, w: FontWeight.w500, ls: -.2))),
                      for (final (j, d) in r.section(_cats[i]).indexed) _MenuItem(d, last: j == r.section(_cats[i]).length - 1),
                    ]),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 170 + bottom)),
            ],
          ),
          Positioned(left: 18, right: 18, bottom: 28 + bottom, child: const CartBar()),
        ]),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final Restaurant r;
  const _Info(this.r);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Reveal(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.name, style: serif(32, height: 1.05, ls: -.9)), const SizedBox(height: 6), Text(r.sub, style: sans(13, color: C.mute))])),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: C.ok.withValues(alpha: .1), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [_Blink(), const SizedBox(width: 6), Text('Open now', style: sans(11.5, w: FontWeight.w800, color: C.ok))]),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          Reveal(
            index: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _Stat(Icons.star_rounded, '${r.rating}', extra: ' (${r.reviews})'),
                const SizedBox(width: 9),
                _Stat(Icons.schedule_rounded, '${r.time} min'),
                const SizedBox(width: 9),
                _Stat(Icons.two_wheeler_rounded, inr(r.fee)),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          Reveal(
            index: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [C.goldSoft, Color(0xFFFBF3E0)])),
              child: Row(children: [const Icon(Icons.local_offer_outlined, size: 17, color: Color(0xFF8A6420)), const SizedBox(width: 10), Expanded(child: Text(r.offer, style: sans(12.5, w: FontWeight.w700, color: const Color(0xFF6D4E17))))]),
            ),
          ),
        ]),
      );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String text;
  final String extra;
  const _Stat(this.icon, this.text, {this.extra = ''});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: card(r: 16),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: C.gold),
          const SizedBox(width: 6),
          Text(text, style: sans(12.5, w: FontWeight.w700)),
          if (extra.isNotEmpty) Text(extra, style: sans(12.5, w: FontWeight.w600, color: C.mute)),
        ]),
      );
}

class _Blink extends StatefulWidget {
  @override
  State<_Blink> createState() => _BlinkState();
}

class _BlinkState extends State<_Blink> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: Tween(begin: 1.0, end: .25).animate(_c), child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: C.ok, shape: BoxShape.circle)));
}

class _TabsDelegate extends SliverPersistentHeaderDelegate {
  final List<String> cats;
  final ValueNotifier<int> current;
  final void Function(int) onTap;
  _TabsDelegate(this.cats, this.current, this.onTap);
  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;
  @override
  bool shouldRebuild(covariant _TabsDelegate old) => old.cats != cats;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(
        decoration: const BoxDecoration(color: C.paper, border: Border(bottom: BorderSide(color: C.line))),
        child: ValueListenableBuilder<int>(
          valueListenable: current,
          builder: (_, cur, __) => ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            separatorBuilder: (_, __) => const SizedBox(width: 26),
            itemCount: cats.length,
            itemBuilder: (_, i) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Stack(alignment: Alignment.bottomCenter, children: [
                Center(child: AnimatedDefaultTextStyle(duration: const Duration(milliseconds: 250), style: sans(14, w: FontWeight.w700, color: cur == i ? C.ink : C.mute), child: Text(cats[i]))),
                AnimatedContainer(duration: const Duration(milliseconds: 400), curve: curve, height: 2.5, width: cur == i ? 22 : 0, decoration: BoxDecoration(color: C.gold, borderRadius: BorderRadius.circular(2))),
              ]),
            ),
          ),
        ),
      );
}

class _MenuItem extends StatelessWidget {
  final Dish d;
  final bool last;
  const _MenuItem(this.d, {required this.last});
  @override
  Widget build(BuildContext context) => Press(
        onTap: () => openDish(context, d),
        scale: .985,
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
          decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: C.line))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [VegDot(d.veg), if (d.tag != null) ...[const SizedBox(width: 8), TagChip(d.tag!)]]),
                const SizedBox(height: 7),
                Text(d.name, style: sans(15.5, w: FontWeight.w800, ls: -.1)),
                const SizedBox(height: 6),
                Text(d.desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: sans(12.5, color: C.mute, height: 1.5)),
                const SizedBox(height: 10),
                Row(children: [Text(inr(d.price), style: sans(15, w: FontWeight.w800)), if (d.hot) ...[const SizedBox(width: 10), const TagChip('Spicy', spicy: true)]]),
              ]),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 112,
              height: 124,
              child: Stack(clipBehavior: Clip.none, children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: const Color(0xFF3C2D0F).withValues(alpha: .4), blurRadius: 22, offset: const Offset(0, 14), spreadRadius: -12)]),
                  child: FoodImage(d.img, align: d.align, radius: BorderRadius.circular(22), cache: 340),
                ),
                Positioned(bottom: -2, left: 0, right: 0, child: Center(child: DishControl(d))),
              ]),
            ),
          ]),
        ),
      );
}
