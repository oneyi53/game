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
