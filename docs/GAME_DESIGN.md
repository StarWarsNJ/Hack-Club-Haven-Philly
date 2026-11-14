# PARADOX HEIST — Game Design Document (GDD)
Version: 1.0 (design baseline; changes must be recorded)

## 1. Elevator pitch
**One thief. Thirty seconds. An army of your past selves.** A kinetic, single-player, top-down puzzle-action game in which the player records 30-second attempts. Every banked attempt becomes a translucent Echo that repeats the saved route and actions in the next attempt. Layer up to four Echoes plus the live player to solve impossible clockwork puzzles, perform theatrical synchronized maneuvers, and reclaim the stolen day from the Vault of Tomorrow.

**Genres:** action-puzzle, time-loop, light strategy, replay optimization. **Platforms:** Windows and HTML5 itch.io. **Engine:** Godot 4 standard, GDScript, Compatibility renderer. **Session:** about 30–50 min first playthrough of 8 compact missions, shorter on replay. Actual time depends on testing. **Audience:** general, non-graphic sci-fi.

### Experience pillars
1. **One clear mechanic, endless combinations:** your previous runs are useful agents in the present.
2. **Planning becomes action:** play and improvise live, not only move objects in a static puzzle.
3. **Readable causality:** players understand why a device opens, why an Echo succeeds, or why a timing attempt fails.
4. **Satisfying synchronized spectacle:** great success looks and sounds coordinated, not random.
5. **Respect time:** short attempts, one-button retries, fast resets, no long cutscenes, optional hints.

### What the game is not
Not an online multiplayer game, realistic security/bank simulation, roguelike, huge open world, realistic combat, level editor, live-service product, complex crafting economy, or procedural story. No online accounts, cloud saves, or network dependency.

## 2. Fiction and story
**World:** The Chrono Bureau has 'borrowed' a day from everyone and exhibits it inside a surreal, clockwork museum. Its paradoxical machinery runs on stylized light, resonance, and looping clocks—not real security technology.

**Protagonist:** ROOK, a nimble blue-white-cloaked trickster with a glowing wristwatch. Nonverbal character expressed through movement and brief animations.
**Companion:** TICK, a witty sentient wristwatch. Short hint lines and narration; no long dialogue.
**Antagonist:** CURATOR MORROW, a theatrical hologram obsessed with perfect schedules. The conflict is playful, not violent.
**Prize:** the 'Stolen Day'—a luminous clockwork star. Finale frees the stolen day and the world gets its morning back.

**Three acts:**
- ACT I — 'Borrowed Seconds' (M1–M2): Echo discovery and first teamwork.
- ACT II — 'The Clockwork Gallery' (M3–M6): hazards, actions, and orchestration.
- ACT III — 'Tomorrow on Display' (M7–M8): choosing Echo tapes, synchronized finale, celebration.

**Final reveal:** The grand clock is powered by people repeating the same unchanging day. Rook's Echoes can break the cycle by doing different things together. The final sequence restores tomorrow; the museum's music resolves as all Echo colors converge. Convey via environmental animation and 4–6 skippable dialogue lines, not a cinematic that blocks replay.

