# Snapback — Physics, Input, and Implementation Contract

## 1. Units and simulation

All defaults below are **starting proposals to prototype and tune**, not verified gameplay values. Use logical pixels; `y` increases downward. Physics runs at exactly **60 fixed steps per second**. `CONFIG` is authoritative in `index.html` and contains every tunable setting. Avoid unexplained hard-coded forces and durations.

`requestAnimationFrame(timestamp)` is only a render scheduler. Accumulate `deltaMs`, clamp unusually large deltas (e.g., 150 ms), update up to a bounded number of 60 Hz steps, then render using interpolation if feasible. Do not advance physics once per paint; a 144 Hz display must not make the game faster. On tab blur, pause and clear accumulator and held keys so an old background time gap cannot fast-forward a match.

State mutations happen in fixed-step update functions. Drawing must not mutate scoring, player position, input history, or match state.

## 2. Proposed top-level CONFIG groups

The following are **tuning defaults**, subject to measured revision:

| Group/key | Initial value | Meaning |
|---|---:|---|
| `canvas.width` / `.height` | 960 / 540 | Logical view |
| `simulation.hz` | 60 | Fixed timestep |
| `player.width` / `.height` | 28 / 40 | Collision bounds; rendered silhouettes may be more expressive |
| `player.gravity` | 0.48 | Added vertical speed per physics tick |
| `player.airAccel` | 0.48 | Horizontal acceleration per held direction per tick |
| `player.maxVx` | 5.8 | Maximum self-steered horizontal speed |
| `player.noInputDrag` | 0.96 | Horizontal drag in air when not steering |
| `player.diveGravityBonus` | 0.32 | Extra vertical acceleration when holding dive while falling |
| `player.maxFallVy` | 19 | Speed cap for downward motion |
| `bounce.startTier` | 2 | Initial bounce level |
| `bounce.minTier` / `.maxTier` | 1 / 5 | Legal levels |
| `bounce.baseImpulse` | 8 | Base upward magnitude |
| `bounce.impulsePerTier` | 2 | Additional upward magnitude per tier |
| `bounce.perfectWindowTicks` | 12 | Valid early press before contact |
| `bounce.pressCooldownTicks` | 15 | Prevent mash-to-win; may tune after testing |
| `bounce.netWaveGainMax` | 1.2 | Maximum speed bonus from rising net |
| `trampoline.left` / `.right` | 180 / 780 | Initial active span |
| `trampoline.equilibriumY` | 410 | Flat resting net height |
| `trampoline.samples` | 25 | Spring-coupled nodes along span |
| `trampoline.maxDeflection` | 38 | Clamp downward/upward deviation as appropriate |
| `trampoline.spring` | 0.035 | Restoring acceleration of each sample |
| `trampoline.neighborCoupling` | 0.11 | Lateral wave coupling |
| `trampoline.damping` | 0.91 | Net velocity attenuation per tick |
| `trampoline.impactStrength` | 2.4 | Standard contact impulse into mesh |
| `trampoline.diveImpactMultiplier` | 1.5 | Additional membrane wave on dive landing |
| `stomp.minRelativeFallSpeed` | 2.5 | Downward relative speed required for stomp |
| `stomp.horizontalBaseKnock` | 7.0 | Defender sideways knock speed |
| `stomp.horizontalSpeedScale` | 0.25 | Additional speed from attacker descent |
| `stomp.horizontalKnockMax` | 11.0 | Hard cap after stomp |
| `stomp.defenderDownVy` | 3.0 | Defender minimum downward speed after hit |
| `stomp.protectionTicks` | 16 | Anti-juggle grace after hit |
| `stomp.attackerBounceImpulse` | 13.0 | Upward launch after stomp; can scale by tier |
| `bumper.leftX` / `.rightX` | 90 / 870 | Recovery bumper x positions |
| `bumper.topY` / `.bottomY` | 270 / 435 | Active recovery segment |
| `bumper.preContactTicks` | 12 | Bounce press may be buffered this many ticks before bumper contact |
| `bumper.postContactGraceTicks` | 5 | Short response window after first touch |
| `bumper.inwardLaunchVx` | 9.5 | Recovery launches toward center |
| `bumper.upwardLaunchVy` | 13 | Recovery upward magnitude |
| `bumper.softReboundVx` | 1.5 | Missed save slows collision but is insufficient to guarantee rescue |
| `overdrive.beginSeconds` | 25 | Rally duration before warning/start |
| `overdrive.shrinkSeconds` | 12 | Time to fully shrink |
| `overdrive.maxInsetEachSide` | 70 | Maximum net inward contraction |
| `scoring.pointsToWin` | 3 | Best-of-five match |
| `scoring.pointPresentationSeconds` | 0.6 | Brief score hold before next rally |
| `presentation.stompShakePx` | 4 | Optional shake; 0 in reduced motion |

