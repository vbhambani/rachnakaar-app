# Rachnakaar — Android App (Flutter)

Companion Android app for **rachnakaar.com**. Reads content directly from the WordPress REST API on the live site, so any content added in wp-admin (or through the AI Assistant) shows up in the app instantly.

## What's inside

```
rachnakaar-app/
├── pubspec.yaml              # Flutter project config + dependencies
├── lib/
│   ├── main.dart             # App entry, bottom-nav shell (5 tabs)
│   ├── theme.dart            # Burgundy/gold theme matching the website
│   ├── api/
│   │   ├── api_client.dart   # HTTP wrapper for rachnakaar.com/wp-json
│   │   └── models.dart       # PressItem, EventItem, InspirationItem, TrackItem
│   └── screens/
│       ├── home_screen.dart        # Hero banner + latest news + upcoming events
│       ├── press_list.dart         # All press releases
│       ├── press_detail.dart       # Full press article view
│       ├── events_list.dart        # All events with date badges + RSVP
│       ├── event_detail.dart       # Event detail + RSVP button
│       ├── inspirations_list.dart  # Grid of literary creators
│       └── tracks_list.dart        # YouTube tracks with thumbnails
```

## How to run it

### Prerequisites (install once on your machine)

1. **Flutter SDK** — https://docs.flutter.dev/get-started/install/windows (~700MB download)
   - Follow the official guide; add `flutter\bin` to your PATH
2. **Android Studio** — https://developer.android.com/studio
   - Open it → Settings → SDK Manager → install Android SDK Platform + Build Tools
   - During first launch, Android Studio will offer to install the Flutter plugin — accept it
3. Verify install: open PowerShell and run:
   ```
   flutter doctor
   ```
   Fix any red `[X]` items it lists.

### First-time project setup

```powershell
cd E:\ClaudeProjects\rachnakaar-app
flutter create . --org com.rachnakaar --project-name rachnakaar --platforms android
flutter pub get
```

The `flutter create .` adds the `android/` and `ios/` folders (platform code) without touching `lib/`. `flutter pub get` downloads dependencies.

### Run on Android emulator (or USB-connected phone)

```powershell
flutter devices            # list emulators / connected phones
flutter run                # launches on the first device found
```

Hot reload: while running, press `r` in the terminal to apply code changes instantly.

### Build a release APK

```powershell
flutter build apk --release
```

APK lands at `build\app\outputs\flutter-apk\app-release.apk` — install it on any Android phone.

## What works in v0.1

- ✅ Home screen with hero banner + latest 4 press + upcoming 3 events
- ✅ Bottom nav: Home · News · Events · Creators · Tracks
- ✅ Pull-to-refresh on every list
- ✅ Press list + detail (full article body)
- ✅ Events list with date badge + type tag + venue, detail with **RSVP / Register** button (opens browser)
- ✅ Creators grid (2-column) with photo + Hindi name + era
- ✅ Tracks list with YouTube thumbnail + tap-to-open in YouTube
- ✅ Cached images (don't re-download on scroll)
- ✅ Burgundy/gold theme matching the website
- ✅ Hindi/Devanagari rendering

## Coming in v0.2 (todo)

- 🔜 Login (JWT auth) — sign up + log in matches the website's `/register/` flow
- 🔜 Submit a story / track from inside the app
- 🔜 Push notifications when Aashish posts new events
- 🔜 Inline YouTube player (don't switch to YouTube app)
- 🔜 Search across creators + articles
- 🔜 Offline cache (read past articles without internet)

## API reference (what the app calls)

| Endpoint | What it returns |
|---|---|
| `GET https://rachnakaar.com/wp-json/wp/v2/press?_embed=1` | List of press releases |
| `GET https://rachnakaar.com/wp-json/wp/v2/press/{id}?_embed=1` | One press release with full content |
| `GET https://rachnakaar.com/wp-json/wp/v2/events?_embed=1` | List of events |
| `GET https://rachnakaar.com/wp-json/wp/v2/events/{id}?_embed=1` | One event with full meta |
| `GET https://rachnakaar.com/wp-json/wp/v2/inspirations?_embed=1` | Literary creators |
| `GET https://rachnakaar.com/wp-json/wp/v2/tracks?_embed=1` | YouTube tracks |

All endpoints return JSON. `_embed=1` includes the featured image data in one request.

## When you (or Aashish) add new content

Either via **wp-admin → AI Assistant** (fastest) or via **wp-admin sidebar** (manual). The app picks up new content automatically on next refresh — no app update needed.

## Troubleshooting

**"No Android devices detected"** — Plug your phone via USB and enable USB debugging in phone Developer Options. Or in Android Studio: Tools → Device Manager → Create a virtual device.

**"Could not load news: ..."** — Phone has no internet, or rachnakaar.com is down. Check `https://rachnakaar.com/wp-json/wp/v2/press` in a browser.

**Hindi text shows as boxes** — Android's default fonts cover Devanagari. If it doesn't render on your test device, install the Noto Sans Devanagari font (Settings → Fonts).
