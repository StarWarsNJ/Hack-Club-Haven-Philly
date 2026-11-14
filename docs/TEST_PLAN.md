# Snapback — Test Strategy and Acceptance Matrix

## 0. Evidence standard

Snapback is a local multiplayer physics game. **A successful syntax check is not equivalent to a working or fun game.** Automated unit/simulation checks, browser execution, visual inspection, and real two-human keyboard playtest are separate kinds of evidence. Record **PASS / FAIL / NOT RUN / BLOCKED** for each; never substitute one for another.

Maintain `docs/QA_REPORT.md` with exact commands, actual output summaries, timestamp, browser/OS version when known, failures, screenshots/paths when generated, and human-only items. Test harness runs should not require network access, paid tools, or permanent extra runtime dependencies.

## 1. Automated simulation test design

The game runtime is one self-contained `index.html`. Implement deterministic gameplay functions and a test-only hook under `?test=1` or a separate test harness that exercises **the real logic**, not a rewritten fake model. If Node.js is available, built-in `node:test` is fine; browser automation through installed tools is fine. The downloadable runtime must still open without Node, a server, or a build step.

Use fixed input sequences and state fixtures. Test at tick boundaries and with different requested render frequencies. Keep test helpers inaccessible from normal gameplay flow (no live cheat keys).

### A. Startup and state machine

- [ ] `index.html` opens in desktop Chrome/Edge/Firefox when available; no uncaught errors or missing resources.
- [ ] Title shows names, controls, objective, play button/keys, and visual identity.
- [ ] Space starts match once; Enter equivalent; repeated held keys cannot repeatedly restart.
- [ ] Countdown/start is brief and never leaks title input into a perfect bounce.
- [ ] `Escape` freezes and resumes match, cooldowns, net physics, timer, and score; input state clears safely on resume.
- [ ] Blur/hidden-tab auto-pauses and clears held keys; long background time does not cause frame catch-up.
- [ ] Winner screen triggers only after exactly three points and `Space`/`Enter` starts a clean new match.
- [ ] `M` mutes/unmutes without double-toggling from key repeat; audio unavailability doesn't crash.
- [ ] Reduced-motion setting doesn't change gameplay outcomes.

### B. Controls and fixed timing

- [ ] P1 and P2 can hold opposite movement directions simultaneously in a synthetic input trace.
- [ ] Both players can steer while diving; dive increases descent but does not break max velocity cap.
- [ ] Bounce input is edge-triggered: one `keydown` per press; holding W/Up doesn't generate endless perfects.
- [ ] Bounce presses expire; old presses from prior rally are never consumed.
- [ ] Multi-key input ordering does not bias P1 or P2.
- [ ] 60 Hz simulation yields the same tick-count behavior at emulated 60/75/120/144 Hz RAF cadence.
- [ ] Pausing at impact and resuming does not duplicate a landing or stomp.

### C. Bounce timing and tier progression

- [ ] Both players begin each rally at tier 2.
- [ ] A fresh press **within the defined pre-landing window** increments tier exactly once, clamped to 5.
- [ ] A press just outside the window is not perfect and cannot carry forward.
- [ ] A normal landing decrements tier by one, clamped to 1, and still launches the character.
- [ ] Higher tiers produce increasingly higher/longer launches in a controlled fixture.
- [ ] Bounce velocities remain bounded; no NaNs, tunneling, or offscreen infinite hang.
- [ ] Rising from below the trampoline does not count as landing from above.

### D. Shared trampoline

- [ ] A landing causes visible/net-state deformation at the actual contact location.
- [ ] A wave propagates to adjacent samples and decays to equilibrium without exploding.
- [ ] Contact y interpolates from authoritative samples; drawn net is close to collision net.
- [ ] A second player's launch changes by only a **bounded** net-wave amount and never receives an unexplained remote shove.
- [ ] Two simultaneous landings do not cause double mutation or numeric blow-up.
- [ ] A dive landing has a visibly stronger but bounded effect.
- [ ] The net remains stable after >10,000 simulated steps of representative impacts.

### E. Stomps and contact fairness

- [ ] Downward collision from above with sufficient relative speed causes one stomp.
- [ ] Horizontal body contact causes side bump, not stomp.
- [ ] Upward contact from below is not a stomp.
- [ ] Ambiguous equal-height contact resolves symmetrically according to explicit rule.
- [ ] Stomp defender gets correct away-from-attacker impulse **from both sides**.
- [ ] Attacker receives a satisfying but bounded upward rebound; defender tier resets to 1.
- [ ] Anti-juggle prevents continuous overlap from stacking hits over many ticks.
- [ ] No double stomp from two update phases; render cannot retrigger a stomp.
- [ ] Knockback isn't reversed unpredictably by control input on the same tick; reasonable escape remains possible.

### F. Snapback Save

- [ ] A player with one charge near the left bumper can time a recovery; the right bumper is equivalent.
- [ ] Both P1 and P2 can recover from both bumpers (not a hardcoded player-side rule).
- [ ] Correct pre-contact input performs one inward/upward rescue and consumes one charge.
- [ ] Short post-contact grace works; too-late input does not count.
- [ ] Missed save is a real risk, not an automatic strong bounce.
- [ ] A player without a charge cannot re-save, including after they return to net.
- [ ] Charge resets after the rally but not during the same rally.
- [ ] Timed bounce input cannot trigger both a perfect net bounce and recovery on the same press.
- [ ] Save direction is toward arena center; no inadvertent launch further into the pit.
- [ ] The opportunity is visually and audibly readable at actual browser speed.

