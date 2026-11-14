# PARADOX HEIST development progress

Updated: 2026-11-14. Goal scope: Milestones 0–13 in order. Milestone 14/release is excluded.
The user now handles all Git commits (latest instruction overrides the original checkpoint requirement). No third-party dependencies, publishing, or remote pushes.

## Current status

Milestones 0–13 have completed their implementation and available automated checks. Development stops here; Milestone 14 has not started. Human gameplay, audible output, accessibility acceptance, browser/Windows exports and sustained FPS remain UNVERIFIED.

Latest evidence: 18/18 main checks, 4/4 alternate-render-rate checks, and 21 native Compatibility captures (17 base + 4 finale), with zero diagnostics in successful final runs. All eight real-recording reference routes still clear. Git commits remain the user’s responsibility; the old Milestone 1 checkpoint incident below is historical and resolved by the later workflow instruction.

## Status conventions
Implementation/automated validation can be complete while human acceptance remains UNVERIFIED. No entry in this log claims hands-on gameplay, visual/audio inspection, Windows export, browser export, or 60 FPS unless explicitly evidenced.

## Milestone 0 — completed audit (read-only)
- Read AGENTS.md, GAME_DESIGN.md, CODEX_PROMPTS.md, TEST_PLAN.md; inspected both startup scenes, project settings, exports, input map and clean Git status.
- Godot executable: C:/Users/aryan/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64.exe. Version check: 4.7.2.stable.official.ed1daf0bf.
- Architecture: persistent app shell; mission-local single fixed-tick coordinator; immutable pose tapes; non-colliding Echo projections; stable device IDs; aggregate pad occupancy; baseline world reinstantiation; presentation separated from logic; versioned local progress later.
- Tick convention: 0–1799 samples, initial spawn separate, 600 samples = 10 seconds, expired Echoes contribute no presence/events. Gate output after movement affects the next movement step. Record these boundaries in tests before gameplay expansion.
- Risks: gate close overlap; pause/discard confirmation; exact pulse targeting; 0.16s dash quantization; reset leaks; browser persistence/audio/focus. Preserve the strict Echo contract. Resolve only non-core implementation details autonomously; ask if a true core-rule conflict blocks implementation.
- Audit itself changed no files and had no checkpoint. This entry records it as part of Milestone 1.

## Milestone 1 — implementation and automated checks complete
- Reusing scenes/main.tscn UID; preserving root main.tscn and existing project/renderer/export settings.
- Adding reusable native UI, keyboard menu routes, functional mixer sliders, help and pausable M1 placeholder. No gameplay yet.
- Files: scenes/main.tscn; scenes/ui/{main_menu,settings,help}.tscn; scenes/game/mission_session.tscn; scripts/core/{app_controller,mission_controller}.gd; scripts/ui/{ui_factory,main_menu,settings,help}.gd; scripts/tests/test_shell.gd; tools/validate.mjs; this log. Generated script UIDs are tracked, .godot metadata is ignored.
- Validation: tools/validate.mjs using existing bundled Node and configured Godot console executable: PASS import, PASS startup (120 frames), PASS test_shell.gd, all exit 0 with zero diagnostics under normal Godot access. Test exercises menu/settings/help/mission routing, mute/volume and pause/resume/return.
- Environment: sandbox blocked certificate/editor data access; initial GUI import timed out. Console executable plus normal access completed cleanly. No security settings changed. Temporary fallback editor metadata moved under ignored .godot/validation.
- Human keyboard/mouse, visual/audio, resize and actual browser checks remain UNVERIFIED. No Echo/gameplay code in this checkpoint.
- Historical checkpoint incident (resolved by the Workflow update below): git add failed with Permission denied writing .git/objects/89/b20c233e961dd39d9326777923e96f92b9b382, including the normal-access attempt. No commit exists for this milestone yet; nothing is staged. Read-only ACL inspection shows explicit deny entries for the automation identity. No permissions/security settings were changed.
- Required human action: create the local commit in VS Code Source Control using subject: Milestone 1: add application shell and menu navigation. Then resume the Goal. Do not push.
- Milestone 2 has NOT started. Goal status: BLOCKED after three consecutive goal turns with the same checkpoint restriction. Latest read-only recheck: HEAD remains 5cae8ac; Milestone 1 files remain uncommitted; .git/objects retains explicit deny permissions. The previous continuation made no implementation progress because this restriction was unchanged. No security settings were changed. Human action is required to create the checkpoint or provide an approved way to write Git metadata. Milestone 2 has not started.

