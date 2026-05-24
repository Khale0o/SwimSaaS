# Phase 8D Single-Academy Evaluation Ownership Hardening

## Phase Goal
Make the current single-academy app safer for production by closing the parent evaluation ownership gap without changing UI, routes, or SaaS architecture.

## Files Changed
- `firestore.rules`
- `firestore.indexes.json`
- `lib/core/constants/app_fields.dart`
- `lib/features/evaluations/domain/evaluation.dart`
- `lib/features/swimmers/domain/swimmer.dart`
- `lib/screens/evaluation_screen.dart`
- `lib/screens/parent_dashboard_screen.dart`
- `test/model_parsing_test.dart`
- `docs/phase_8d_single_academy_evaluation_ownership_hardening.md`

## Current Issue
Parents previously read evaluations through a legacy swimmer-name match. That cannot be secured reliably in Firestore rules because names are not stable ownership identifiers.

## Fields Added
New field constants:
- `swimmerId`
- `swimmerName`
- `parentUid`
- `createdBy`
- `updatedBy`

Existing timestamp fields reused:
- `createdAt`
- `updatedAt`

## How New Evaluations Are Secured
New evaluations now attempt to store:
- `swimmerId`
- `swimmerName`
- `parentUid`
- `createdBy`
- `updatedBy`
- `createdAt`
- `updatedAt`

When an evaluation is created from a swimmer card, the app uses that swimmer document. When an evaluation is created manually by name, the app attempts to resolve the matching swimmer document by name.

`parentUid` is resolved from:
1. Existing `swimmers.parentUid`, if present.
2. The parent user document matching the swimmer email and parent role.

If ownership cannot be resolved, the evaluation is still created for coach/admin workflows, but it will not be visible to parents under strict production rules until backfilled.

## Backward Compatibility Notes
- Legacy evaluation documents without ownership fields do not crash the app.
- Parent dashboard prefers secure `parentUid` evaluation reads when the swimmer has ownership data.
- Legacy name-based reads remain as a fallback for non-strict/demo datasets, but strict rules will not expose legacy evaluations to parents unless `parentUid` is backfilled.
- Coach/admin screens continue to read operational evaluation data.

## Backfill/Migration Plan
Before deploying strict production rules to an existing dataset:
1. Export or back up Firestore.
2. For each legacy `Evaluations` document, match to `swimmers` by the existing `name` field only if it is unique and manually reviewed.
3. Write:
   - `swimmerId = matched swimmer document id`
   - `swimmerName = matched swimmer name`
   - `parentUid = matched swimmer parentUid`, or the user id of the parent whose email matches the swimmer email
   - `updatedAt = server timestamp`
4. Skip ambiguous name matches until manually resolved.
5. Re-test parent accounts before deploying rules.

Name matching is a legacy fallback and must be manually reviewed. It should not be treated as a long-term ownership model.

## Firestore Rules Changes
Rules now allow parent reads of `Evaluations` only when:
- `request.auth.uid == resource.data.parentUid`

Rules still allow approved coaches/admins to read and write operational evaluation data.

Rules still deny by default and do not expose legacy evaluation documents without `parentUid` to parents.

Staff users can list `users` so the app can resolve a parent uid from swimmer email when stamping new evaluation ownership metadata.

## Firestore Indexes
Versioned indexes were added for likely production queries:
- `Evaluations.parentUid + date desc`
- `Evaluations.name + date desc`
- `users.role + isApproved`
- `users.email + role`

## Manual QA Checklist
- Coach/admin creates evaluation from a swimmer card.
- Coach/admin creates manual evaluation for a known swimmer.
- Parent sees only their child evaluations after `parentUid` is present.
- Parent cannot see another parent child evaluation.
- Legacy evaluation without `parentUid` does not crash app.
- Legacy evaluation without `parentUid` is not exposed to parents under strict rules.
- Rules are tested in Firebase emulator before deploy.
- Build/deploy still works.

## Remaining Production Risks
- Existing legacy evaluation documents require backfill before strict production rules are deployed.
- Swimmer documents without parent ownership may still need `parentUid` backfill for future-proofing.
- Parent uid resolution from swimmer email depends on a matching parent user document.
- Firebase rules were not deployed in this phase.
- Firebase emulator validation was not run in this environment.