## 3. Exact gameplay contract
### 3.1 Mission clock and attempts
- Each mission uses a **30.0 second simulation window**, exactly **1,800 physics ticks at 60 Hz**. Frame rendering can run at any rate; the tape operates on physics ticks only.
- A mission begins with **no Echoes**. The user can hold at most **four banked Echo tapes**. A fifth entity is the live Rook.
- All actors spawn at their recorded starting position (the same entrance for Rook). Echoes are visually distinct and labeled E1–E4.
- Live attempt is controlled by the user. After 30 seconds, simulation pauses at an **Attempt Review** panel: Bank Echo / Retry Attempt / inspect timeline. Never bank silently at timeout.
- **Q** banks the current attempt early after a brief confirm UI. Banking freezes the tape at its last recorded tick; the Echo appears only during its recorded duration on following attempts, then fades away. Early banking is a strategy.
- **R** retries the current live attempt without saving it, preserving banked Echoes. Pause/menu confirmation where necessary.
- At an attempt end, banking appends a tape if a free slot exists, then resets the world for a new live attempt. If four slots are full, the player chooses an existing slot to replace; never overwrite without selection.
- Undo/remove an Echo from the Timeline Director, outside of an active run (or via pause, which discards the active unsaved run first). Do not allow accidental erasure.
- Losing to a hazard pauses the action with 'Retry Attempt'; it never auto-banks that failed attempt. Keep the already banked Echoes.
- A mission ends immediately when live Rook reaches the mission goal after all mission conditions are satisfied. Echoes cannot complete a mission or collect the prize themselves.
- Pause, menus, and loss of browser focus freeze mission simulation and audio timing. No saving/consuming ticks while paused.

### 3.2 Echo rules (strict; don't change casually)
- A **tape** records Rook's world position, facing direction, animation state, and accepted action events at every physics tick. Use compact arrays where useful; up to 1,800 samples/tape.
- Playback is **pose-based**: Echoes are non-physical projections whose recorded transforms are authoritative. Do not try to re-simulate their motion via CharacterBody2D and world collisions; this causes drift.
- Echoes do not collide with Rook, walls, doors, hazards, moving elements, or each other; passing through a changed obstacle is a deliberate hologram property.
- Echoes can **activate resonance floor pads by their presence** and issue **recorded 'interact' or pulse events** to compatible holographic devices, after validating event target/proximity at the playback tick.
- Echoes cannot pick up the mission core, physically push crates, break real scenery, consume collectible items, initiate level transitions, or trigger live-player failure.
- Animated Echoes follow a tape. Their visuals never affect world collision or timing.
- Every attempt resets consoles, pads, doors, drones, hazard phases, movable state, and effect states to an explicit level baseline. Tape collection is the only state carried between attempts.
- Dynamic hazards follow scripted repeatable schedules from mission tick 0. They react to the live player; Echoes may pulse them through recorded abstract 'freeze' events if in range. Avoid stateful chasing/pathfinding that makes replay ambiguous.
- When multiple Echo actions land on the same tick, order resolution consistently by slot E1, E2, E3, E4, then live player; make device effects idempotent where possible. Continuous pad occupancy should use aggregate presence, not repeated toggles.
- Every registered event uses **tick index** as canonical time, not wall-clock seconds or render FPS.
- For readability, show a brief failure explanation (e.g. 'Plate B became inactive at 0:12') when a player fails a timing puzzle, not punishment for paradox interference.

### 3.3 Time-loop interaction vocabulary
**Resonance pad:** stays active while any live or Echo projection stands in its marked circular area. Doors use AND/OR connections, with animated glowing lines to show the cause.
**Resonance terminal:** accepted `E` interaction when a compatible actor is within range; emits a discrete pulse. Resettable, with clearly shown cooldown/state.
**Clock gate:** solid to live Rook; opens while the specified pad/terminal conditions hold. Projections pass through, but do not open it automatically.
**Orbit sentinel:** abstract glowing clockwork orb moving along a fixed visible path. Touching it fails the live attempt; projections are unaffected. A temporal pulse makes it pause for a short duration.
**Phase beam:** periodic bright/light beam following a clearly telegraphed repeating schedule. Contact with live Rook fails the attempt. Optional pulse might not affect beams; keep rule visible.
**Conductor node:** special resonance target requiring two separate actors to activate its pads during the same time interval. This awards a visible 'SYNC' flourish; if used as a gate condition, show the required actor count.
**Stolen Day core:** mission-end item collected only by live Rook after vault objectives are met.

**Never introduce a gadget whose rules silently contradict the above.** No realistic hacking or harm simulation.

