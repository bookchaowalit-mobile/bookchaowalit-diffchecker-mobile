# Diffchecker — Mobile

Compare two texts line by line and see what was added or removed.

Part of [Chaowalit Greepoke](https://bookchaowalit.com)'s 101 Portfolio Projects.

## Features

- LCS-based line diff with added/removed/unchanged lines
- Optional whitespace-insensitive comparison
- Summary counts of additions and removals

Data lives in memory for the current session only; there is no account,
backend, analytics or network access.

## Tech Stack

- **Framework:** Flutter (CI pinned to 3.47.5) + Material 3
- **Language:** Dart
- **State:** `StatefulWidget` / `setState`; the core logic is pure Dart in
  `lib/logic/` and unit-tested without widgets

## Develop and verify

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter run
```

CI (`.github/workflows/build.yml`) runs the same format/analyze/test checks
and fails closed; a debug APK is built on pushes to `main`.

## Build

```bash
# Android
flutter build apk --debug
```

Release signing is not configured yet (see `docs/UPGRADE-PLAN.md`).

## Related

- **Frontend:** [bookchaowalit-website/diffchecker-frontend](https://github.com/bookchaowalit-website/diffchecker-frontend)
- **Portfolio:** [bookchaowalit.com](https://bookchaowalit.com)

## License

MIT
