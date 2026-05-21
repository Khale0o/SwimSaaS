# SwimSaaS

SwimSaaS is a Flutter application for managing a swimming academy. The current app focuses on swimmer management, coach/parent authentication flows, attendance tracking, evaluations, subscription status, and basic admin approval for coach accounts.

The codebase is currently organized as a screen-driven Flutter app backed by Firebase Authentication and Cloud Firestore.

## What The System Does

SwimSaaS provides different experiences based on the authenticated user's role:

- Coaches can access the main academy dashboard, manage swimmers, track attendance, manage evaluations, view subscription status, and edit their profile.
- Parents can view attendance, evaluations, subscription information, and profile details linked to their swimmer record.
- Swimmer routing exists, with a dedicated swimmer dashboard screen present in the project.
- Admin users can approve or reject pending coach accounts.

## Implemented Features

- Email/password authentication with Firebase Auth.
- Login state check on app launch.
- Role-based navigation for `coach`, `parent`, and `swimmer`.
- Account creation for parents and coaches.
- Coach approval workflow using `isApproved`, `isActive`, and `needsApproval` fields.
- Password reset screen.
- Password change flows.
- Coach dashboard with swimmer, subscription, and evaluation statistics.
- Swimmer list with add/edit/delete functionality.
- Parent/contact management view.
- Attendance marking by training group and date.
- Evaluation management, including add, edit, delete, pass, and fail actions.
- Subscription management with active, expiring soon, and expired views.
- Single and bulk subscription renewal flows.
- Profile screen for account details.
- Admin panel for pending coach approvals.

## Tech Stack

- Flutter
- Dart
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Provider dependency is present, but app-level Provider state management is not currently used.
- `intl` for date formatting.

## Project Structure

```text
lib/
  main.dart                         App entry point and Firebase initialization.
  upload_students.dart              Utility screen for seeding evaluation-style sample data.
  screens/
    login_screen.dart               Login, current-user check, and role-based navigation.
    create_account_screen.dart      Parent/coach registration.
    forget_password_screen.dart     Password reset flow.
    home_screen.dart                Coach main shell with page navigation.
    dashboard_screen.dart           Coach dashboard, stats, schedule, and attendance.
    swimmers_list_screen.dart       Swimmer listing and swimmer CRUD flows.
    parents_screen.dart             Parent/contact-focused swimmer list.
    evaluation_screen.dart          Evaluation list, creation, editing, and deletion.
    subscriptions_screen.dart       Subscription status and renewal management.
    parent_dashboard_screen.dart    Parent dashboard pages.
    swimmer_dashboard_screen.dart   Swimmer dashboard screen.
    profile_screen.dart             User profile and password update.
    admin_panel_screen.dart         Pending coach approval management.
    admin_setup_screen.dart         Manual admin promotion utility.
    active_subs_screen.dart         Active subscription drill-down.
    expired_subs_screen.dart        Expired subscription drill-down.
    pending_evals_screen.dart       Pending evaluation drill-down.
    splash_screen.dart              Splash screen, currently not used as app home.
    lib/firebase_options.dart       Placeholder Firebase options file, not used by main.dart.

assets/
  logo.jpg
  swimming_background*.jpeg

android/
  app/google-services.json          Android Firebase configuration.

test/
  widget_test.dart                  Default generated Flutter test; not aligned with current app.
```

## App Flow

1. `main.dart` initializes Flutter and Firebase.
2. The app starts at `LoginScreen`.
3. `LoginScreen` checks `FirebaseAuth.instance.currentUser`.
4. If no user is signed in, the login form is shown.
5. If a user is signed in, the app reads `users/{uid}` from Firestore.
6. Navigation is selected from the user's `role`:
   - `coach` -> `HomeScreen`
   - `parent` -> `ParentDashboardScreen`
   - `swimmer` -> `SwimmerDashboardScreen`
7. Coach users with `isApproved == false` are blocked until approved.
8. Inactive users with `isActive == false` are blocked.

The coach `HomeScreen` contains the main coach pages:

