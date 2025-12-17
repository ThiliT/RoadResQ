# RoadResQ – Local Setup
RoadResQ is an Android-based roadside emergency assistance application that allows drivers to request help and automatically identifies nearby mechanics based on the user’s location. The system uses a Flutter mobile app, a Node.js backend, and a MySQL database.

## Requirements
- Flutter
- Node.js + npm
- MySQL
- Android Studio/Android phone with USB debugging

## Android Device Setup
1. Enable **Developer Mode** on the Android device
2. Enable **USB Debugging**
3. Connect the device via USB
4. Run once per USB connection to enable ADB port forwarding:
   adb reverse tcp:3000 tcp:3000

## Frontend
flutter pub get
flutter run

## Backend
cd backend
npm install
npm start
