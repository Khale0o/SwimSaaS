# Phase 6D Navigation And Runtime Performance Audit

## 1. Phase Goal

Audit app runtime performance and navigation smoothness without modifying production code. The focus is identifying why main pages feel heavy, where navigation rebuilds or reloads too much data, and which safe optimizations should be implemented in later phases.

## 2. Files Inspected

- `lib/screens/home_screen.dart`
- `lib/screens/dashboard_screen.dart`
- `lib/screens/subscriptions_screen.dart`
- `lib/screens/swimmers_list_screen.dart`
- `lib/screens/evaluation_screen.dart`
- `lib/screens/parent_dashboard_screen.dart`
- `lib/screens/admin_panel_screen.dart`
- `lib/screens/profile_screen.dart`
- `lib/screens/login_screen.dart`
- Supporting references checked:
  - `pubspec.yaml`
  - `assets/`

## 3. Navigation Performance Findings

- `home_screen.dart` uses a `PageView` for the main coach/admin areas. This preserves child page widgets better than repeated `Navigator.push`, but changing pages still calls `setState` on `HomeScreen`, rebuilding the shell, floating nav, and conditional dashboard header.
- `home_screen.dart` eagerly initializes all main pages after the admin check: dashboard, evaluation, subscriptions, parents, and profile. Heavy child pages can start listeners or reads as soon as they are built by `PageView`, which may make the first app open and early navigation feel heavy.
- `home_screen.dart` performs a user document `.get()` in `_checkAdminStatus()` on startup. This is small and reasonable, but it is another startup read before the main shell appears.
- `dashboard_screen.dart` cards navigate with `Navigator.push` to separate list/detail screens: swimmers list, active subscriptions, expired subscriptions, and pending evaluations. These pushed screens open their own full listeners, while the dashboard listener remains active underneath.
- Logout flows in `home_screen.dart`, `parent_dashboard_screen.dart`, and `profile_screen.dart` use `pushAndRemoveUntil`, which is correct for clearing the stack. Some of these methods still have async-context analyzer risks in files outside this phase.
- `parent_dashboard_screen.dart` also uses a `PageView` for parent pages. It preserves pages once mounted, but each child page owns its own Firestore fetch logic and loading state.
- `login_screen.dart` uses `pushReplacement` after login and `push` for sign-up and forgot-password flows. The stack behavior is mostly expected, but startup/login routing should avoid duplicate auth checks in later phases if AuthGate is already authoritative.
- There is no current `IndexedStack` for main coach/admin tabs. `PageView` can preserve page state, but an `IndexedStack` with lazy page creation can make tap navigation feel more immediate and avoid swipe/page lifecycle surprises.

## 4. Heavy Screen Findings

- `home_screen.dart`
  - Owns the main shell and rebuilds on each page change.
  - Eagerly constructs all page widgets after admin status resolves.
  - Has repeated gradient/background/nav UI work on every shell rebuild.

- `dashboard_screen.dart`
  - Entire screen body is inside a `StreamBuilder` on the full `swimmers` collection.
  - Nested `StreamBuilder` listens to the full `evaluations` collection for pending evaluations.
  - Recalculates subscription counts and today's group schedule on every swimmers snapshot.
  - Uses dashboard cards to push additional full-list screens that open separate listeners.

- `subscriptions_screen.dart`
  - Phase 6B reduced duplicate swimmers listeners to one shared stream.
  - Still listens to the full `swimmers` collection and builds all filtered subscription cards in a `Column` inside a `SingleChildScrollView`.
  - Bulk renewal still performs a full collection `.get()` and sequential update loop, intentionally unchanged.

- `swimmers_list_screen.dart`
  - List area uses a full `swimmers` collection `StreamBuilder`.
  - Search filters and sorts all swimmers on every stream rebuild and every search keystroke.
  - Uses `ListView.builder`, which is good for long lists.
  - Add/edit dialog flows trigger broad parent `setState` or stream refresh behavior.

- `evaluation_screen.dart`
  - `_getSwimmersWithoutEvaluation()` listens to all swimmers and then runs a full `evaluations` `.get()` inside `asyncMap` whenever swimmers snapshots update.
  - `_getSwimmersWithoutEvaluation()` and `_getEvaluatedSwimmers()` are called from build helpers, creating stream expressions during rebuilds.
  - Both evaluated and non-evaluated lists render all cards through `Column` inside a page-level `SingleChildScrollView`, not `ListView.builder`.
  - Search filtering is recalculated on every keystroke across the full in-memory result.

- `parent_dashboard_screen.dart`
  - Multiple child pages independently query the same swimmer by current user email.
  - Attendance, evaluations, subscription, and profile pages each perform separate `.get()` calls.
  - `ModernProfilePage` creates a `FutureBuilder` future directly inside `build`, so parent rebuilds can create another `.get()`.
  - Contains several `print` calls in runtime paths.

- `admin_panel_screen.dart`
  - Scope is narrow: one filtered users stream for pending coach approvals and a `ListView.builder`.
  - Async approval/rejection methods still use context after awaits, but this is correctness/analyzer cleanup more than runtime heaviness.

