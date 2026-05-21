# Phase 5 Auth Gate Routing Summary

## 1. Phase Goal

Centralize app startup authentication and role routing behind a small `AuthGate`, while preserving the current UI, Firebase schema, stored data, and user-facing behavior.

## 2. Files Created

- `lib/features/auth/presentation/auth_gate.dart`
- `lib/features/auth/presentation/auth_route_resolver.dart`
- `docs/phase_5_auth_gate_routing_summary.md`

## 3. Files Modified

- `lib/main.dart`
- `lib/screens/login_screen.dart`

## 4. Startup/Auth Flow After The Change

- `MyApp` now starts with `AuthGate` instead of starting directly with `LoginScreen`.
- `AuthGate` uses the existing `AuthRepository` to check the current Firebase Auth user.
- If no Firebase user exists, the gate shows `LoginScreen` with the duplicate session check disabled.
- If a Firebase user exists, the gate uses the existing `UserRepository` to load `users/{uid}` with the same timeout pattern already used by login.
- While the startup check is running, the app shows a minimal loading screen using the existing blue gradient, pool icon, and EasySwim branding.
- If startup profile loading throws an error, the app falls back to login and shows a small visible startup error banner instead of leaving a blank screen.

## 5. Role Routing Behavior And What Stayed The Same

The role routing from `login_screen.dart` was extracted into `dashboardForRole` and reused by both the startup gate and manual login:

- `coach` routes to `HomeScreen`.
- `parent` routes to `ParentDashboardScreen`.
- `swimmer` routes to `SwimmerDashboardScreen`.
- Unknown roles preserve the previous fallback to `ParentDashboardScreen`.

The existing coach approval and inactive account behavior remains the same:

- Unapproved coach accounts show the existing pending approval dialog.
- Inactive accounts show the existing inactive account dialog.
- Manual login still performs the same user profile checks after email/password sign-in.

## 6. Missing Profile Fallback Behavior

If `users/{uid}` is missing, startup routing preserves the current login fallback behavior and routes using the existing parent fallback.

No Firestore document is created, updated, migrated, or repaired by this phase.

## 7. Logout Behavior

- Existing logout screens still navigate back to `LoginScreen`.
- The named `/login` route now builds `LoginScreen(checkExistingSession: false)` so logout/navigation to login does not immediately re-run startup routing inside the login page.
- Pending approval and inactive account startup handling signs out through `AuthRepository` before leaving the user on login.

## 8. Firebase Behavior That Remained Unchanged

- No collection names changed.
- No field names changed.
- No Firestore schema changed.
- No stored data was migrated.
- No existing documents are updated by startup routing.
- The existing meanings of `role`, `isActive`, `isApproved`, `isAdmin`, and `needsApproval` were not changed.
- The same `AuthRepository` and `UserRepository` introduced in Phase 4 are used.

## 9. Manual Testing Checklist

- Launch the app while signed out and confirm it shows the login screen.
- Sign in with an approved coach account and confirm routing to `HomeScreen`.
- Sign in with a parent account and confirm routing to `ParentDashboardScreen`.
- Sign in with a swimmer account and confirm routing to `SwimmerDashboardScreen`.
- Restart the app while already signed in and confirm the startup gate routes to the same dashboard.
- Test an unapproved coach and confirm the pending approval dialog appears.
- Test an inactive account and confirm the inactive account dialog appears.
- Sign out from a protected screen and confirm login remains available.
- Open `/login` through named navigation and confirm it shows login without looping.

## 10. Commands To Run

```bash
dart format lib/main.dart lib/screens/login_screen.dart lib/features/auth/presentation/auth_gate.dart lib/features/auth/presentation/auth_route_resolver.dart
flutter analyze
flutter test
flutter run -d chrome
```

## 11. Known Risks Or Remaining TODOs

- `AuthGate` intentionally preserves the current missing-profile parent fallback. A later phase should decide whether missing profiles need a dedicated recovery flow.
- Existing direct Firebase usage remains in most screens and should be migrated gradually in later phases.
- Existing logout code still lives in individual screens. It can be centralized later after more screens move behind repositories.
- The project still has an existing analyzer info-level lint backlog unrelated to this phase.
- No complex Firebase emulator tests were added in this phase.

## 12. Responsive UI Notes

- No broad responsive refactor was performed.
- The new startup loading screen uses `SafeArea` and centered content with the existing visual style.
- `login_screen.dart` keeps the Phase 1 scrollable, keyboard-safe behavior.
- No fixed-size screen layout changes were introduced beyond the small startup loading indicator content.