### 3.4 Live Rook mechanics (suggested initial values; tune by playtesting)
- 8-direction WASD/arrow movement, normalized diagonal speed; base speed ~230 world pixels/sec.
- **Shift** short dash: 0.16s, speed ~550 px/s, 1.7s cooldown, visible trail. Doesn't cross solid gates or protect against hazards. Tape records resulting poses, so replay matches.
- **E** interact: nearest eligible resonance terminal within ~48 px, clear prompt, 0.2s debounce; signal logged as accepted action.
- **Space** temporal pulse: short-radius (~76 px) cartoon wave, 3.5s cooldown. It pauses orbit sentinels for ~1.5s. Log accepted action; do not introduce projectiles or gun mechanics.
- **Q** bank the tape; **R** retry unsaved attempt; **Tab** open/pause Timeline Director; **Esc** pause; optional mouse UI controls.
- Start mission with movement + E taught first; dash and pulse introduced later. Rebindable controls and gamepad support are stretch features, not blockers for baseline.

### 3.5 The Timeline Director
- Opens as pause overlay; displays time bar 0–30s, lanes E1–E4 and LIVE, color plus slot number.
- Each Echo tape draws a miniature path or a row of action icons: enter pad, interact, pulse, stop. Do not require every stored pose to be drawn in real-time.
- Buttons: Resume, Restart Unsaved Run, Remove Echo (confirm), Replace Echo on bank, View Controls.
- During a live run, timeline inspector may show prior tapes but not rewrite active history. Advanced drag-to-edit tape is **not baseline scope** (would break design consistency).
- Optional after first release: scrub replay in a read-only viewer, no mutation. Keep it separate from simulation.

## 4. Player-facing experience
### 4.1 Controls
| Input | Action | Context |
|---|---|---|
| W/A/S/D or arrows | Move (8-way) | live attempt |
| Shift | Dash | after mission 2 |
| E | Activate nearby terminal | in range |
| Space | Temporal pulse | after mission 3 |
| Q | Bank run with confirmation | live attempt |
| R | Retry unsaved run | live attempt |
| Tab | Timeline Director | mission |
| Esc | Pause / resume | all screens |
| Mouse | UI buttons / selection | menus and timeline |

### 4.2 Main screen
Top-left: mission name + objective in one sentence. Top-center: large **0:30** countdown and circular progress arc. Top-right: E1–E4 bank slots with time lengths, cooldown pip, and a compact help icon. Bottom: contextual controls and visible next objective marker. Active recording indicated by thin red pulse around timer. Keep world visually dominant.

### 4.3 Menus and states
Start screen → optional 20-second skippable comic-strip premise → Mission Select → Mission Intro (one line + instant Play) → Live Attempt ↔ Pause/Timeline → Attempt Review (Bank/Retry) → Mission Complete (stars + showcase) → Next Mission or Select.

First launch offers 'Play' immediately. No account/signup. Settings: master/music/SFX volumes, fullscreen/windowed, reduce flashes, show hints, screen shake on/off. Browser loss of focus pauses automatically. Save to local user:// data.

### 4.4 Failure and feedback
- Fail states are soft and instant: freeze, short effect, 'Retry (R)' button. No deaths or injuries depicted.
- Invalid terminal interaction gives a soft click + prompt; doesn't modify tape.
- Gate animations respond visibly to pad/terminal state; synchronized actions produce tasteful screen/audio feedback.
- The player can always inspect how many Echoes are saved and when an Echo disappears.
- Hints are optional and progressive: (a) objective reminder, (b) highlighted plate, (c) suggested roles for Echoes. Never require external instructions.

## 5. Signature feature: Echo Orchestra
Each Echo has a distinct audio timbre and color: E1 cyan/percussion, E2 violet/pluck, E3 amber/bass, E4 mint/chime; LIVE is bright white. When a coordinated action succeeds, a beat-aligned accent and visual 'SYNC' arc play. These should be musical **responses to events**, not a complicated procedural rhythm engine at first. Use original/generated simple effects or properly licensed assets; include silent/visual fallback.

