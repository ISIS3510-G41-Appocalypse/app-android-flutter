# app_android_flutter

Flutter mobile application project.

## Requirements

- Git installed
- Flutter SDK installed (recommended: latest stable, compatible with Dart `^3.11.3`)
- Android Studio or VS Code
- Android SDK (for Android builds) and at least one emulator/device

## 1. Download the Repository

```bash
git clone https://github.com/ISIS3510-G41-Appocalypse/app-android-flutter.git
cd app-android-flutter
```

If you downloaded a ZIP file, extract it and open the project folder in your terminal or IDE.

## 2. Configure Flutter SDK

1. Install Flutter from the official guide: [Flutter Install](https://docs.flutter.dev/get-started/install).
2. Add Flutter to your system `PATH`.
3. Verify setup:

```bash
flutter doctor
```

Resolve any issues reported by `flutter doctor` before running the app.

## 3. Install Dependencies

From the project root:

```bash
flutter pub get
```

## 4. Run the App (Terminal)

1. Start an emulator or connect a physical device.
2. Run:

```bash
flutter run
```

Optional check:

```bash
flutter devices
```

## 5. Open and Run in Android Studio

1. Open Android Studio.
2. Select **Open** and choose the project root folder.
3. Confirm Android Studio recognizes Flutter and Dart plugins.
4. Go to **File > Settings > Languages & Frameworks > Flutter** and set the Flutter SDK path if required.
5. Run `flutter pub get` (Terminal tab) if dependencies are not yet loaded.
6. Select a device/emulator and click **Run**.

## Quick Troubleshooting

- If build tools are missing, run `flutter doctor` and install suggested components.
- If no devices appear, start an emulator from Android Studio Device Manager.
- If dependencies fail, run:

```bash
flutter clean
flutter pub get
```
