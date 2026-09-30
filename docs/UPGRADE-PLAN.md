# Upgrade Plan — Diffchecker Mobile

## Current state

Score: 7.5/10 — LCS line diff with prefix/suffix trimming, edge-case tests, readable semantics, a11y guideline tests and fail-closed signing; no intra-line diff, icon or E2E flow yet.

## Backlog

### P0
- None open. (Release signing now fails closed without `android/key.properties`.)

### P1
- Word/character-level diff within changed lines.
- Paste-from-clipboard buttons for both inputs.
- Replace the template launcher icon with a real app icon (the application ID `com.bookchaowalit.*` is already set).
- Add a Maestro smoke flow for the main journey.
- Add a CI job that builds a signed release bundle from repository secrets (keystore decoded at runtime, never committed).

### P2
- Tablet layout (NavigationRail).
- Localisation (Thai/English) for UI strings.

## Done in this pass (pass 3)

- Improvement: identical leading/trailing lines are matched before the O(n·m) LCS table, so the 2000-line cap now applies only to the changed middle section — two 6000-line files with a one-line edit diff fine instead of erroring (and large diffs are faster).
- Bug fix: lone `\r` (classic Mac) line endings were not split, so such text was one giant line.
- Accessibility: diff rows are announced as "Added/Removed/Unchanged: …" ("blank line" for empty rows) instead of enum names; summary and error are live regions.
- Edge-case unit tests: large files with small edits, cap on a large changed section, CR endings, blank/whitespace-only lines, trimming with ignoreWhitespace, repeated and unicode lines, empty sides. Widget tests: whitespace toggle, oversized-section error state, semantics labels, a11y guidelines, 200% text scale.

## Done in pass 2

- Release builds no longer sign with the debug key: `android/app/build.gradle.kts` reads the ignored `android/key.properties` and a Gradle guard fails any release assemble/bundle without it (pattern from `bookchaowalit-goal-tracker-mobile`). Root `.gitignore` also ignores `key.properties`, `*.jks`, `*.keystore`; README documents the setup. Not build-verified here (no Android SDK/Gradle in this environment).


## Done in pass 1

- Replaced the Expo/npm CI (which could never fail) with fail-closed Flutter CI: `dart format` check, `flutter analyze`, `flutter test`, debug APK on `main`.
- Implemented the core feature (compare two texts line by line and see what was added or removed) with pure-Dart logic in `lib/logic/`.
- Replaced placeholder Explore/Profile tabs with an About screen describing features and privacy.
- Added unit tests for the logic and widget tests for the main journey.
- Removed unused `go_router` / `flutter_riverpod` dependencies; README now matches the code.
