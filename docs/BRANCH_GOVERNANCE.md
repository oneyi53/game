# Branch Governance and Cleanup Audit

**Audit date:** 2026-11-06  
**Repository:** `oneyi53/game`  
**Default branch:** `main`  
**Active implementation branch:** `feat/exploration-progression-foundation-2026-11-05`

## Audit snapshot

The repository currently has **70 branch refs** and **51 pull requests**.

| Classification | Count | Policy |
|---|---:|---|
| Open pull requests | 8 | Preserve; each is an active review/workstream until explicitly merged or closed |
| Merged pull-request heads | 40 unique branches | Safe cleanup candidates after confirming they are not the active build/release pointer |
| Closed without merge | 3 | Preserve for review; do not delete automatically |
| Other refs (including `main`, the active exploration branch, and refs without a merged PR) | 19 | Audit individually before any deletion |

The 8 open PRs at audit time are #50 (reference HUD), #49 (daily activity UI), #48 (Android export optimization), #47 (daily activity core), #45 (red-dot UI), #18 (equipment art UI), #9 (Godot cloud validation), and #6 (local code audit).

The 3 closed, unmerged PR heads are:
- `feat/campfire-fast-travel-2026-11-04` (#25)
- `tools/effect-atlas-components-2026-11-04` (#21)
- `tools/inspect-effect-atlas-2026-11-04` (#13)

## Canonical workflow from this audit onward

1. `main` is the stable integration/release branch. Do not force-push it.
2. Keep one active gameplay integration branch for the current exploration milestone: `feat/exploration-progression-foundation-2026-11-05`.
3. Do not create a new long-lived branch for every tiny documentation, UI, or test adjustment. Continue related work on the active milestone branch.
4. A genuinely independent feature gets one short-lived branch and one PR to the agreed integration base.
5. Merge only after Godot cloud validation passes and the PR's scope is reviewed.
6. After merge, delete the source branch; keep the commit history and PR as the permanent record.
7. Never delete an open-PR head, a closed-unmerged head, `main`, or the active integration branch as part of bulk cleanup.
8. Keep build artifact identity in workflow run/artifact metadata; do not retain a branch solely as an APK download pointer.

## Cleanup execution boundary

This audit classifies the refs and establishes the future workflow. The connected GitHub operations available in this session support branch listing/creation/ref updates but do **not** expose branch-ref deletion. Therefore no branch was force-moved or deleted during this audit. The 40 merged heads are cleanup candidates, not falsely reported as deleted. Delete them through GitHub's branch UI or an authorized Git client after confirming the branch is not protected or used by an external release process.

## Current milestone

The active exploration branch remains the only branch for E3 map work. E3a now has a fog-aware map panel connected to the live player, enemy, resource, and campfire state. Cloud validation passed on commit `4eb3df7d8af5d5fb123309aa984add4cc0a25ceb` (Godot 4.7.2, all configured regression suites and headless startup).

Next: finish E3b interaction/teleport consistency, then open one reviewed integration PR rather than spawning additional work branches.

## Reconciliation audit — 2026-11-06 (live GitHub recheck)

The initial merged-PR count needs a base-branch distinction. Of the 40 merged PRs:
- 38 were merged into `main`, representing 37 unique source branch names (PRs #16 and #17 share one head).
- 2 were merged into `feat/reference-grade-world-exploration-2026-11-05`, not into `main`: PR #51 (`fix/camp-manager-test-type-2026-11-05`) and PR #52 (`build/android-apk-from-tested-exploration-2026-11-05`). Keep these two heads until the reference-grade branch's unique commits are reconciled with the active exploration branch.
- 8 open PR heads remain protected.
- 3 closed-unmerged PR heads remain protected pending manual code review.
- 18 other refs have no merged/open/closed PR mapping and require individual comparison; this includes build pointers, content drafts, art, and gameplay branches.

### Integration graph findings

Live compare results:
- `main` vs `feat/exploration-progression-foundation-2026-11-05`: active branch is 250 commits ahead and 2 commits behind; the two main-only file changes are `5.png` and `image.png`. This is a divergence, not a fast-forward.
- `feat/reference-grade-world-exploration-2026-11-05` vs active exploration: active branch is 86 commits ahead and 3 commits behind, with changes across gameplay scripts, scenes, workflows, tests, and project records.
- Therefore neither moving `main` nor deleting the reference-grade/build heads is safe until the two main-only image assets and the three reference-grade-only commits have been reconciled and verified. Do not use a force update to make the graph appear linear.

### Updated live inventory

| Classification | Count | Action |
|---|---:|---|
| All remote refs | 70 | Baseline |
| Open PR heads | 8 | Preserve |
| Merged into main (unique source heads) | 37 | Cleanup candidates after final ancestry/build-pointer check |
| Merged into reference-grade branch | 2 | Preserve until branch reconciliation |
| Closed without merge | 3 | Preserve pending review |
| Other refs without PR mapping | 18 | Compare individually |
| `main` + active exploration branch | 2 | Preserve |

### Cleanup execution status

No branch refs have been deleted. The connected GitHub integration in this session exposes branch listing and ref updates, but no branch-ref DELETE operation; its generic GitHub fetch is GET-only. Do not claim deletion or attempt to simulate it by moving refs. The 37 main-merged heads are now the first cleanup batch for an authorized GitHub UI/client operation, but first verify that none is protected or referenced by a release process. The two feature-base merged heads and all 18 unclassified refs are explicitly excluded from that batch.

### Next safe sequence

1. Reconcile the two main-only original PNG assets into the active integration line without changing their content.
2. Inspect the three reference-grade-only commits and determine whether their content is already present, superseded, or still required in the active line.
3. Compare each of the 18 no-PR refs against the active line and record unique files/commits.
4. Only then prepare a precise deletion list for merged-to-main source heads; delete through an authorized GitHub branch-management surface.
5. Keep `main` stable; integrate the validated active milestone through a reviewed PR rather than force-moving the branch.
