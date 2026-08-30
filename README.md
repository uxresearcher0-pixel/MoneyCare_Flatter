# Money Care

A cross-platform (iOS + Android) rebuild of the Money Care money-management app in
**Flutter**, implemented from the ["Money Management" Figma file](https://www.figma.com/design/h6YwghQ4SyaiuuRwCj6QDm/Money-Management).

Money Care lets a household or team share a budget: multiple contributors pledge
money into a project, purchases are logged against categories, and everyone can
see running balances, budgets and spending reports in real time.

## Getting started

```bash
cd app
flutter pub get
flutter run            # launches on a connected iOS or Android device/simulator
```

Requires the Flutter SDK (stable channel) plus Xcode (for iOS) and/or Android
Studio (for Android) set up as usual — see `flutter doctor`.

## Project structure

```
app/lib
├── core/                 # Design system & app-wide plumbing
│   ├── theme/            # Colors, typography, spacing (extracted from Figma)
│   ├── widgets/          # Shared components: buttons, cards, inputs, nav bar…
│   ├── router/           # go_router route table
│   └── utils/            # Currency/date formatting
├── data/
│   ├── models/           # Plain Dart domain models
│   └── providers/        # In-memory Riverpod store (AppData) + seed data
└── features/             # One folder per product area, mirroring the Figma
    ├── auth/              # Splash, Welcome, Sign in, Sign up
    ├── dashboard/          # Home tab / active period dashboard
    ├── workspaces/         # Workspace list, overview, creation
    ├── projects/           # Project creation wizard, overview tabs
    ├── periods/            # Period list & creation
    ├── people/             # People hub, member roles, contributions, details
    ├── purchases/          # Add purchase / contribution, bulk entry, scan receipt
    ├── activity/           # Transaction activity feed & details
    ├── reports/            # Spending overview report
    ├── budget/             # Budget overview
    ├── config/             # Custom project fields & templates
    ├── settings/           # Settings hub, categories, units, accounts…
    └── more/               # More hub, import/export, archive, help
```

## Notes on this implementation

- **State**: `AppData` (a `ChangeNotifier` exposed via Riverpod) holds all
  workspaces/projects/periods/people/transactions in memory, seeded with
  sample data so every screen is populated and fully interactive from first
  launch (add a purchase, add a contribution, create a workspace/project/period,
  etc. all update the UI live). Swap `AppData` for a real API-backed repository
  when a backend is ready — the screens only depend on the public methods on
  `AppData`, not on how the data is stored.
- **Design system**: colors, type scale, spacing and the shared widgets in
  `core/` were extracted directly from the Figma file's design tokens
  (`color-action-primary` #167257, `color-background-default` #F6F8F6, etc.)
  so every screen stays visually consistent even where it was hand-built from
  the same component patterns rather than a 1:1 Figma pull.
- **Fonts/icons**: body text uses Inter via `google_fonts`; iconography uses
  Flutter's bundled Material Symbols (rounded) set to match the Figma icon style.
- Verified with `flutter analyze` (zero issues) and `flutter test` (app boots
  and renders end-to-end). Native `.apk`/`.ipa` builds need to be produced on a
  machine with the Android/iOS SDKs installed (not available in this build
  environment) — the project is a stock `flutter create --platforms ios,android`
  scaffold, so `flutter build apk` / `flutter build ios` work out of the box.
