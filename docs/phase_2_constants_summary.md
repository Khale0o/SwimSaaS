# Phase 2 Constants Summary

## 1. Phase Goal

Centralize repeated production string values for Firestore collections, Firestore fields, roles, statuses, and app routes. This reduces typo-risk without changing UI, features, user flows, Firestore schema, or business behavior.

## 2. Files Created

- `lib/core/constants/app_collections.dart`
- `lib/core/constants/app_constants.dart`
- `lib/core/constants/app_fields.dart`
- `lib/core/constants/app_roles.dart`
- `lib/core/constants/app_routes.dart`
- `lib/core/constants/app_statuses.dart`
- `docs/phase_2_constants_summary.md`

## 3. Files Modified

- `lib/main.dart`
- `lib/upload_students.dart`
- `lib/screens/active_subs_screen.dart`
- `lib/screens/admin_panel_screen.dart`
- `lib/screens/admin_setup_screen.dart`
- `lib/screens/create_account_screen.dart`
- `lib/screens/dashboard_screen.dart`
- `lib/screens/evaluation_screen.dart`
- `lib/screens/expired_subs_screen.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/parent_dashboard_screen.dart`
- `lib/screens/parents_screen.dart`
- `lib/screens/pending_evals_screen.dart`
- `lib/screens/profile_screen.dart`
- `lib/screens/subscriptions_screen.dart`
- `lib/screens/swimmers_list_screen.dart`

## 4. Constants Added

Collections:

- `AppCollections.users = 'users'`
- `AppCollections.swimmers = 'swimmers'`
- `AppCollections.evaluations = 'Evaluations'`

Routes:

- `AppRoutes.login = '/login'`

Roles:

- `AppRoles.coach = 'coach'`
- `AppRoles.parent = 'parent'`
- `AppRoles.swimmer = 'swimmer'`

Fields:

- User fields including `uid`, `fullName`, `email`, `phone`, `role`, `isActive`, `isApproved`, `isAdmin`, `needsApproval`, `createdAt`, `updatedAt`, `profileCompleted`, `approvedAt`, and `approvedBy`.
- Swimmer/subscription fields including `name`, `emergencyContact`, `medicalNotes`, `level`, `joinDate`, `trainingDays`, `trainingTime`, `subscriptionStatus`, `subscriptionExpiry`, `lastRenewalDate`, and `attendance`.
- Evaluation fields including `passed`, `score`, `notes`, `date`, and `evaluatedAt`.

Statuses:

- `AppStatuses.active = 'Active'`
- `AppStatuses.inactive = 'Inactive'`
- `AppStatuses.expired = 'Expired'`
- `AppStatuses.pending = 'Pending'`
- `AppStatuses.yes = 'Yes'`
- `AppStatuses.no = 'No'`

## 5. What Raw Strings Were Replaced

- App login route string in `MaterialApp.routes`.
- Firestore collection names for the obvious direct `users`, `swimmers`, and `Evaluations` reads/writes.
- Role checks and defaults in login and signup flows.
- Admin, approval, active, and role field names in auth/admin flows.
- Common profile user fields.
- Common subscription status reads/writes for `Active`, `Expired`, and `Pending`.
- Some evaluation subscription status writes and dropdown values.

This phase intentionally did not replace every UI label or every map key in every file to avoid risky churn.

## 6. Behavior That Should Remain The Same

- Firestore collection names and field names are unchanged.
- Existing documents remain compatible.
- Login, signup, coach approval, parent dashboard, swimmer lists, evaluations, subscriptions, profile updates, and logout behavior should remain the same.
- UI colors, gradients, spacing, cards, screen order, and visual identity should remain the same.
- No new features were added.
- No product features were removed.

## 7. Manual Testing Checklist

- Launch app on Chrome.
- Launch app on Android if available.
- Sign in as a parent and confirm the parent dashboard loads.
- Sign in as a coach and confirm the coach dashboard loads.
- Confirm pending coach approval flow still blocks unapproved coaches.
- Approve/reject a pending coach from admin panel if test data is available.
- Open swimmers list and confirm list filtering/status display still works.
- Add/edit a swimmer in a test environment.
- Open dashboard and confirm active/expired subscription counts still display.
- Open subscriptions and confirm renewal writes still work in a test environment.
- Open evaluations and confirm evaluated/pending lists still load.
- Update profile name/phone in a test environment.

## 8. Responsive UI Notes

No broad responsive UI refactor was performed in this phase. Existing Phase 1 keyboard-safe auth screen changes were preserved.

Touched screens were changed for constants imports and string replacements only. No intentional layout, color, spacing, or navigation-order changes were made.

Remaining responsive risks to review later:

- Large dialogs in `swimmers_list_screen.dart`.
- Dense subscription tabs/cards in `subscriptions_screen.dart`.
- Large parent dashboard sections in `parent_dashboard_screen.dart`.
- Evaluation dialogs in `evaluation_screen.dart`.

## 9. Commands To Run

```bash
dart format lib/core/constants lib/main.dart lib/upload_students.dart lib/screens/login_screen.dart lib/screens/create_account_screen.dart lib/screens/home_screen.dart lib/screens/admin_panel_screen.dart lib/screens/admin_setup_screen.dart lib/screens/dashboard_screen.dart lib/screens/subscriptions_screen.dart lib/screens/profile_screen.dart lib/screens/swimmers_list_screen.dart lib/screens/parents_screen.dart lib/screens/evaluation_screen.dart lib/screens/pending_evals_screen.dart lib/screens/active_subs_screen.dart lib/screens/expired_subs_screen.dart lib/screens/parent_dashboard_screen.dart
flutter analyze
flutter test
flutter run -d chrome
```

## 10. Known Risks Or Remaining TODOs

- `flutter analyze` still reports the existing info-level lint backlog, mostly `use_build_context_synchronously`, `prefer_const_constructors`, `avoid_print`, and minor style suggestions.
- Some raw strings remain by design, especially UI labels and less common map keys, to keep this phase safe.
- The app still lacks typed models and repositories; this phase only centralized constants.
- The old placeholder `lib/screens/lib/firebase_options.dart` still exists and should be cleaned up in a later focused Firebase/config cleanup.
- Further constants adoption can continue gradually when touching each feature in future phases.
