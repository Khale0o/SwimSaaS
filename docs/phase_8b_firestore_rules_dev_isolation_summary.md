# Phase 8B Firestore Rules and Dev Isolation Summary

## Phase Goal
Create a versioned production security foundation for the current single-academy app by adding Firebase rules/config files, isolating obvious dev-only risk where safe, and documenting remaining schema blockers.

## Files Inspected
- `docs/phase_8_firebase_security_production_review.md`
- `lib/core/constants/app_collections.dart`
- `lib/core/constants/app_fields.dart`
- `lib/core/constants/app_roles.dart`
- `lib/features/auth/domain/user_profile.dart`
- `lib/features/auth/presentation/auth_gate.dart`
- `lib/features/auth/presentation/auth_route_resolver.dart`
- `lib/screens/admin_panel_screen.dart`
- `lib/screens/admin_setup_screen.dart`
- `lib/upload_students.dart`
- `firebase.json`
- `pubspec.yaml`
- Existing data-access references found by search for `users`, `swimmers`, and `Evaluations`

## Files Modified
- `firebase.json`
- `firestore.rules`
- `storage.rules`
- `firestore.indexes.json`
- `docs/phase_8b_firestore_rules_dev_isolation_summary.md`
- Removed unused placeholder: `lib/screens/lib/firebase_options.dart`

## Rules Files Added/Updated
- Added `firestore.rules`.
- Added `storage.rules`.
- Added `firestore.indexes.json` with no custom indexes.

## firebase.json Changes
Added deployable references for:
- Firestore rules: `firestore.rules`
- Firestore indexes: `firestore.indexes.json`
- Storage rules: `storage.rules`

The existing FlutterFire platform metadata was preserved.

## Exact Security Model Implemented
- Firestore is deny-by-default.
- App data requires `request.auth != null`.
- User profiles:
  - Users can read their own `users/{uid}` document.
  - Admins can read/list/create/update/delete user documents.
  - Users can create only their own initial parent/coach profile shape.
  - Users can update only non-privileged self-profile fields: `fullName`, `phone`, `updatedAt`, `profileCompleted`.
- Privileged fields are not user-editable through self-update:
  - `role`
  - `isAdmin`
  - `isApproved`
  - `isActive`
  - `needsApproval`
  - `approvedAt`
  - `approvedBy`
- Staff access:
  - Admin is verified from `users/{uid}.isAdmin == true` and active account state.
  - Coach is verified from active, approved `users/{uid}.role == coach`.
  - Admins and approved coaches can read/write `swimmers`.
  - Admins and approved coaches can read/write `Evaluations`.
- Parent access:
  - Parents can read `swimmers` documents only when `resource.data.email == request.auth.token.email`.
  - Parents are not granted `Evaluations` reads because current evaluation documents do not have a safe owner field.
- Storage is deny-all because the app does not currently need Firebase Storage access.

## What The Rules Protect
- Hidden admin/coach screens cannot be used as security boundaries by themselves.
- Coach approval/rejection requires admin-level rule permission.
- Swimmer, subscription, attendance, and evaluation writes require staff-level rule permission.
- Parent users cannot directly list all swimmers unless every returned document is owned by their auth email.
- Users cannot promote themselves by editing privileged role/admin/approval fields.

## What The Rules Intentionally Do Not Allow
- Parent reads of `Evaluations`.
- Anonymous access.
- Normal user edits to role/admin/approval fields.
- Firebase Storage reads/writes.
- Public collection reads.
- Client-side admin bootstrapping from a non-admin account.

## Parent/Ownership Limitations
Parent swimmer access can be partially enforced by matching `swimmers.email` to the authenticated email.

Parent evaluation access cannot be safely enforced with the current schema because `Evaluations` records are queried by swimmer name and do not contain a reliable `parentUid`, `ownerUid`, `swimmerId`, or parent email field. Do not deploy these rules expecting the current parent evaluation tab to keep working. A future schema-safe migration is required.

## Dev Utility Isolation Result
- `admin_setup_screen.dart` is not referenced from normal app imports/routes found by search. It already has strong dev-only warnings and remains in source for now.
- `lib/upload_students.dart` is not referenced from normal app imports/routes found by search. It already has dev-only warnings and remains in source for now.
- No functional dev utility was deleted.

## Placeholder Firebase Config Result
Removed unused placeholder file:
- `lib/screens/lib/firebase_options.dart`

The real generated config remains:
- `lib/firebase_options.dart`

## Production Blockers Remaining
- Firebase rules must be reviewed and tested in the Firebase emulator before deployment.
- Parent evaluation reads need an ownership field/migration before strict production rules can support them.
- A secure admin bootstrap process is still required outside the client app.
- Dev-only admin/seed utilities should be removed from production source or excluded from production packaging in a follow-up hardening step.
- Firebase Auth authorized domains must be confirmed in Firebase Console.

## Manual Firebase Console/Deploy Checklist
- Confirm Firebase project is the intended production project.
- Confirm Authentication authorized domains include the final Netlify/custom domains.
- Confirm Email/Password and any Google sign-in configuration.
- Review and test `firestore.rules` locally.
- Review and test `storage.rules` locally.
- Deploy rules only after emulator tests pass.
- Create first admin through a trusted process, not through public client UI.
- Disable Firebase test mode/open rules.

## Rules Testing Checklist
- Unauthenticated user: cannot read/write anything.
- New parent: can create only own parent profile.
- New coach: can create only pending inactive coach profile.
- Parent: can read own `users/{uid}` and matching `swimmers.email`.
- Parent: cannot read all swimmers.
- Parent: cannot read `Evaluations` until ownership schema is added.
- Parent: cannot update role/admin/approval fields.
- Pending coach: cannot read/write staff collections.
- Approved coach: can read/write swimmers and evaluations.
- Admin: can list pending coaches and approve/reject them.
- Non-admin: cannot approve/reject coaches.
- Storage: all reads/writes denied.

## Commands Run
- `rg` inspections for config, auth, rules, dev utilities, and Firebase data access.
- `firebase --version` attempted; Firebase CLI is not installed in this environment.
- `Get-Content -Raw firebase.json | ConvertFrom-Json`
- `Get-Content -Raw firestore.indexes.json | ConvertFrom-Json`
- `flutter analyze`
- `flutter test`
- `flutter build web --release --base-href /`

## Final Recommendation
Ready for rules review and emulator testing, not ready to deploy these rules to production until the parent evaluation ownership blocker and admin bootstrap plan are resolved. App behavior is unchanged because no rules were deployed and no production screen queries/writes were changed.