## Human acceptance backlog
- M1: F5; keyboard and mouse menu navigation; Play placeholder; Esc pause/resume and Return; mixer sliders and readable layout at common window sizes.
- Future: playtest timing tolerance, audio/visual quality, actual browser/Windows builds and sustained performance remain unverified.

## Validation commands
- tools/validate.mjs is a dependency-free optional runner using existing Node.js and the Godot console sibling of the executable configured in .vscode/settings.json. No runtime was installed.
- In this workstation Node is not on PATH; the existing Codex runtime was used: C:/Users/aryan/AppData/Local/OpenAI/Codex/runtimes/cua_node/bbc9141fe9f920ac/bin/node.exe tools/validate.mjs. Normal-access run completed with PASS import, PASS startup, PASS test_shell.gd; zero host/project diagnostics.
- Direct equivalents (using the configured Godot console executable): --headless --path . --import; --headless --path . --quit-after 120; --headless --path . --script res://scripts/tests/test_shell.gd.
- Detailed transient check output is under ignored .godot/validation/results.json.

## Milestone 1 human checklist (all UNVERIFIED)
1. F5 opens PARADOX HEIST. Use arrows/Tab and Enter to navigate; check visible focus.
2. Open Settings; adjust/mute each volume slider; return with Back or Esc. Audio assets are not introduced yet.
3. Open How to play; verify readable instructions and Back/Esc.
4. Play opens visible M1 staging placeholder. Esc pauses; Esc/Resume returns; Return to menu works from pause.
5. Resize the window and inspect readability. Actual browser Quit behavior is unverified.

## Workflow update
- User explicitly removed the agent commit requirement: the user will commit at the end. Existing staged Milestone 1 changes are preserved. No more Git writes will be attempted; the prior checkpoint blocker is resolved by this instruction.

## Milestone 2 — implementation and automated checks complete
- Fixed-tick clock, explicit keyboard input actions, top-down Rook, fixed camera room, HUD, pause/focus-loss and retry baseline. Recording and Echoes are not included yet.

### Milestone 2 evidence and handoff
- Files: project.godot; scripts/core/{mission_clock,mission_world,mission_controller}.gd; scripts/actors/rook.gd; scenes/actors/rook.tscn; scenes/levels/m01.tscn; scripts/ui/mission_hud.gd; scripts/tests/{physics_driver,test_movement}.gd and generated script UIDs. Existing root scene, rendering and export settings preserved. Added reference viewport 1152x648 and explicit 60 physics Hz; expand keeps fixed world geometry with extra outside margin.
- Automated: full tools/validate.mjs run PASS import, startup (120 frames), test_movement.gd and test_shell.gd, all exit 0 with zero diagnostics. Movement harness uses real physics ticks to verify 230px/s, equal diagonal distance, solid walls, pause, focus loss, exact 1800-tick limit, action presence and physical arrow codes. Raw Tab with a focused HUD button pauses correctly.
- Fixed during validation: mission shortcuts are intercepted before GUI focus handling, so Tab does not silently move focus.
- Human UNVERIFIED: F5 → Play; move with both key sets against all walls; inspect HUD, countdown, small/windowed layout; Esc/Tab pause; switch app focus, resume; wait 30s and Retry; return to menu. No recording/Echo mechanics yet.
- Suggested user commit: Milestone 2: add Rook movement and fixed-tick mission HUD. No Git writes performed.

