# Phase 6A Firebase Cost And Performance Audit

## 1. Phase Goal

Audit current Firebase Auth and Firestore usage for future performance and cost optimization. This phase is documentation-only: no production Dart files, UI, Firebase schema, Firestore collection names, field names, queries, data, or user flows were changed.

## 2. Files Inspected

- `lib/main.dart`
- `lib/screens/create_account_screen.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/forget_password_screen.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/profile_screen.dart`
- `lib/screens/dashboard_screen.dart`
- `lib/screens/swimmers_list_screen.dart`
- `lib/screens/parents_screen.dart`
- `lib/screens/subscriptions_screen.dart`
- `lib/screens/active_subs_screen.dart`
- `lib/screens/expired_subs_screen.dart`
- `lib/screens/evaluation_screen.dart`
- `lib/screens/pending_evals_screen.dart`
- `lib/screens/parent_dashboard_screen.dart`
- `lib/screens/admin_panel_screen.dart`
- `lib/screens/admin_setup_screen.dart`
- `lib/upload_students.dart`
- `lib/features/auth/data/auth_repository.dart`
- `lib/features/auth/data/user_repository.dart`
- `lib/features/swimmers/data/swimmer_repository.dart`
- `lib/features/evaluations/data/evaluation_repository.dart`
- `lib/features/subscriptions/data/subscription_repository.dart`
- `lib/features/attendance/data/attendance_repository.dart`
- `firebase.json`
- Project root for Firestore rules files

## 3. Firestore Read Map By Screen/File

| File | Read Pattern | Cost/Performance Notes |
| --- | --- | --- |
| `lib/features/auth/data/user_repository.dart` | `users/{uid}.get()`, timed `users/{uid}.get()`, `users/{uid}.snapshots()`, pending coaches query stream | User document reads are small and appropriate. Pending coach stream is filtered but needs index/rules review. |
| `lib/features/swimmers/data/swimmer_repository.dart` | Full `swimmers.snapshots()`, typed full `swimmers.snapshots()`, `swimmers/{id}.get()` | Repository exposes full collection listeners. Future screens should prefer filtered/limited methods. |
| `lib/features/evaluations/data/evaluation_repository.dart` | Full `Evaluations.snapshots()`, ordered `Evaluations.orderBy(date).snapshots()` | Ordered real-time full collection can become expensive as evaluations grow. |
| `lib/features/subscriptions/data/subscription_repository.dart` | Full `swimmers.get()` for bulk renewal | Bulk read of all swimmers before selective updates. Cost grows linearly. |
| `lib/screens/dashboard_screen.dart` | Full real-time `swimmers.snapshots()` plus nested full real-time `Evaluations.snapshots()` | High-cost dashboard: every open dashboard reads all swimmers and all evaluations in real time to calculate counts and schedules client-side. |
| `lib/screens/swimmers_list_screen.dart` | Full real-time `swimmers.snapshots()` | Full collection listener, client-side search and sort. Expensive with large swimmer counts. |
| `lib/screens/subscriptions_screen.dart` | Two separate full real-time `swimmers.snapshots()` listeners in the same screen | Very high duplicate-read risk: one stream for stats and another stream for list filtering. |
| `lib/screens/active_subs_screen.dart` | Full real-time `swimmers.snapshots()` | Reads all swimmers, filters active subscriptions client-side. |
| `lib/screens/expired_subs_screen.dart` | Full real-time `swimmers.snapshots()` | Reads all swimmers, filters expired subscriptions client-side. |
| `lib/screens/evaluation_screen.dart` | Full real-time `swimmers.snapshots()`; inside async map, full one-time `Evaluations.get()` after swimmer updates; ordered real-time `Evaluations.orderBy(date).snapshots()` | Highest risk pattern: each swimmer snapshot refresh can trigger a full evaluations read. Evaluated list streams all evaluations ordered by date. |
| `lib/screens/pending_evals_screen.dart` | Full real-time `Evaluations.snapshots()` | Reads all evaluations and filters pending client-side. Should become query-filtered later. |
| `lib/screens/parents_screen.dart` | Full one-time `swimmers.get()` in `initState` | Lower than a listener, but still a full collection scan and refreshes after add. |
| `lib/screens/parent_dashboard_screen.dart` | Multiple one-time `swimmers.where(email).limit(1).get()` calls across attendance, evaluations, subscription, profile; `Evaluations.where(name).orderBy(date).get()` | Per-tab reads are filtered and limited for swimmer lookup, but repeated across nested pages. Evaluation query likely needs composite index. |
| `lib/screens/home_screen.dart` | One-time `users/{currentUid}.get()` | Low cost; used for admin flag. Can be cached in current user session later. |
| `lib/screens/profile_screen.dart` | One-time `users/{currentUid}.get()` | Low cost; profile screen read. |
| `lib/screens/admin_panel_screen.dart` | Real-time `users.where(role == coach).where(isApproved == false).snapshots()` | Appropriate to keep real-time for admin approvals, but needs rules and composite index awareness. |
| `lib/screens/admin_setup_screen.dart` | One-time `users.where(email).get()` | Dev-only privileged utility. Should not be reachable in production. |
| `lib/screens/create_account_screen.dart` | No Firestore read; writes user profile after Firebase Auth creation | Low read cost. |
| `lib/upload_students.dart` | No reads; writes many sample docs | Dev-only utility. Cost/security risk if reachable. |

