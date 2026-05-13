# PosterCraft (UI Prototype)

Modern responsive Flutter Web + Mobile UI prototype for an event poster template platform (GetX + glassmorphism + light/dark).

## Firebase (Web ready)

This repo includes a **Web-only** Firebase config in `lib/core/firebase/firebase_options.dart`.

- To generate proper options for **Android/iOS/Desktop**, run FlutterFire:
  - `dart pub global activate flutterfire_cli`
  - `flutterfire configure --project utsavframeai`

## Deploy to Firebase Hosting (Flutter Web)

1. Install Firebase CLI: `npm i -g firebase-tools`
2. Login: `firebase login`
3. Build Flutter Web: `flutter build web --release`
4. Deploy: `firebase deploy`

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
