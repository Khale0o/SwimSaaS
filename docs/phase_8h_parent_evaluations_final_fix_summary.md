# Phase 8H Parent Evaluations Final Fix

## Root Cause Found
The parent dashboard was querying the correct collection and field:

```text
Evaluations where parentUid == currentUser.uid
```

However, the query also used `orderBy(date)`. Firestore `orderBy` only returns documents where that ordered field exists. Legacy evaluation documents can have the correct `parentUid` but no usable `date`, so the parent-owned query could return zero documents and the UI showed the empty state.

## Files Changed
- `lib/screens/parent_dashboard_screen.dart`
- `docs/phase_8h_parent_evaluations_final_fix_summary.md`

## Exact Query Before / After
Before:

```text
Evaluations.where(parentUid == uid).orderBy(date desc)
```

After:

```text
Evaluations.where(parentUid == uid)
```

The dashboard now sorts returned evaluations in memory by `date` or `evaluatedAt` when available. Documents are not dropped just because `date` is missing.

## Why Attendance Worked But Evaluations Did Not
Attendance reads from the linked swimmer document after `swimmers.parentUid` is set. Evaluations were a separate Firestore query and could be filtered out by `orderBy(date)` even when `Evaluations.parentUid` was correct.

## Rules / Index Notes
- `AppFields.parentUid` is exactly `parentUid`.
- Evaluation parsing reads `parentUid`.
- Firestore rules still allow parent reads only when `request.auth.uid == resource.data.parentUid`.
- No broad parent read was added.
- Existing indexes remain valid, but the primary parent dashboard query no longer depends on the `parentUid + date` index.

## Debug Logging
Parent evaluation loading now logs, in debug mode only:
- current user uid/email
- linked swimmer count and ids
- query path used
- returned evaluation count
- first returned evaluation id, `parentUid`, `swimmerId`, and name
- Firebase exception code/message

## Manual QA Checklist
1. Register/login parent with email matching `swimmer.email`.
2. Confirm `swimmers.parentUid` is set.
3. Create evaluation for that swimmer as coach/admin.
4. Confirm evaluation has `parentUid == parent uid`.
5. Login parent and confirm evaluation appears.
6. Confirm another parent cannot see it.
7. Check Chrome console for permission-denied/missing-index errors.
