# Phase 6G Evaluation Performance Summary

## 1. Phase Goal

Reduce unnecessary Firebase reads and rebuild work in `evaluation_screen.dart` without changing the UI, Firebase schema, Firestore fields, stored data shape, user flows, or evaluation behavior.

## 2. Files Modified

- `lib/screens/evaluation_screen.dart`
- `docs/phase_6g_evaluation_performance_summary.md`

## 3. Existing Evaluation Performance Issues Found

- `_getSwimmersWithoutEvaluation()` listened to the full swimmers collection and then performed a full evaluations `.get()` inside `asyncMap`.
- That full evaluations `.get()` could run again every time the swimmers stream emitted.
- Stream expressions were created from build helper methods instead of being stable state fields.
- Search filtering logic was duplicated in evaluated and non-evaluated list builders.
- Several dialog actions used `context` after async Firestore writes/deletes.
- `_searchController` did not have a local `dispose()` override.

## 4. Firebase Reads And Listeners Before

- Non-evaluated swimmers mode:
  - Full `swimmers` snapshots listener.
  - Full `evaluations` one-time `.get()` triggered inside each swimmers stream update.

- Evaluated swimmers mode:
  - Full `evaluations` snapshots listener ordered by `date` descending.

- Dialog actions:
  - Existing add, update, and delete writes to `AppCollections.evaluations`.

## 5. What Changed

- Added stable `_swimmersStream` and `_evaluationsStream` fields initialized once in `initState`.
- Removed the repeated full evaluations `.get()` from the swimmers stream path.
- Non-evaluated swimmers are now derived in memory from the stable swimmers and evaluations snapshots using the same lowercased swimmer-name matching logic.
- Evaluated swimmers mode reuses the stable evaluations stream.
- Shared name filtering through `_filterByName(...)`.
- Added mounted checks after async evaluation add/update/delete operations before `Navigator` and `ScaffoldMessenger` calls.
- Disposed `_searchController`.
- Applied low-risk local lint cleanup.

## 6. Behavior That Should Remain Exactly The Same

- Screen layout, cards, colors, gradients, icons, spacing, labels, text, dialogs, and scroll behavior.
- Search behavior.
- Evaluated vs non-evaluated switch behavior.
- Evaluation creation fields and saved data shape.
- Evaluation edit behavior and update payload.
- Evaluation delete behavior.
- Existing name-based matching between swimmers and evaluations.
- No pagination or server-side filtering was added.

## 7. Firebase Behavior

Changed:

- The repeated full evaluations `.get()` inside the swimmers stream path was removed.
- The screen now uses stable stream fields for swimmers and evaluations while the relevant view is mounted.

Unchanged:

- Firestore collection names.
- Firestore field names.
- Evaluation status values.
- Evaluation add/update/delete payloads.
- Evaluated swimmers query remains ordered by `date` descending.
- No schema changes, migrations, or new where filters were introduced.

## 8. Performance Improvement Expected

- Avoids repeated full evaluations reads caused by swimmers stream updates.
- Reduces stream recreation during rebuilds.
- Keeps filtering/counting logic out of the widget builder bodies where practical.
- Makes the non-evaluated/evaluated lists respond from stable stream data instead of mixing a stream with repeated full reads.

## 9. What Was Intentionally Not Changed

- No UI redesign.
- No child screen or parent navigation changes.
- No Firestore schema or data migration.
- No swimmerId-based matching migration.
- No pagination.
- No server-side where filters.
- No changes to evaluation dialogs or saved field names.

## 10. Manual Testing Checklist

- Open Evaluation screen and confirm the UI looks unchanged.
- Confirm "Swimmers Without Evaluation" still lists swimmers by the existing name-matching behavior.
- Toggle to "Evaluated Swimmers" and confirm evaluated cards still appear in the same date-descending behavior.
- Search both modes by swimmer/evaluation name.
- Add an evaluation from the floating action button.
- Add an evaluation from a swimmer card.
- Edit an evaluation.
- Delete an evaluation.
- Confirm success/error snackbars still appear.
- Check web and mobile viewport layouts.

## 11. Commands To Run

```powershell
dart format lib\screens\evaluation_screen.dart
flutter analyze
flutter test
flutter run -d chrome
flutter build web --release --base-href /
```

## 12. Known Risks Or Remaining TODOs

- The screen still listens to full swimmers and evaluations collections.
- List rendering still uses `SingleChildScrollView` plus `Column`, preserving current layout but still eagerly building cards.
- Name-based matching remains fragile if duplicate swimmer names exist; schema-safe swimmerId matching is intentionally deferred.
- Existing analyzer info-level findings in other files may keep `flutter analyze` nonzero.

## 13. Responsive UI Notes

- No layout, spacing, responsive behavior, cards, gradients, labels, or dialogs were changed.
