import 'package:flutter/foundation.dart';
import 'data.dart';
export 'data.dart' show restaurants;
import 'models.dart';

final Map<String, Dish> dishIndex = {for (final r in restaurants) for (final d in r.menu) d.id: d};
final Map<String, Restaurant> restIndex = {for (final r in restaurants) r.id: r};

const cravings = [
  Craving('chef', 'Chef’s picks'),
  Craving('Pizza', 'Pizza', ['Italian']),
  Craving('Bowls', 'Bowls', ['Japanese', 'Healthy', 'Asian']),
  Craving('Burgers', 'Burgers', ['American', 'Grill']),
  Craving('Indian', 'Indian', ['Indian']),
  Craving('Desserts', 'Desserts', ['Dessert', 'Beverages']),
  Craving('Brunch', 'Brunch', ['Café']),
  Craving('Seafood', 'Seafood', ['Seafood', 'Mexican']),
];

class Promo {
  final String label;
  final int Function(int sub) calc;
  const Promo(this.label, this.calc);
}

final promos = <String, Promo>{
  'FOODEX': Promo('10% off, up to ₹150', (s) => (s * .1).round().clamp(0, 150)),
  'WELCOME50': Promo('₹50 off your first order', (s) => s >= 300 ? 50 : 0),
};

const addresses = [
  ('Home', 'Home · 12 Palm Street, Apt 4B', 'Arrives in 25–30 min'),
  ('Office', 'Office · Level 9, Orchid Tower, MG Road', 'Arrives in 30–35 min'),
];

class AppState extends ChangeNotifier {
  final Map<String, int> cart = {};
  final Set<String> favs = {'oro'};
  String? promo;
  int tip = 20;
  String method = 'upi';
  String upiApp = 'GPay';
  int addr = 0;
  bool skipCutlery = true;
  String craving = 'chef';
  PlacedOrder? placed;
  int tab = 0;

  int qty(String id) => cart[id] ?? 0;
  List<MapEntry<Dish, int>> get lines => [for (final e in cart.entries) if (e.value > 0) MapEntry(dishIndex[e.key]!, e.value)];
  int get count => cart.values.fold(0, (a, b) => a + b);
  Restaurant? get cartRestaurant => lines.isEmpty ? null : restIndex[lines.first.key.rid];

  Totals get totals {
    final sub = lines.fold<int>(0, (a, l) => a + l.key.price * l.value);
    final r = cartRestaurant;
    final fee = r?.fee ?? 0, svc = r == null ? 0 : 25, tax = (sub * .05).round();
    final disc = promo == null ? 0 : promos[promo]!.calc(sub);
    return Totals(sub, fee, svc, tax, disc, sub + fee + svc + tax - disc, tip, count);
  }

  /// True when adding [d] would mix restaurants in one cart.
  bool conflicts(Dish d) => cart.isNotEmpty && cartRestaurant != null && cartRestaurant!.id != d.rid;

  void setQty(String id, int q) {
    if (q <= 0) {
      cart.remove(id);
    } else {
      cart[id] = q;
    }
    if (cart.isEmpty) promo = null;
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    promo = null;
    notifyListeners();
  }

  void loadDemo() {
    cart
      ..clear()
      ..addAll({'oro1': 1, 'oro2': 1, 'oro9': 1});
    promo = null;
    notifyListeners();
  }

  void toggleFav(String id) {
    favs.contains(id) ? favs.remove(id) : favs.add(id);
    notifyListeners();
  }

  void set({String? method, String? upiApp, int? tip, int? addr, bool? skipCutlery, String? craving, int? tab, String? promo, bool clearPromo = false}) {
    this.method = method ?? this.method;
    this.upiApp = upiApp ?? this.upiApp;
    this.tip = tip ?? this.tip;
    this.addr = addr ?? this.addr;
    this.skipCutlery = skipCutlery ?? this.skipCutlery;
    this.craving = craving ?? this.craving;
    this.tab = tab ?? this.tab;
    if (clearPromo) this.promo = null;
    if (promo != null) this.promo = promo;
    notifyListeners();
  }

  void place(String methodLabel) {
    final t = totals;
    placed = PlacedOrder(id: 'FX-4821', restaurantId: cartRestaurant!.id, items: {for (final l in lines) l.key.id: l.value}, pay: t.pay, method: methodLabel);
    notifyListeners();
  }
}

final app = AppState();
