# FoodEX

Premium food-delivery app UI built with Flutter. Six core screens plus Explore, Orders and Profile tabs:
Home, Restaurant and menu, Your order, Payment, Payment complete, Delivery tracking.

- 12 restaurants, 126 dishes (`lib/data.dart`, real photography in `assets/img`)
- Working cart, promo codes (`FOODEX`, `WELCOME50`), tipping, payment methods, live rider tracking
- Fonts: Fraunces and Manrope, bundled offline

## Run

    flutter pub get
    flutter run                     # connected phone or emulator
    flutter build apk --release     # installable Android build

Desktop windows show the app inside a phone-sized frame; on a phone it fills the screen.
