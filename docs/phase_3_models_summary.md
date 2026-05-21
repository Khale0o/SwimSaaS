# Phase 3 Models Summary

## 1. Phase Goal

Add typed Dart models for the current Firestore data shape while keeping the app fully backward-compatible. This phase does not change Firestore collection names, field names, stored documents, UI, screens, or production behavior.

## 2. Files Created

- `lib/core/utils/firestore_parsers.dart`
- `lib/features/auth/domain/user_profile.dart`
- `lib/features/swimmers/domain/swimmer.dart`
- `lib/features/evaluations/domain/evaluation.dart`
- `lib/features/subscriptions/domain/subscription_info.dart`
- `lib/features/attendance/domain/attendance_record.dart`
- `test/model_parsing_test.dart`
- `docs/phase_3_models_summary.md`

## 3. Files Modified

- No production screen files were modified in this phase.

## 4. Models Added And What Firestore Data They Represent

- `UserProfile`
  - Represents documents from the existing `users` collection.
  - Covers fields such as `uid`, `fullName`, `email`, `phone`, `role`, `isActive`, `isApproved`, `isAdmin`, `needsApproval`, `profileCompleted`, `createdAt`, `updatedAt`, `approvedAt`, and `approvedBy`.

- `Swimmer`
  - Represents documents from the existing `swimmers` collection.
  - Covers fields such as `name`, `email`, `phone`, `emergencyContact`, `medicalNotes`, `level`, `joinDate`, `trainingDays`, `trainingTime`, subscription fields, and embedded attendance.

- `Evaluation`
  - Represents documents from the existing `Evaluations` collection.
  - Preserves the current name-based swimmer identifier pattern.
  - Covers fields such as `name`, `level`, `passed`, `score`, `notes`, `date`, `evaluatedAt`, `trainingDays`, and `subscriptionStatus`.

- `SubscriptionInfo`
  - Represents subscription fields embedded inside swimmer documents.
  - Does not change storage behavior.
  - Adds safe helpers for active, expired, expiring-soon, and remaining-day checks.

- `AttendanceRecord` and `AttendanceSnapshot`
  - Represent the current embedded attendance map inside swimmer documents.
  - Do not migrate attendance to another collection or subcollection.

## 5. Date And Type Parsing Compatibility Notes

Added `FirestoreParsers` with safe helpers for:

- `parseString`
- `parseBool`
- `parseInt`
- `parseDouble`
- `parseDateTime`
- `parseStringList`
- `parseMap`

Date parsing supports:

- Firestore `Timestamp`
- Dart `DateTime`
- ISO-style `String`
- `null`

Invalid or unknown date values return `null` instead of throwing.

Type parsing is defensive. Unexpected values fall back to safe defaults where appropriate instead of crashing model creation.

## 6. What Old Data Remains Supported

- Missing fields.
- Null fields.
- Boolean values stored as booleans, numbers, or common strings such as `true`, `false`, `yes`, `no`, `1`, and `0`.
- Scores stored as numbers or strings.
- Dates stored as `Timestamp`, `DateTime`, or parseable strings.
- Attendance stored as the current nested map.
- Subscription data embedded in swimmer documents.
- Evaluation documents linked by swimmer name rather than swimmer ID.

## 7. Whether Any Screens Were Migrated To Models

No screens were migrated to models in this phase.

This was intentional. The models and tests were added first so future phases can migrate one feature at a time with less risk.

## 8. Behavior That Should Remain The Same

- Firebase reads and writes should behave the same.
- Existing Firestore documents remain compatible.
- No existing documents are updated or migrated.
- No UI, routing, screen order, colors, gradients, spacing, or visual identity changed.
- No user-facing features were added or removed.

## 9. Manual Testing Checklist

- Launch the app on Chrome.
- Sign in as a parent and confirm dashboard data loads.
- Sign in as a coach and confirm dashboard data loads.
- Open swimmer list and confirm swimmers still display.
- Open subscriptions and confirm subscription states still display.
- Open evaluations and confirm evaluation data still displays.
- Open parent attendance and confirm attendance data still displays.
- Update a profile in a test environment.
- Add/edit a swimmer in a test environment.
- Add/edit an evaluation in a test environment.

## 10. Commands To Run

```bash
dart format lib/core/utils/firestore_parsers.dart lib/features/auth/domain/user_profile.dart lib/features/swimmers/domain/swimmer.dart lib/features/evaluations/domain/evaluation.dart lib/features/subscriptions/domain/subscription_info.dart lib/features/attendance/domain/attendance_record.dart test/model_parsing_test.dart
flutter analyze
flutter test
flutter run -d chrome
```

## 11. Known Risks Or Remaining TODOs

- Existing screens still use raw `Map<String, dynamic>` data. Future phases should migrate screens gradually.
- Some Firestore data types are inferred from current usage rather than a formal schema.
- `joinDate`, `date`, and subscription dates are still mixed across strings, timestamps, and date objects in existing data.
- Evaluation-to-swimmer relationship still appears name-based.
- Parent-to-swimmer relationship still appears email-based.
- The existing analyzer info-level lint backlog remains.
- Future phases should add repositories/services before broad screen migration.

## 12. Responsive UI Notes

No UI screens were touched in this phase, so no responsive layout changes were made.

Known responsive risks from earlier phases remain:

- Large dialogs in `swimmers_list_screen.dart`.
- Dense subscription layouts in `subscriptions_screen.dart`.
- Large parent dashboard sections in `parent_dashboard_screen.dart`.
- Evaluation dialogs in `evaluation_screen.dart`.