## 4. Firestore Write Map By Screen/File

| File | Write Pattern | Notes |
| --- | --- | --- |
| `lib/screens/create_account_screen.dart` | `users/{uid}.set({...})` | Creates app profile after Firebase Auth account creation. Coach accounts start inactive/unapproved. |
| `lib/features/auth/data/user_repository.dart` | `users/{uid}.set`, `users/{uid}.update`, approve coach update, reject coach delete | Repository mirrors existing user profile/admin behavior. |
| `lib/screens/admin_panel_screen.dart` | Update pending coach approval fields; delete rejected coach doc | Privileged writes. Must be protected by Firestore rules/server trust before production. |
| `lib/screens/admin_setup_screen.dart` | Query user by email, update admin/approval/active flags | Development-only privileged write. High security risk if exposed. |
| `lib/screens/profile_screen.dart` | `users/{uid}.update` for profile changes | Normal profile write. |
| `lib/features/swimmers/data/swimmer_repository.dart` | Add/update/delete swimmer docs | Repository wrapper only; screens still mostly use direct Firestore. |
| `lib/screens/swimmers_list_screen.dart` | Add swimmer, update swimmer, delete swimmer | Normal operational writes. Delete is permanent and may orphan evaluations by name. |
| `lib/screens/parents_screen.dart` | Add swimmer | Duplicates swimmer creation behavior in a separate screen. |
| `lib/features/evaluations/data/evaluation_repository.dart` | Add/update/delete evaluation docs | Repository wrapper. |
| `lib/screens/evaluation_screen.dart` | Add evaluation, update evaluation, delete evaluation | Writes to `Evaluations`; relation to swimmers is name-based. |
| `lib/screens/pending_evals_screen.dart` | Update evaluation passed/score/notes/evaluatedAt | Operational evaluation update. |
| `lib/features/subscriptions/data/subscription_repository.dart` | Update one swimmer subscription; full read then update matching swimmers in bulk | Bulk renewal performs N reads and up to N updates. |
| `lib/screens/subscriptions_screen.dart` | Update one swimmer subscription; full read then update expired/expiring swimmers in bulk | Highest write-cost risk due sequential per-document updates after full scan. |
| `lib/features/attendance/data/attendance_repository.dart` | Update embedded `attendance.dateKey` map in swimmer doc | No subcollection migration. Large attendance maps can grow individual swimmer documents. |
| `lib/screens/dashboard_screen.dart` | Update embedded attendance map for selected swimmer/date | Normal attendance write, but document size may grow over time. |
| `lib/upload_students.dart` | Adds 50 sample documents to `Evaluations` | Dev-only bulk writes; risky if exposed or run repeatedly. |

## 5. High-Cost Risk Areas

1. `subscriptions_screen.dart`
   - Two independent full `swimmers.snapshots()` listeners on the same screen.
   - Client-side tab filtering and search.
   - Bulk renewal scans every swimmer and updates matches one by one.

2. `dashboard_screen.dart`
   - Full real-time `swimmers` listener for counts, active/expired totals, and today's groups.
   - Nested full real-time `Evaluations` listener for pending evaluations count.
   - Counts are derived client-side instead of using counters or filtered count queries.

3. `evaluation_screen.dart`
   - Full `swimmers` listener.
   - Full `Evaluations.get()` inside `asyncMap` whenever swimmer stream emits.
   - Full ordered `Evaluations` listener for evaluated swimmers.

4. `swimmers_list_screen.dart`, `active_subs_screen.dart`, `expired_subs_screen.dart`, `pending_evals_screen.dart`
   - Full collection real-time listeners with client-side filtering/sorting.
   - No limits or pagination.

