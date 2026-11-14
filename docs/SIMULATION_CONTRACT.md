# Fixed-tick implementation contract

The GDD remains the gameplay source of truth. These details make its ordering testable.

- MissionClock counts completed 60 Hz ticks. Full duration is exactly 1800 samples, indexed 0..1799. The initial spawn pose is separate. 600 samples is 10s; an Echo with that duration is inactive at playback index 600.
- MissionController owns the only mission physics callback. It moves live Rook and applies Echo sample k, collects actors in E1..E4/LIVE order, resolves devices, records the committed live sample, evaluates outcomes and publishes UI. Discrete accepted action resolution is added in the corresponding milestones; visual feedback never mutates simulation.
- Pads use current authoritative floor-position geometry and aggregate actor IDs, not delayed Area2D enter/exit signals. Sparse live pad-entry/exit timeline markers are annotations, never replay commands.
- Gates resolve after movement. Collision changes are deferred to the safe engine boundary and affect the next movement step. There is no second live movement pass.
- Closing-overlap safety: a gate already open waits for overlapping live Rook to clear it, visibly displaying CLEAR GATE. This is not an active objective circuit and does not let a closed gate open. It prevents crushing/physics displacement; Echoes always ignore the collider.
- Echo logic ends immediately at its duration. A 12-tick presentation fade cannot keep pads occupied or emit events.
- Every retry/bank recreates the whole mission world subtree, including devices, while the TimeLoopController bank survives above it. Mission exit clears the bank. No mission state is stored in shared mutable resources.
- Pause, confirmation, review and focus loss freeze ticks, samples, actors and mission audio. Tab is intercepted before GUI navigation in the active mission, but navigates buttons inside bank confirmation. Cancel does not change a tape or consume a tick.
- Banked data owns copies of buffers. Accessors return values or copies. GDScript has no private fields; underscored buffers are internal and must never be mutated by consumers.

Automated invariants live in scripts/tests. Human visual/audio acceptance, practical keyboard timing tolerance and actual browser compatibility remain separate unverified checks.

## Dash and hazards (Milestone 6)
- Dash is 10 ticks at 550px/s with a 102-tick cooldown. Normal movement snaps to 230px/s with normalized diagonals. Its resulting poses/animation state are recorded; no dash collision is re-simulated for Echoes.
- Prepare scripted environment at tick k using the prior committed pad state, then move/apply poses and resolve occupancy. Beam phase is an integer modulo schedule. Swept live movement against expanded beam geometry prevents tunnelling.
- End-of-tick outcome precedence is hazard failure, otherwise eligible live goal, otherwise timeout review. Failure freezes without banking and preserves prior tapes.
- The optional validator now uses --fixed-fps 60 for GDScript harnesses (documented CLI disables wall-clock synchronization). Engine physics remains 60 Hz. M1/M2 observed win ticks remained exactly 271/336 after this change. Normal game startup remains unmodified. This mode cannot measure real FPS or browser performance.

## Accepted pulse events (Milestone 7)
- Live pulse cooldown is 210 ticks, range 76px, freeze window 90 ticks. Accepted casts record original compatible target IDs. Replays validate those IDs and current proximity; they never acquire a different target. A valid empty cast still consumes cooldown and records its visual wave.
- Actions resolve explicitly E1..E4 then LIVE, with per-event/tick duplicate guards. Multiple freezes use max(until), not additive durations. Device feedback signals are presentation-only.
- Orbit sentinel position follows a 600-tick circular rail from tick zero. Its rail counter stops while frozen, so resumption does not jump to a wall-clock phase. Pulse resolution occurs after environment movement and cannot undo already-computed movement/contact. A frozen sentinel remains hazardous.
- Pulse targets, charge state and cooldowns are mission-local and reset with the world; Echo tapes keep recorded poses/events unchanged.

## Terminal actions and presentation (Milestone 8)
- E selects nearest currently eligible terminal within 48px, stable ID breaks ties. Replay uses the recorded target only; no retargeting. Accepted live E has a 12-tick debounce. E resolves before pulse for simultaneous live requests, after E1–E4 events.
- Charges are active on [activation_tick, activation_tick+240); a live-only, explicitly labeled two-actor master checks overlapping charge owners and latches once. That latch is an objective state reset on retry.
- SYNC and original pre-rendered audio react to committed events only. Audio can be muted/disabled without changing any device or tick. Headless runs deliberately use silent feedback because accelerated Dummy playback can outlive teardown; native/Web audio requires separate inspection.

## Moving bridges (Milestone 9)
- Deck targets follow a 360-tick schedule. Active pads guide decks toward their center lane with a bounded 4px/tick step, avoiding teleportation on state changes. Retry recreates phase zero.
- Solid layer 1 is walls/gates, layer 2 live Rook, layer 4 bridge rails. Echoes have no collision layers or bodies. Top-down decks support live floor positions over gaps; rails physically block leaving the deck.
- The coordinator prepares deck transforms, carries previously supported live Rook with move_and_collide, then performs live movement. Hazard sweeps preserve the pre-environment live position so carry cannot bypass contact checks. Only live Rook is queried for unsupported-gap failure.

## Bank history (Milestone 10)
- Production capacity is four across all missions. Echo budgets remain per mission for scoring. Empty slots are holes; removing E2 never renumbers E3/E4.
- Every successful bank/replacement/removal stores exactly one prior bank array of immutable tape references. Cancel never changes history or content. Undo is allowed only outside a running simulation, requires confirmation to discard the unsaved run, restores the prior bank and clears undo history. A fresh mission/replay clears all bank/history state.

## Campaign/profile boundary (Milestone 12)
- Only mission results/settings persist. Score is 1 star for a valid clear, +1 for banked Echo count within the published mission budget, +1 for that efficient clear finishing at or before tick 1500 (25.0s). Retries never enter the formula. Best stars and fastest successful time update independently.
- Unlocks derive from the contiguous completed mission chain. Routing enforces them in addition to disabled select buttons. Save schema version 1 writes via a temporary sibling and atomic replacement. Corrupt data is backed up; unsupported versions remain untouched while session play continues.
- Settings/hints/camera/audio are presentation only. HUD and overlays live in a separate CanvasLayer so camera offsets/aspect changes cannot move controls or affect tape coordinates. Hint and leave modals freeze the same clock and preserve the unsaved run when cancelled.
- All integration tests explicitly inject transient or dedicated validation profiles. No test mutates player data. Separate processes prove actual completion-signal save/reload wiring.


## Presentation and onboarding (Milestone 13)
- The first bank in a MissionSession rebuilds baseline and opens a paused, skippable actual-tape preview at completed tick zero. Skipping resumes the existing attempt; it does not add a sample or rewind a running clock. Later banks skip this reveal. Intro, first reveal and finale viewer use the same frozen mission boundary.
- Dial, gate countdowns, timeline axis, background, labels, star, camera and orchestra consume committed state. Presentation never drives devices or records commands. Spawn interpolation history resets prevent a visual streak from a previous transform; authoritative world poses remain the replay source.
- The native viewer and all validation profiles are isolated from player data. Render captures and fixed-render-rate harnesses are evidence of native drawing and tick consistency only; they cannot establish human usability, audible quality, browser support or sustained FPS.
