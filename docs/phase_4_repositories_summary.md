# Phase 4 Repositories Summary

## 1. Phase Goal

Start separating Firebase Auth and Firestore access from UI screens with small repository classes. This phase keeps the current Firebase behavior, Firestore schema, stored data, UI, and user-facing flows unchanged.

## 2. Files Created

- `lib/features/auth/data/auth_repository.dart`
- `lib/features/auth/data/user_repository.dart`
- `lib/features/swimmers/data/swimmer_repository.dart`
- `lib/features/evaluations/data/evaluation_repository.dart`
- `lib/features/subscriptions/data/subscription_repository.dart`
- `lib/features/attendance/data/attendance_repository.dart`
- `docs/phase_4_repositories_summary.md`

## 3. Files Modified

- `lib/screens/forget_password_screen.dart`
- `lib/screens/login_screen.dart`

## 4. Repositories Added And Responsibilities

- `AuthRepository`
  - Wraps `FirebaseAuth`.
  - Provides `currentUser`, `authStateChanges`, email/password sign-in, account creation, password reset, sign-out, password reauthentication, and password update.

- `UserRepository`
  - Wraps the existing `users` collection.
  - Provides user profile reads, stream reads, profile create/update, coach approval, coach rejection, and pending coach stream.
  - Uses the current role, active, approval, admin, and audit fields without changing values.

- `SwimmerRepository`
  - Wraps the existing `swimmers` collection.
  - Provides swimmer streams, typed swimmer streams, get by ID, add, update, and delete.

- `EvaluationRepository`
  - Wraps the existing `Evaluations` collection.
  - Provides evaluation streams, typed evaluation streams, add, update, and delete.
  - Preserves the current name-based relation for now.

- `SubscriptionRepository`
  - Wraps embedded subscription fields inside swimmer documents.
  - Provides one-swimmer renewal and bulk renewal helpers using the current field names and `Active` status.

- `AttendanceRepository`
  - Wraps embedded attendance maps inside swimmer documents.
  - Provides read helper and `markAttendance` using the current nested `attendance.dateKey` map structure.

## 5. Screens Migrated And Why

- `forget_password_screen.dart`
  - Migrated password reset from direct `FirebaseAuth.instance` to `AuthRepository`.
  - Low risk because it is a single Firebase Auth call and no UI behavior changed.

- `login_screen.dart`
  - Migrated current-user lookup, sign-in, sign-out, and user profile reads to `AuthRepository` and `UserRepository`.
  - Kept the existing 10-second user document timeout, parent fallback for missing user docs, coach approval check, inactive account check, and role navigation behavior.

## 6. Screens Still Directly Using Firebase

Most screens still directly use Firebase and should be migrated gradually in later phases:

- `create_account_screen.dart`
- `home_screen.dart`
- `profile_screen.dart`
- `admin_panel_screen.dart`
- `admin_setup_screen.dart`
- `dashboard_screen.dart`
- `swimmers_list_screen.dart`
- `parents_screen.dart`
- `parent_dashboard_screen.dart`
- `evaluation_screen.dart`
- `pending_evals_screen.dart`
- `subscriptions_screen.dart`
- `active_subs_screen.dart`
- `expired_subs_screen.dart`
- `upload_students.dart`

## 7. Firebase Behavior That Remained Unchanged

- No collection names changed.
- No field names changed.
- No Firestore data migration was added.
- No existing documents are updated except through existing user actions.
- Login still reads `users/{uid}` after authentication.
- Missing user documents still route with the existing parent fallback.
- Coach approval and inactive account checks behave the same.
- Password reset still uses Firebase Auth email reset behavior.

## 8. Behavior That Should Remain The Same

- Login screen UI and routing should look and behave the same.
- Forgot password screen UI and messages should look and behave the same.
- Existing role-based navigation remains unchanged.
- Existing approval/inactive dialogs remain unchanged.
- No app colors, gradients, spacing, screen order, or visual identity changed.

## 9. Manual Testing Checklist

- Launch the app on Chrome.
- Sign in with a parent account and confirm parent dashboard routing.
- Sign in with a coach account and confirm coach dashboard routing.
- Sign in with an unapproved coach and confirm the pending approval dialog.
- Sign in with an inactive account and confirm the inactive account dialog.
- Use forgot password with a valid email.
- Use forgot password with an invalid or unknown email and confirm the same error behavior.
- Sign out from pending/inactive dialogs and confirm login remains available.

## 10. Commands To Run

```bash
dart format lib/features/auth/data/auth_repository.dart lib/features/auth/data/user_repository.dart lib/features/swimmers/data/swimmer_repository.dart lib/features/evaluations/data/evaluation_repository.dart lib/features/subscriptions/data/subscription_repository.dart lib/features/attendance/data/attendance_repository.dart lib/screens/forget_password_screen.dart lib/screens/login_screen.dart
flutter analyze
flutter test
flutter run -d chrome
```

## 11. Known Risks Or Remaining TODOs

- Repository tests were not added in this phase because testing Firebase wrappers well would require mock setup or Firebase emulator work. Existing model tests remain in place.
- Several screens still directly use Firebase and should be migrated one feature at a time.
- `create_account_screen.dart` is a good next migration target because `AuthRepository.createUserWithEmailAndPassword` and `UserRepository.createUserProfile` now exist.
- `profile_screen.dart` is another good next target for user reads, profile updates, sign-out, and password changes.
- Subscription, attendance, dashboard, and evaluation screens should be migrated later because they have more business logic and higher regression risk.
- The existing analyzer info-level lint backlog remains.

## 12. Responsive UI Notes

No layout or visual changes were made.

Touched screens:

- `forget_password_screen.dart`
- `login_screen.dart`

Both retained the Phase 1 keyboard-safe scroll behavior. No new fixed-size layout risks were introduced.
