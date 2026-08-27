# 🍽️ MealMate

> Discover, save, and shop for recipes — a polished Flutter recipe app powered by [TheMealDB](https://www.themealdb.com/), featuring a random-recipe roulette and an auto-generated shopping list.

<p>
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.22%2B-02569B?logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.4%2B-0175C2?logo=dart&logoColor=white">
  <img alt="State" src="https://img.shields.io/badge/State-Riverpod-4c51bf">
  <img alt="Material 3" src="https://img.shields.io/badge/UI-Material%203-757de8">
  <img alt="License" src="https://img.shields.io/badge/License-MIT-green">
</p>

MealMate is a portfolio Flutter app: a feature-first architecture with Riverpod,
offline favorites in Hive, and deliberate UX states (shimmer loading, empty and
error views, light/dark, tablet layouts). It talks to one public read-only API,
so there is no auth, no backend and no sync — see
[Scope & known limitations](#-scope--known-limitations).

---

## ✨ Features

- **Browse by category** — a responsive grid of meal categories from TheMealDB.
- **Search** — debounced, incremental recipe search by name.
- **Rich meal detail** — hero image, category/area/tags, ingredients paired with
  their measures, numbered step-by-step instructions, and a YouTube link when
  the recipe has one.
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
  `ShoppingListBuilder`, free of Flutter, and unit-tested directly.
- **Defensive parsing.** TheMealDB returns ingredients as 20 flat
  `strIngredient*`/`strMeasure*` fields and `{"meals": null}` for "no results".
  `Meal.fromApiJson` folds those into a clean list and never throws on missing
  keys (`Meal.fromJson`/`toJson` are the generated canonical form used for Hive).
- **Offline-first favorites.** The full recipe is serialized to Hive, so
  favorites and the shopping list work with no network.

### Networking hygiene

TheMealDB is a public, key-less, read-only API, so there is no auth, no token
storage and nothing to encrypt. What the code does do:

- **HTTPS-only transport.** The base URL is HTTPS, a Dio interceptor rejects any
  request on another scheme, Android sets `usesCleartextTraffic="false"` and
  `ios/Runner/Info.plist` sets `NSAllowsArbitraryLoads=false`.
- **Errors never leak internals.** `DioException`s are mapped to `ApiException`
  and screens render `ApiException.messageFor(error)`, never `error.toString()`
  — covered by `test/error_message_test.dart`. Dio's `LogInterceptor` is wired
  only under `kDebugMode`.
- **Validated external links.** `UrlHelper` only opens well-formed HTTPS URLs.
- **Query guards.** Search ignores queries under two characters and debounces
  input by 400 ms.

---

## 🚀 Build & run

### Required SDK versions

| Tool | Version |
| --- | --- |
| Flutter | **3.22+** (`pubspec.yaml`); CI runs the latest `stable` |
| Dart | **3.4+** (bundled with Flutter) |
| Android | `compileSdk` / `minSdk` from the Flutter toolchain defaults |
| JDK | 17 (for Android/Gradle) |
| Gradle | 8.11.1 (via wrapper) · Android Gradle Plugin 8.9.2 · Kotlin 1.9.24 |

### Steps

```bash
# 1. Fetch dependencies (pubspec.lock is committed, so versions are exact)
flutter pub get

# 2. Only after changing a model: regenerate freezed / json_serializable code
dart run build_runner build --delete-conflicting-outputs

# 3. Static analysis (uses the strict lints in analysis_options.yaml)
flutter analyze

# 4. Run the tests
flutter test

# 5. Run the app on a connected device / emulator
flutter run
```

> **Generated code:** every `*.freezed.dart` / `*.g.dart` file is committed, so
> a fresh clone analyzes, tests and builds without step 2. Re-run `build_runner`
> (step 2) after changing any model and commit the regenerated files.

> **Platform folders:** Android builds from a clone (the Gradle wrapper,
> `gradle-wrapper.jar` included, is committed). Copy
> `android/local.properties.example` to `android/local.properties` first.
> **iOS does not build from a clone** — only `AppDelegate.swift` and
> `Info.plist` are versioned; run `flutter create --platforms=ios .` once to
> generate the Xcode project. See [`ios/README_IOS.md`](ios/README_IOS.md).

---

## 🧪 Tests

Unit and widget tests cover the parts most worth protecting:

- `test/shopping_list_builder_test.dart` — de-duplication, distinct-measure
  merging, per-meal counting, sorting (the shopping-list logic).
- `test/meal_parsing_test.dart` — flat-ingredient folding, step splitting,
  defensive/missing-field handling, HTTPS YouTube validation, round-trip
  persistence.
- `test/favorites_repository_test.dart` — add/toggle and persistence across box
  reopen (offline durability).
- `test/meal_remote_datasource_test.dart` — the HTTP layer against a mocked Dio:
  response parsing, `{"meals": null}` as "no results", and every
  `DioException` → user-safe `ApiException` mapping.
- `test/shopping_list_page_test.dart` — tick-off state stays bound to the
  ingredient (not the row index) when the list reorders or shrinks.
- `test/search_page_test.dart` — the 400 ms search debounce: one request per
  keystroke burst, the two-character minimum, and cancellation on clear.
- `test/error_message_test.dart` — error screens render the friendly
  `ApiException` message, never the raw `ApiException(500): ...` form.

Run them with `flutter test`.

---

## 🚧 Scope & known limitations

Stated up front so nothing here is a surprise:

- **Android only from a clone.** `ios/` holds just `AppDelegate.swift` and
  `Info.plist`; the Xcode project has to be generated (see above). CI runs
  `analyze` + `test` — it does not build an artifact for either platform.
- **Release APKs are signed with the debug keystore** so `flutter run --release`
  works out of the box. They are for local profiling, not for distribution.
- **No screenshots or hosted demo yet.** Run it locally to see the UI.
- **Read-only, single public API.** No accounts, no backend of my own, no sync
  and no write path, so there is nothing to authenticate or encrypt.
- **Not covered by tests:** the router, theme persistence, the categories
  datasource and the favorites providers. No golden or integration tests.

---

## 📄 License

MIT © Lucas Gabriel Ferreira do Nascimento — see [LICENSE](LICENSE).
Recipe data © [TheMealDB](https://www.themealdb.com/).
