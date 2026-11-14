# PARADOX HEIST — Copy-paste Codex build prompts

**Instructions to operator:** Execute in order. Run each prompt in Codex in the local VS Code project. Let the agent finish. Test in Godot. Fix discovered defects before the next milestone. Git-commit accepted milestones yourself. `AGENTS.md` and `docs/GAME_DESIGN.md` are the primary requirements, and `docs/TEST_PLAN.md` defines verification. Avoid executing all prompts in one conversation as a giant task. If context grows too large, start a new chat and refer Codex to the files.

## Milestone 0 — Repository audit and architecture plan (read-only)
> Read `AGENTS.md`, `docs/GAME_DESIGN.md`, and `docs/TEST_PLAN.md`, plus inspect `project.godot`, current scenes, input map, and Git status. Do NOT modify files yet. Propose the smallest scene/script architecture supporting a deterministic 30-second Echo recorder, one single-screen puzzle, and future campaign expansion. Identify any Godot/web incompatibilities, architectural decisions, and possible contradictions. Explain how you will synchronize recording, Echo pose playback, pad occupancy, and gate state within one fixed physics tick. End with a short exact implementation plan for Milestone 1 only. Do not implement gameplay.

Acceptance: You understand the planned architecture; no files changed.

## Milestone 1 — Project skeleton, working menu, scene transitions
> Implement only Milestone 1 of PARADOX HEIST. Read the relevant GDD and AGENTS instructions. Preserve existing Godot project settings and working files. Create an organized folder structure and a minimal but attractive game title screen with Play, Settings (functional audio sliders placeholders acceptable), Quit (Windows; browser-friendly behavior), and one placeholder M1 scene. Set main scene, build keyboard navigation and a clear help screen. Use original Godot-native vector art/colors; do not add dependencies. No Echo logic yet. Run Godot import/parse and short startup checks if available. Report changed files, checks and manual tests, and stop.

Acceptance: F5 opens menu, Play loads a visible M1 placeholder, Pause/Return works, no errors.

## Milestone 2 — Responsive Rook and mission HUD
> Implement only responsive top-down 8-way player controls in Godot 4 GDScript with `CharacterBody2D`, normalized movement, facing, collisions, and a camera fixed on a one-screen level. Add the mission HUD: objective, fixed-tick 30-second countdown, bank slots E1–E4 (empty), interaction hint, pause screen, and keyboard hints. Add input actions exactly per GDD, with movement and pause active; dash and pulse controls may be visible as locked. Ensure pause and browser focus loss stop the mission tick. No recording/Echo playback yet. Implement low-cost procedural visuals for Rook. Validate project and report manual steps.

Acceptance: Move against walls, diagonals aren't faster, pause stops countdown, UI legible.

## Milestone 3 — Authoritative 30s recorder and Echo playback
> Implement the Echo core described precisely in GDD §3 and §9. Use one 60-Hz mission tick authority, exactly 1,800 ticks/attempt, an immutable EchoTape recording per-tick world poses/facing/accepted discrete actions, and a purely kinematic EchoPlayer with no world collisions. Add bank-via-Q confirmation, timer-expiration review (Bank/Retry), R retry without bank, baseline mission reset, first Echo slot, and simple visual Echo trails. Do not fake recordings, use render FPS, or re-simulate Echo physics. Add small programmatic verification of tape length, immutability, frame-accurate playback, pause, retry and early-banked fade. Only create a very small empty test room here. Keep scope tight. Report observed validation.

Acceptance: Bank a 10-second route and watch an Echo repeat it exactly and vanish at 10s; pause/retry behaves as specified.

## Milestone 4 — First playable puzzle (M1) + early browser sanity check
> Build M1 'Borrowed Second' using `ResonancePad`, `ClockGate`, `MissionExit`, and the mission baseline reset contract. Design a fair, visually clear one-screen layout: first live run stands on a pad for a long interval, banks Echo; next live run crosses the gate while Echo holds the pad and reaches exit. Connect devices via signal-driven glowing traces. Record accepted actions and pad presence through the shared tick coordinator. Add minimal hint/tutorial captions. Create `docs/LEVEL_SOLUTIONS.md` describing exact tested M1 solution and test cases. Implement win overlay. Run current test suite plus Godot parse/startup checks. Optionally prepare a throwaway Web smoke export IF user approves/install templates; do not stop progress on lack of templates. Stop at M1.

