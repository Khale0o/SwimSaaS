# Phase 1 Stabilization Summary

## 1. Phase Goal

Stabilize the current SwimSaaS Flutter/Firebase app with small, low-risk changes only. This phase keeps the existing UI identity, user flows, Firebase collections, Firestore fields, and product features unchanged.

## 2. Files Created

- `docs/phase_1_stabilization_summary.md`

## 3. Files Modified

- `lib/main.dart`
- `lib/screens/admin_setup_screen.dart`
- `lib/screens/create_account_screen.dart`
- `lib/screens/forget_password_screen.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/parent_dashboard_screen.dart`
- `lib/screens/profile_screen.dart`
- `lib/upload_students.dart`
- `test/widget_test.dart`

Note: `README.md` and the existing `docs/` directory already appeared as changed/untracked before this phase's edits.

## 4. What Changed And Why

- Registered the `/login` route in `MaterialApp` so any named login navigation has a valid target.
- Replaced the parent dashboard's direct `pushNamedAndRemoveUntil('/login')` logout path with direct navigation to the existing `LoginScreen`, matching the rest of the app's logout behavior.
- Kept logout behavior the same: sign out from Firebase Auth, then clear the navigation stack back to login.
- Added a development-only warning comment and visible warning banner to `AdminSetupScreen` because it can promote users to admin.
- Added a development-only warning comment to `upload_students.dart` because it writes sample data to Firestore.
- Made auth-related scroll views safer when the keyboard is open by including `MediaQuery.viewInsets.bottom` in bottom padding.
- Replaced small auth-row `Row` widgets with `Wrap` where text can overflow on narrow phones.
- Removed a few unused imports that were safe to remove.
- Replaced the default Flutter counter test with a minimal `MyApp` shell smoke test that does not initialize Firebase plugins.

## 5. Behavior That Should Remain The Same

- Login, signup, password reset, role-based routing, coach approval checks, inactive-account checks, parent dashboard navigation, coach dashboard navigation, and logout should behave the same.
- No Firestore collection names or field names were changed.
- No Firebase read/write logic was redesigned.
- No app colors, gradients, screen order, cards, or product UI identity were intentionally changed.
- Google and Apple social buttons remain placeholders, but their existing image fallbacks still prevent runtime crashes when assets are missing.

## 6. Responsive UI Notes

Screens checked:

- `LoginScreen`
- `CreateAccountScreen`
- `ForgetPasswordScreen`
- `ParentDashboardScreen`
- `HomeScreen`
- `AdminSetupScreen`

Overflow risks fixed:

- Login "Keep me logged in / Forgot Password" row can now wrap on small phones.
- Login and signup bottom links can now wrap instead of overflowing.
- Login, create account, forgot password, and admin setup screens now preserve bottom scroll space when the keyboard is open.

Screens that still need deeper responsive work:

- `parent_dashboard_screen.dart`: large file with many fixed paddings and dense cards.
- `swimmers_list_screen.dart`: large dialogs and card layouts should be reviewed on small phones.
- `subscriptions_screen.dart`: bulk renewal dialogs and tab/card content need a deeper responsive pass.
- `evaluation_screen.dart`: dialogs and evaluation cards need a deeper responsive pass.
- `dashboard_screen.dart`: group schedule and attendance dialog should be checked with realistic data.

## 7. Manual Testing Checklist

- Open app signed out and confirm login screen renders.
- Sign in as coach and confirm routing to coach dashboard.
- Sign in as parent and confirm routing to parent dashboard.
- Sign in as swimmer if a swimmer role user exists and confirm routing to swimmer dashboard.
- Confirm pending coach account still shows pending approval dialog.
- Confirm inactive account still shows inactive account dialog.
- Logout from coach dashboard and confirm it returns to login.
- Logout from parent dashboard and confirm it returns to login.
- Open signup screen, focus each field, and confirm the keyboard does not hide the bottom actions.
- Open forgot password screen, focus email field, and confirm the keyboard does not hide the action.
- Confirm Admin Setup is not reachable from normal app navigation.
- Confirm Upload Swimmers utility is not reachable from normal app navigation.

## 8. Commands To Run

```bash
dart format lib/main.dart lib/screens/parent_dashboard_screen.dart lib/screens/login_screen.dart lib/screens/create_account_screen.dart lib/screens/forget_password_screen.dart lib/screens/admin_setup_screen.dart lib/upload_students.dart test/widget_test.dart
flutter analyze
flutter test
```

## 9. Known Risks Or Remaining TODOs

- `flutter analyze` still reports many info-level lint findings across the existing codebase. These are mostly pre-existing and should be handled in later phases to avoid broad risky churn.
- Several screens still use `BuildContext` after async gaps.
- Several screens still use `print()` diagnostics.
- There are many `prefer_const_constructors` and small style lints.
- Firestore security rules are still not included in this repository.
- `AdminSetupScreen` remains dangerous if manually wired into production navigation or exposed without backend/rules protection.
- `upload_students.dart` remains a Firestore-writing development utility and must stay out of production navigation.
- Font families such as `Inter` and `SF Pro` are referenced without bundled font assets; Flutter will fall back, but a later UI-safe asset/font phase should decide whether to configure fonts or remove explicit family references consistently.
- `assets/google.png` and `assets/apple.png` are referenced but not present/declared. The current UI uses `errorBuilder` fallbacks, so this is not a runtime crash risk, but it should be cleaned up in a later asset pass.
