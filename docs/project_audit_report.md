# SwimSaaS Technical Audit Report

This report is based on the current Flutter codebase and does not assume features, infrastructure, or backend rules that are not present in the repository.

## 1. Architecture Review

The project is currently a screen-driven Flutter application. Most business logic, Firebase access, form handling, validation, and navigation are implemented directly inside UI widgets.

Current architectural characteristics:

- `main.dart` initializes Firebase and launches `LoginScreen`.
- Screens directly call `FirebaseAuth.instance` and `FirebaseFirestore.instance`.
- There are no dedicated model, service, repository, controller, provider, or feature modules.
- Firestore documents are handled as `Map<String, dynamic>` and `QueryDocumentSnapshot`.
- User role decisions are performed in `login_screen.dart`.
- Coach and parent dashboard flows are implemented as large widget files with local state.

Strengths:

- The current structure is easy to inspect for a small app.
- Firebase integration is already present.
- Role-based app entry is implemented.
- Main academy workflows are represented in UI.

Weaknesses:

- Business rules are tightly coupled to widgets.
- Data access is duplicated across screens.
- There is no clear domain layer.
- There is no app-wide error handling strategy.
- Large files make changes risky and difficult to test.

## 2. Folder Structure Review

Current relevant structure:

```text
lib/
  main.dart
  upload_students.dart
  screens/
    active_subs_screen.dart
    admin_panel_screen.dart
    admin_setup_screen.dart
    create_account_screen.dart
    dashboard_screen.dart
    evaluation_screen.dart
    expired_subs_screen.dart
    forget_password_screen.dart
    home_screen.dart
    login_screen.dart
    parent_dashboard_screen.dart
    parents_screen.dart
    pending_evals_screen.dart
    profile_screen.dart
    splash_screen.dart
    subscriptions_screen.dart
    swimmer_dashboard_screen.dart
    swimmers_list_screen.dart
    lib/firebase_options.dart
assets/
test/
android/
ios/
web/
windows/
macos/
linux/
```

Observations:

- `lib/screens/` contains nearly all application logic.
- `lib/screens/lib/firebase_options.dart` is oddly nested and contains placeholder Firebase values.
- There are no `models/`, `services/`, `repositories/`, `providers/`, `routing/`, or `theme/` folders.
- `upload_students.dart` is a development utility but sits in production `lib/`.
- Generated platform folders are standard Flutter platform shells.

Risks:

- Screen files are becoming very large.
- Similar UI patterns are copied across multiple files.
- Shared logic has no clear home.
- Development utilities may accidentally be shipped or exposed.

## 3. State Management Review

The project includes `provider` in `pubspec.yaml`, but Provider is not currently used for app state.

Current state mechanisms:

- Local `StatefulWidget` state with `setState`.
- `StreamBuilder` for Firestore live data.
- `FutureBuilder` for one-time Firestore reads.
- Direct `FirebaseAuth.currentUser` checks inside screens.

Issues:

- Auth state is not represented in a central app state.
- Role, approval, and admin state are fetched in individual screens.
- Firestore query logic is repeated.
- UI state and data mutation state are mixed together.
- Testing state transitions is difficult.

Recommendation:

- Introduce a small state layer only after extracting Firebase calls into services.
- Keep state management simple at first: an `AuthController`/`AuthProvider`, repositories, and typed models would already reduce most complexity.

## 4. Routing And Navigation Review

Current routing:

- `MaterialApp` starts directly at `LoginScreen`.
- Navigation uses `Navigator.push`, `pushReplacement`, and `pushAndRemoveUntil`.
- Role routing is handled in `login_screen.dart`.
- Coach dashboard uses a `PageView` inside `HomeScreen`.
- Parent dashboard uses a separate `PageView` inside `ParentDashboardScreen`.

Issues:

- No centralized route definitions.
- No reusable auth guard.
- No route-level authorization.
- `SplashScreen` exists but is not used as the app home.
- At least one code path uses `Navigator.pushNamedAndRemoveUntil(context, '/login', ...)`, but no named routes are registered in `MaterialApp`.
- Multiple logout implementations exist across screens.

Recommendation:

- Add a central router or route factory.
- Define authenticated and unauthenticated areas explicitly.
- Make role-based redirects a single reusable flow.
- Replace inconsistent logout navigation with one shared method.