## Milestone 3 — implementation and automated checks complete
- Next: immutable per-tick pose tapes, single-slot bank confirmation, retry/review, non-physical playback, early expiry, explicit world reset and verification.

### Milestone 3 evidence and handoff
- Files: scripts/core/{echo_tape,echo_recorder,time_loop_controller,mission_controller,mission_world}.gd; scripts/actors/echo_player.gd; scenes/actors/echo.tscn; scripts/ui/mission_hud.gd; scripts/tests/test_echo.gd and script UIDs.
- Behavior: Q freezes a nonempty recording for confirmation; cancel resumes unchanged; bank saves E1 and rebuilds the world; R discards only the live tape; 1800 ticks enters Bank/Retry review; full capacity requires explicit replacement selection; non-colliding Echoes apply poses/facing/animation at matching ticks, contribute no logic after duration, and visually fade over 12 ticks. Tab navigates bank confirmation rather than dismissing it.
- Automated: final full validator PASS import/startup/test_echo/test_movement/test_shell, all exit 0 with zero diagnostics. Echo integration physically records 600 ticks and checks every replayed pose/facing for 600 ticks, then inactivity at sample 600; verifies frozen confirmation, cancel, world replacement/spawn, persistence on retry and safe full-slot behavior. Pure tests check sealed data/event copy ownership and exact 1800-sample review.
- Fixed: explicit EchoTape fixture typing in harness; bank-modal keyboard focus; recording/clock mutations remain outside debug-only assert expressions for release safety.
- Human UNVERIFIED: record a ten-second route, Q/cancel, Q/bank, observe exact playback/fade, R, timeout/review, and keyboard confirmation. Only empty training room in this milestone.
- Suggested user commit: Milestone 3: add authoritative Echo recording and replay. No Git writes.

## Milestone 4 — implementation and automated checks complete
- Next: reusable pad/gate/exit, stable registry, explicit same-tick occupancy evaluation, M1 single-screen puzzle, tutorial/win, real-input route harness and LEVEL_SOLUTIONS.md. Browser export remains optional/unverified; no templates will be installed.

### Milestone 4 evidence and handoff
- Files: reusable pad/gate/exit scenes/scripts; scripts/core/device_registry.gd; scripts/levels/borrowed_second.gd; scenes/levels/m01.tscn; recorder/tape/controller/world/HUD extensions; scripts/tests/test_puzzle_m1.gd; docs/LEVEL_SOLUTIONS.md and SIMULATION_CONTRACT.md.
- Behavior: one-screen M1 with Pad A, visible signal-driven trace, solid live gate, Echo occupancy and live-only exit; contextual TICK captions and one-time win overlay; replay clears bank, retry preserves it. Presence markers are separate timeline annotations and never replay commands. Closing gates visibly wait for an already-overlapping Rook to clear (no crush/soft-lock); this safety state does not satisfy objectives.
- Automated: full validator PASS import/startup/echo/movement/M1/shell, all exit 0 with zero diagnostics. Strengthened M1 rerun also exit 0 with no diagnostics; actual movement/banking solves M1 at tick 271 (4.52s) with one Echo, verifies closed-gate blocking, two-presence aggregation, reset, exact sample-1020 release, completed fade, collider closure, safety overlap and one live-only win.
- Browser smoke/export was not attempted: optional approval/templates gate remains; no templates installed. Actual web compatibility is UNVERIFIED and not a blocker to this milestone.
- Human UNVERIFIED: execute LEVEL_SOLUTIONS M1 route from fresh game, inspect wire/pad/gate readability, Echo fade, win/Replay, retry and closing safety. Keyboard timing tolerance and visual feel need human playtesting.
- Suggested user commit: Milestone 4: build Borrowed Second Echo puzzle. No Git writes.

