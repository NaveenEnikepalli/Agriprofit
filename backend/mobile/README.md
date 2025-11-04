# CSP Prices Mobile (Expo)

A minimal Expo React Native app that fetches crop prices from your backend.

How to run

1. Install Expo CLI (if you don't have it):

   npm install -g expo-cli

2. From the `mobile` folder, install dependencies and start:

   npm install
   npm start

3. Run on device or emulator

- Android emulator: Expo will open the app; default backend host is `http://10.0.2.2:5000` (Android emulator localhost mapping).
- iOS simulator or web: default backend host is `http://localhost:5000`.

If your backend runs on a different machine or you use a physical device, update the Backend URL field in the app's top to point to your machine (e.g., `http://192.168.1.100:5000`).

Notes

- The app calls `/api/prices/fetch?state=...&commodity=...` and displays the `prices` array returned by that endpoint.
- This is a minimal starter. I can add search, pagination, caching, or nicer UI next.