**Perfect Heist playback:** On mission completion, show a brief 3–8s montage (read-only playback of poses and event times, camera/zoom/captions), then grade screen. Replay is skippable. Implement after core is stable, and provide a simple summary as fallback.

**Grades:** 1 star for clearing; 2 stars for clearing with at most each mission's **published Echo budget**; 3 stars for 2-star clear plus final successful attempt completed by 25.0s. Display the Echo budget before each mission and the score calculation after success. Suggested 2-star budgets: M1=1, M2=1, M3=1, M4=2, M5=2, M6=2, M7=4, M8=4. These are design targets **that must be changed if playtesting proves a level cannot meet them**. Record local best stars and fastest success. 'Echo budget' counts banked tapes in the winning setup; unsuccessful retries do not affect star count. No online leaderboards.

## 6. Level layout and progression
**World format:** Single-screen top-down stages designed at a consistent 16:9 reference size (suggested 1152×648); tile scale ~32 px for level authoring. Camera fixed except concise cinematic moments. Distances below are targets, not final pixels. Every stage should be solvable with <=4 banked Echoes plus live player, with non-frame-perfect windows (aim 0.5–1.5s tolerance). The dev must maintain a canonical solution walkthrough for every level in `docs/LEVEL_SOLUTIONS.md` and test that it works.

| Mission | Title | New teaching concept | Suggested minimum banked Echoes | Expected first clear |
|---|---|---|---:|---:|
| M1 | Borrowed Second | bank/replay & hold a pad | 1 | 2–4 min |
| M2 | Crossed Signals | simultaneous pad conditions | 1–2 | 3–4 min |
| M3 | Laser Waltz | dash, periodic phase beams | 1–2 | 3–5 min |
| M4 | Clockwork Patrol | pulse & sentinel, recorded pulse | 2 | 4–6 min |
| M5 | The Relay | terminals, staggered timings, sync | 2–3 | 4–6 min |
| M6 | Split the Second | moving clockwork platforms, spatial timing | 2–3 | 5–7 min |
| M7 | Interference | four-slot limit and replacing a tape | 3–4 | 5–8 min |
| M8 | Vault of Tomorrow | full multi-Echo synchronized finale | 4 | 6–10 min |

These times are design aspirations, not verified player metrics. Make an enjoyable **M1 + M2 vertical slice** first, then build the other levels after testing.

### Level recipes and intended solutions
**M1 Borrowed Second** — A single resonance pad beside the entrance opens a door 2 rooms away. First bank a tape of standing on the pad from ~t=4 to t=17. Next attempt, pass the gate while E1 holds it. Finish through a glowing exit. Tutorial explains bank/retry without blocking interaction.

**M2 Crossed Signals** — Two pads across a wide chamber must be active together for at least 1s, then the final gate opens for ~5s as a grace interval. Bank E1 holding Pad A from t=6 onward. Live player holds Pad B from around t=10; then both release and live crosses within the grace time. A second alternative solution may use an extra Echo. On-screen illuminated wires display the AND condition.

**M3 Laser Waltz** — A periodic phase beam sweeps a corridor with a visible telegraph, teaching dash timing. Bank one Echo to hold Pad A to shift the beam's safe window while live crosses with dash. Two large safe windows per 30s; no frame-precision puzzle. Dash never makes player invulnerable to beam.

**M4 Clockwork Patrol** — Clockwork orb follows a clearly drawn circular rail (repeatable start and path). Record E1 standing on a gate pad; E2 uses the temporal pulse at an orb intersection at a known tick to freeze it; live navigates the stable gap. Introduce accepted action replay and its cool-down visualization.

**M5 The Relay** — Three glowing relay terminals at different locations; successful interactions emit 4s energy charges. Two terminals must be active together so live can touch the master terminal. Bank one Echo for north terminal, another for south; live triggers master within the overlap. Show animated time lines in timeline overlay, plus 'SYNC' payoff.