5. `parent_dashboard_screen.dart`
   - Filtered reads are safer, but the same swimmer lookup by email is repeated across attendance, evaluations, subscription, and profile pages.
   - `Evaluations.where(name).orderBy(date)` may need a composite index.

6. `upload_students.dart` and `admin_setup_screen.dart`
   - Development-only tools with write/security risk if reachable in production.

## 6. Real-Time Listeners That Should Stay

These can reasonably remain real-time in a later optimized form:

- Admin pending coach approvals:
  - Real-time is useful because admins should see new coach requests immediately.
  - Keep as a filtered listener, with rules/indexes verified.

- Coach dashboard core data:
  - Some real-time behavior is useful for attendance and daily operations.
  - Later implementation should avoid full collection listeners for every count.

- Swimmers list:
  - Real-time updates are useful when multiple staff may add/edit swimmers.
  - Later implementation should use query limits, pagination, and server-side filters where possible.

- Attendance state for today's sessions:
  - Real-time can be valuable if attendance is updated from multiple devices.
  - Later implementation should limit the read scope to today's groups/swimmers rather than all swimmers.

## 7. Reads That Could Become Future/Paginated Later

- Active subscriptions and expired subscriptions:
  - Replace full `swimmers.snapshots()` plus client filtering with `where(subscriptionStatus == Active/Expired)`, `orderBy(name)`, and `limit`.

- Pending evaluations:
  - Replace full `Evaluations.snapshots()` with filtered queries for pending values.
  - Because current pending logic treats `passed == 'No'` or missing/null as pending, this needs a careful compatibility plan.

- Evaluated evaluations list:
  - Add `orderBy(date, descending: true).limit(pageSize)` and cursor pagination.

- Full swimmers list:
  - Add `orderBy(name).limit(pageSize)` pagination.
  - Search should eventually be prefix-based, indexed, or delegated to a search service if fuzzy search is needed.

- Parents screen:
  - One-time full `swimmers.get()` can become paginated or limited.

- Parent dashboard:
  - Cache/memoize the current user's swimmer document after the first email lookup during a session.

- Home screen admin flag:
  - Cache current user profile after AuthGate/Login loads it instead of re-reading in `home_screen.dart`.

## 8. Recommended Pagination/Caching Opportunities

Low-risk future opportunities:

- Share one `swimmers` stream within `subscriptions_screen.dart` instead of opening two separate listeners.
- Move dashboard counts to repository methods so reads can be centralized and later optimized without touching UI.
- Cache the current `UserProfile` loaded by `AuthGate` or login for the active session.
- Cache the parent/swimmer document lookup by email in parent dashboard child pages.
- Add `limit` to evaluated lists where screen behavior can tolerate pagination.

Medium-risk future opportunities:

- Add query-filtered subscription list methods:
  - `swimmers.where(subscriptionStatus == Active).orderBy(name).limit(n)`
  - `swimmers.where(subscriptionStatus == Expired).orderBy(name).limit(n)`
- Add paginated swimmer list with `orderBy(name)`, `limit`, and `startAfterDocument`.
- Add paginated evaluations with `orderBy(date, descending: true)`, `limit`, and cursor pagination.
- Replace `evaluation_screen.dart` non-evaluated swimmers calculation with a safer marker/counter strategy in a later schema-aware phase.

High-risk or delayed opportunities:

- Introduce tenant/academy partitioning and update every query to filter by `academyId`.
- Move attendance from embedded maps to subcollections.
- Replace name-based swimmer/evaluation relation with stable swimmer IDs.
- Add denormalized aggregate documents and Cloud Functions.

## 9. Future Denormalized Counter Opportunities

These should not be implemented until requirements and write paths are centralized:

- `totalSwimmers`
- `activeSubscriptions`
- `expiredSubscriptions`
- `expiringSoonSubscriptions`
- `pendingEvaluations`
- `todayAttendancePresent`
- `todayAttendanceAbsent`
- `pendingCoachApprovals`
- Per-swimmer evaluation totals and average score

Possible future storage shape:

- `stats/global` for single-academy aggregate counters.
- `academies/{academyId}/stats/dashboard` after SaaS tenant isolation exists.

These counters would reduce dashboard and summary reads but require safe, centralized writes or backend functions to avoid drift.

## 10. Firebase Index Risks

Queries likely to need or benefit from Firestore indexes:

- `users.where(role == coach).where(isApproved == false)`
  - Used in `admin_panel_screen.dart` and `UserRepository.streamPendingCoaches`.
  - Composite index may be required depending on Firestore index state.

