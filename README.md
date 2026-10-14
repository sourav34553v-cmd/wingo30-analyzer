# WinGo 30S Statistical Analyzer

A free Flutter starter app for manually recording 0–9 results and reviewing historical frequency/streaks.

## Requirements
- Flutter SDK (stable)
- Android Studio or Android SDK

## Run
```bash
flutter pub get
flutter run
```

## Build Android APK
```bash
flutter build apk --release
```
APK output:
`build/app/outputs/flutter-apk/app-release.apk`

## Important limitations
- This app does not connect to JaiClub66 and does not hack, scrape, or change server results.
- Timer is local only and is not synchronized with the website.
- Results are stored only in memory and disappear when the app closes. Persistence/export can be added later.
- The color mapping in the demo is a configurable example; verify it against the specific game's rules.
- Past frequencies and streaks are not reliable predictions of future random outcomes.