**M6 Split the Second** — Two clockwork platforms shift on prescribed 6s cycles and reappear at tick 0 in identical phases. Recorded pads stabilize them and live player crosses. Banked Echoes may pass through the platforms visually because they are projections, but only live player physically collides with platforms.

**M7 Interference** — Four available Echo slots become tactically meaningful, with four resonance stations arranged around a central chamber. A teaching objective allows experimentation with removing/replacing a poor tape before finalizing the coordinated loop. No real-time editing of an Echo's tape. A low-risk suggested solution: E1–E3 hold separate pads, E4 pulses a moving orb to provide a crossing window, live takes the central exit.

**M8 Vault of Tomorrow** — Multi-stage but single-screen finale: four colored stations each require a distinct actor presence in a shared overlap window (>=2s); live Rook activates the center core while all stations are lit; the whole clock reverses color, the Stolen Day appears, and a 5s dramatic exit window follows. On success, show Perfect Heist montage, closing comic panels, and replay stats. A scripted, fully solvable reference route must be included and hand-tested; never rely on spontaneous AI coordination.

**Fairness rule:** Every puzzle must be beatable through understandable spatial movement/timing, not exact single-frame alignment or blind guesses. Add tolerant windows and visible telegraphs.

## 7. Visual identity
- **Perspective:** top-down slightly angled orthographic *look* in 2D (not 3D), strong silhouettes.
- **World:** midnight indigo (#151A31), slate panels (#283654), brass highlights (#D9AC5F); energetic cyan (#58D7EF), violet (#AD82F5), amber (#F4BE6C), mint (#74DBBB).
- **Rook:** white/bright mask and blue coat; visual arrow indicating facing. **Echoes:** same silhouette, translucent with outlined shape, slot number and trailing particles. Ensure independent distinguishability in grayscale/colorblind view.
- **Devices:** circular pads, flowing wire indicators, clockwork doors, softly sweeping beams; minimalist magical sci-fi, not realistic surveillance tech.
- **Motion:** responsive dash smear, Echo spawn ripple, banded time reset sweep, beat-aligned gate unlock, slow-motion finish. Screen shake brief and toggleable; reduce-flashes setting.
- **Art plan:** Phase 1 procedural primitives with clean shapes and elegant tween animation. Phase 2 replace with cohesive original art and consistent icons. Third-party resources only with explicit licensing approval.
- **HUD:** generous margins, readable text at 720p and HTML embed size. Color alone must never convey Echo state.

## 8. Audio and narrative delivery
Ambient clockwork pulse builds with new Echo lanes; each bank adds subtle texture. Gameplay SFX: soft tick, echo imprint, pad activation, gate sweep, failed attempt, 'SYNC' flourish, mission success. No copyrighted tracks. Code must offer volume sliders, mute, and fallback when audio unavailable. Tick's lines are very short: 'Bank that move. Your Echo will finish the job.'; 'Two switches. One you. For now.'; 'They are not copies. They are your plans.'; final 'A whole day, returned on time.'

## 9. Architecture proposal (adapt to actual project)
Suggested scenes:
- `scenes/ui/main_menu.tscn`, `mission_select.tscn`, `hud.tscn`, `attempt_review.tscn`, `timeline_director.tscn`, `mission_complete.tscn`, `settings.tscn`.
- `scenes/actors/rook.tscn`, `echo.tscn`.
- `scenes/devices/resonance_pad.tscn`, `resonance_terminal.tscn`, `clock_gate.tscn`, `orbit_sentinel.tscn`, `phase_beam.tscn`, `chrono_core.tscn`.
- `scenes/levels/m01.tscn` ... `m08.tscn`.
Scripts grouped into `scripts/core/`, `scripts/actors/`, `scripts/devices/`, `scripts/ui/`, `scripts/tests/`.

Core systems:
- `GameState`: menu/campaign/save and mission transitions (autoload if needed).
- `MissionController`: owns baseline reset, win/loss flow, and mission-local devices.
- `TimeLoopController`: single authority for physics tick, live tape recording, Echo bank/retry/replacement and pause transitions.
- `EchoTape` (`RefCounted`/`Resource`): positions, facing/animation, accepted discrete events, duration in ticks.
- `EchoPlayer`: projection visuals and scheduled event emission from stored tape.
- `DeviceRegistry`/typed interfaces: validate resonance pad presence, console interactions and deterministic door conditions.
- `UIController`: menus/inputs and presenter events only; no game authority.
- `ProgressStore`: versioned user:// JSON for unlocked missions, stars, settings. Handle absent/bad save safely.

**Avoid:** giant all-in-one game.gd; each Echo carrying a physics body that collides; frame delta for recording time; arbitrary signal interdependencies; full per-frame timeline resimulation that ignores recorded poses; unapproved addons; real-time networking.

### 9.1 Fixed-tick ordering contract
At each physics tick: (1) determine scripted environment phase; (2) move/record live Rook and set Echo poses for same tick; (3) collect all actor presence/action requests; (4) resolve queued events in stable slot order; (5) recompute pads, terminals and gates; (6) evaluate hazards/win and publish UI events. If Godot's node process ordering makes this exact order awkward, implement an explicit coordinator; avoid one-frame timing inconsistencies. Record the agreed order in code comments and tests.

### 9.2 Tape structure
Tape fields: `duration_ticks:int`, `positions:PackedVector2Array`, `facing_codes:PackedByteArray` or similarly compact array, `action_events:Array[Dictionary]` (tick, type, optional device ID), and metadata (slot ID, color). A banked tape is immutable while used; replacement removes a tape without modifying others' content. If a tape ends at t<30s, its Echo fades at its end and no longer occupies pads or emits actions.

### 9.3 Production constraints
- Game should stay responsive on typical laptop browser hardware; 60 FPS target, test actual builds.
- No web-only API assumptions; no network calls. Godot Compatibility renderer, single-threaded default for browser export. Avoid C#, GDExtension, heavyweight shader effects.
- Internal reference resolution 1152x648 / 16:9, scalable UI; fit/embed on itch.io.
- Logs disabled/minimal in release; don't spam per tick. Stable save paths under `user://`.
- Export presets may be committed if they contain no secrets; built artifacts belong under ignored `builds/`.

## 10. Prioritized implementation scope
**Must-have vertical slice:** M1 and M2, time recorder, 1–2 Echoes, bank/retry/timeout review, pad/gate/exit, HUD, clean reset, pause, sound placeholders, deterministic automated tests, keyboard instructions.
**Must-have full game:** 8 distinct solvable missions, dash/pulse/sentinel/terminal/beam/platform, four Echo slots and replacement, timeline overlay, progression save, main menu/settings, final win, simple replay showcase, original art/audio polish, Windows & web release tested.
**Nice-to-have after release:** replay scrubber, customizable controls, gamepad, accessibility extra assistance, optional challenge missions, sophisticated audio layering, cinematic camera system, downloadable run replay files, speedrun splits.
**Out-of-scope baseline:** multiplayer, leaderboard server, level editor, branching story, realistic combat, real security mechanics, procedural 100-level game, physics puzzles requiring Echo to push rigid bodies, massive procedural graphics pipelines.

## 11. Production acceptance gates
A milestone is accepted only when: (a) requested behavior exists, (b) project loads without Godot parse errors, (c) existing completed missions work, (d) `docs/TEST_PLAN.md` relevant cases pass with observed evidence, (e) the user hand-plays the change, (f) no unapproved dependencies or asset licenses. Stop at milestone boundary. Full completion requires real test on Windows and at least one itch.io browser embed, not just Godot editor.

## 12. Change log
- v1.0: baseline design, fixed-physics-tick Echo specification, 8-mission campaign, release scope.
