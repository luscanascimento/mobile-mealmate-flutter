# 🍽️ MealMate

> Discover, save, and shop for recipes — a polished Flutter recipe app powered by [TheMealDB](https://www.themealdb.com/), featuring a random-recipe roulette and an auto-generated shopping list.

<p>
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.4%2B-0175C2?logo=dart&logoColor=white">
  <img alt="State" src="https://img.shields.io/badge/State-Riverpod-4c51bf">
  <img alt="Material 3" src="https://img.shields.io/badge/UI-Material%203-757de8">
  <img alt="License" src="https://img.shields.io/badge/License-MIT-green">
</p>

MealMate is a mobile recipe-discovery app built to production-quality standards:
clean feature-first architecture, reactive state management, offline persistence,
careful UX (shimmer loading, empty & error states, light/dark, tablet layouts),
and security-minded networking (HTTPS-only, no secrets, defensive JSON parsing).

---

## ✨ Features

- **Browse by category** — a responsive grid of meal categories from TheMealDB.
- **Search** — debounced, incremental recipe search by name.
- **Rich meal detail** — hero image, category/area/tags, ingredients paired with
  their measures, numbered step-by-step instructions, and a direct YouTube link.
- **Favorites** — save recipes locally; they persist across restarts and are
  fully available **offline** (the whole recipe is stored, not just an id).
- **"Surprise Me" roulette** — a spinning animation that lands on a fresh
  random recipe, for when you cannot decide what to cook.
- **Auto-generated shopping list** — aggregates and
  **de-duplicates** ingredients across *all* favorited meals (case-insensitive),
  preserves distinct measures (e.g. `200g + 1 cup`), shows how many favorites use
  each item, and updates **live** as you favorite/unfavorite. Includes tick-off
  checkboxes.
- **Light / dark theme** with a persisted preference, **shimmer** loading
  placeholders, graceful **empty & error** states with retry, and **responsive**
  layouts (bottom navigation on phones, a navigation rail + wider grids on
  tablets).

---

## 🧱 Tech stack

| Concern | Choice |
| --- | --- |
| Framework / UI | Flutter (stable) + Material 3 |
| State management | [Riverpod](https://riverpod.dev) (`flutter_riverpod`) |
| Networking | [Dio](https://pub.dev/packages/dio) (HTTPS-only, interceptors) |
| Models / serialization | [freezed](https://pub.dev/packages/freezed) + `json_serializable` |
| Navigation | [go_router](https://pub.dev/packages/go_router) (`StatefulShellRoute`) |
| Local persistence | [Hive](https://pub.dev/packages/hive) (favorites + settings) |
| Images / loading UX | `cached_network_image` + `shimmer` |
| External links | `url_launcher` (validated HTTPS only) |
| API | [TheMealDB](https://www.themealdb.com/api.php) — public, **no key** |

---

## 🏗️ Architecture overview

MealMate uses a **feature-first** structure with a shared `core/` layer and a
light **data → repository → presentation** separation per feature.

```
lib/
├── core/                      # cross-cutting concerns
│   ├── config/                # API endpoints (no secrets)
│   ├── network/               # Dio client, providers, ApiException mapping
│   ├── router/                # go_router config + route names
│   ├── theme/                 # Material 3 theme + persisted ThemeMode
│   ├── utils/                 # responsive helpers, safe URL launcher
│   └── widgets/               # shared UI (shimmer, states, network image, shell)
└── features/
    ├── categories/            # browse categories → category meals
    ├── meals/                 # meal models, datasource, repo, detail UI
    ├── search/                # debounced search
    ├── favorites/             # Hive-backed favorites (offline-first)
    ├── surprise/              # random-recipe roulette
    └── shopping_list/         # aggregated shopping list
        └── domain/            # pure, unit-tested aggregation logic
```

Key decisions:

- **Reactive data flow.** UI widgets watch Riverpod providers. The shopping list
  is a *derived* provider that recomputes automatically whenever favorites change
  — no manual refresh, no duplicated state.
- **Pure domain logic.** The de-duplication/aggregation lives in
  `ShoppingListBuilder`, free of Flutter, so it is trivially unit-tested.
- **Defensive parsing.** TheMealDB returns ingredients as 20 flat
  `strIngredient*`/`strMeasure*` fields and `{"meals": null}` for "no results".
  `Meal.fromJson` folds those into a clean list and never throws on missing keys.
- **Offline-first favorites.** The full recipe is serialized to Hive, so
  favorites and the shopping list work with no network.

### 🔒 Security & best practices

- **HTTPS-only.** The base URL is HTTPS and a Dio interceptor *rejects* any
  non-HTTPS request. Android sets `usesCleartextTraffic="false"`; iOS sets
  `NSAllowsArbitraryLoads=false`.
- **No secrets / no API keys.** TheMealDB's public test endpoint needs none, and
  nothing sensitive is committed (`.gitignore` blocks `.env`, keystores, etc.).
- **Safe error handling.** Low-level `DioException`s are mapped to friendly,
  user-safe messages via `ApiException`; verbose logging is debug-only.
- **Validated external links.** `UrlHelper` only opens well-formed HTTPS URLs.
- **Input validation.** Search ignores blank/too-short queries and is debounced.

---

## 🚀 Build & run

### Required SDK versions

| Tool | Version |
| --- | --- |
| Flutter | **3.24+** (stable channel) |
| Dart | **3.4+** (bundled with Flutter) |
| Android | `compileSdk` managed by Flutter; `minSdk` 21 |
| JDK | 17 (for Android/Gradle) |
| Gradle | 8.9 (via wrapper) · Android Gradle Plugin 8.5.2 · Kotlin 1.9.24 |
| Xcode | 15+ (for iOS) |

### Steps

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Generate code for freezed / json_serializable / riverpod
dart run build_runner build --delete-conflicting-outputs

# 3. Static analysis (uses the strict lints in analysis_options.yaml)
flutter analyze

# 4. Run the tests
flutter test

# 5. Run the app on a connected device / emulator
flutter run
```

> **Generated code:** committed `*.freezed.dart` / `*.g.dart` files are included
> so the project builds immediately, but re-running `build_runner` (step 2) is
> recommended after changing any model.

> **Platform folders:** Android is fully configured. The binary
> `gradle-wrapper.jar` is intentionally **not** committed — Android Studio (or
> `gradle wrapper`) regenerates it on first open. For a complete iOS project run
> `flutter create --platforms=ios .` once (it won't touch `lib/`); see
> [`ios/README_IOS.md`](ios/README_IOS.md). Copy
> `android/local.properties.example` to `android/local.properties`.

---

## 🧪 Tests

Unit tests cover the parts most worth protecting:

- `test/shopping_list_builder_test.dart` — de-duplication, distinct-measure
  merging, per-meal counting, sorting (the shopping-list logic).
- `test/meal_parsing_test.dart` — flat-ingredient folding, step splitting,
  defensive/missing-field handling, HTTPS YouTube validation, round-trip
  persistence.
- `test/favorites_repository_test.dart` — add/toggle and persistence across box
  reopen (offline durability).

Run them with `flutter test`.

---

## 🎯 What this demonstrates

- **Clean, scalable architecture** — feature-first modules with a clear
  data/repository/presentation split and a reusable `core/` layer.
- **Modern state management** — Riverpod providers, derived state, and
  `StateNotifier`s wired to persistence.
- **Real mobile engineering** — offline persistence (Hive), navigation with
  per-tab stacks (`go_router`), responsive phone/tablet layouts, and polished
  loading/empty/error UX.
- **API integration done carefully** — HTTPS-only Dio client, typed models with
  `freezed`, and defensive parsing against a quirky real-world API.
- **Security awareness** — no secrets, cleartext traffic disabled, validated
  external links, and user-safe error messaging.
- **Product thinking** — two features that go beyond a CRUD demo: the random
  roulette and the auto-built shopping list.

---

## 📄 License

Released under the MIT License. Recipe data © [TheMealDB](https://www.themealdb.com/).
