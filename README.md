# Milk Count

A simple, beautiful Flutter app to track milk intake for newborn babies.

## Features

- **Bottle Feeding Tracking** - Log amount in ml with quick-select buttons
- **Breast Feeding Tracking** - Log duration and side (left/right/both)
- **Daily Summary** - See today's feeding count, total ml, and total minutes at a glance
- **Time Since Last Feeding** - Always know when the last feeding was
- **Feeding History** - Browse past days with a date navigator
- **Notes** - Add optional notes to any feeding
- **Delete Entries** - Swipe to remove incorrect entries
- **Local Storage** - All data saved on device using SharedPreferences

## Screenshots

The app uses a soft pink and blue color scheme designed for a calming, parent-friendly experience with native iOS (Cupertino) styling.

## Getting Started

### Prerequisites
- Flutter SDK (>=3.1.0)
- Xcode (for iOS development)

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd milk-count

# Install dependencies
flutter pub get

# Run on iOS simulator
flutter run
```

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **SharedPreferences** - Local data persistence
- **fl_chart** - Charts for data visualization
- **intl** - Date/time formatting
- **Cupertino Widgets** - Native iOS look and feel
