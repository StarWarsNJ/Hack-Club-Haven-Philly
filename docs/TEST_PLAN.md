# PARADOX HEIST — Verification and Playtest Plan

## How to test
Use Godot editor F5 for hands-on tests. When the Godot executable is accessible from terminal, run a project import/parse check and a short headless startup. Example only if `godot` is on PATH:

```powershell
godot --headless --path . --import
godot --headless --path . --quit-after 120
```

Codex should create small GDScript test harnesses for pure game-logic classes; tests must not require an additional addon without approval. Report observed console errors, not guesses. Visual/audio/UI behavior requires manual testing.

## A. Environment
- [ ] Existing `project.godot` remains valid, Compatibility rendering used, 16:9 UI scales.
- [ ] Main menu opens and Start launches M1.
- [ ] Inputs work on standard Windows keyboard; browser focus loss pauses.
- [ ] Source code changes don't cause unintended `.godot/` tracking or generated build tracking.

## B. Tick/replay invariants (automated where possible)
- [ ] Mission clock has exactly 1,800 simulation ticks for a normal 30-second attempt at 60 physics ticks/sec.
- [ ] Pausing for arbitrary real time does not advance tick count, recorded tape, sentinels, or HUD countdown.
- [ ] Banked tape has exact recorded duration (includes early-bank example at tick 600 = 10s).
- [ ] Echo path at known ticks matches the saved tape pose (position and facing, within floating-point tolerance).
- [ ] Echoes become inactive and stop holding pads after their recorded duration.
- [ ] Player movement is 8-direction normalized; dash produces correct recorded poses, not desynced simulation.
- [ ] Simultaneous actions resolve in stable slot order E1–E4, then live, and don't double-toggle one-shot devices.
- [ ] World state baseline resets on each bank/retry while Echo tapes persist correctly.
- [ ] Echoes don't collide with closed doors, live player, each other, or hazard; live Rook DOES collide with solid closed doors.
- [ ] Two overlapping presences on one pad do not cause a second unwanted toggle; pad remains pressed until last eligible actor leaves.
- [ ] Recorder only logs accepted interactions; invalid or out-of-range inputs do not create a successful replay event.
- [ ] Hazards use a fixed start phase after reset; no random or chase behavior corrupts replay.

## C. User workflows
- [ ] Fresh M1 starts with no Echo and a clear objective.
- [ ] Q asks before bank; R retries but does not add an Echo; 30s timeout shows Bank / Retry review.
- [ ] Loss to hazard preserves previously banked Echoes but discards current unsaved run on retry.
- [ ] Bank a first Echo holding a resonance pad; second attempt crosses gate successfully.
- [ ] When all 4 Echo slots occupied, banking a new attempt asks which slot to replace; canceling does not delete old tapes.
- [ ] Removing an Echo requires confirmation and updates timeline/pad state on the next attempt.
- [ ] Tab/Timestamp preview and pause cannot leave game running behind overlay.
- [ ] An Echo alone cannot complete mission or pick up Stolen Day core.
- [ ] Mission win fires once even if multiple triggers overlap; UI and save not duplicated.
- [ ] Saved stars/mission unlocks remain after restarting app; corrupted save falls back safely.
- [ ] Audio mute, reduce flashes, screen shake-off settings work.

## D. Level solvability acceptance
For each level M1–M8, store an accurate timed walkthrough in `docs/LEVEL_SOLUTIONS.md` with banked Echo slot, relevant positions or pad names, rough tick ranges, final live route. Play it on a fresh level with default settings. Require >=0.5 s forgiving timing for ordinary windows (ideally >1 s). Verify 1-star clear, 2-star loop efficiency, 3-star final-run time threshold are achievable. No puzzle must require frame-perfect precision.

## E. Playtest quality
- [ ] First-time player can identify: live Rook, Echoes, timer, current objective, and what Q/R/Tab do.
- [ ] First Echo reveal is visually and aurally satisfying but instantly skippable.
- [ ] No essential instructions hidden in external readme.
- [ ] Bad attempt can be retried in <=2 clicks / a shortcut without long transitions.
- [ ] 15-minute test shows no soft locks, unintended Echo state leaks, or progressive slowdown.
- [ ] HUD text fits common laptop/browsers and remains legible at smaller embed size.

## F. Release verification
- [ ] Windows binary launches outside editor; files needed for it are included.
- [ ] Web single-threaded Compatibility export runs from a server/itch.io draft; press F12 to check errors.
- [ ] `index.html` exists at the root of itch.io ZIP with matching Godot export assets.
- [ ] Keyboard focus, audio unlock, pause on tab-out, fullscreen/resize all work in web.
- [ ] 60 FPS aspirational on target reference machine; report actual sustained frame time and issues.
- [ ] Final game can be completed start to finish and replayed after closing/reopening.

## Standard Codex handoff template
After each milestone Codex reports:
1. Files created/changed.
2. What behavior can be tested now.
3. Commands run and their actual outputs / problems.
4. Exactly how user should test in Godot.
5. Known limitations and next milestone recommended.
6. Suggested Git commit message (do not commit unless asked).
