# Phase 6B Subscriptions Listener Optimization Summary

## 1. Phase Goal

Reduce duplicate Firestore listener overhead in `subscriptions_screen.dart` by sharing one existing swimmers collection stream result for both subscription statistics and list rendering.

## 2. Files Modified

- `lib/screens/subscriptions_screen.dart`
- `docs/phase_6b_subscriptions_listener_optimization_summary.md`

## 3. Duplicate Listener Pattern Before

`subscriptions_screen.dart` opened two separate full `swimmers` collection snapshot listeners in the same screen:

- one `StreamBuilder<QuerySnapshot>` for the quick statistics cards
- one `StreamBuilder<QuerySnapshot>` for tab filtering, search filtering, and subscription card rendering

Both listeners used the same collection stream:

```dart
_firestore.collection(AppCollections.swimmers).snapshots()
```

## 4. What Changed

- Added one cached `_swimmersStream` on `_SubscriptionsScreenState`.
- Initialized that stream once in `initState()` using the same existing `AppCollections.swimmers` snapshots query.
- Replaced the two duplicate `StreamBuilder<QuerySnapshot>` widgets with one shared `StreamBuilder<QuerySnapshot>`.
- Reused the single loaded `snapshot.data!.docs` list for:
  - subscription statistics
  - active, expiring soon, expired, and total counts
  - tab filtering
  - search filtering
  - subscription card rendering
- Extracted the existing tab container markup into `_buildTabsSection()` so the visual structure remains the same while being rendered from the shared stream builder.

## 5. Behavior That Should Remain Exactly The Same

- Search by swimmer name.
- All, Active, Expiring, and Expired tab behavior.
- Active, Expiring Soon, Expired, and Total statistics calculations.
- Empty states.
- Loading states.
- Individual subscription renewal behavior.
- Bulk renewal behavior.
- Navigation and screen order.
- Existing responsive scroll behavior and Phase 1 layout fixes.

## 6. Firebase Behavior

Changed:

- The subscriptions screen now opens one full `swimmers` collection snapshots listener instead of two duplicate full listeners for the same screen data.

Not changed:

- Firestore collection names.
- Firestore field names.
- Status string values.
- Firestore schema or stored data.
- The snapshots query itself.
- Individual renewal writes.
- Bulk renewal writes and its existing one-time `get()` behavior.
- Any other screens, including `active_subs_screen.dart` and `expired_subs_screen.dart`.

## 7. Manual Testing Checklist

- Open the subscriptions screen and confirm the header, search bar, stats, tabs, list cards, and floating action button look unchanged.
- Confirm stats show the same Total, Active, Expiring, and Expired counts as before.
- Search for a swimmer by name and confirm the same cards appear.
- Switch between All, Active, Expiring, and Expired tabs and confirm filtering is unchanged.
- Renew one swimmer subscription and confirm the success snackbar and updated subscription data.
- Use bulk renewal and confirm it still renews expired and expiring soon subscriptions only.
- Test on a narrow/mobile viewport to confirm there is no new overflow and scrolling still works.

## 8. Commands To Run

```powershell
dart format lib\screens\subscriptions_screen.dart
flutter analyze
flutter test
flutter run -d chrome
```

## 9. Known Risks Or Remaining TODOs

- The screen still listens to the full `swimmers` collection. Pagination and Firestore `where` filters are intentionally left for a later phase.
- Bulk renewal still performs its existing full collection `get()` and update loop. That behavior was intentionally not changed in Phase 6B.
- Counts still depend on the existing `_getSubscriptionStatus()` logic and `DateTime.now()` behavior, including the current expiring-soon threshold.

## 10. Responsive UI Notes

- No broad layout refactor was performed.
- Existing spacing, colors, gradients, cards, tab order, scroll behavior, and visual identity were preserved.
- The tab markup was moved into a helper without changing its layout values.