**Beware of the bounce anti-mash interaction:** a press for the next bounce must not be disallowed if the natural flight time is shorter than the cooldown. Verify real cycles at tier 1–5. A held key does not count as repeated presses; `keydown` edges do.

## 3. Suggested state shape

```js
const state = {
  phase: 'TITLE', // TITLE, COUNT_IN, RALLY, POINT_FREEZE, MATCH_OVER, PAUSED
  previousPhase: null,
  roundIndex: 0,
  rallyTicks: 0,
  scores: [0, 0],
  players: [createPlayer(0), createPlayer(1)],
  net: createNet(),
  keysHeld: Object.create(null),
  pressEdges: [],
  audioEnabled: true,
  reducedMotion: false,
  effectEvents: [],
  winner: null,
  pendingPoint: null,
  overdriveInset: 0,
};
```

Each player has `x,y,vx,vy,prevX,prevY,tier,lastBouncePressTick,recoveryCharge,bumperContactGrace,stompImmunityTicks,airborne,wasDiving`, as needed. Store positions consistently (center x / top y, or center x / center y); choose one convention and document it.

`CONFIG` and game state must not mix: config is static tunables; state is live session data.

## 4. Input contract

- Listen to `keydown`/`keyup`; map **physical** `event.code` values: `KeyA`, `KeyD`, `KeyW`, `KeyS`, `ArrowLeft`, `ArrowRight`, `ArrowUp`, `ArrowDown`, `Space`, `Enter`, `Escape`, `KeyM`, and optional `KeyV`.
- `event.preventDefault()` on recognized keys to stop arrow/space scrolling when game has focus.
- Ignore `event.repeat` for edge-triggered actions, but keep `keysHeld` for movement/dive.
- Bounce presses are **events**, not a continuously true flag. Stamp them with simulation tick. Clear consumed and expired presses; never allow a press from a prior rally to count.
- Simultaneous P1 and P2 input must be processed independently on the same tick. Avoid a single `currentKey` variable.
- Prevent screen hotkeys from activating repeatedly on held keys.
- On blur/hidden tab, pause and clear all held keys; on resume reset wall-clock accumulator.
- If keyboard ghosting prevents some physical combinations, cannot fix that via code; explain it and test actual hardware. Never pretend all hardware supports every chord.

## 5. Collision ordering — important

A recommended deterministic update order for each fixed tick:

1. Advance state/rally timer if running; collect fresh key edges.
2. Apply horizontal steering, gravity, and dive to both players; decrement relevant cooldowns.
3. Store previous positions; advance players with bounded velocities.
4. Update net spring samples and compute local piecewise-linear collision surface.
5. Resolve **player–player** contacts once, distinguishing stomps vs side bumps.
6. Resolve recovery bumper contacts, using prior/current x and y and buffered save key edges.
7. Resolve trampoline landings from above using swept foot crossing against the interpolated net surface; apply bounce impulse and net deformation.
8. Resolve pit knockouts **simultaneously**, then award at most one point or a no-point draw.
9. Queue presentation/audio events, update state phase, expire input edge events.

