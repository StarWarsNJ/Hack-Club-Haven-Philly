# Snapback — Autonomous Implementation and Iteration Plan

This is **one sustained Codex project**, not a list of manual prompts. The goal document (`CODEX_GOAL.md`) authorizes Codex to carry out the stages below autonomously. The stages are **internal quality gates**; do not stop after each one unless blocked.

## Initial audit

1. Read every design document and `AGENTS.md`.
2. Inspect Git status, root files, previous experimental content, and available test/browser tools. Do not delete or overwrite valuable user work. Do not revive the retired Godot/Paradox Heist game.
3. Confirm the chosen deliverable: **one self-contained browser game in `index.html`**. The existing `project.godot` may remain unused.
4. Write initial observations and assumptions in `docs/DEV_LOG.md`.

## Stage A: Prove the core fun (highest priority)

- Render one arena and two distinct controllable player silhouettes.
- Fixed 60 Hz movement, gravity, steering, always-bouncing trampoline and pits.
- Correct simultaneous WASD/arrow input.
- Minimal center scoreboard, start/retry, and full rally reset.
- Make two humans able to play a short rally immediately. If human testing is unavailable, run browser/input tests and mark human fun **unverified**.

**Gate:** players can move and bounce simultaneously; single knockout produces exactly one point; first-to-three match can end and rematch.

## Stage B: Build the skill loop

- Timed bounce press with clear timing cue and five tiers; avoid mash/hold exploits.
- Descending dive; top-down stomp; side collisions; short anti-juggle protection.
- Correct loss/recovery physics and fair impulse directions.
- Tune CONFIG to keep all movement within the useful vertical field.

**Gate:** physics tests prove perfect vs missed bounce difference, correct stomps from both sides, and no high-speed pass-through.

## Stage C: The theme-defining comeback

- Implement **Snapback Save** at both side bumpers, one charge/player/rally.
- Add readable save-ready prompt, strict timing, launch inward/up, reset next rally.
- Ensure saves are possible when knocked toward the pits but can fail if mistimed.
- Implement coupled net waves so both players actually affect the same trampoline; cap interactions.

**Gate:** deterministic save tests pass on both sides for both players; no unlimited rescue; net remains stable over long simulation.

## Stage D: Pace and rematch polish

- Quick point freeze and instant rally reset; winner screen and rematch.
- Pause/resume, focus loss, mute, reduced motion.
- If rallies stall, add telegraphed Overdrive contraction; tune or omit if it produces unfair outcomes.
- Small screen-edge help that fades once players get moving, without clutter.

**Gate:** 50 scripted complete match resets stable; no repeated point award; no stale controls between rounds.

## Stage E: Designed visual and sonic identity

- Replace placeholder rectangles with original procedural athletes and deliberate title/HUD/winner layouts.
- Animate character squash/stretch and membrane deformations based on real state.
- Add concise generated audio, responsive and never required for gameplay.
- Tune typography, color contrast, visual timing, tiny effects, accessibility.
- Inspect screenshots at several viewport sizes when tools allow.

**Gate:** readable and cohesive; no invisible collisions, cut-off text, overflow, or obstructive screen effects. Visual inspection documented, not assumed.

## Stage F: Validation and release readiness

- Execute the full `TEST_PLAN.md`; fix critical/high defects, rerun regression.
- Browser check, resize check, pause/focus and keyboard chord check.
- Where possible test in real embedded browser conditions and prepare distribution instructions for itch.io.
- Finalize `README.md`, `DEV_LOG.md`, `QA_REPORT.md`, and any tunings; confirm one complete match loop works.

**Gate:** all objective, executable acceptance tests pass, and unsupported human/hardware tests are explicitly marked NOT RUN/BLOCKED. Report limitations; do not publish.

## Prioritization when something goes wrong

1. Restore ability to play from title to match result.
2. Repair unfair or nondeterministic collision/scoring behavior.
3. Repair Snapback Save and bounce timing.
4. Repair visuals/sound/accessibility.
5. Tune subtle effects and polish.

Do not bolt on new arenas, levels, multiplayer networking, complex menus, AI, or high-score progression to paper over a weak core loop. Refactor when necessary, but preserve project history.

## Iteration rule

**Inspect → implement → test → observe → retune → rerun regressions.** Maintain an honest record of what was tested. If no browser automation is available, state what happened and what needs manual verification rather than claiming visual or interaction checks passed.

## Stop criteria

Stop and present a final report only when:
- One complete match is functional and can rematch.
- All required mechanics and interface screens are finished and tested where possible.
- No known critical or high bugs remain.
- There is clear evidence for implemented mechanics and candid flags for human-only checks.
- Additional work would be cosmetic, unsupported by data, or unsafe without asking the user.

Do not claim the game is 'hackathon-winning'. Quality and user delight are objectives; judges and human players decide results.