- Dashboard
- Evaluation
- Subscriptions
- Parents
- Profile

## Backend And Database Notes

The app uses Firebase Authentication and Cloud Firestore directly from Flutter screens.

Main Firestore collections used by the current code:

- `users`
- `swimmers`
- `Evaluations`

Approximate `users` fields:

```text
uid
fullName
email
phone
role
isActive
isApproved
isAdmin
needsApproval
createdAt
updatedAt
approvedAt
approvedBy
profileCompleted
```

Approximate `swimmers` fields:

```text
name
email
phone
emergencyContact
level
medicalNotes
joinDate
trainingDays
trainingTime
subscriptionStatus
subscriptionExpiry
lastRenewalDate
attendance
createdAt
updatedAt
```

Approximate `Evaluations` fields:

```text
name
level
passed
subscriptionStatus
trainingDays
score
notes
date
evaluatedAt
```

At the moment, there are no typed model classes or repository/service layers. Firestore reads and writes are performed directly inside screen widgets.

## Setup Instructions

Prerequisites:

- Flutter SDK installed.
- Dart SDK matching the Flutter version.
- A Firebase project.
- Android Studio or another Flutter-compatible IDE.

Steps:

1. Clone or open the project.
2. Install dependencies:

```bash
flutter pub get
```

3. Configure Firebase for the target platform.

For Android, the project already expects:

```text
android/app/google-services.json
```

For other platforms, Firebase configuration may need to be completed. The existing `lib/screens/lib/firebase_options.dart` file is a placeholder and is not currently used by `main.dart`.

4. Confirm that Firebase Authentication and Cloud Firestore are enabled in Firebase Console.
5. Ensure the Firestore collections expected by the app exist or can be created by app actions.

## Running The App

Run on a connected device or emulator:

```bash
flutter run
```

Run on a specific platform/device:

```bash
flutter devices
flutter run -d <device-id>
```

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Note: the current test file is still the default generated counter test and does not reflect the current SwimSaaS app behavior.

## Known Limitations

- No centralized routing system or route guard layer.
- Some navigation uses named routes that are not registered.
- No app-wide state management is currently implemented, despite `provider` being listed as a dependency.
- Firestore access is embedded directly inside UI screens.
- No typed data models for users, swimmers, evaluations, subscriptions, or attendance.
- Evaluations are often associated with swimmers by name instead of a stable swimmer ID.
- Parent dashboard data is linked by matching the authenticated user's email to `swimmers.email`.
- No true multi-tenant/SaaS isolation is implemented yet.
- Firestore collections are global rather than scoped by academy/tenant.
- Firestore security rules are not included in this repository.
- Google and Apple login buttons are present but not implemented.
- Terms and privacy screens are not implemented.
- Some UI strings/comments show encoding issues.
- `Inter` and `SF Pro` font names are referenced, but custom font assets are not configured in `pubspec.yaml`.
- `assets/google.png` and `assets/apple.png` are referenced in login UI but are not listed in the current assets section.
- The Firebase options file under `lib/screens/lib/` contains placeholder values and is not wired into app startup.
- The app currently lacks meaningful automated tests.

## Future Roadmap

Planned/future improvements:

- Add typed Dart models for users, swimmers, evaluations, subscriptions, and attendance.
- Move Firebase logic into services or repositories.
- Add centralized routing and authenticated route guards.
- Normalize Firestore collection and field naming.
- Replace name/email-based relationships with stable document IDs.
- Add real multi-tenant support with academies/organizations.
- Scope data by `tenantId` or tenant subcollections.
- Add Firestore security rules for roles, admins, and tenant isolation.
- Add admin audit logs for approvals, deletions, renewals, and role changes.
- Complete Google and Apple sign-in if required.
- Add production terms, privacy, and support screens.
- Extract shared UI components for cards, backgrounds, nav bars, dialogs, and form fields.
- Add tests for authentication, routing, Firestore services, and business rules.
- Add CI checks for formatting, analysis, and tests.
- Add error reporting and crash monitoring.
- Add backup/export tools for academy data.