## 5. UI/UX Review

The app has a consistent visual direction:

- Dark blue water-themed gradients.
- Glass-like cards.
- Floating bottom navigation.
- Rounded stat cards.
- Icons and color-coded statuses.

Strengths:

- The product has a recognizable identity.
- Coach and parent dashboards follow similar navigation patterns.
- Most screens include loading and empty states.
- Forms and cards are visually consistent in broad style.

Issues:

- UI components are duplicated across many screens.
- Background, cards, stats, search bars, dialogs, and form fields should be shared widgets.
- Some comments and strings show encoding corruption.
- `fontFamily: 'Inter'` and `fontFamily: 'SF Pro'` are used without configured font assets.
- `assets/google.png` and `assets/apple.png` are referenced but are not declared in `pubspec.yaml`.
- Some screens may become crowded on small devices due to dense cards and large fixed spacing.
- Dialog/form UX is inconsistent between screens.

Recommendation:

- Extract a small design system: app background, app card, stat card, search field, dialog shell, status badge, and app nav item.
- Add responsive checks for smaller Android devices.
- Clean corrupted text and comments.

## 6. Security Risks

Current security risks visible from the codebase:

- No Firestore security rules are included in the repository.
- Client code directly reads and writes sensitive role fields such as `isAdmin`, `isApproved`, `isActive`, and `needsApproval`.
- `AdminSetupScreen` can promote users to admin by email if reachable.
- Admin and approval checks are performed client-side.
- Rejection of a coach deletes the Firestore user document but not the Firebase Auth user.
- There is no tenant boundary for SaaS data.
- Parent access is based on matching authenticated email to `swimmers.email`.
- Evaluation and swimmer relationships are often name-based, which is unsafe for authorization.
- No audit logs exist for admin actions, approvals, deletions, or subscription renewals.

Security priorities:

- Write strict Firestore security rules.
- Move role/approval/admin mutation authority to trusted backend logic where possible.
- Add tenant/academy ownership fields.
- Prevent users from editing privileged fields from the client.
- Remove or strongly protect admin setup functionality.

## 7. Backend And Data Risks

Backend currently used:

- Firebase Authentication.
- Cloud Firestore.
- Android Firebase config via `google-services.json`.

Collections used:

- `users`
- `swimmers`
- `Evaluations`

Data risks:

- No typed models or schema validation.
- Inconsistent collection naming: `Evaluations` is capitalized while `users` and `swimmers` are lowercase.
- Date fields mix strings, `Timestamp`, ISO strings, and server timestamps.
- Evaluations are not consistently linked to swimmers by document ID.
- Parent/swimmer relationship relies on email matching.
- Subscription state can be stored as both `subscriptionStatus` and derived from `subscriptionExpiry`.
- Some screens fetch entire collections and filter client-side.
- Attendance is stored as a nested map under swimmer documents, which can grow large over time.
- No migration strategy exists for changing fields.

Recommendation:

- Define canonical schemas for `users`, `swimmers`, `evaluations`, `subscriptions`, and `attendance`.
- Use stable IDs for relationships.
- Normalize all date fields.
- Consider subcollections for attendance and evaluations.
- Plan tenant-aware data layout before production.

## 8. Performance Risks

Current performance risks:

- Several screens listen to entire Firestore collections with `.snapshots()`.
- Filtering and sorting are often performed client-side.
- Large widget files rebuild broad UI sections with `setState`.
- Nested and repeated gradients/shadows may be expensive on lower-end devices.
- `SingleChildScrollView` plus large generated lists can render many children at once.
- Evaluation filtering compares swimmer names against all evaluation documents.
- Dashboard uses multiple live streams and local calculations.

Recommendations:

- Use Firestore queries with `where`, `orderBy`, and pagination where possible.
- Prefer `ListView.builder` for large lists.
- Move derived counts to efficient queries, aggregate documents, or backend-maintained counters if data grows.
- Extract widgets so local rebuilds are smaller.
- Avoid fetching entire tenant/global collections for role-specific views.

## 9. Code Quality Issues

Observed code quality concerns:

- Large files with mixed responsibilities.
- Repeated UI code across screens.
- Repeated Firebase access logic.
- Repeated logout and password-change flows.
- Raw strings for roles, statuses, group names, and collection names.
- Firestore field names are scattered throughout the UI.
- `print()` is used for diagnostics instead of structured logging.
- Several `use_build_context_synchronously` warnings are ignored.
- Some TODOs are user-facing features: Google login, Apple login, terms/privacy.
- The default Flutter counter test remains in place.
- Some dependencies appear unused, including `provider` and `curved_navigation_bar`.
- There are hard-coded training groups and times.

Recommendations:

- Introduce constants/enums for roles, statuses, collections, and fields.
- Extract shared services.
- Extract shared widgets.
- Replace repeated auth/logout code with reusable helpers.
- Add lint-driven cleanup after architecture stabilization.

## 10. Missing Tests

The project currently has only the default generated Flutter widget test, which does not match the current app behavior.

Missing test coverage:

- Login validation.
- Auth state routing.
- Role-based redirects.
- Coach approval restrictions.
- Admin approval behavior.
- Swimmer creation and update flows.
- Evaluation creation, update, pass, fail, and delete flows.
- Subscription status calculation.
- Subscription renewal and bulk renewal.
- Parent dashboard data lookup.
- Attendance update logic.
- Profile update and password change behavior.
- Error and empty states.

Recommended testing approach:

- Start with pure Dart tests for date/status calculations.
- Add repository/service tests after extracting Firebase access.
- Add widget tests for key screens with mocked services.
- Add integration tests for login and role navigation once routing is centralized.

## 11. Production-Readiness Checklist

Current status:

- [x] Flutter project structure exists.
- [x] Firebase Auth dependency present.
- [x] Cloud Firestore dependency present.
- [x] Android Firebase plugin/config path present.
- [x] Role-based navigation exists.
- [x] Core academy workflows are represented in UI.
- [ ] Centralized routing.
- [ ] Centralized auth guard.
- [ ] Typed domain models.
- [ ] Service/repository layer.
- [ ] Firestore security rules in repository.
- [ ] Tenant/academy data isolation.
- [ ] Backend-enforced admin actions.
- [ ] Audit logging.
- [ ] Error monitoring/crash reporting.
- [ ] Meaningful automated tests.
- [ ] CI pipeline.
- [ ] Data validation strategy.
- [ ] Backup/export strategy.
- [ ] Production Firebase configuration for all target platforms.
- [ ] Real terms/privacy/support screens.
- [ ] Google/Apple sign-in implementation or removal of placeholder buttons.
- [ ] Clean font and asset configuration.
- [ ] Performance review for large datasets.
- [ ] Release build verification.

## 12. Recommended Development Phases

### Phase 1: Stabilize The Current App

- Fix broken or inconsistent navigation paths.
- Remove or protect development-only screens.
- Clean corrupted strings/comments.
- Resolve missing asset/font references.
- Replace the default widget test with a basic app smoke test.
- Document current Firestore schemas.

### Phase 2: Extract Core Architecture

- Add model classes for users, swimmers, evaluations, subscriptions, and attendance.
- Add Firebase Auth and Firestore service classes.
- Centralize collection and field constants.
- Move business logic out of screen widgets.
- Consolidate logout, password change, and auth checks.

### Phase 3: Improve Data Integrity

- Link evaluations, attendance, subscriptions, parents, and swimmers by stable IDs.
- Normalize date fields.
- Standardize collection naming.
- Move attendance and evaluation history to scalable structures if needed.
- Add validation before writes.

### Phase 4: Add Real SaaS Foundations

- Introduce academy/organization entities.
- Add `tenantId` or tenant-scoped subcollections.
- Add role membership per tenant.
- Write Firestore security rules for tenant isolation.
- Add admin audit logs.

### Phase 5: Production Hardening

- Add tests around auth, routing, data services, and key workflows.
- Add CI for `flutter analyze` and `flutter test`.
- Add crash/error reporting.
- Add backup/export workflows.
- Add release configuration for required platforms.
- Run performance checks with realistic data volumes.

### Phase 6: Product Expansion

- Complete planned social login if required.
- Add terms/privacy/support experiences.
- Add billing or academy subscription management if SwimSaaS will be sold as SaaS.
- Add reporting, exports, notifications, and parent communication tools.
