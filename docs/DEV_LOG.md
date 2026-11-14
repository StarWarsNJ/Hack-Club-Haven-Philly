# Snapback — Development and Tuning Log

**Status:** Implementation, available automated/browser QA, and local review packaging complete; human-only acceptance remains NOT RUN.

Codex should log dated changes with:
- What was implemented or changed and which files were touched.
- Why the change improves feel, fairness, presentation, or reliability.
- Any modified `CONFIG` values (old → new and reason).
- Test commands actually run, with PASS/FAIL/NOT RUN.
- Known limitations and next highest-impact issue.

## Initial decisions

- Two-player local multiplayer, WASD versus arrows.
- Exactly one arena and one competitive best-of-five mode.
- Timed auto-bounce, dive, stomp, physical shared net, one-use Snapback Save.
- One browser-native, self-contained `index.html` runtime; old Godot infrastructure unused.
- Retro kinetic sports-poster art and user-gesture-enabled synthesized audio.
- No levels, AI, internet gameplay, or paid assets.

## Progress

- Implementation underway. See dated evidence below.

## 2026-11-14 — Audit and first simulation

- Read the attached complete objective and canonical specifications. A parallel read-only audit found no blocking conflict. The worktree was clean and contained design files only. Dormant Godot/Git/VS Code settings are preserved.
- Created the first index.html with the complete callable fixed-step simulation and temporary basic rendering. It includes movement, bounce tiers, dives, swept contact, shared springs, bumper recovery, pit scoring and rematch. Validation is in progress; these are not pass claims.
- Coordinates use center x / top y. Knockout requires the whole collider below the screen (top y > 540). Both net contacts use one snapshot before depositing their impulses. Save input buffering is independent of ordinary bounce anti-mash.
- Browser/UI host unavailable: discovery, lightweight retry, and reset/retry all returned missing native pipe/browser access host. No interactive browser or physical keyboard test has run. Checking available local CLI test options while simulation testing continues.
- The initial Node REPL write attempt timed out before writing. Verified index.html was absent, then wrote through the normal filesystem shell tool. No user files were lost.

## 2026-11-14 — Functional gates and defect fixes

- Actual deterministic Node harness reached 40/40 PASS; installed Chrome headless direct-file startup and DOM-input gate reached 15/15 PASS. Browser inputs are synthetic DOM events, not physical keyboard/human evidence.
- Tested all four player/bumper combinations including subsequent landings on the narrowed net, 12,000 spring steps and 12,000 full simulation ticks, 50 deliberately self-KO match/reset traces, and 60/75/120/144 render cadence equivalence. The 312-tick scripted match duration is a reset stress scenario, not a normal human match estimate.
- Fixed exact corner contacts incorrectly qualifying as stomps by requiring positive horizontal overlap at swept time of impact.
- Fixed accumulator reset during a physics callback with a generation check; it no longer creates a negative accumulator or extra skipped ticks.
- Fixed neutral upward contacts leaving the lower body at its integrated endpoint. Both now resolve at time of contact with symmetric, bounded velocity sharing and no added energy.
- Event audio is dispatched only for an advancing simulation step; match-over cannot replay the terminal sound during extra accumulator iterations.
- Implemented original short Web Audio cues. Context creation is restricted to trusted user gestures; synthetic input correctly stays silent. Voices release both gain and oscillator nodes on mute, pause, completion and failure. Further lifecycle tests are running.
- No supplied physics defaults have been retuned yet; extra robustness caps/geometry constants live in CONFIG. Human balance, enjoyment, audio quality and physical keyboard rollover remain NOT RUN.

## 2026-11-14 — Original presentation and review artifact

- Integrated original Canvas poster-style title, angular coral/rounded visor mint athletes, fixed tier/save HUD, real-sample net mesh, visible pits/recovery bands, precise landing cues, and coherent pause/point/winner layouts. All layout tokens are grouped in CONFIG.art; rendering remains read-only.
- Expanded the inline script into readable blocks without introducing a runtime dependency or build step. The intermediate renderer fragment was removed after integration; the shipped game remains one file.
- AI-inspected real browser captures of title, rally, perfect, stomp, save, Overdrive, pause, point, winner and maximum-wave height. The tiny landing avatar was independently checked at pixel/crop level and is present; no missing-avatar bug existed.
- Fixed a presentation issue found in captures: point/winner overlays could hide a live body's torso while leaving feet/hair visible. Those phases now omit the frozen world avatars; the winner retains its dedicated illustration. The teaching hint appears only during the opening rally.
- Improved accessible live-region announcement timing, native focused-button Space/Enter behavior, and DOM-control scaling in small viewports. These changes do not alter physics.
- Initial review-artifact SHA256: 05fb03b977ca8ef86099a48247d76e8450de5a9e6c520694acd1436d640b8c58. Created builds/Snapback-review.zip with exactly one index.html entry and verified the contained bytes match. No upload or publication occurred.
- Supplied physics defaults were retained. Technical tier-1..5 launch/apex measurements were 10/270.79, 12/225.99, 14/172.79, 16/111.27, 18/41.43 (px/tick / minimum top-y); maximum wave bonus gives 19.2/-4.41 with eight partially clipped ticks. These fixtures do not measure human pacing or fun. Full body and fixed HUD remain readable in the inspected maximum-wave capture; this is a low-priority human tuning consideration.

## 2026-11-14 — Final regression, browser refresh and handoff

- Final source SHA256: 3ce462b09556f05be1880ad3e8b3c7f51e1db037763bbad29475e92acdf01e27. The last draw-only patch removes arena/body fragments beneath opaque pause/winner overlays. Updated the review ZIP to the final source.
- Executed final Node regression: 46/46 PASS, exit 0, 13.061 seconds. No skipped/cancelled tests. The complete 22-case Chrome snapshot passed 71 assertions with 13 verified scene captures and exact four-size iframe checks; comparison proves simulation/config/input/audio/boot outside the renderer unchanged from that snapshot.
- Final-source Chrome and Edge each passed actual file startup plus 17/17 DOM/browser checks. Final affected PAUSE/WINNER captures both pass and were visually inspected. All instrumented page JS error/warning counts are zero. Test child processes and temporary HTTP server completed.
- All original supplied design defaults remain as implemented hypotheses. Tests justified collision/resource/reset repairs and presentation fixes, not invented human balance claims. Maximum-wave apex clipping remains a documented low-priority human tuning note.
- Current docs, source, optional tests, and package are consistent. The original kit bundles are labeled historical snapshots; the real-person scorecard is deliberately untouched. Details and exact manual checklist are in QA_REPORT.md.
- Stop after this review handoff. No publishing, remote pushes, Git commits, dependency installation, security changes, extra game modes, or Godot gameplay development occurred.