Acceptance: Complete M1 from fresh game with one Echo, repeat consistently, no gate timing glitch; one clear tutorial.

## Milestone 5 — M2 & timeline director baseline
> Implement M2 'Crossed Signals' with two concurrent resonance pads, an AND gate with visible glowing connections and ~5 second safe-open grace, solvable with an Echo plus live Rook. Create the paused Timeline Director overlay with visible E1–E4 lanes, approximate event timing and tape duration, selected tape detail, resume/retry, and remove-with-confirm controls. Do not allow in-place tape editing. Expand tests for multi-pad occupancy, actor-independent detection, locked gate and Echo fade. Write and manually validate an M2 solution in `docs/LEVEL_SOLUTIONS.md`. Keep M1 working. Report proof and stop.

Acceptance: M2 correctly requires both pads, timeline pauses mission and allows safe tape removal.

## Milestone 6 — Action feel, dash, telegraphed beam, M3
> Improve movement feel with brief acceleration/snap tuning without compromising replay determinism; add Shift dash (0.16s / approx 550px/s, 1.7s cooldown, blocked by walls, no hazard invulnerability), readable cooldown and trail. Introduce `PhaseBeam` with visible repeating telegraph, deterministic tick schedule, live-player failure and instant retry. Build M3 'Laser Waltz' with forgiving timing and an Echo-operated pad, requiring both coordination and dash timing. Test replay after dashes, reset/hazard phase consistency, and browser-safe effects. Add tested M3 solution. Stop after M3.

Acceptance: Dash feels responsive, same recorded pose path plays in Echo, phase beam isn't frame-perfect or unpredictable.

## Milestone 7 — Clockwork sentinel + pulse, M4
> Implement abstract orbit sentinels moving on scripted rails from tick 0, clearly telegraphed paths, no pathfinding or dynamic live-player tracking. Add Space temporal pulse: short-range expanding visual wave, ~3.5s cooldown, stun/pause sentinels ~1.5s. Tape logs ONLY accepted pulse actions with their tick; Echo replays pulse when scheduled; sentinel behavior resets predictably each attempt. Build M4 'Clockwork Patrol' using one pad Echo and one recorded pulse Echo before live crosses. Include tests of pulse replay, timeline reset, and retry. Document a successful timed walkthrough and stop.

Acceptance: A recorded pulse reliably pauses a sentinel at the same mission tick in a fresh attempt; no flaky collisions.

## Milestone 8 — Terminals + Echo Orchestra and M5
> Add a reusable proximity-validated E-interaction `ResonanceTerminal` (4s energy charge) and device registration with stable IDs. Echoes replay accepted interaction events only when they target the correct compatible device. Implement simple Echo Orchestra feedback: distinct visual colors/number labels, one short original sound cue for each accepted Echo activation, a tasteful 'SYNC' pulse when two separate actor actions overlap; disable audio without breaking logic. Build M5 'The Relay' with two terminals' overlapping charge windows and a live master control. Update HUD to show window countdown. Document verified M5 walkthrough. No complex generated-music engine. Stop.

Acceptance: simultaneous terminal charge window works across loops, audio can mute, pulse+interact events never duplicate.

## Milestone 9 — Clockwork moving platforms, M6
> Implement tick-scripted moving platforms/bridges with visible periodic phase, deterministic reset to tick 0, and collisions affecting live Rook only. Echo projections always follow their tape through any currently closed area. Build M6 'Split the Second' combining recorded pads with predictable moving geometry, with timing tolerance above half a second and readable rail guides. Verify repeated restarts yield identical platform motion and that no Echo physics divergence occurs. Add exact walkthrough, retain M1–M5. Stop.

Acceptance: M6 can be beaten consistently without frame-precise timing or invisible rules.

## Milestone 10 — Four Echo slots, replacement, M7
> Expand from initial Echo capacity to exactly four saved slots E1–E4 with stable label/color/number. When bank is attempted with full slots, show explicit modal for choosing replacement; cancel must preserve recordings. Build remove/replace/undo flows safely and test pending live-run discard semantics. Create M7 'Interference' that genuinely requires planning three or four roles, plus an optional tutorial moment to replace an inefficient tape. Provide a real reproducible solution with <=4 Echoes, never auto-solve with a scripted fake Echo. Stop.

