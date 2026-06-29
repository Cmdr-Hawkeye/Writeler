# Native Release Guide

Writeller is configured as a local-first Flutter app for Web, Android, iOS, Windows, and macOS. This guide tracks the platform metadata, release commands, and signing tasks that should be checked before distributing builds.

## Product Identity

- App name: `Writeller`
- Version source: `app/pubspec.yaml`
- Android application ID: `com.writeller.app`
- iOS bundle ID: `com.writeller.app`
- macOS bundle ID: `com.writeller.app.macos`
- Windows executable: `writeller.exe`
- Web/PWA title: `Writeller`

The checked-in icon source is `app/assets/brand/writeller_icon.svg`. Regenerate platform icons with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\generate_brand_assets.ps1
```

## Local Release Check

Run the default verification pass:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\release_check.ps1
```

Optional native builds:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\release_check.ps1 -IncludeWindowsBuild
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\release_check.ps1 -IncludeAndroidApk
```

Package a Windows zip:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\package_windows.ps1
```

## Platform Notes

### Android

- Release metadata is in `app/android/app/build.gradle.kts`.
- App label comes from `app/android/app/src/main/res/values/strings.xml`.
- Release manifest disables Android backup for local manuscript privacy.
- Release manifest allows HTTPS/network AI providers through `INTERNET` but keeps cleartext traffic disabled.
- Store signing must be configured outside source control before Play Store distribution.

### iOS

- Bundle metadata is in `app/ios/Runner/Info.plist` and `app/ios/Runner.xcodeproj/project.pbxproj`.
- The bundle ID is `com.writeller.app`.
- `ITSAppUsesNonExemptEncryption` is set to `false` for standard exempt platform/network encryption disclosure.
- App Store release requires an Apple Developer Team, signing profile, and archive from macOS/Xcode.

### macOS

- App metadata is in `app/macos/Runner/Configs/AppInfo.xcconfig`.
- Release sandboxing stays enabled.
- `com.apple.security.network.client` is enabled so optional AI providers can be reached.
- Distribution outside development needs Developer ID signing and notarization.

### Windows

- Product metadata is in `app/windows/runner/Runner.rc`.
- Window title is set in `app/windows/runner/main.cpp`.
- The application manifest enables Per-Monitor V2 DPI awareness and long-path awareness.
- Installer/MSIX signing is not committed and should be added in the release environment.
- Local Windows release builds require Visual Studio with the "Desktop development with C++" workload.

### Web/PWA

- PWA metadata is in `app/web/manifest.json` and `app/web/index.html`.
- The production web build should use:

```powershell
cd app
flutter build web --no-pub --no-web-resources-cdn
```

The current web build emits a Flutter WASM dry-run warning because `flutter_secure_storage_web` uses APIs outside Flutter's WASM target. The regular JavaScript web build is supported.

## Manual Release Checklist

- Regenerate icons after brand changes.
- Run `scripts/release_check.ps1`.
- Confirm no signing secrets, keystores, provisioning profiles, or notarization credentials are committed.
- Check that import/export, provider settings, secure API key storage, and local database persistence work on the target platform.
- For store builds, fill store privacy forms consistently with the offline-first design: local manuscript data stays on device unless users explicitly export, sync, or call an AI provider.