- `profile_screen.dart`
  - Performs a user document `.get()` in `initState`, which is appropriate for a profile page.
  - Contains a `print` in error handling.
  - Page is large, but it does not appear to be a major navigation bottleneck compared with dashboard/evaluation/list screens.

- `login_screen.dart`
  - Large visual tree and social buttons reference missing assets.
  - Missing assets generate web runtime warnings and fallback rendering, which adds noise and can make startup feel less clean.

## 5. Rebuild Hotspots

- Main shell rebuilds:
  - `home_screen.dart` calls `setState` on every `PageView` change.
  - `parent_dashboard_screen.dart` calls `setState` on every `PageView` change.

- Large `StreamBuilder` rebuild surfaces:
  - `dashboard_screen.dart` wraps almost the entire dashboard content in the swimmers stream.
  - `subscriptions_screen.dart` now has one stream, but it still rebuilds stats, tabs, and all visible cards from the same builder.
  - `swimmers_list_screen.dart` rebuilds the whole list builder section on every swimmers snapshot.
  - `evaluation_screen.dart` rebuilds list columns from streams and recalculates filters in builders.

- Futures or streams created in build/build helpers:
  - `evaluation_screen.dart` creates stream expressions through `_getSwimmersWithoutEvaluation()` and `_getEvaluatedSwimmers()` when building list sections.
  - `parent_dashboard_screen.dart` creates a Firestore `.get()` future inside `ModernProfilePage.build`.

- Heavy calculations inside build:
  - `dashboard_screen.dart` calculates active/expired counts and group membership from all swimmers on each stream event.
  - `swimmers_list_screen.dart` filters and sorts all swimmers in the stream builder.
  - `subscriptions_screen.dart` filters full swimmers lists by search and tab.
  - `evaluation_screen.dart` filters full evaluated/non-evaluated lists.
  - `parent_dashboard_screen.dart` derives attendance records and evaluation summaries during build.

## 6. Data-Loading Hotspots

- Full collection listeners:
  - `dashboard_screen.dart`: full `swimmers` stream.
  - `dashboard_screen.dart`: full `evaluations` stream for pending count.
  - `subscriptions_screen.dart`: full `swimmers` stream, now single after Phase 6B.
  - `swimmers_list_screen.dart`: full `swimmers` stream.
  - `active_subs_screen.dart`, `expired_subs_screen.dart`, and `pending_evals_screen.dart` are pushed from dashboard and open their own listeners when entered.

- Full collection reads:
  - `evaluation_screen.dart`: full `evaluations` `.get()` inside swimmers stream `asyncMap`.
  - `parents_screen.dart`: full `swimmers` `.get()` in `initState` and after add.
  - `subscriptions_screen.dart`: full `swimmers` `.get()` during bulk renewal.

- Repeated same-user reads:
  - `parent_dashboard_screen.dart`: attendance, evaluations, subscription, and profile pages each query the swimmer by email separately.
  - `ModernProfilePage` creates its `.get()` directly inside build.

- Missing caching/memoization opportunities:
  - Parent dashboard could load the current swimmer once and share it with child pages.
  - Evaluation screen could maintain stable streams/futures in state and avoid a full evaluations `.get()` per swimmers stream event.
  - Search filters could be memoized or debounced for large local lists.

## 7. UI Rendering Hotspots

- Very large files/build methods make rebuild cost and maintenance harder:
  - `parent_dashboard_screen.dart` is about 60 KB.
  - `swimmers_list_screen.dart` is about 61 KB.
  - `subscriptions_screen.dart` is about 55 KB.
  - `evaluation_screen.dart` is about 49 KB.

- Repeated decorative gradients, shadows, opacity, and radial backgrounds appear across many screens. The visual identity should remain, but extracting shared widgets later can reduce rebuild work and reduce mistakes.
- `SingleChildScrollView` plus `Column` rendering all cards is used in `subscriptions_screen.dart` and `evaluation_screen.dart`. This can be expensive for large data sets because all rows are built eagerly.
- `dashboard_screen.dart` uses nested shrink-wrapped layout sections and a full-screen stream rebuild. This is acceptable for small data but will feel heavier as data grows.
- Several screens use translucent containers, shadows, and gradients heavily. These are not necessarily wrong, but they increase paint cost on lower-end devices and web.

## 8. Missing Asset And Runtime Warnings

- `login_screen.dart` references:
  - `assets/google.png`
  - `assets/apple.png`
- The `assets/` folder currently contains only:
  - `logo.jpg`
  - `swimming_background.jpeg`
  - `swimming_background1.jpeg`
  - `swimming_background2.jpeg`
- `pubspec.yaml` does not declare `assets/google.png` or `assets/apple.png`.
- `flutter run -d chrome` in Phase 6C reported:
  - `assets/assets/google.png` returned HTTP 404.
  - `assets/assets/apple.png` returned HTTP 404.
- This phase does not fix these assets. Treat this as a small runtime cleanliness issue and a candidate for Phase 6I.

