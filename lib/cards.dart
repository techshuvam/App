import 'package:flutter/material.dart';
import 'models.dart';
import 'nav.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets.dart';

Widget _favBtn(Restaurant r, {double size = 30}) => ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final on = app.favs.contains(r.id);
        return Press(
          scale: .8,
          onTap: () {
            app.toggleFav(r.id);
            toast(context, on ? 'Removed from favourites' : 'Saved to favourites', icon: Icons.favorite_rounded);
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .9), shape: BoxShape.circle),
            child: TweenAnimationBuilder<double>(
              key: ValueKey(on),
              tween: Tween(begin: on ? .6 : 1, end: 1),
              duration: const Duration(milliseconds: 450),
              curve: Curves.elasticOut,
              builder: (_, s, child) => Transform.scale(scale: s, child: child),
              child: Icon(on ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 16, color: on ? C.rose : C.ink),
            ),
          ),
        );
      },
    );

/// Large carousel card.
class RestCard extends StatelessWidget {
  final Restaurant r;
  final int index;
  const RestCard(this.r, {super.key, this.index = 0});
  @override
  Widget build(BuildContext context) => Reveal(
        index: index,
        child: Press(
          onTap: () => openRestaurant(context, r),
          scale: .97,
          child: Container(
            width: 202,
            decoration: card(r: 26, shadow: true),
            clipBehavior: Clip.antiAlias,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 140,
                child: Stack(fit: StackFit.expand, children: [
                  FoodImage(r.cover),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .9), borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [const StarIcon(size: 13), const SizedBox(width: 3), Text('${r.rating}', style: sans(11.5, w: FontWeight.w800))]),
                    ),
                  ),
                  Positioned(right: 9, top: 9, child: _favBtn(r)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: sans(15, w: FontWeight.w800, ls: -.1)),
                  const SizedBox(height: 2),
                  Text(r.sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: sans(12, color: C.mute)),
                  const SizedBox(height: 10),
                  Row(children: [MetaItem(Icons.schedule_rounded, '${r.time} min'), const SizedBox(width: 12), MetaItem(Icons.place_outlined, r.dist)]),
                ]),
              ),
            ]),
          ),
        ),
      );
}

/// Compact dish tile for horizontal rails.
class DishTile extends StatelessWidget {
  final Dish d;
  final int index;
  const DishTile(this.d, {super.key, this.index = 0});
  @override
  Widget build(BuildContext context) => Reveal(
        index: index,
        child: Press(
          onTap: () => openDish(context, d),
          scale: .97,
          child: SizedBox(
            width: 150,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 150,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: const Color(0xFF3C2D0F).withValues(alpha: .35), blurRadius: 26, offset: const Offset(0, 18), spreadRadius: -16)]),
                child: Stack(fit: StackFit.expand, children: [
                  FoodImage(d.img, align: d.align, radius: BorderRadius.circular(24), cache: 500),
                  Positioned(right: 8, bottom: 8, child: DishControl(d, square: true)),
                ]),
              ),
              const SizedBox(height: 10),
              Text(d.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: sans(13.5, w: FontWeight.w700, height: 1.25)),
              const SizedBox(height: 2),
              Text(restIndex[d.rid]!.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: sans(11.5, color: C.mute)),
              const SizedBox(height: 4),
              Text(inr(d.price), style: sans(13, w: FontWeight.w800)),
            ]),
          ),
        ),
      );
}

/// Full-width restaurant row.
class RestRow extends StatelessWidget {
  final Restaurant r;
  final int index;
  const RestRow(this.r, {super.key, this.index = 0});
  @override
  Widget build(BuildContext context) => Reveal(
        index: index,
        child: Press(
          onTap: () => openRestaurant(context, r),
          scale: .98,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: card(r: 26),
            child: Row(children: [
              SizedBox(width: 96, height: 96, child: FoodImage(r.cover, radius: BorderRadius.circular(19), cache: 360)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: sans(15.5, w: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(r.sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: sans(12, color: C.mute)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const StarIcon(size: 13),
                    const SizedBox(width: 3),
                    Text('${r.rating}', style: sans(12, w: FontWeight.w700, color: C.ink2)),
                    const SizedBox(width: 11),
                    MetaItem(Icons.schedule_rounded, '${r.time} min'),
                    const SizedBox(width: 11),
                    Flexible(child: MetaItem(Icons.place_outlined, r.dist)),
                  ]),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: C.goldSoft, borderRadius: BorderRadius.circular(8)),
                    child: Text(r.offer, maxLines: 1, overflow: TextOverflow.ellipsis, style: sans(11, w: FontWeight.w700, color: const Color(0xFF7D5B1F))),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      );
}

/// Dish row used in search results.
class DishRow extends StatelessWidget {
  final Dish d;
  final int index;
  const DishRow(this.d, {super.key, this.index = 0});
  @override
  Widget build(BuildContext context) => Reveal(
        index: index,
        child: Press(
          onTap: () => openDish(context, d),
          scale: .98,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: card(r: 26),
            child: Row(children: [
              SizedBox(width: 84, height: 84, child: FoodImage(d.img, align: d.align, radius: BorderRadius.circular(19), cache: 300)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [VegDot(d.veg), const SizedBox(width: 7), Expanded(child: Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: sans(14.5, w: FontWeight.w800)))]),
                  const SizedBox(height: 2),
                  Text(restIndex[d.rid]!.name, style: sans(12, color: C.mute)),
                  const SizedBox(height: 10),
                  Row(children: [Text(inr(d.price), style: sans(15, w: FontWeight.w800)), const Spacer(), DishControl(d)]),
                ]),
              ),
            ]),
          ),
        ),
      );
}