## Milestone 5 — implementation and automated checks complete
- Next: M2 AND-pad gate with explicit 60-tick hold/300-tick grace, data-driven mission selection, paused read-only Timeline Director and confirmed removal/discard/reset. Preserve M1; no new abilities yet.

### Milestone 5 evidence and handoff
- Files: MissionDefinition/MissionCatalog and resources/missions/m01-m02.tres; crossed_signals.gd/m02.tscn; clock_gate grace/hold extensions; registry/world/controller/app/HUD mission routing; TimelineDirector/TimelineLane and timeline scene; test_puzzle_m2.gd; LEVEL_SOLUTIONS.md.
- Behavior: M1 Next loads fresh M2; A+B must overlap for 60 ticks, gate then allows a ~300-tick grace crossing; numbered E1–E4/LIVE timeline lanes show durations and sparse markers; inspection pauses all mission clocks; selected-tape removal explicitly confirms discarding the live run; Cancel preserves both. No in-place tape editing.
- Automated: full validator PASS import/startup/echo/movement/M1/M2/shell, all exit 0 with zero diagnostics. M1 still wins at 271 ticks; M2 actual one-Echo route wins at 336 ticks. M2 verifies A alone cannot open, overlap must sustain, leaving B keeps grace, timeline does not consume ticks, cancel preserves the active run, and confirmed removal recreates the baseline without E1.
- Human UNVERIFIED: play M1 then Next; complete M2 using LEVEL_SOLUTIONS; inspect all timeline lanes, selected details and controls; cancel/confirm removal; check grace readability and small-window layout. Human timed walkthrough is not claimed.
- Suggested user commit: Milestone 5: add Crossed Signals and paused Timeline Director. No Git writes.

## Milestone 6 — implementation and automated checks complete
- Next: tick-based blocked dash and trail/cooldown; scripted telegraphed phase hazard; M3 coordination/dash route; hazard failure and replay/reset tests.

### Milestone 6 evidence and handoff
- Files: Rook dash/trail and HUD cooldown; phase_beam scene/script; simulation_geometry.gd swept collision; Laser Waltz m03 scene/script/resource; mission catalog/definition/controller/registry extensions; test_puzzle_m3.gd; fixed-frame validator; solution/contract docs.
- Automated: final full suite PASS import/startup/echo/movement/M1/M2/M3/shell, exit 0 with zero diagnostics. M1/M2 remain 271/336 ticks. M3 records an actual dashed pad route, checks Echo poses, wins at 622 ticks with 44-tick margin, clears with a 30-tick delayed start, fails the same walking-only route, verifies blocked dash, swept beam contact with no invulnerability, phase reset and failed-run bank rejection/persistence.
- Fixed reproducible quality failure: first route won at tick 644 but had only 22 safe ticks; improved reference approach/corners and visible route yielded 44 ticks without changing the beam window or weakening the half-second assertion.
- Dash duration explicitly quantized to 10 ticks (0.167s), cooldown 102 ticks (1.7s). No acceleration-induced replay drift; responsive velocity snap remains.
- Human UNVERIFIED: play M1–M3; inspect dash responsiveness/trail/cooldown, warnings/field readability and forgiving route; test focus loss and retry with hazards. Browser graphics and actual FPS remain unverified.
- Suggested user commit: Milestone 6: add dash and Laser Waltz phase puzzle. No Git writes.

## Milestone 7 — implementation and automated checks complete
- Next: repeatable orbit sentinel, accepted pulse event replay with stable targets/proximity, 210-tick cooldown/90-tick freeze, M4 two-Echo reference route and pulse/reset tests.