## 9. Low-Risk Fixes

- Replace main `PageView` navigation in `home_screen.dart` with an `IndexedStack` or keep `PageView` but add lazy page creation and keep-alive behavior intentionally.
- Cache the parent dashboard current swimmer lookup once and pass data into attendance, evaluations, subscription, and profile child sections.
- Move `FutureBuilder` futures out of `build` into `initState` where the data does not need to be recreated per rebuild.
- Reduce `StreamBuilder` rebuild surfaces by putting only data-dependent sections under builders.
- Add `PageStorageKey`s to long lists to preserve scroll position while navigating.
- Convert eager `Column` list rendering to `ListView.builder` where a bounded scroll area already exists or can be introduced without visual redesign.
- Replace runtime `print` calls with `debugPrint` in later cleanup phases.
- Fix missing social login image assets or remove unused social asset references if those buttons remain placeholder-only.

## 10. Medium-Risk Fixes

- Rework `evaluation_screen.dart` so non-evaluated swimmers are computed from stable shared streams or cached snapshots instead of a swimmers stream plus repeated full evaluations `.get()`.
- Introduce lightweight repositories/providers for shared screen data and cache lifetimes, especially current swimmer, swimmers list, and evaluation summaries.
- Split large screens into smaller widgets while preserving layout and visuals. This can reduce rebuild area but should be done carefully to avoid responsive regressions.
- Add search debounce or memoized filtered lists for large local datasets.
- Replace dashboard pushed list screens with state-preserved main-tab routes only if the product flow allows it.

## 11. High-Risk Fixes To Delay

- Firestore pagination or server-side filtering for core swimmer/evaluation lists. This is valuable but can change ordering, empty states, and search semantics.
- Changing Firestore schema or adding denormalized counters.
- Replacing broad streams with aggregate documents or Cloud Functions.
- Redesigning the visual system to reduce gradients/shadows.
- Changing auth routing architecture beyond small duplicated-check cleanup.
- Reworking bulk renewal behavior or write batching before a dedicated safety phase.

## 12. Recommended Next Implementation Phases

- Phase 6E low-risk navigation smoothness fix:
  - Preserve main tab/page state intentionally.
  - Avoid eager construction of heavy pages where possible.
  - Add scroll-position preservation for main pages.
  - Keep visuals and user flows unchanged.

- Phase 6F dashboard rebuild/read optimization:
  - Reduce the dashboard `StreamBuilder` rebuild surface.
  - Avoid nesting a full evaluations stream inside the stats grid if a safer structure is available.
  - Memoize dashboard counts and group calculations per snapshot.

- Phase 6G evaluation screen performance fix:
  - Stop repeated full evaluations `.get()` calls inside swimmers stream updates.
  - Stabilize stream creation.
  - Convert eager card columns to builder-based rendering where safe.

- Phase 6H list rendering optimization:
  - Review `subscriptions_screen.dart`, `swimmers_list_screen.dart`, parents, active/expired/pending screens.
  - Preserve search and filtering behavior while reducing eager list builds.
  - Add keys and scroll preservation where appropriate.

- Phase 6I missing assets cleanup:
  - Fix or remove the missing `google.png` and `apple.png` asset references.
  - Update `pubspec.yaml` only if real assets are added.
  - Confirm Chrome runtime no longer logs 404 asset warnings.

## 13. What Code Was Changed

No production Dart files were modified in Phase 6D.

Only this documentation file was created:

- `docs/phase_6d_navigation_runtime_performance_audit.md`

Note: existing uncommitted changes from prior phases may still appear in `git status`, including `lib/screens/subscriptions_screen.dart` from Phase 6C and prior documentation files. They were not modified by this audit phase.

## 14. Commands Run

Inspection commands:

```powershell
git -c safe.directory=C:/Users/hp/AndroidStudioProjects/swim -C C:/Users/hp/AndroidStudioProjects/swim status --short
rg -n "Navigator\.|pushReplacement|pushNamed|MaterialPageRoute|BottomNavigationBar|IndexedStack|PageView|TabBarView|FutureBuilder|StreamBuilder|\.get\(|\.snapshots\(|setState\(|ListView\(|ListView\.builder|SingleChildScrollView|Image\.asset|AssetImage|google\.png|apple\.png" lib\screens lib\features -S
Get-ChildItem -Path lib\screens -File | Select-Object Name,Length
rg -n "assets:|assets/|uses-material-design" pubspec.yaml firebase.json web -S
```

Verification commands:

```powershell
flutter analyze
flutter test
flutter run -d chrome
```

## 15. Known Risks And TODOs

- This was a static/runtime-pattern audit, not a profiler trace. DevTools frame timing should be used before and after each implementation phase.
- Some findings depend on current data size. The full-list patterns become more important as swimmer/evaluation counts grow.
- Main navigation smoothness may improve from state preservation, but Firebase read reduction requires separate, carefully scoped phases.
- Missing assets should be fixed separately so this audit remains non-production-code-only.
- Existing analyzer issues in files outside this phase remain and may keep `flutter analyze` nonzero.
