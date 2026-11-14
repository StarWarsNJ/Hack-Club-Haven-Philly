# PARADOX HEIST reference solutions

These are reproducible routes for the authored scenes. Automated execution uses the real Rook movement/coordinator and banks its actual tape. Human keyboard gameplay, feel, visuals, browser behavior and timing-tolerance acceptance remain UNVERIFIED. No synthetic Echo tapes are used to solve a level.

## M1 — Borrowed Second

Layout: entrance (140,324), Pad A (232,248), middle passage at y=324, gate centered (800,324), EXIT (1030,324). Walk right/up to the circular pad; the wire shows the gate it powers.

1. Fresh mission: move right for about 0.40s (24 ticks), then up about 0.32s (19 ticks). Rook finishes around (232,251), inside A's radius.
2. Stay on A until the elapsed time reaches 17s (countdown 0:13). Press Q and confirm Bank as E1. Tape duration: 1020 samples. A is held from roughly tick 36 through 1019.
3. New attempt: wait about 0.75s (45 ticks), allowing E1 to reach A. Move right along y=324 through both passages and the open gate to EXIT. Completion should take under 5 seconds in this live attempt and use one banked Echo.
4. Repeat via Replay mission, which clears the bank. Retry (R) instead preserves the bank and restores the world baseline.

Tolerance: bank after standing on the pad for a generous interval (e.g. 12–20s); the final live crossing uses approximately four seconds. No single-frame inputs are required. Keyboard timings above are approximate; the visible pad and wire are the authoritative cues.

Automated status: PASS test_puzzle_m1.gd, exit 0, zero diagnostics. Observed final completion tick: 271 (4.52s), with one Echo. A strengthened run also passed exact last-active/first-inactive tick checks, full fade, collider closure and safe closing-overlap checks. This verifies locked gate before banking, aggregate actor occupancy, real recorded holding route, bank reset, Echo-driven opening, live-only one-time completion, replay expiry and gate release. Human test: UNVERIFIED.

Gate boundary: pad state is resolved after movement; collision output takes effect on the next movement step. A gate already occupied by Rook visibly waits with CLEAR GATE before closing; this safety state does not satisfy the goal circuit. Echoes ignore the collider in all states.

## M2 — Crossed Signals

Layout: entrance (140,324), A (232,220), B (660,420), AND gate (900,324), EXIT (1030,324). The circuit requires both pads continuously active for 60 ticks (1s), then provides a visible approximately 300-tick (5s) grace window after release.

1. Fresh mission: move right ~0.40s (24 ticks), then up ~0.45s (27 ticks) onto A. Hold until elapsed 17s, Q and confirm E1 (1020-sample tape). A alone never opens the gate.
2. Next attempt: move right ~2.27s (136 ticks) to x≈661, then down ~0.42s (25 ticks) onto B. E1 reaches A in parallel.
3. Hold B for at least one full second; wait for the visible OPEN/SYNC indication. Leave B by moving up ~0.42s (25 ticks) to the center corridor, then right through the gate to EXIT. The crossing fits comfortably inside five seconds.
4. Tab opens the paused Timeline Director. Inspect numbered lanes and pad markers. Remove E1 asks for confirmation that also discards the current unsaved run; Cancel preserves both, and confirming starts a fresh world without E1.

Automated status: PASS test_puzzle_m2.gd, exit 0, zero diagnostics. Real one-Echo route completed at tick 336 (5.60s). AND hold, grace crossing, paused inspection, cancelled removal and confirmed discard/reset passed. Human gameplay/visual timing validation is UNVERIFIED. M1 remains available by starting mission M1; the M1 win screen advances to M2.

## M3 — Laser Waltz

Layout: Pad A (232,180), gate (370,190), a single-screen serpentine beam field, EXIT (1090,468). E1 holding A shifts the field into safe intervals [3.00,11.10) and [18.00,26.10) seconds. The final second of each safe interval turns amber as a warning. Dash never bypasses walls or protects from contact.

