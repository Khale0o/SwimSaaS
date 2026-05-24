# Phase 8I Single-Academy Production Closeout

## What Was Verified
- Parent auto-linking uses parent email to claim matching swimmer records by writing `swimmers.parentUid`.
- Parent attendance/profile/subscription lookups prefer `swimmers.parentUid == currentUser.uid` and keep legacy email fallback.
- Parent evaluations load from `Evaluations.parentUid == currentUser.uid` without `orderBy(date)`, so legacy records without `date` are still visible.
- Coach/admin evaluation writes continue to stamp `swimmerId`, `swimmerName`, `parentUid` where resolvable, `createdBy`, `updatedBy`, `createdAt`, and `updatedAt`.
- Firestore rules still deny by default.
- Parents can only claim swimmer records when the swimmer email matches `request.auth.token.email`, and only `parentUid`/`updatedAt` may change.
- Parents can only read evaluations when `request.auth.uid == resource.data.parentUid`.
- Staff access remains available for approved coach/admin operational screens.
- `web/index.html` keeps `<base href="$FLUTTER_BASE_HREF">`.
- `web/_redirects` exists for direct-route refresh safety.
- `firebase.json` references versioned Firestore rules, indexes, and Storage rules.
- `lib/screens/lib/firebase_options.dart` is removed; the active generated config is `lib/firebase_options.dart`.
- `admin_setup_screen.dart` and `upload_students.dart` remain in source but are not referenced from normal app routes/imports found by search.

## Tiny Files Changed
- `docs/phase_8i_single_academy_production_closeout.md`

No app code, UI, routes, Firestore schema, or rules were changed in this closeout phase.

## Manual QA Checklist Before Deploying
1. Register/login a parent with email matching `swimmers.email`.
2. Confirm `swimmers.parentUid` is set to that parent uid.
3. Confirm parent Attendance appears.
4. Confirm parent Evaluations appear.
5. Create a new evaluation as coach/admin for that swimmer.
6. Confirm the new evaluation has `swimmerId`, `swimmerName`, `parentUid`, `createdBy`, `updatedBy`, `createdAt`, and `updatedAt`.
7. Confirm the parent sees that evaluation.
8. Confirm another parent cannot see that swimmer/evaluation.
9. Confirm coach/admin dashboard, swimmers, evaluations, and subscriptions still work.
10. Check Chrome console for permission-denied or missing-index errors.
11. Confirm dev-only admin/setup utilities are not reachable in the deployed app.

## Deployment Commands To Run Later
Do not run these until manual QA is complete:

```powershell
firebase deploy --only firestore:rules,firestore:indexes,storage
flutter build web --release --base-href /
```

## Hosting Reminder
- Publish `build/web`.
- For Netlify, keep `web/_redirects` copied into the build output.
- Add the deployed domain to Firebase Authentication authorized domains.

## Final Status
Ready for single-academy controlled production/staging only after manual QA and rules deploy.

Multi-academy SaaS remains a separate future project/architecture and was not added here.
