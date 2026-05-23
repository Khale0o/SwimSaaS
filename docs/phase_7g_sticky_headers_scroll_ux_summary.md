# Phase 7G Sticky Headers Scroll UX Summary

## 1. Phase Goal

Remove unwanted large sticky/fixed header behavior so production screens do not waste visible space while content scrolls, starting with the normal Dashboard flow and auditing the other main screens.

## 2. Files Inspected

- `lib/screens/dashboard_screen.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/evaluation_screen.dart`
- `lib/screens/subscriptions_screen.dart`
- `lib/screens/parents_screen.dart`
- `lib/screens/profile_screen.dart`
- `lib/screens/parent_dashboard_screen.dart`
- `lib/screens/swimmer_dashboard_screen.dart`
- `lib/screens/swimmers_list_screen.dart`
- `lib/screens/active_subs_screen.dart`
- `lib/screens/expired_subs_screen.dart`
- `lib/screens/pending_evals_screen.dart`

## 3. Files Modified

- `lib/screens/home_screen.dart`
- `lib/screens/parent_dashboard_screen.dart`
- `docs/phase_7g_sticky_headers_scroll_ux_summary.md`

## 4. Exact Dashboard Sticky/Fixed Header Issue Found

`dashboard_screen.dart` already placed its large welcome section inside the Dashboard `SingleChildScrollView`, so that section was not the sticky item.

The unwanted fixed header came from `home_screen.dart`: `_buildModernHeader()` was rendered above the Dashboard `PageView` when `_currentIndex == 0`. Because the Dashboard content scrolls inside the PageView, this shell header stayed fixed and consumed vertical space while the Dashboard content scrolled underneath.

## 5. What Changed In Dashboard

No direct `dashboard_screen.dart` change was needed. The fix was applied in the HomeScreen shell that owns the fixed Dashboard header:

- Added `_dashboardHeaderVisible` state.
- Wrapped the shell Dashboard header in `AnimatedSize`.
- Added a `NotificationListener<ScrollNotification>` around the HomeScreen `PageView`.
- When Dashboard vertical scroll offset moves away from the top, the shell header collapses out of the layout.
- When Dashboard scroll returns to the top, the shell header appears again.

## 6. Whether Phase 7E Dashboard Responsive Grid Was Preserved

Yes. `dashboard_screen.dart` was not modified in this phase, so the Phase 7E responsive max-width wrapper and desktop four-column stats grid remain intact.

## 7. Other Screens Audited And Result

- Evaluation: no issue. Its large welcome section is inside a `SingleChildScrollView`.
- Subscriptions: no issue. Its large welcome section is inside a `SingleChildScrollView`.
- Parents: no issue. Its large welcome section is inside a `SingleChildScrollView`.
- Profile: no issue. Its large welcome section is inside a `SingleChildScrollView`.
- Parent Dashboard: has issue. Its large shell header was fixed above its internal `PageView`; fixed in this phase with the same collapse-on-scroll pattern.
- Swimmer Dashboard: no large sticky hero issue; it uses a normal small `AppBar`.
- Swimmers List: deferred. It has a normal back/app bar plus a large welcome section outside the internal list scroll; fixing it cleanly would require restructuring the list screen scroll ownership.
- Active Subs: deferred for the same reason as Swimmers List.
- Expired Subs: deferred for the same reason as Swimmers List.
- Pending Evals: deferred for the same reason as Swimmers List.

## 8. Any Other Screens Modified And Why

`parent_dashboard_screen.dart` was modified because it clearly had the same unwanted large fixed header pattern as the Dashboard shell: a large header outside an internal `PageView` whose child pages scroll independently.

## 9. What Behavior Should Remain Unchanged

- Header text, colors, icons, gradients, typography, labels, menu items, and visual identity are unchanged.
- Normal navigation/back controls remain unchanged.
- Bottom floating navigation remains unchanged.
- Dashboard card counts, navigation, schedule display, and group dialogs remain unchanged.
- Parent Dashboard tab order and content remain unchanged.

## 10. Firebase Behavior Confirmation

- No schema changes.
- No collection changes.
- No field changes.
- No query changes.
- No read/write changes.
- No stream changes.

## 11. Mobile/Responsive Behavior Confirmation

- No mobile redesign was made.
- Phase 7C HomeScreen desktop constraints are preserved.
- Phase 7E Dashboard responsive grid is preserved.
- Phase 7D and Phase 7F keep-alive/loading preservation wrappers are preserved.
- The header collapse is driven by vertical scroll offset and applies on mobile and desktop.

## 12. Manual Testing Checklist

- Open Dashboard.
- Scroll down and confirm the large top dashboard shell header scrolls/collapses away.
- Confirm it no longer stays fixed and consumes screen height.
- Confirm dashboard stat cards still show correct values.
- Confirm today schedule/group section still works.
- Confirm dashboard desktop 4-column stats from Phase 7E still work.
- Confirm mobile dashboard is not intentionally redesigned.
- Confirm floating nav does not cover important content.
- Open Evaluation, Subscriptions, Parents, Profile, Parent Dashboard, and other audited screens.
- Scroll each screen and confirm no large unwanted sticky header remains on the fixed screens.
- Confirm normal navigation/back controls still work where expected.
- Confirm no Firebase data behavior changed.

## 13. Commands Run

- `rg -n "Scaffold|AppBar|SliverAppBar|SliverPersistentHeader|Stack\\(|Positioned\\(|SingleChildScrollView|ListView|CustomScrollView|PageView|Expanded\\(|_buildWaterWelcomeSection|_buildModernHeader|floatingActionButton" ...`
- `Get-Content lib\screens\dashboard_screen.dart`
- `Get-Content lib\screens\home_screen.dart`
- `Get-Content lib\screens\parent_dashboard_screen.dart`
- `git -c safe.directory=C:/Users/hp/AndroidStudioProjects/swim status --short`
- `dart format lib\screens\home_screen.dart lib\screens\parent_dashboard_screen.dart`
- `flutter analyze`
- `flutter test`
- `flutter build web --release --base-href /`
- `flutter run -d chrome --no-resident`

Verification results:

- `dart format lib\screens\home_screen.dart lib\screens\parent_dashboard_screen.dart`: passed.
- `flutter analyze`: completed with 40 existing info-level findings in older feature/admin screens; no new errors were introduced.
- `flutter test`: passed, 10 tests.
- `flutter build web --release --base-href /`: passed.
- `flutter run -d chrome --no-resident`: launched Chrome in debug mode and finished successfully.

## 14. Known Risks And TODOs

- Swimmers List, Active Subs, Expired Subs, and Pending Evals still have fixed top sections above internal list scrolls. They were deferred because a clean fix should restructure each screen's scroll ownership in a targeted phase.
- The shell header now collapses based on scroll offset rather than being physically inside the child scroll view. This is a small reversible shell fix that avoids rewriting Dashboard internals.
- Manual QA should confirm the collapse threshold feels natural at mobile and desktop sizes.