1. Fresh mission: hold Right and tap Shift, then release movement after the ten-tick dash (~0.17s), reaching x≈232. Move up ~0.63s (38 ticks) to A. Hold until elapsed 17s and bank E1. Its saved dash is replayed as poses, not physics. A longer tape permits the later safe interval.
2. New attempt: up 27 ticks to y≈220, right 59 ticks to x≈366, then wait until elapsed 3s (countdown 0:27) for cyan. Keep outside the field while red.
3. Follow the visible serpentine route: first right passage around (1012,220), down to around y=268, down-left into the middle lane near (920,360), left to (460,360), down to (460,412), down-right to (496,448), then right to EXIT. Tap Shift on long straights when the HUD says ready (1.7s cooldown); avoid starting a dash immediately before a turn. Corner collisions block motion normally.
4. Automated reference used five accepted dashes and completed at tick 622 (10.37s), leaving 44 ticks (0.73s) before the beam returns. The same route starting 30 ticks later also cleared; walking it without dashes failed. Human timing and feel remain UNVERIFIED.

Automated: full suite PASS, including saved dash pose replay, walls, swept hazard collision, deterministic phase after retry, failure preserving Echoes, failed runs not bankable, >=0.5s delayed-start clearance. No browser/performance claim.

## M4 — Clockwork Patrol

Layout: A (232,248), gate at (600,324), visible sentinel rail centered (760,324), pulse marker (678,313), narrow crossing at y=324, EXIT (1030,324). A pulse freezes motion, not contact danger.

1. E1: right 24 ticks, up 19 ticks onto A; stay until elapsed 17s and bank the actual 1020-sample route.
2. E2: from the entrance move right 140 ticks (~2.33s) to x≈677, then up 3 ticks to y≈312.5 on the pulse marker. Wait until elapsed 4s (tick 240), press Space once, then bank at 5s (300 samples). The accepted event targets orb_a; E2 appears for only five seconds, but its freeze effect may continue afterward.
3. Final live run: wait until ~2.65s (159 ticks), then move right down the center corridor to EXIT. E1 opens the gate; E2 freezes the orb below the crossing at tick 240; live reaches EXIT at tick 385 (6.42s).
4. Do not touch a frozen orb. If a changed tape makes a pulse target unavailable/out of range, replay reports that failure without changing the Echo route.

Automated: PASS real two-Echo solution, exact event/cooldown/freeze, stable E1–E4/LIVE ordering, duplicate rejection, range validation, reset, and failure of the same crossing after removing E2. Actual replacement tapes pulsing at ticks 225 and 255 (the endpoints of a half-second window) both cleared. Human gameplay, aim/readability and audio remain UNVERIFIED.

## M5 — The Relay

Layout: NORTH (180,180), SOUTH (180,480), gate (850,324), live-only MASTER (980,324), EXIT (1060,324). Each accepted E interaction charges its terminal for exactly 240 ticks (4s). MASTER explicitly requires overlapping charges from two different actors and latches its objective until retry.

1. E1: up 38 ticks, right 10, wait until elapsed 5s (tick 300), E at NORTH. Bank at elapsed 10s (600 samples).
2. E2: down 40 ticks, right 10, E at SOUTH at tick 300, bank at elapsed 10s. The saved tapes charge both devices at 5s.
3. Final live run: move right along y=324. The gate blocks passage until both charges activate at tick 300, then opens for the charge overlap. Stop near MASTER at around tick 340, press E at around tick 360 (6s), then continue right to EXIT.
4. Automated clear: tick 377 (6.28s), two Echoes. Charges remain valid until tick 540, leaving a generous interaction/crossing margin. An Echo cannot activate MASTER or complete the mission.

Automated: PASS accepted-only E targets and debounce, exact charge expiry, two distinct actors, live master/one-shot latch, E+pulse ordering, one event cue per Echo and one SYNC, silent/muted completion and retry baseline. Separate protocol tests reject moved/out-of-range recorded targets without retargeting, live-only devices and duplicate interactions. Human sound quality, visual clarity and gameplay remain UNVERIFIED.

## M6 — Split the Second

