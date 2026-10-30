import 'package:flutter/material.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'cart.dart';
import 'success.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _busy = false;
  final _shake = ValueNotifier<int>(0);

  static const _methods = [
    ('upi', 'UPI', 'Pay with any UPI app', null),
    ('card', 'Credit or debit card', '•••• 4242', Icons.credit_card_rounded),
    ('wallet', 'FoodEX Wallet', 'Balance ₹350', Icons.account_balance_wallet_outlined),
    ('cod', 'Cash on delivery', 'Pay your rider at the door', Icons.payments_outlined),
  ];

  Future<void> _pay() async {
    final t = app.totals;
    if (app.method == 'wallet' && t.pay > 350) {
      _shake.value++;
      toast(context, 'Wallet balance is low. Pick another method', icon: Icons.info_outline_rounded);
      return;
    }
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 1700));
    if (!mounted) return;
    final label = {'upi': 'UPI', 'card': 'Card •••• 4242', 'wallet': 'FoodEX Wallet', 'cod': 'Cash on delivery'}[app.method]!;
    app.place(label);
    Navigator.of(context).pushAndRemoveUntil(softRoute(const SuccessScreen()), (r) => r.isFirst);
    Future.delayed(const Duration(milliseconds: 900), app.clearCart);
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.paper,
        body: ListenableBuilder(
          listenable: app,
          builder: (context, _) {
            final t = app.totals, a = addresses[app.addr];
            return Column(children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(22, MediaQuery.paddingOf(context).top + 16, 22, 30),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const Reveal(child: ScreenTop('Payment')),
                    const SizedBox(height: 22),
                    Reveal(
                      index: 1,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                        decoration: card(r: 24),
                        child: Row(children: [
                          Container(width: 44, height: 44, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [C.gold2, C.gold])), child: const Icon(Icons.place_rounded, size: 20, color: Color(0xFF1B1407))),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('DELIVER TO', style: sans(11, w: FontWeight.w600, color: C.mute, ls: .5)),
                              AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: Text(a.$2, key: ValueKey(a.$2), style: sans(13.5, w: FontWeight.w800, height: 1.3))),
                              Text(a.$3, style: sans(12, w: FontWeight.w700, color: C.ok)),
                            ]),
                          ),
                          GestureDetector(
                            onTap: () {
                              app.set(addr: (app.addr + 1) % addresses.length);
                              toast(context, 'Delivery address updated', icon: Icons.place_rounded);
                            },
                            child: Text('Change', style: sans(13, w: FontWeight.w800, color: C.gold)),
                          ),
                        ]),
                      ),
                    ),
                    Reveal(index: 2, child: Padding(padding: const EdgeInsets.fromLTRB(2, 24, 2, 12), child: Text('Pay with', style: serif(19, w: FontWeight.w500, ls: -.2)))),
                    for (final (i, m) in _methods.indexed) ...[
                      Reveal(index: 3 + i, child: _Method(m.$1, m.$2, m.$3, m.$4, app.method == m.$1, warn: m.$1 == 'wallet' && t.pay > 350)),
                      if (m.$1 == 'upi')
                        AnimatedSize(
                          duration: const Duration(milliseconds: 500),
                          curve: curve,
                          child: app.method == 'upi'
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 12, top: 2),
                                  child: Row(children: [
                                    for (final (j, n) in ['GPay', 'PhonePe', 'Paytm', 'BHIM'].indexed) ...[
                                      if (j > 0) const SizedBox(width: 8),
                                      Expanded(
                                        child: Press(
                                          onTap: () => app.set(upiApp: n),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            height: 38,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(color: app.upiApp == n ? C.goldSoft : Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: app.upiApp == n ? C.gold : C.line, width: app.upiApp == n ? 1.5 : 1)),
                                            child: Text(n, style: sans(12, w: FontWeight.w700, color: app.upiApp == n ? const Color(0xFF6D4E17) : C.ink2)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ]),
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                    ],
                    Reveal(index: 7, child: Padding(padding: const EdgeInsets.fromLTRB(2, 14, 2, 12), child: Text('Tip your rider', style: serif(19, w: FontWeight.w500, ls: -.2)))),
                    Reveal(
                      index: 8,
                      child: Row(children: [
                        for (final v in [10, 20, 30]) ...[Expanded(child: _Tip('₹$v', app.tip == v, () => app.set(tip: v))), const SizedBox(width: 9)],
                        Expanded(
                          child: _Tip(const [10, 20, 30].contains(app.tip) ? 'Other' : '₹${app.tip}', !const [10, 20, 30].contains(app.tip), () {
                            const o = [50, 75, 100];
                            final i = o.indexOf(app.tip);
                            app.set(tip: o[(i + 1) % o.length]);
                          }),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 18),
                    Reveal(
                      index: 9,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                        decoration: card(r: 26),
                        child: Column(children: [
                          _line('Item total', inr(t.sub)),
                          _line('Delivery and service', inr(t.fee + t.svc)),
                          _line('Taxes', inr(t.tax)),
                          if (t.disc > 0) _line('Promo discount', '−${inr(t.disc)}', green: true),
                          _line('Rider tip', inr(t.tip)),
                          const SizedBox(height: 10),
                          Container(height: 1.2, color: C.line2),
                          const SizedBox(height: 14),
                          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                            Expanded(child: Text('Total to pay', style: sans(14, w: FontWeight.w700))),
                            AnimatedMoney(t.pay, style: serif(30, w: FontWeight.w500, ls: -.5)),
                          ]),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              Dock(children: [
                ValueListenableBuilder<int>(
                  valueListenable: _shake,
                  builder: (_, n, child) => TweenAnimationBuilder<double>(key: ValueKey(n), tween: Tween(begin: n == 0 ? 0 : 1, end: 0), duration: const Duration(milliseconds: 400), builder: (_, v, c) => Transform.translate(offset: Offset(10 * v * ((v * 14).floor().isEven ? 1 : -1), 0), child: c), child: child),
                  child: Cta(_busy ? 'Processing payment…' : 'Pay ${inr(t.pay)}', icon: Icons.lock_outline_rounded, busy: _busy, onTap: _pay),
                ),
              ]),
            ]);
          },
        ),
      );

  Widget _line(String l, String v, {bool green = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [Expanded(child: Text(l, style: sans(13.5, color: green ? C.ok : C.ink2))), Text(v, style: sans(13.5, w: FontWeight.w700, color: green ? C.ok : C.ink))]),
      );
}

class _Method extends StatelessWidget {
  final String id, title, sub;
  final IconData? icon;
  final bool on, warn;
  const _Method(this.id, this.title, this.sub, this.icon, this.on, {this.warn = false});
  @override
  Widget build(BuildContext context) => Press(
        onTap: () => app.set(method: id),
        scale: .98,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: curve,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(13, 13, 16, 13),
          decoration: BoxDecoration(
            color: on ? const Color(0xFFFCFBF7) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: on ? C.forest : C.line, width: on ? 1.6 : 1),
            boxShadow: on ? [BoxShadow(color: C.forest.withValues(alpha: .5), blurRadius: 26, offset: const Offset(0, 16), spreadRadius: -18)] : null,
          ),
          child: Row(children: [
            Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: C.cream, borderRadius: BorderRadius.circular(14)), child: icon == null ? Text('UPI', style: sans(11, w: FontWeight.w800, color: C.forest)) : Icon(icon, size: 20, color: C.forest)),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: sans(14, w: FontWeight.w800)), Text(warn ? 'Balance ₹350 · not enough for this order' : sub, style: sans(12, w: warn ? FontWeight.w700 : FontWeight.w500, color: warn ? C.rose : C.mute))])),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 22,
              height: 22,
              decoration: BoxDecoration(shape: BoxShape.circle, color: on ? C.forest : Colors.transparent, border: Border.all(color: on ? C.forest : C.line2, width: 1.5)),
              child: AnimatedScale(scale: on ? 1 : 0, duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack, child: Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.gold2, shape: BoxShape.circle)))),
            ),
          ]),
        ),
      );
}

class _Tip extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;
  const _Tip(this.label, this.on, this.onTap);
  @override
  Widget build(BuildContext context) => Press(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: curve,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            gradient: on ? const LinearGradient(colors: [C.gold2, C.gold]) : null,
            color: on ? null : Colors.white,
            border: Border.all(color: on ? Colors.transparent : C.line),
            boxShadow: on ? [BoxShadow(color: const Color(0xFF785000).withValues(alpha: .6), blurRadius: 18, offset: const Offset(0, 12), spreadRadius: -10)] : null,
          ),
          child: Text(label, style: sans(14, w: FontWeight.w700, color: on ? const Color(0xFF1B1407) : C.ink)),
        ),
      );
}
