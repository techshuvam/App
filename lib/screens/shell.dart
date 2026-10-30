import 'package:flutter/material.dart';
import '../nav.dart';
import '../state.dart';
import '../theme.dart';
import 'home.dart';
import 'tabs.dart';

class Shell extends StatelessWidget {
  const Shell({super.key});
  static const _pages = [HomeTab(), ExploreTab(), OrdersTab(), ProfileTab()];
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: C.paper,
      body: Stack(children: [
        ListenableBuilder(
          listenable: app,
          builder: (_, __) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: curve,
            transitionBuilder: (c, a) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0, .02), end: Offset.zero).animate(a), child: c)),
            child: KeyedSubtree(key: ValueKey(app.tab), child: _pages[app.tab]),
          ),
        ),
        Positioned(left: 18, right: 18, bottom: 100 + bottom, child: const CartBar()),
        Positioned(left: 18, right: 18, bottom: 22 + bottom, child: const FloatNav()),
      ]),
    );
  }
}