Acceptance: Banking a fifth recording cannot destroy a previous tape without confirmation; M7 is demonstrably solvable.

## Milestone 11 — M8 finale, story & cinematic playback
> Implement M8 'Vault of Tomorrow' as a genuinely playable, solvable final level: E1–E4 occupy four independent conductor stations in a shared >=2s overlap; live Rook activates the central objective and reaches an exit within a forgiving grace period. Include short skippable dialogue for Rook's wristwatch TICK and hologram Curator Morrow. On success, create a concise, skippable 3–8s Perfect Heist showcase using existing saved poses and events; provide a static completion summary fallback if cinematic replay is too fragile. Add a short ending and return to mission select. Ensure all mission reset/retry paths survive. Document reproducible solution. Stop.

Acceptance: M8 fully playable, 4 Echoes useful, victory cannot fire from Echo alone, no unskippable long scene.

## Milestone 12 — Progression, scoring, hints and settings
> Complete the game shell: mission unlock order; local versioned user:// JSON progress (stars/fastest time/mission completion); safe fallback for corrupt data; scoring as defined in GDD (1-star clear, 2-star efficient Echo count, 3-star fast final loop), with human-readable result breakdown. Add optional progressive hints, master/music/SFX sliders, reduce flashes, screen shake toggle, keyboard controls menu, focus-loss pausing, and fair restart behavior. Create tests of level unlock, save/reload, scoring edge cases, and pause/resume. No external services. Stop.

Acceptance: restart app keeps progress, scoring rules match displayed formula, accessibility settings work.

## Milestone 13 — Original visual/audio polish & onboarding
> Improve the finished game's visual identity consistently using the GDD palette, crisp silhouettes, subtle layered backgrounds, animated device states, distinguishable Echo identities, responsive menu transitions, concise tutorial overlays, satisfying loops and 'SYNC' feedback. Add only original procedural/audio assets or approved licensed resources; inventory and attribute any third-party licenses. Implement graceful performance-friendly effects for Compatibility renderer, reduce-flashes and mute options. Prioritize the first 30 seconds and completed levels over ornamental screens. Do not change mechanics without documenting it and getting approval. Test M1–M8 after UI/art changes. Stop.

Acceptance: polished coherent visuals, strong first Echo reveal, every HUD signal still readable, muted/no-flash usable.

## Milestone 14 — QA, performance, browser smoke and release preparation
> Run a structured QA pass against `docs/TEST_PLAN.md`; fix parse/runtime warnings, soft-locks, broken save states, timing desyncs and regressions. For each mission produce or verify an exact successful walkthrough in `docs/LEVEL_SOLUTIONS.md` and check intended achievements. Profile performance and minimize unnecessary per-frame work; keep 60fps a target rather than an unsupported claim. Prepare Windows and default single-threaded Compatibility Web export presets if export templates exist; do not add secrets. If tools are unavailable, provide a human checklist rather than claiming success. Produce readme and itch.io packaging instructions (Web ZIP with `index.html` at root), but do NOT publish/upload without explicit instruction. Stop.

Acceptance: all eight missions completed by hand, Windows executable and itch.io draft web build tested, stable replay/timeline, no blocker errors.

## Reusable bug-fix prompt (use any time before the next milestone)
> The latest milestone has this observed problem: [WRITE EXACT PROBLEM, WHAT YOU DID, EXPECTED VS ACTUAL, RELEVANT GODOT ERROR]. Reproduce it using the project and relevant design/test rules. Make the smallest fix. Add a regression test where feasible. Re-run relevant checks, summarize modified files and observed outcomes, and do NOT expand feature scope or start the next milestone.

## Milestone handoff checklist for operator
After Codex finishes each milestone:
1. Read changed-file summary and open Godot F5.
2. Run the stated manual tests; report any failures using the bug-fix prompt.
3. Look at Git diff; ensure no generated builds, creds or unrelated files are staged.
4. Once satisfied, commit yourself with `git add .` (after status review) and a milestone-specific message.
5. Start a fresh Codex chat when context grows large; include milestone number and file paths.
