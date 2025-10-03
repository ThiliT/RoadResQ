# RoadResQ (Prototype)

A simple Flutter prototype demonstrating core roadside assistance flows with a modern Material 3 UI.

## Features
- Welcome flow with role selection (Driver/Mechanic)
- Registration screens with validation
- Driver dashboard:
  - Status card with online/offline indicator
  - Map view with current location and dummy mechanics
  - Mechanic list with distance and ETA
  - Offline mode with SMS simulation and parsed results
- Mechanic dashboard with availability and mock requests

## Tech
- Flutter/Dart, Material 3, Google Fonts (Poppins)
- google_maps_flutter, geolocator, connectivity_plus
- shared_preferences, url_launcher, provider-ready

## Getting Started
1. Install Flutter SDK.
2. In `android/app/src/main/AndroidManifest.xml`, replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your Google Maps Android API key.
3. From project root:
```
cd road_resq
flutter pub get
flutter run
```

## Permissions
Declared in `android/app/src/main/AndroidManifest.xml`:
- ACCESS_FINE_LOCATION / ACCESS_COARSE_LOCATION
- INTERNET / ACCESS_NETWORK_STATE
- CALL_PHONE
- Google Maps API meta-data

## Notes
- SMS mode is simulated; no backend is used.
- Dummy mechanics are defined in `lib/utils/dummy_data.dart`.
- Theme and design tokens are in `lib/utils/constants.dart`.

## Screenshots (Description)
- Splash: Gradient background with app icon and title.
- Welcome: Deep gradient with two large role cards.
- Driver Dashboard: Status card, map/list tabs, FAB emergency.
- Mechanic Dashboard: Profile, availability, stats, mock requests.
