# Phase 8G Parent Evaluation parentUid Query Hotfix

## Actual Root Cause Found
Parent evaluation ownership fields were present, and `AppFields.parentUid` correctly equals `parentUid`.

The parent dashboard did query `Evaluations` by `parentUid`, but then applied an extra client-side filter against the first loaded swimmer document id. If the evaluation's `swimmerId` did not match that first swimmer id, or the parent had multiple linked swimmers, valid parent-owned evaluations could be dropped from the UI.

## Query Behavior Before
- Load one swimmer using `swimmers.parentUid == currentUser.uid`, with email fallback.
- If that swimmer had `parentUid`, query `Evaluations.parentUid == currentUser.uid`.
- Then filter each evaluation by `swimmerId == firstSwimmerDoc.id` unless `swimmerId` was missing.

That final filter could hide valid evaluations even when `Evaluation.parentUid` was correct.

## Query Behavior After
- Load owned swimmer data for page context, still preferring `swimmers.parentUid == currentUser.uid`.
- Load evaluations primarily with:

```text
Evaluations.parentUid == currentUser.uid
```

- Display those parent-owned evaluations without requiring a match to the first swimmer id.
- Legacy name fallback remains only when no parent-owned evaluations are found and the loaded swimmer has no `parentUid`.

## Rules / Index Notes
- `firestore.rules` already allows parent reads only when:

```text
request.auth.uid == resource.data.parentUid
```

- No broad parent read was added.
- `firestore.indexes.json` already includes the required index:
  - collection group: `Evaluations`
  - `parentUid` ascending
  - `date` descending

## Manual QA Checklist
- Login as the parent whose UID exists in `swimmer.parentUid` and `Evaluation.parentUid`.
- Confirm Attendance still appears.
- Confirm Evaluations appear.
- Confirm another parent cannot see these evaluations.
- Create a new evaluation as coach/admin and confirm it appears for the parent.
- Check Chrome console for permission-denied or missing-index errors.

## Commands Run
- `dart format lib\screens\parent_dashboard_screen.dart`
- `flutter analyze`
- `flutter test`
- `flutter build web --release --base-href /`
