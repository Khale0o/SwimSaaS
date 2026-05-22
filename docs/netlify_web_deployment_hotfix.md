# Netlify Flutter Web Deployment Hotfix

## Goal

Fix the most common Netlify Flutter Web white-screen causes without changing app UI, Firebase schema, user flows, or feature behavior.

## Changes Made

- Verified Flutter Web base href handling. Source `web/index.html` must keep Flutter's placeholder so the release build can inject the requested root base href:

```html
<base href="$FLUTTER_BASE_HREF">
```

The command `flutter build web --release --base-href /` generates `build/web/index.html` with `<base href="/">`.

- Added `web/_redirects` for Flutter Web single-page app routing:

```text
/*    /index.html   200
```

- Added missing social login image assets to `pubspec.yaml`:

```yaml
- assets/google.png
- assets/apple.png
```

- Created the missing asset files:
  - `assets/google.png`
  - `assets/apple.png`

## Build Command

Use this exact Netlify build command:

```bash
flutter build web --release --base-href /
```

## Publish Folder

Use this Netlify publish folder:

```text
build/web
```

## Redirect Rule

Netlify must publish this file with the build output:

```text
web/_redirects
```

Rule:

```text
/*    /index.html   200
```

This prevents refresh/deep-link 404s for Flutter Web routes.

## Firebase Authorized Domain Requirement

In Firebase Console, add the deployed Netlify domain to Authentication authorized domains:

- Firebase Console
- Authentication
- Settings
- Authorized domains
- Add the Netlify domain, for example `your-site-name.netlify.app`

If a custom domain is used, add that domain too.

## Firebase Web Config

`lib/firebase_options.dart` includes a web `FirebaseOptions` config with:

- `apiKey`
- `appId`
- `messagingSenderId`
- `projectId`
- `authDomain`
- `storageBucket`

## Verification Commands

```powershell
flutter clean
flutter pub get
flutter build web --release --base-href /
```

## Notes

- The Flutter Web asset URL for `assets/google.png` is served under `assets/assets/google.png` in the built web app. The source file and `pubspec.yaml` entry must both exist for that request to succeed.
- No Firebase schema, Firestore queries, UI layout, or user flows were changed.
