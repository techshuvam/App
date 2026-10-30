import 'package:flutter/painting.dart';

class Dish {
  final String id, rid, name, desc, img, cat;
  final int price;
  final bool veg, hot;
  final String? tag;
  final Alignment align;
  Dish({
    required this.id,
    required this.rid,
    required this.name,
    required this.desc,
    required this.price,
    required this.img,
    required this.cat,
    this.veg = false,
    this.hot = false,
    this.tag,
    this.align = Alignment.center,
  });
}

class Restaurant {
  final String id, name, sub, cuisine, reviews, time, dist, cover, thumb, offer;
  final double rating;
  final int fee;
  final List<String> cats;
  final List<Dish> menu;
  Restaurant({
    required this.id,
    required this.name,
    required this.sub,
    required this.cuisine,
    required this.rating,
    required this.reviews,
    required this.time,
    required this.fee,
    required this.dist,
    required this.cover,
    required this.thumb,
    required this.offer,
    required this.cats,
    required this.menu,
  });

  /// Dishes shown under a menu tab. "Popular" also surfaces bestsellers.
  List<Dish> section(String cat) => menu
      .where((d) => cat == 'Popular' ? (d.cat == 'Popular' || d.tag == 'Bestseller') : d.cat == cat)
      .toList();
}

class Craving {
  final String id, label;
  final List<String>? match;
  const Craving(this.id, this.label, [this.match]);
}

class PlacedOrder {
  final String id, restaurantId, method;
  final Map<String, int> items;
  final int pay;
  const PlacedOrder({required this.id, required this.restaurantId, required this.items, required this.pay, required this.method});
  int get count => items.values.fold(0, (a, b) => a + b);
  String get itemsLabel => '$count item${count == 1 ? '' : 's'}';
}

class Totals {
  final int sub, fee, svc, tax, disc, total, tip, count;
  const Totals(this.sub, this.fee, this.svc, this.tax, this.disc, this.total, this.tip, this.count);
  int get pay => total + tip;
}