Adapt ordering if tests reveal missed contacts, but keep it deterministic and documented. Player–net contact must not trigger when rising from below or when off the active net span. Player–player stomp must not trigger from side or bottom collisions.

### Continuous-enough collision checks

At all supported speeds, a player should not pass through the trampoline or another avatar in a single frame. Use swept collision or segment crossing for feet and bumper contact, and constrained substeps if needed. Avoid only checking AABB overlap *after* movement when high speeds can skip contact.

### Net mesh

Represent net as 25 coupled vertical displacement samples. Each step: integrate restoring force to equilibrium + neighbor coupling, multiply by damping, clamp positions/velocities. Sample collision y at any player x by interpolating the relevant segment. Apply landing force distributed to nearby samples. The net visual should render the same sample positions with smoothing that **does not move the visible net far from collision geometry**.

If full discrete spring simulation proves unstable or becomes impossible to make readable, replace it with a simpler deterministic traveling-wave representation, but retain real shared contact effects. No fake visual-only rubber band.

### Bounce press validity

At landing, a bounce press is valid only if:
- It is a fresh keydown edge for that player.
- It occurred within `perfectWindowTicks` of this precise landing tick.
- It was not already consumed for a bumper/save or prior landing.
- It respects anti-mash cooldown.

A press after landing does not retroactively confer a perfect. Use a highly readable timing cue to avoid users needing to predict precise ticks from unseen state.

### Stomp resolution

A stomp requires all of:
- Bounding boxes overlap horizontally at the expected time of contact.
- Attacker's previous bottom is at or above defender's previous upper hit region (allow small numerical tolerance).
- Attacker crosses toward defender from above while descending **relative to defender** faster than threshold.
- Defender is not in anti-juggle protection and attacker has not already stomped this contact.

Direction of lateral knockback = sign(defender.x - attacker.x); if nearly equal use attacker horizontal motion; if still exactly equal use deterministic player-index tie convention mirrored by role and covered by tests. Avoid right-side bias.

### Bumper save priority

When near a lit bumper, bounce input should be eligible as a save. On genuine contact, check a fresh press within the pre-contact buffer or short post-contact grace. Consume the player's one recovery charge and immediately apply an inward/upward impulse on success. After grace expires, player continues falling or receives only a weak nonrescuing bumper contact. Players cannot repeatedly hit a bumper to farm upward speed.

Test saving at both bumpers from both player roles, and make saved character land safely on the shrinking net when reasonably steered inward.

## 6. Match consistency

- Maintain a single authoritative `resolveRallyOutcome` function.
- Both players lose on same tick → no point, restart rally quickly.
- One player loses → opposite player receives one point. Do not award twice on subsequent frames.
- Reset players, net, wave, recovery charges, bounce tiers, timer, pending inputs, stomps, shake, and other round-only state between rallies.
- Match-over begins immediately on a third point; no accidental fourth point.
- Pausing must freeze simulation tick, timer, wave, and cooldowns.
- Reduced-motion affects draw effects, **not authoritative physics**.

## 7. Robustness and test hooks

Implement pure or dependency-light functions such as `createMatchState`, `stepSimulation(state, inputEdges)`, `resolveStomp`, `sampleNetAt`, `resolveNetLanding`, `resolveBumperSave`, `resolveRallyOutcome`, `resetRally`.

Expose testing helpers **only in a test environment/query flag** (e.g., `?test=1`), not as visible cheats in the shipped experience. Codex may implement a Node harness using built-in `node:test` or browser automation if installed; don't add a mandatory package manager/build requirement to the shipped game.

Do not claim exact deterministic replay across different JavaScript engines until verified; require repeatable outcomes within the same environment for identical seed/input fixtures.

## 8. Tuning and fairness

Use a tuning notebook in `docs/DEV_LOG.md`. Record each changed CONFIG value and the reason. Tune *pairs* of humans whenever possible: one novice and one experienced player, swap colors, and check whether the rebound/save mechanics are both understandable and counterable. No machine-run test can validate subjective fun.