### G. Scoring and flow

- [ ] Falling entirely below loss plane awards exactly one point to opponent.
- [ ] Simultaneous knockouts produce one no-score replay; never two points.
- [ ] No scoring occurs during pause or after match end.
- [ ] Reset restores player, net, tiers, save charges, cooldowns, Overdrive geometry, timers, and input edges.
- [ ] Match over at third point cannot accidentally award further points.
- [ ] Rematch resets to 0:0, no stale score or recovery state.
- [ ] Test repeated complete matches (e.g., 50 deterministic simulated matches) without a memory/state explosion.

### H. Overdrive

- [ ] Warning starts at configured rally time only; displayed state agrees with active collision geometry.
- [ ] Both endpoints move symmetrically; no sudden collision teleport.
- [ ] Shrink stops at configured limit and resets next rally.
- [ ] No forced arbitrary winner if both survive; no permanent stall from trapped avatars.

## 2. Real browser and presentation checks

At minimum if tooling allows:
- Desktop Chromium-based browser, 960×540, 1280×720, and typical smaller iframe viewport.
- Another desktop browser engine (Firefox or Safari where available) for basic compatibility.
- Resize window without stretching 960×540 aspect ratio or misaligning canvas pointer interactions.
- Inspect screenshots for title, in-rally, perfect, stomp, save, Overdrive, pause, point, match-over.
- Check console for warnings/errors, absence of external requests, sound handling after click/keypress, focus-loss behavior, and keyboard scrolling.
- Verify readability on a low-resolution laptop screen.
- Verify that with reduced motion: no screen shake/flashes, while gameplay stays unchanged.
- Run a long enough session to observe whether impact effects/audio nodes accumulate or lag. Record actual metrics only if measured.
- **Check physical keyboard rollover with two humans pressing `A+D` analogs?** Better test realistic simultaneous chords such as `A+W+ArrowLeft+ArrowUp`, `D+S+ArrowRight+ArrowDown`, and mixed three-key chords. Hardware may fail some; explain the limitation.

Do not mark physical keyboard tests PASS if only simulated input was used.

## 3. Human playtests — required for engagement claims

Conduct at least **three actual two-person matches** with people who have not been coached on mechanics, if humans are available. Observer records:
- Seconds to start a match and correctly identify controls.
- Whether both players understand when a perfect bounce occurred.
- Whether stomp vs side bump is obvious.
- Whether a Snapback Save is discovered and attempted (if not, why).
- Whether knockouts feel fair.
- Whether rounds end promptly and rematch invitation is noticed.
- Whether someone asks for a rematch without prompting.
- Any accidental key ghosting on actual keyboard.

Use `docs/PLAYTEST_SCORECARD.md`. If Codex cannot conduct human playtests, it must leave the scorecard as **NOT RUN: requires humans** and recommend exact steps. Never invent testimonials or replay statistics.

## 4. Browser deployment check

- [ ] All playable runtime material is inside `index.html`; no external fonts, images, audio, JavaScript or CSS.
- [ ] Double-click `index.html` launch works in target browser as far as file URL policies allow.
- [ ] Static HTTP/localhost test works.
- [ ] Itch.io-compatible HTML5 upload: self-contained `.html` upload or ZIP with `index.html` at ZIP root; embedded iframe 960×540 or responsive.
- [ ] File runs without build process/network.
- [ ] No stale Godot `project.godot` dependency in runtime.
- [ ] No accidental publishing or pushing.

## 5. Quality gates (not fake completion criteria)

The game should not be declared ready for user review until:
1. **All implemented functional mechanics have passing deterministic test evidence.**
2. **No known high-severity gameplay bugs** remain: duplicate points, irrecoverable softlocks, input loss after pause, broken stomps, broken rematch, invisible collision.
3. A real browser run and visual review are completed **if supported**; otherwise recorded as blocked.
4. Each required screen and control has been manually exercised or clearly marked NOT RUN.
5. The QA report differentiates test categories honestly; subjective fun is **never certified by automation**.
6. The full core match is implemented, not just a physics prototype or decorative title screen.

## 6. Severity rubric

- **Critical:** cannot start/complete match, crash, corrupt score, infinite state loop, controls unusable.
- **High:** systematic unfair collision/knockout, repeated save exploit, unreliable bounce timing, broken rematch.
- **Medium:** infrequent visual clipping, audio glitch, misleading help text, mild late-match stalemate.
- **Low:** cosmetic alignment, subtle animation mismatch, non-blocking typography issue.

Fix critical/high before more polish. Do not delete a failing test or widen an assertion to hide defects.

## 7. Execution record template

| Date | Environment | Test / scenario | Command or steps | Result | Evidence / bug |
|---|---|---|---|---|---|
| — | — | — | — | NOT RUN | Awaiting implementation |

Each real test entry should replace the placeholder. Add separate 'Human playtest' section with actual people only when conducted.