### Milestone 7 evidence and handoff
- Files: OrbitSentinel scene/script; ActionResolver; Clockwork Patrol m04 scene/script/resource; registry/actor/controller/HUD/catalog/definition extensions; test_puzzle_m4.gd; solution and simulation contract docs.
- Behavior: Space logs accepted casts only (210-tick cooldown), stores stable targets, validates replay proximity, freezes a scripted non-chasing rail for 90 ticks, and emits presentation events in E1–E4/LIVE order. Repeated same-tick resolution is idempotent. M4 uses E1 pad plus E2 early-banked pulse route; expiry does not undo an already accepted effect.
- Automated: final full suite PASS import/startup/echo/movement/M1–M4/shell, exit 0, zero diagnostics. M4 actual two-Echo route wins at tick 385; verifies pulse at 240, cooldown rejection, stationary freeze, E2 expiry before victory, baseline retry and no-pulse route failure. Protocol fixtures verify ordering independent of registration, duplicate rejection, max-duration freezes and out-of-range rejection. Marker placement was improved and real replacement tapes at 225/255 both clear (half-second window endpoints).
- Human UNVERIFIED: execute M4 reference route and timing variants, inspect pulse wave/range/cooldown, orbital telegraph, frozen-contact rule and failure explanations. No browser/performance claim.
- Suggested user commit: Milestone 7: add recorded pulses and Clockwork Patrol. No Git writes.

## Milestone 8 — implementation and automated checks complete
- Next: stable-ID proximity E terminals with 240-tick charges; two-terminal/master Relay puzzle; original pre-rendered audio cues and visual SYNC feedback; invalid-action/overlap/mute tests.

### Milestone 8 evidence and handoff
- Files: ResonanceTerminal scene/script, The Relay m05 scene/script/resource, EchoOrchestra, five original PCM WAV cues and assets inventory; resolver/registry/gate/world/controller/catalog/Rook extensions; test_puzzle_m5.gd, test_actions.gd, adjusted pulse-only M4 event observer; solution docs.
- Behavior: stable-ID E targets within 48px, accepted-only replay/recording and 12-tick debounce; 240-tick terminal charges; visible two-actor live-only master; labeled/colors E1–E4 cues, sparse pad-entry/interaction/pulse responses and event-driven SYNC. Pre-rendered original WAVs avoid runtime procedural-audio dependency.
- Automated: final full suite PASS import/startup/echo/movement/M1–M5/shell (exit 0, zero diagnostics), plus targeted test_actions PASS (exit 0, zero diagnostics). Relay uses real recordings, clears at tick 377 with two Echoes; verifies charge boundary, invalid E not recorded, cooldown, one-shot live master, simultaneous E+pulse order, mute/audio-disabled independence and reset. Protocol tests cover stable target/no retarget, Echo compatibility, duplicate E rejection and distinct-actor requirement.
- Fixed reproducible failure: accelerated headless audio left AudioStreamWAV/PlaybackWAV references in M2/M3 teardown. Added explicit stop/stream release and a silent headless fallback; event/visual paths remain enabled. Full rerun has no leak warnings. Native/Web audible playback is UNVERIFIED, not claimed by this workaround.
- Human UNVERIFIED: M5 timed solution, terminal range/cooldown prompts, numbered timbres, SYNC readability, muted fallback and pause audio; replay M1–M4 after feedback changes.
- Suggested user commit: Milestone 8: add Relay terminals and Echo Orchestra. No Git writes.

## Milestone 9 — implementation and automated checks complete
- Next: two 360-tick scripted bridges with live-only rail collisions/carry and void support, recorded pads stabilizing geometry, M6 solution and reset/no-Echo-physics-divergence checks.

### Milestone 9 evidence and handoff
- Files: ClockworkBridge scene/script, Split the Second m06 scene/script/resource, live collision mask/platform layering, registry prepare/carry/support checks, swept pre-environment pose preservation, test_puzzle_m6.gd and solution docs.
- Behavior: two bounded-speed 360-tick scripted decks; pads guide them to the center without teleporting; live-only rail collision/carry and unsupported-gap failure; authoritative Echo paths remain independent of current deck geometry.
- Automated: full validator PASS import/startup/actions/echo/movement/M1–M6/shell, exit 0, zero diagnostics. M6 actual two-Echo route clears at tick 257; isolated real-physics carry and rail blocking pass; paired 180-tick platform traces match after retries; removing A leaves E2 exactly on its tape across an unsupported deck without failure for the live player at the entrance.
- Human UNVERIFIED: execute M6 route, inspect rails/deck alignment/support failure, carry feel, pauses and early tape expiry; replay M1–M5 after collision-mask/layering changes. No browser/FPS claim.
- Suggested user commit: Milestone 9: add deterministic bridges and Split the Second. No Git writes.

