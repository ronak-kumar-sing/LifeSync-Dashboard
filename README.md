# LifeSync Dashboard

A cross-platform Flutter application that runs natively on macOS (Apple Silicon M1) and Android. Features a shared widget system with real-time data sync across both platforms using local (Hive) + cloud (Firebase Firestore) sync layer.

## Features

- **Income/Expense Tracker**: Dark green glassmorphism card with bar chart showing 14-day balance
- **Minimal Calendar**: Dark purple/navy calendar with month navigation and date selection
- **Water Intake Tracker**: Circular progress ring, weekly bar chart, configurable daily goal
- **Analytics/Views Widget**: Custom metric tracking with area charts and date range picker
- **AI Agent**: Chat-based AI assistant with OpenAI/Gemini integration

## Platform Targets

- **macOS**: Desktop layout with sidebar navigation
- **Android**: Mobile layout with bottom navigation bar

## Tech Stack

- Flutter 3.x
- Firebase (Core, Auth, Firestore)
- Hive (local storage)
- fl_chart (charts)
- Provider (state management)
- macos_ui (macOS native feel)
- flutter_local_notifications (reminders)

## Setup

1. Clone the repository
2. Run `flutter pub get`
3. Set up Firebase:
   - Add `google-services.json` for Android
   - Add `GoogleService-Info.plist` for macOS/iOS
4. Create a `.env` file with your AI API key:
   ```
   OPENAI_API_KEY=your_key_here
   GEMINI_API_KEY=your_key_here
   ```
5. Run `flutter run`

## Architecture

- **Offline-first**: Data is written to Hive first, then synced to Firebase
- **Cross-platform**: Adaptive layout using LayoutBuilder/MediaQuery
- **Real-time sync**: Firestore listeners update all connected devices

## License

MIT