- `Evaluations.where(name == swimmerName).orderBy(date, descending: true)`
  - Used in `parent_dashboard_screen.dart`.
  - Composite index likely required.

- Future recommended queries:
  - `swimmers.where(subscriptionStatus == Active).orderBy(name)`
  - `swimmers.where(subscriptionStatus == Expired).orderBy(name)`
  - `swimmers.where(email == currentUser.email).limit(1)`
  - `Evaluations.where(passed == No).orderBy(date)`
  - Tenant-scoped queries such as `where(academyId == id).where(status == value).orderBy(name)`

No index files were found in this audit.

## 11. Security/Cost Risks

- No Firestore rules file was found in the repository scan.
  - Rules may exist outside this repo, but they are not visible here.
  - Production readiness should include rules review before launch.

- `admin_setup_screen.dart`
  - Development-only utility can make a user admin by email.
  - Must remain unreachable from normal navigation and protected by rules/backend trust.

- `upload_students.dart`
  - Development-only seeding utility writes 50 sample documents to `Evaluations`.
  - Repeated accidental use can create extra reads/writes and pollute production data.

- Broad reads without tenant filtering:
  - Most reads currently target global `users`, `swimmers`, and `Evaluations`.
  - Future SaaS isolation will need `academyId` or another tenant boundary.

- Client-side admin logic:
  - Admin approval and setup writes are initiated from the client.
  - Firestore rules must enforce who can update admin/approval fields.

- Name-based evaluation relation:
  - Evaluations are linked to swimmers by name in multiple places.
  - This can cause duplicated reads, mismatches after name edits, and hard-to-secure queries.

- Embedded attendance maps:
  - Attendance is stored inside swimmer documents.
  - This is simple and currently schema-compatible, but can grow document size and cause whole-document reads for attendance history.

## 12. Safe Phase 6B Plan

### Low-Risk Changes

- Update documentation for production Firebase rules and index requirements.
- Centralize read methods in repositories without changing queries yet.
- In `subscriptions_screen.dart`, share one existing `swimmers` stream result within the screen instead of opening two listeners.
- Cache the current user profile loaded during startup/login for the current session.
- Cache parent-dashboard swimmer lookup by email during the active page/session.
- Add repository methods for one-time reads where screens do not require real-time behavior.

### Medium-Risk Changes

- Add filtered queries for active/expired subscription screens.
- Add `orderBy(name)` and `limit` to swimmers lists with pagination UI/logic.
- Add `orderBy(date)` and `limit` to evaluation lists with pagination.
- Replace pending-evaluation full scans with a compatibility-safe query once `passed` values and null behavior are documented.
- Add a batch-write or chunked write strategy for bulk subscription renewal.

### High-Risk Changes To Delay

- Tenant isolation with `academyId` across all collections and queries.
- Firestore schema migration for swimmer/evaluation relations.
- Moving attendance to subcollections.
- Adding Cloud Functions for aggregate counters.
- Changing current dashboard behavior from real-time full reads to denormalized counters.

## 13. What Code Was Changed

No production Dart files were modified in Phase 6A.

Created documentation only:

- `docs/phase_6a_firebase_cost_performance_audit.md`

## 14. Commands Run

```bash
git -c safe.directory=C:/Users/hp/AndroidStudioProjects/swim status --short
rg -n "FirebaseFirestore|collection\\(|doc\\(|snapshots\\(|get\\(|set\\(|update\\(|add\\(|delete\\(|FieldValue|WriteBatch|batch\\(|StreamBuilder|FutureBuilder" lib
rg -n "users|swimmers|Evaluations|attendance|subscriptionStatus|subscriptionExpiry|isApproved|isActive|isAdmin|needsApproval" lib
rg -n "where\\(|orderBy\\(|limit\\(" lib
rg -n "StreamBuilder<|FutureBuilder<|snapshots\\(|\\.get\\(\\)" lib\\screens lib\\features lib\\upload_students.dart
rg -n "rules_version|match /databases|allow read|allow write|firestore" -g "*.rules" -g "firebase.json" -g "*.json" .
```

Verification commands requested after documentation:

```bash
flutter analyze
flutter test
```

## 15. Known Risks And TODOs

- The audit is static and based on source inspection; it does not include Firebase console billing metrics.
- No Firestore rules file was available in the repo, so rules quality could not be verified.
- No index definitions were available in the repo, so index status must be checked in Firebase Console.
- Existing full collection listeners are acceptable for small datasets but will become costly as swimmer/evaluation counts grow.
- Phase 6B should avoid schema changes and begin with duplicate-listener reduction, caching, and repository-level query centralization.
