# Phase 6F Dashboard Performance Summary

## 1. Phase Goal

Optimize `dashboard_screen.dart` runtime performance in a low-risk way while preserving the dashboard UI, Firebase schema, Firestore queries, user flows, navigation, dashboard values, and visual identity.

## 2. Files Modified

- `lib/screens/dashboard_screen.dart`
- `docs/phase_6f_dashboard_performance_summary.md`

## 3. Existing Dashboard Performance Issues Found

- The dashboard created the full swimmers `snapshots()` stream directly inside `build`.
- The pending evaluations card created the full evaluations `snapshots()` stream inside a nested `StreamBuilder` in `build`.
- Active and expired subscription counts were calculated with separate `.where(...)` passes over the same swimmers list.
- Pending evaluation count was calculated inline inside the widget builder.
- Attendance toggling inside the group dialog used `context` after an async Firestore update.

## 4. What Changed

- Converted `DashboardScreen` from `StatelessWidget` to `StatefulWidget`.
- Cached the existing swimmers stream in `initState`.
- Cached the existing evaluations stream in `initState`.
- Kept the exact same Firestore collections and snapshot query behavior.
- Moved active, expired, and total swimmer counting into `_getSubscriptionCounts(...)`.
- Moved pending evaluation counting into `_getPendingEvaluationCount(...)`.
- Added mounted checks after the attendance update await before dialog `setState` and snackbar context usage.

## 5. Behavior That Should Remain Exactly The Same

- Dashboard layout, cards, labels, icons, colors, gradients, shadows, and spacing.
- Total swimmer count.
- Active subscription count.
- Expired subscription count.
- Pending evaluation count.
- Today's schedule group display.
- Group details dialog.
- Attendance toggle writes.
- Navigation from dashboard cards.

## 6. Firebase Behavior

Changed:

- Stream objects are now created once per `DashboardScreen` state instance instead of being recreated during rebuilds.

Unchanged:

- Firestore collection names.
- Firestore field names.
- Firestore query semantics.
- The swimmers stream still listens to `AppCollections.swimmers`.
- The evaluations stream still listens to `AppCollections.evaluations`.
- Attendance update payloads are unchanged.
- No pagination, denormalized counters, where filters, or schema changes were added.

## 7. Performance Improvement Expected

- Reduces avoidable stream recreation during dashboard rebuilds.
- Reduces repeated count work by calculating active and expired counts in one pass over swimmers.
- Keeps pending evaluation count logic outside the widget tree for a smaller builder body.
- Avoids context-after-dispose risks after attendance updates.

## 8. What Was Intentionally Not Changed

- No dashboard redesign.
- No changes to child screens.
- No changes to HomeScreen navigation.
- No changes to Firestore reads/listeners beyond stabilizing existing stream objects.
- No server-side counters.
- No pagination.
- No schedule calculation behavior changes.

## 9. Manual Testing Checklist

- Open Dashboard and confirm all cards look unchanged.
- Confirm Total Swimmers, Active Subs, Expired Subs, and Pending Evals match previous behavior.
- Tap each dashboard stat card and confirm it navigates to the same screen.
- Confirm today's schedule groups and swimmer counts still match previous behavior.
- Open a group details dialog and toggle attendance.
- Confirm attendance snackbar appears and the write succeeds.
- Revisit Dashboard from other main pages and confirm it feels lighter.
- Check mobile and web viewport layouts.

## 10. Commands To Run

```powershell
dart format lib\screens\dashboard_screen.dart
flutter analyze
flutter test
flutter run -d chrome
flutter build web --release --base-href /
```

## 11. Known Risks Or Remaining TODOs

- The dashboard still listens to full swimmers and evaluations collections.
- The full dashboard body is still built from the swimmers stream.
- The pending evaluations card still uses a nested `StreamBuilder`.
- Further optimization may reduce rebuild surface or move shared counts to a later dedicated phase.
- Existing analyzer info-level findings in other files may keep `flutter analyze` nonzero.

## 12. Responsive UI Notes

- No layout, spacing, card, gradient, icon, or responsive behavior was changed.
