# Phase 6E2 Home Navigation Jank Hotfix Summary

## 1. Phase Goal

Fix noticeable jank when navigating between distant HomeScreen pages, such as Dashboard directly to Profile, without changing UI, Firebase behavior, page order, user flows, or child screens.

## 2. Files Modified

- `lib/screens/home_screen.dart`
- `docs/phase_6e2_home_navigation_jank_hotfix_summary.md`

## 3. Root Cause Suspected

`HomeScreen` used `PageController.animateToPage(...)` for direct floating navigation taps. When jumping from a low index to a far index, the animated `PageView` transition can traverse intermediate pages. Because several intermediate pages own heavy build surfaces and Firestore listeners, this can cause visible stutter.

## 4. What Changed

- Direct floating navigation taps now call `_pageController.jumpToPage(index)` instead of `animateToPage(...)`.
- `_currentIndex` is updated immediately for direct taps.
- Taps on the already-selected page still do nothing.
- Swipe gestures remain enabled and continue to update the selected index through `onPageChanged`.
- Phase 6E page keys, stable page list, and `PageController.dispose()` remain intact.

## 5. Behavior That Should Remain Exactly The Same

- Same pages in the same order:
  - Dashboard
  - Evaluation
  - Subscription
  - Parents
  - Profile
- Same floating navigation icons, labels, spacing, colors, gradients, and selected styling.
- Same Dashboard-only header behavior.
- Same admin menu behavior.
- Same logout and change-password flows.
- Same Firebase reads, writes, queries, listeners, collection names, and field names.
- Same child screen behavior.

## 6. Performance Improvement Expected

- Direct taps between distant pages should feel snappier because the app no longer animates through intermediate heavy pages.
- Intermediate pages should not be traversed as part of tap navigation.
- Existing swipe behavior remains available for users who intentionally swipe between adjacent pages.

## 7. What Was Intentionally Not Changed

- No child screens were modified.
- No Firestore behavior was changed.
- No visual redesign was performed.
- No routing package was added.
- No `IndexedStack` conversion was done in this phase.
- No dashboard/evaluation/subscriptions/list performance refactors were included.

## 8. Manual Testing Checklist

- Start on Dashboard and tap Profile. Confirm the page changes directly with less stutter.
- Tap Dashboard from Profile. Confirm the page changes directly.
- Tap Evaluation, Subscription, Parents, and Profile from the nav bar and confirm labels/icons/order are unchanged.
- Tap the currently selected tab and confirm nothing changes.
- Swipe between adjacent pages and confirm the selected nav item updates.
- Confirm Dashboard header still appears only on Dashboard.
- Confirm no Firebase data behavior changes are visible.
- Check mobile and web viewport layouts.

## 9. Commands To Run

```powershell
dart format lib\screens\home_screen.dart
flutter analyze
flutter test
flutter run -d chrome
flutter build web --release --base-href /
```

## 10. Known Risks Or Remaining TODOs

- This hotfix avoids animated traversal but does not reduce the heavy listeners/build work inside child screens.
- Very heavy destination pages may still take time to render when first opened.
- Further performance work remains for dashboard and evaluation screens in later phases.
- `flutter analyze` may still report existing info-level issues in files outside `home_screen.dart`.

## 11. Responsive UI Notes

- No layout, spacing, labels, colors, icons, gradients, or responsive behavior were changed.