## Milestone 10 — implementation and automated checks complete
- Next: full four-slot bank in all missions, explicit fifth-tape replacement/cancel, single-step undo of bank mutations with discard/reset confirmation, and a genuinely four-role M7 puzzle.

### Milestone 10 evidence and handoff
- Files: Interference m07 scene/script/resource; four-slot mission resources/default; TimeLoopController mutation history/guards; Timeline undo UI and controller confirmations; test_puzzle_m7.gd; legacy single-slot fixture and M4 endpoint tests adapted to production four-slot/removal workflow; solution docs.
- Behavior: all missions expose at most four stable E1–E4 slots; fifth bank requires explicit selection, cancellation preserves bank and live recording; replacement/removal have one bounded undo snapshot; undo/removal confirmation discards the unsaved run and rebuilds baseline; fresh replay clears history. M7 genuinely requires four independent pad roles while live exits.
- Automated: full suite PASS import/startup/actions/echo/movement/M1–M7/shell, exit 0, zero diagnostics. M7 actual four-tape route wins at tick 286; tests replacement isolation and reference identity, cancelled/confirmed undo, slot preservation after removal, three-tape gate failure, full-bank cancel and replay reset. M1–M6 win ticks unchanged.
- Human UNVERIFIED: fill all slots in M7, inspect numbered roles/paths, replace a poor tape, cancel/remove/undo with an active unsaved run, verify prompts and solvability from LEVEL_SOLUTIONS.
- Suggested user commit: Milestone 10: add four-role Interference and safe bank undo. No Git writes.

## Milestone 11 — implementation and automated checks complete
- Next: four-station 120-tick conductor overlap, live CORE and 300-tick exit window, M8 reference solution, skippable story/ending and isolated read-only pose showcase with summary fallback.

### Milestone 11 evidence and handoff
- Files: ConductorNode scene/script; Vault of Tomorrow m08 scene/script/resource; live terminal enable/activation/deadline fields; registry overlap/deadline; mission intro/results/showcase orchestration; ShowcaseSnapshot/Canvas/View and scene; basic mission select; test_puzzle_m8.gd; solution docs.
- Behavior: four distinct station actors sustain 120 ticks, live E at CORE then EXIT within 300 ticks; skippable six-line intro/short ending; six-second read-only pose/event showcase with Skip and static fallback; one completion signal and return to select. No world re-simulation or progression effects in the viewer.
- Automated: full suite PASS import/startup/actions/echo/movement/M1–M8/shell, exit 0, zero diagnostics. Strengthened M8 targeted test also PASS, exit 0, zero diagnostics: win tick 465; exact conductor boundary, rejected early E, live core/deadline failure, preserved/reset tapes, intro frozen, showcase clock/conductor frozen, skip/automatic finish/fallback without duplicate win and select transition.
- Fixed parse failure: conductor field ready conflicted with native Node.ready signal; renamed is_ready. Validator rejected the diagnostic despite exit 0/PASS text; rerun was clean.
- Human UNVERIFIED: full M8 route, intro/ending timing, all four Echo identities, CORE/exit feedback, showcase presentation, keyboard Skip/Back and mission select. All eight levels now have automated real-input routes, but none is claimed hand-played.
- Suggested user commit: Milestone 11: add Vault finale and isolated Perfect Heist showcase. No Git writes.

