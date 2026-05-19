# SuperSave — Flutter Finance App

Personal finance manager for **iOS, Android, and Web** — one codebase.

## Features
- **Dashboard** — Monthly summary, savings rate, interactive pie chart by category
- **Expenses** — Add/search/delete expenses, swipe to dismiss, recurring support
- **Budget** — Per-category monthly limits with color-coded progress bars
- **Savings Goals** — Create goals, deposit money, track progress to target
- **Recurring Expenses** — Weekly / Monthly / Yearly intervals
- **Auth** — Email & password via Supabase

---

## Quick Start

### 1. Create a Supabase Project
1. Go to [https://supabase.com](https://supabase.com) → New Project (free tier works)
2. Open **SQL Editor** → paste and run `supabase_schema.sql`

### 2. Add your credentials
Open `lib/core/constants.dart` and replace:
```dart
const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```
Find both values at: Supabase Dashboard → Settings → API

### 3. Install Flutter
If not installed: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

### 4. Run the app

```bash
cd SuperSave

# Install dependencies
flutter pub get

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Run as web app (localhost)
flutter run -d chrome

# Build for web deployment
flutter build web
```

---

## Project Structure
```
lib/
├── main.dart                    # Entry point — Supabase init
├── app.dart                     # App widget + auth routing
├── core/
│   ├── constants.dart           # Supabase credentials + presets
│   └── theme.dart               # Light/dark Material 3 theme
├── models/
│   └── models.dart              # All data types (Income, Category, Expense, Goal)
├── services/
│   └── supabase_service.dart    # All Supabase API calls
├── providers/
│   ├── auth_provider.dart       # Auth state (ChangeNotifier)
│   └── finance_provider.dart    # Finance data + business logic
├── screens/
│   ├── auth/                    # Login / Sign Up
│   ├── home/                    # Bottom navigation shell
│   ├── dashboard/               # Summary + pie chart
│   ├── expenses/                # Expense list + add form
│   ├── budget/                  # Category budget management
│   ├── savings/                 # Savings goals
│   └── settings/                # Account + sign out
└── widgets/
    └── common_widgets.dart      # Shared UI components
```

## Requirements
- Flutter 3.16+
- Dart 3.2+
- Supabase free account
