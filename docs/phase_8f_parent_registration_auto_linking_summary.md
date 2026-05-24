# Phase 8F Parent Registration Auto-Linking Summary

## Files Changed
- `lib/features/auth/data/parent_linking_service.dart`
- `lib/features/auth/presentation/auth_gate.dart`
- `lib/screens/create_account_screen.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/parent_dashboard_screen.dart`
- `firestore.rules`
- `test/model_parsing_test.dart`
- `docs/phase_8f_parent_registration_auto_linking_summary.md`

## What Changed
Added a focused parent linking helper that links legacy swimmer records to the current parent user when the swimmer email matches the parent account email.

The helper:
- Trims/lowercases the parent email for matching.
- Checks legacy parent email fields: `parentEmail`, `parent_email`, `guardianEmail`, `guardian_email`, and `email`.
- Writes only `swimmers.parentUid` and `updatedAt`.
- Skips already-linked swimmers.
- Never overwrites a non-empty `parentUid` owned by another user.
- Never deletes data.

## Registration/Login Behavior
After a parent account is created, the app attempts to link matching swimmer records to that new parent uid. If no swimmer exists yet, registration continues normally.

On login/startup, parent users run the same link step once before routing to the parent dashboard. This catches older parent accounts and any registration link that was missed.

## Parent Dashboard Behavior
Parent dashboard swimmer lookups now prefer `swimmers.parentUid == currentUser.uid`, then fall back to the legacy `swimmers.email == currentUser.email` lookup for demo/backward compatibility.

Evaluation reads still prefer `Evaluations.parentUid == currentUser.uid` when ownership is available.

## Firestore Safety Rules Behavior
Rules now allow a parent to update a swimmer only for the claim path:
- The existing swimmer `email` must match `request.auth.token.email`.
- The incoming `parentUid` must equal `request.auth.uid`.
- Existing `parentUid` must be missing, empty, or already equal to the same parent uid.
- The only changed fields may be `parentUid` and `updatedAt`.

Staff/admin/coach permissions remain unchanged, and deny-by-default remains in place.

## No Matching Swimmer
If a parent registers or logs in with no matching swimmer email, the app continues normally and the parent dashboard shows the existing empty state.

## Already Claimed Swimmer
If a matching swimmer already has a different non-empty `parentUid`, the helper skips it and does not overwrite ownership.

## Manual QA Checklist
- Create/register a parent account with email matching an existing `swimmers.email`.
- Confirm `swimmers.parentUid` is written for matching swimmers.
- Confirm parent dashboard shows the child.
- Create a new evaluation for that swimmer as coach/admin.
- Confirm the evaluation stores `parentUid`.
- Confirm parent sees the evaluation.
- Register/login parent with no matching swimmer and confirm the app does not crash.
- Try a swimmer already linked to another `parentUid` and confirm it is not overwritten.
- Confirm coach/admin flows still work.
- Confirm `flutter analyze`, `flutter test`, and web release build pass.

## Remaining Production Blockers
- Run manual QA against the real Firebase project or staging copy.
- Backfill existing swimmers/evaluations where auto-link cannot safely resolve ownership.
- Validate Firestore rules in emulator or staging before deployment.
- Do not deploy strict rules until parent dashboard and evaluation ownership QA pass.

## Commands Run
- `dart format lib\features\auth\data\parent_linking_service.dart lib\features\auth\presentation\auth_gate.dart lib\screens\create_account_screen.dart lib\screens\login_screen.dart lib\screens\parent_dashboard_screen.dart test\model_parsing_test.dart`
- `flutter analyze`
- `flutter test`
- `flutter build web --release --base-href /`
- `flutter run -d chrome --no-resident`
