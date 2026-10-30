import 'package:flutter/material.dart';
import 'models.dart';
import 'screens/cart.dart';
import 'screens/dish_sheet.dart';
import 'screens/restaurant.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets.dart';

void openRestaurant(BuildContext c, Restaurant r) => Navigator.of(c).push(softRoute(RestaurantScreen(r)));
void openCart(BuildContext c) => Navigator.of(c).push(softRoute(const CartScreen()));
void openDish(BuildContext c, Dish d) => showDishSheet(c, d);

/// Floating "View cart" pill that slides up whenever the cart has items.
class CartBar extends StatelessWidget {
  const CartBar({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final n = app.count, show = n > 0;
          final t = app.totals;
          return IgnorePointer(
            ignoring: !show,
            child: AnimatedSlide(
              offset: show ? Offset.zero : const Offset(0, 3.2),
              duration: const Duration(milliseconds: 650),
              curve: show ? Curves.easeOutBack : Curves.easeInCubic,
              child: AnimatedOpacity(
                opacity: show ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Press(
                onTap: () => openCart(context),
                scale: .97,
                child: Container(
                  height: 66,
                  padding: const EdgeInsets.fromLTRB(24, 0, 10, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(33),
                    gradient: const LinearGradient(colors: [Color(0xFF25473A), C.forestDeep], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [BoxShadow(color: C.forest.withValues(alpha: .8), blurRadius: 34, offset: const Offset(0, 22), spreadRadius: -14)],
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('View cart', style: sans(15.5, w: FontWeight.w800, color: C.cream)),
                        const SizedBox(height: 1),
                        Text('$n item${n == 1 ? '' : 's'}${app.cartRestaurant != null ? ' · ${app.cartRestaurant!.name}' : ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: sans(12, color: C.cream.withValues(alpha: .62))),
                      ]),
                    ),
                    Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(23), gradient: const LinearGradient(colors: [C.gold2, C.gold])),
                      child: AnimatedMoney(t.sub, style: serif(18, w: FontWeight.w600, color: const Color(0xFF1B1407), ls: 0)),
                    ),
                  ]),
                ),
              ),
              ),
            ),
          );
        },
      );
}

/// Frosted floating tab bar with an expanding active pill.
class FloatNav extends StatelessWidget {
  const FloatNav({super.key});
  static const items = [
    (Icons.home_rounded, 'Home'),
    (Icons.explore_rounded, 'Explore'),
    (Icons.receipt_long_rounded, 'Orders'),
    (Icons.person_rounded, 'Profile'),
  ];
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) => Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .9),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: C.line),
            boxShadow: [BoxShadow(color: const Color(0xFF3C2D0F).withValues(alpha: .35), blurRadius: 40, offset: const Offset(0, 22), spreadRadius: -18)],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            for (var i = 0; i < items.length; i++) _NavItem(i, items[i].$1, items[i].$2, app.tab == i, i == 2 ? app.count : 0),
          ]),
        ),
      );
}

class _NavItem extends StatelessWidget {
  final int i;
  final IconData icon;
  final String label;
  final bool on;
  final int badge;
  const _NavItem(this.i, this.icon, this.label, this.on, this.badge);
  @override
  Widget build(BuildContext context) => Press(
        onTap: () => app.set(tab: i),
        scale: .92,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: curve,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: on ? C.forest : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: on ? [BoxShadow(color: C.forest.withValues(alpha: .7), blurRadius: 18, offset: const Offset(0, 10), spreadRadius: -8)] : null,
          ),
          child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 22, color: on ? C.cream : C.mute),
              AnimatedSize(
                duration: const Duration(milliseconds: 450),
                curve: curve,
                child: on ? Padding(padding: const EdgeInsets.only(left: 8), child: Text(label, style: sans(13.5, w: FontWeight.w700, color: C.cream))) : const SizedBox(),
              ),
            ]),
            if (badge > 0)
              Positioned(
                top: -4,
                right: on ? -12 : -9,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16),
                  height: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: C.gold, borderRadius: BorderRadius.circular(8)),
                  child: Text('$badge', style: sans(10, w: FontWeight.w800, color: const Color(0xFF1B1407))),
                ),
              ),
          ]),
        ),
      );
}