## Milestone 12 — implementation and automated checks complete
- Next: versioned local JSON progress, ordered unlocks, exact star scoring/best times, full settings/accessibility, progressive hints and safe game-shell flows. Test fixtures will use isolated/transient profiles, not player data.

### Milestone 12 evidence and handoff
- Files: ProgressStore/ScoreRules, app profile/routing/settings integration, settings/select/menu/help/HUD updates, camera-only response and accessibility flags, screen-space CanvasLayer interface, progressive hints and leave confirmation, transient CampaignFixture injection, profile and separate-process restart tests.
- Behavior: local version-1 JSON with atomic temp-file replacement; corrupt data backed up before recovery; newer schemas never overwritten; ordered unlocks and guarded routes; best stars/fastest success; displayed Echo budgets and exact inclusive 25.0s star threshold; saved master/music/SFX/fullscreen/reduced-flash/hints/shake settings; three-level optional H hints and explicit leave cancellation. Mission UI is separate from camera transforms.
- Automated: full suite PASS import/startup/actions/echo/movement/progress/M1–M8/restart-write/restart-read/shell, all exit 0, zero diagnostics. Separate Godot processes verify a real M1 completion signal saved 3 stars, tick-271 best, M2 unlock and settings UI values, then a new app restored them, continued to M2 and rejected locked M3. Pure checks cover score edges, corruption backup, future-version preservation, atomic overwrite/reload and settings sanitization. Hint levels/preferences and leave-cancel preservation pass. All mission win ticks unchanged.
- Test isolation: integration apps inject empty-path transient profiles; disk checks use only res://.godot/validation fixtures, never user:// player data. Native/Web fullscreen, audible pause/mute, actual browser persistence and subjective accessibility acceptance remain UNVERIFIED.
- Human UNVERIFIED: play/unlock/close/reopen, inspect stars and budgets, settings controls, reduced-flash/shake-off, progressive hints, pause/focus, cancel leaving an unsaved setup; repeat all levels.
- Suggested user commit: Milestone 12: add local campaign progress and accessible game shell. No Git writes.

## Milestone 13 — implementation and automated checks complete
- Cohesive original native presentation, first-Echo onboarding, readable responsive UI, differentiated audio cues, asset inventory and full M1–M8 regression. No gameplay-rule changes, exports, publishing or Milestone 14.


### Milestone 13 evidence and handoff

