# App UI

Reusable monochrome Flutter design system by [Hensell](https://hensell.dev).

Import `package:app_ui/app_ui.dart` to use shared themes, color and spacing tokens,
responsive content widths, semantic typography, and accessible controls.
The package depends only on Flutter at runtime. Pass localized strings and
callbacks from the application; keep Cubits, routes, repositories, and domain
entities outside this package.

Shared controls include `AppScreen`, `AppContent`, `AppText`, `AppGap`,
`AppButton`, `AppIconButton`, `AppFloatingAction`, `AppTextField`, `AppRadioTile`,
`AppListTile`, `AppProgress`, and `AppDivider`. Flutter layout primitives remain
available for composing feature widgets. Add reusable styling here instead of
introducing numeric spacing or colors in features.

Run `flutter pub get`, `flutter analyze`, and `flutter test --coverage` in this
folder. The root `tool/test.sh` and the dedicated CI job additionally enforce
100% line coverage. Only barrel exports and compile-time token declarations are
excluded; executable component and theme code is fully included.

Licensed under the [MIT License](LICENSE).
