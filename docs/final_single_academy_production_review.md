# Final Single-Academy Production Review

## Files Changed
- `docs/final_single_academy_production_review.md`

No app code, Firestore rules, Firebase config, routes, UI, or schema were changed in this final pass.

## Firebase / Rules Safety
- `firebase.json` points to:
  - `firestore.rules`
  - `firestore.indexes.json`
  - `storage.rules`
- `firestore.rules` remains deny-by-default through the final catch-all rule.
- Parent swimmer claiming remains constrained:
  - user must be an active parent
  - `request.auth.token.email` must match the existing swimmer `email`
  - incoming `parentUid` must equal `request.auth.uid`
  - only `parentUid` and `updatedAt` may change
  - existing non-empty ownership cannot be overwritten by another parent
- Parent evaluation reads remain ownership-based:
  - `request.auth.uid == resource.data.parentUid`
- Staff access remains compatible for current app flows:
  - admin or approved active coach can read/write operational swimmer and evaluation data
  - admin can manage users/coach approval

## Parent Production Flow
- Parent registration calls `ParentLinkingService.linkCurrentParentToSwimmers`.
- Login and startup routing also run the same parent linking safety net.
- Parent dashboard swimmer lookups prefer `swimmers.parentUid == currentUser.uid`, with legacy email fallback for old single-academy data.
- Parent evaluations load from `Evaluations.parentUid == currentUser.uid` without `orderBy(date)`.
- Evaluation creation/update still stamps ownership/audit fields where resolvable:
  - `swimmerId`
  - `swimmerName`
  - `parentUid`
  - `createdBy`
  - `updatedBy`
  - `createdAt`
  - `updatedAt`
- Legacy fallback is app-side compatibility only; Firestore rules still require ownership for parent evaluation reads.

## Web Deployment
- `web/index.html` keeps `<base href="$FLUTTER_BASE_HREF">`.
- `web/_redirects` exists with SPA fallback:
  - `/*    /index.html   200`
- Web build command remains:

```powershell
flutter build web --release --base-href /
```

- `assets/google.png` and `assets/apple.png` exist and are listed in `pubspec.yaml`.

## Responsive / UX Closeout
- Main coach/admin screens use `ResponsiveMaxWidth` wrappers for laptop/desktop constraints.
- Floating navigation bottom padding uses `floatingNavSafeBottomPadding` on the reviewed scrollable screens.
- Large headers are collapsed with scroll-driven `AnimatedSize` behavior on the dashboard-style screens.
- Parent dashboard keep-alive/loading behavior remains preserved.

## Dev-Only Utilities
- `admin_setup_screen.dart` exists but was not found in production route/import references.
- `upload_students.dart` exists and remains dev-only; it was not found wired into production navigation.
- These files should stay unreachable in deployed builds or be removed in a future cleanup after confirmation.

## Verification
- `flutter analyze`: passed
- `flutter test`: passed
- `flutter build web --release --base-href /`: passed

## Final Deployment Checklist
1. Run manual QA with real/staging Firebase:
   - parent registers with email matching `swimmers.email`
   - `swimmers.parentUid` is set
   - parent attendance appears
   - parent evaluations appear
   - another parent cannot see those records
   - coach/admin evaluation create/update still works
2. Confirm Firebase Auth authorized domains include the deployed domain.
3. Deploy rules/indexes/storage only after manual QA:

```powershell
firebase deploy --only firestore:rules,firestore:indexes,storage
```

4. Build web:

```powershell
flutter build web --release --base-href /
```

5. Publish `build/web` to Netlify/Firebase Hosting.

## Final Production Status
Ready for single-academy controlled production/staging after final manual QA on the deployed Firebase project.

This closeout does not add SaaS or multi-academy architecture. Multi-academy should be handled as a separate future project.
