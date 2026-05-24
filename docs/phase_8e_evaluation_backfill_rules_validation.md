# Phase 8E Evaluation Backfill and Rules Validation

## Phase Goal
Prepare the single-academy app for safe production rule deployment by adding a reviewed backfill helper for legacy `Evaluations` ownership fields and documenting Firebase rules validation steps.

## Files Changed
- `tool/backfill_evaluation_ownership.dart`
- `docs/phase_8e_evaluation_backfill_rules_validation.md`

No production app screens, routes, UI, Firestore rules, or data model fields were changed in this phase.

## Why Backfill Is Required
Strict rules allow parents to read `Evaluations` only when:

```text
request.auth.uid == resource.data.parentUid
```

Legacy `Evaluations` documents created before Phase 8D may not have `parentUid`, `swimmerId`, or `swimmerName`. Those records will not be visible to parents after strict rules are deployed until they are safely backfilled.

## Backfill Tool
Added:

```text
tool/backfill_evaluation_ownership.dart
```

The tool uses the Firestore REST API and requires:
- `--project-id`
- an access token via `--access-token`, `FIRESTORE_ACCESS_TOKEN`, or `--use-gcloud-token`

It reads:
- `Evaluations`
- `swimmers`
- `users`

It matches legacy evaluations to swimmers by normalized swimmer name and only accepts unique swimmer-name matches.

## How Dry-Run Works
Dry-run is the default:

```powershell
dart tool\backfill_evaluation_ownership.dart --project-id swim-38b51 --use-gcloud-token
```

Dry-run prints:
- total evaluations scanned
- already backfilled count
- matched count
- ambiguous count
- missing swimmer count
- missing parentUid count
- would-update count
- manual-review rows

Dry-run does not write anything.

## How Apply Mode Works
Apply mode requires `--apply`:

```powershell
dart tool\backfill_evaluation_ownership.dart --project-id swim-38b51 --use-gcloud-token --apply
```

Apply mode updates only safe unique matches and writes:
- `swimmerId`
- `swimmerName`
- `parentUid`
- `updatedAt`

The tool does not delete anything and does not overwrite existing non-empty `parentUid`.

## Required Safety Checks Before Apply
- Export or back up Firestore.
- Run dry-run and save the report.
- Confirm `would-update` count is expected.
- Review all ambiguous and missing-owner rows.
- Confirm parent users exist with emails matching swimmer emails.
- Confirm no duplicate swimmer names will cause unsafe matches.
- Run apply first on a staging/demo copy if possible.

## Manual Review Instructions
For ambiguous matches:
- Compare swimmer name, email, phone, level, and training schedule manually.
- Do not update by name alone if there are duplicates.
- Resolve ambiguity by manually adding the correct `swimmerId` and `parentUid`, or by correcting duplicate swimmer records before re-running dry-run.

For missing parent uid:
- Ensure the swimmer has a parent email.
- Ensure a `users` document exists for that email with `role == parent`.
- If needed, manually add `parentUid` to the swimmer first, then re-run dry-run.

## Backup / Rollback Recommendation
Before apply:
- Export Firestore or take a managed backup.
- Save the dry-run report.
- Save the list of updated evaluation ids from apply output.

Rollback can be done by restoring the backup or manually clearing/reverting the four added fields from the affected evaluation ids if the update list was saved.

## Rules Validation Checklist
Use Firebase Emulator Suite or a staging Firebase project before deploying rules:
- Approved coach/admin can read and write `Evaluations`.
- Parent can read only docs where `parentUid == auth.uid`.
- Parent cannot read docs for another parent.
- Parent cannot read legacy docs without `parentUid`.
- Unauthenticated user is denied.
- Normal user cannot create/update/delete evaluation documents.
- Normal user cannot change ownership fields.

Firebase CLI was not available in this environment, so emulator validation was not run here.

## Parent Dashboard QA Checklist
- Backfilled parent sees their child evaluations.
- Parent with multiple same-name swimmers is manually checked.
- Parent cannot see another parent's child evaluation.
- Legacy evaluation without `parentUid` does not crash the app.
- Empty parent evaluations state still renders cleanly.
- Build/deploy still works after backfill.

## Commands Run
- `dart format tool\backfill_evaluation_ownership.dart`
- `dart analyze tool\backfill_evaluation_ownership.dart` attempted, but timed out in this shell.
- `dart tool\backfill_evaluation_ownership.dart --help` attempted, but timed out in this shell.
- `flutter analyze`
- `flutter test`
- `flutter build web --release --base-href /`
- `firebase --version` attempted; Firebase CLI is not installed.

## Remaining Production Blockers
- Run the backfill dry-run against the real project.
- Review ambiguous/missing-owner rows.
- Back up Firestore before `--apply`.
- Run Firebase emulator/staging rules validation.
- Deploy rules only after backfill and validation pass.