- Files: scripts/ui/{paradox_backdrop,mission_clock_dial,tape_preview,timeline_axis,chrono_star}.gd; shared UiFactory, menu/settings/help/select/timeline/showcase/HUD presentation; app music and mission onboarding; Rook/Echo spawn interpolation resets and device labels/countdowns; assets/ui/paradox_icon.svg; seven original assets/audio/*.wav; tools/{generate_audio,render_checks,validate_rates}.mjs; scripts/tests/{test_onboarding,render_capture}.gd; README.md and asset/architecture/progress docs. Existing tests now explicitly skip the first-bank reveal when testing later simulation behavior. Godot-generated script UIDs and source import descriptors accompany their sources; .godot remains ignored.
- Behavior: consistent clock/grid background, brass/cyan palette and clear focus states; scrollable keyboard-friendly cards; centered 30-second dial and numbered/color-coded tape-duration badges; accurately aligned timeline axis; visible live identity, gate hold/grace and terminal charge state; static clockwork star after the finale core. First bank pauses at tick zero with an actual saved-route preview and Enter/Esc skip; later banks immediately resume. Original distinct per-slot cues, SYNC chord, imprint arpeggio and quiet clockwork music loop are presentation only. Mute/reduced-flash/shake preferences leave simulation unchanged.
- Main automated run: tools/validate.mjs completed 18/18 checks (import, startup and 16 GDScript test processes), all exit 0, zero host/project diagnostics. Includes all eight actual movement/recording solutions, tape immutability/expiry, pause/focus, action ordering/targets, safe bank mutations, saved progress and separate-process restart. The onboarding test proves the first reveal consumes no ticks/samples, raw Esc resumes, later banks are immediate, and the muted/reduced-effects path retains the same controls and tape.
- Functional timing check: tools/validate_rates.mjs PASS 4/4 cases, test_echo.gd and test_puzzle_m1.gd at 30 and 144 fixed render FPS while physics remains 60 Hz. M1 still completes at tick 271 in both cases. This is functional tick/replay verification with a physics-driven harness, not a frame-time benchmark.
- Native artifact check: tools/render_checks.mjs captured 17 base + 4 finale frames using the installed engine, Compatibility/ANGLE over D3D11 on Intel HD Graphics. Transient muted profiles and a no-focus offscreen window preserved player saves and the open editor. Captures include 1152×648 and 960×540 menus, settings/help/select, M1–M8 rooms, first reveal, live Echo, timeline, a 1536×648 reduced-effects HUD, four-Echo finale/core, showcase and results. Both final phases exited 0 without warnings/errors. These are AI-inspected native render artifacts, not human acceptance or Web/export tests.
- Fixes from native inspection: explicitly inherit the UI theme across CanvasLayer; align timeline labels with lanes; move REC outside the dial; initialize the visible environment/HUD at baseline tick zero; separate core, LIVE and station labels; resize/reposition the freed-vault banner. All eight win ticks stayed unchanged after these changes.
- Validation limitation resolved: one concurrent native finale repeat exceeded its 90-second runner limit with no Godot diagnostic. No capture helper remained running. The runner now reports elapsed time/process errors with a 180-second phase limit; the isolated finale rerun passed in 82.139 seconds. This harness duration is not measured gameplay FPS. No security settings or rendering project defaults were changed.
- Original asset inventory: assets/README.md lists all seven mono 22,050 Hz / 16-bit PCM sources and the clock icon. WAV headers were checked. No third-party content, packages, fonts, plugins or downloads were added. Audible quality/latency and music balance require human review.
- Repository checks: git diff --check passed; git ls-files .godot returned no tracked cache files. No Git writes, commits, exports, installs, publishing or remote pushes were performed after the user’s workflow override.

### Final reference clears after presentation changes

| Mission | Successful live tick | Saved Echoes |
|---|---:|---:|
| M1 | 271 | 1 |
| M2 | 336 | 1 |
| M3 | 622 | 1 |
| M4 | 385 | 2 |
| M5 | 377 | 2 |
| M6 | 257 | 2 |
| M7 | 286 | 4 |
| M8 | 465 | 4 |

These clears use actual recorded player routes, not synthetic tapes. Exact routes and tested timing variants are in docs/LEVEL_SOLUTIONS.md. Human execution remains UNVERIFIED.

### Milestone 13 human checklist (all UNVERIFIED)

1. F5 opens the title screen. Check keyboard focus, menu/help/settings readability and smaller-window scrolling.
2. In M1, hold A, bank E1, inspect the paused first-Echo preview, then skip with Enter or Esc. Follow the lit circuit through the gate. Retry and bank again to check the immediate repeat flow.
3. Play M1–M8 using LEVEL_SOLUTIONS; judge teaching, controls, collision feedback, timing tolerance and all objective/charge/hold/grace labels.
4. Hear all four Echo timbres, SYNC, imprint and music. Set Master/SFX/Music to zero, enable reduce flashes and disable shake; verify every necessary signal remains readable and the game remains playable.
5. Inspect Tab lanes and duration labels; cancel and confirm full-bank replacement, remove, undo and leave flows. Pause or change focus during active devices and confirm clocks/audio resume appropriately.
6. Complete M8, skip/watch the showcase, inspect result grades, return to select, close and reopen to check local results/settings.

Suggested user commit: Milestone 13: polish presentation and first Echo onboarding. Stop here. Milestone 14’s structured human QA, profiling and Windows/Web release/export checks require the next explicit authorization.
