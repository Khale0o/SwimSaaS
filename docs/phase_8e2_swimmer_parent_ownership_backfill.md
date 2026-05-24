# Phase 8E2 Swimmer Parent Ownership Backfill

## Phase Goal
Prepare the single-academy production dataset for secure evaluation ownership backfill by adding a dry-run-first helper that can populate missing `swimmers.parentUid` from existing parent user records.

## Files Changed
- `tool/backfill_swimmer_parent_ownership.dart`
- `docs/phase_8e2_swimmer_parent_ownership_backfill.md`

No production app screens, routes, UI, Firestore rules, or Firebase schema names were changed.

## Why This Phase Is Required
The Phase 8E evaluation backfill dry-run found legacy evaluations that could be matched to swimmers, but those swimmer documents did not have a unique `parentUid`.

Strict production rules depend on stable ownership fields. Before safely backfilling `Evaluations.parentUid`, the matched swimmer records need `parentUid` where it can be resolved from existing data.

## Backfill Tool
Added:

```text
tool/backfill_swimmer_parent_ownership.dart
```

The tool uses the Firestore REST API and requires:
- `--project-id`
- an access token through `--access-token`, `FIRESTORE_ACCESS_TOKEN`, or `--use-gcloud-token`

It reads:
- `swimmers`
- `users`

Parent users are identified by:

```text
role == parent
```

It tries these swimmer fields as parent email identifiers:
- `parentEmail`
- `parent_email`
- `guardianEmail`
- `guardian_email`
- `email`

The current legacy app primarily uses `swimmers.email`.

## How Dry-Run Works
Dry-run is the default:

```powershell
dart tool\backfill_swimmer_parent_ownership.dart --project-id swim-38b51 --use-gcloud-token
```

Dry-run reports:
- total swimmers scanned
- already has `parentUid`
- uniquely matched
- ambiguous parent matches
- missing parent identifier
- missing parent user
- would-update count
- manual-review rows

Dry-run does not write anything.

## How Apply Mode Works
Apply mode requires `--apply`:

```powershell
dart tool\backfill_swimmer_parent_ownership.dart --project-id swim-38b51 --use-gcloud-token --apply
```

Apply mode updates only safe unique matches and writes:
- `parentUid`
- `updatedAt`

The tool never deletes data and never overwrites an existing non-empty `swimmers.parentUid`.

## Safety Rules
- Dry-run by default.
- Writes require explicit `--apply`.
- Existing non-empty `parentUid` is skipped.
- Ambiguous parent email matches are skipped.
- Swimmers with no usable parent email are skipped.
- Swimmers with no matching parent user are skipped.
- No swimmer names, subscriptions, attendance, groups, levels, or unrelated fields are changed.

## Manual Review Instructions
Review every manual-review row before apply:
- For duplicate parent users with the same email, merge or correct the duplicate user records first.
- For missing parent users, confirm whether the swimmer email is a parent email or a swimmer/contact email.
- For missing identifiers, manually identify the correct parent account before setting ownership.
- Do not infer ownership from swimmer name alone.

## Backup Recommendation Before Apply
Before running with `--apply`:
- Export or back up Firestore.
- Save the dry-run output.
- Confirm `would-update` matches expectations.
- Prefer running on a staging/demo copy first.

## Rerun Phase 8E After This
After `swimmers.parentUid` is safely backfilled:

```powershell
dart tool\backfill_evaluation_ownership.dart --project-id swim-38b51 --use-gcloud-token
```

If the evaluation dry-run report is clean and reviewed, run its `--apply` mode to write `swimmerId`, `swimmerName`, `parentUid`, and `updatedAt` to legacy `Evaluations` documents.

## Remaining Production Blockers
- Run swimmer parent ownership dry-run against the real Firebase project.
- Review ambiguous and missing-parent rows.
- Back up Firestore before apply.
- Run Phase 8E evaluation ownership dry-run again after swimmer ownership is fixed.
- Validate Firestore rules in emulator or staging before deployment.
- Do not deploy strict rules until parent dashboard QA passes with backfilled data.