Two 6s-cycle bridge decks span gaps x=410..560 and x=760..910. Pads A (232,248) and B (660,430) guide their matching decks to the center lane. Live Rook collides with the rails and is carried by moving supported decks. Echoes remain projections.

1. E1: right 24 ticks, up 19 onto A; hold until elapsed 17s, bank (1020 samples).
2. E2: move right 136 ticks across stabilized bridge A to x≈661, down 27 ticks onto B (y≈428). Bank at elapsed 10s (600 samples).
3. Final live run: wait about 20 ticks (~0.33s), then walk right across both decks to EXIT. The recorded pads align each deck before arrival. Automated completion tick: 257 (4.28s), two Echoes, with several seconds before the shorter tape expires.
4. A failed/poor recording can be removed through Timeline. If A is removed, E2 still follows its original route across the currently unavailable bridge; live Rook cannot use the same unsupported crossing.

Automated: PASS actual recording-based route, physical bridge carry and rail blocking, 180-tick paired phase traces matching after retry, baseline, and exact Echo poses across changed bridge geometry. Human moving-platform feel, clarity, timing tolerance and browser behavior remain UNVERIFIED.

## M7 — Interference

The authored M7 uses four separated resonance stations, an alternative to the GDD's suggested pad/pulse arrangement. It teaches the same four-role planning and replacement limit with existing pad rules; no extra gadget is introduced. A (240,200), B (240,460), C (640,200), D (640,460) must all remain occupied while live Rook reaches EXIT (1030,324).

1. Record E1: right 26 ticks, up 32 to A; bank at 10s (600 samples).
2. Record E2: right 26, down 35 to B; bank at 10s.
3. Record E3: right 130, up 32 to C; bank at 10s.
4. Record E4: right 130, down 35 to D; bank at 10s.
5. Final live run: wait about 1s (60 ticks), then move right through the gate to EXIT. Automated completion tick: 286 (4.77s), four genuine recorded tapes.
6. Optional teaching exercise: bank a short unhelpful run with all slots full, select E2 for replacement, and observe the missing role. Use Tab → Undo last bank change → confirm to restore the prior setup. Cancel at either prompt changes nothing. Removing a tape retains slot labels and supports the same confirmed undo.

Automated: PASS full-bank no-overwrite/cancel, explicit isolated replacement, undo cancellation/commit, active-run reset, stable slot holes, replay clearing history and actual four-role solution. With B removed, the other three recordings cannot open the gate. Human gameplay/UI and narrative acceptance remain UNVERIFIED.

## M8 — Vault of Tomorrow

Four independent stations A (240,190), B (240,470), C (840,190), D (840,470) require distinct actors for 120 continuous ticks (2s). Live-only CORE is at (640,324); EXIT is at (1060,324). Core acceptance starts a 300-tick (5s) exit deadline, still bounded by the ordinary 30s mission limit.

1. Skip/read the intro; it consumes no mission ticks. Record four actual 15s (900-sample) tapes: E1 right 26/up 35 to A; E2 right 26/down 38 to B; E3 right 183/up 35 to C; E4 right 183/down 38 to D. Hold each station until banking at 15s.
2. Final live run: right 130 ticks to CORE, then wait. The last recorded station becomes occupied near tick 213; the conductor completes its two-second overlap near tick 332.
3. Press E once the ring is ready (reference tick 360, elapsed 6s). Walk right to EXIT. Reference clear is tick 465 (7.75s), four Echoes, with over three seconds left in the exit window. An early E at tick 330 is rejected; Echoes cannot activate CORE.
4. The six-second Perfect Heist view reads sealed poses/events only. Skip immediately or let it finish, then read the ending and return to mission select. Neither path replays gameplay or writes completion twice.

Automated: PASS four real recordings, distinct matching/120-tick boundary, rejected early CORE, live activation, exact deadline failure, reset, paused/skippable intro, non-mutating skipped and automatic six-second showcase, summary fallback and select transition. Human story/visual/audio acceptance and start-to-finish hand play remain UNVERIFIED.
