# Snapback — Game Design Document

**Version:** 1.0 design specification  
**Theme:** Bounce Back  
**Genre:** Two-player, same-keyboard, single-arena physics sports brawler  
**Primary promise:** *Every fall is a chance for a comeback.*

## 1. Creative thesis

Make two people shout, laugh, and demand a rematch after a 60–120-second competition. The player never waits for a jump or a respawn to become interesting: both avatars continually bounce on one trampoline. A tap near landing builds height. A dive makes a high-risk aerial attack. A clean stomp sends the other player toward a side pit. A well-timed Snapback Save can turn an almost-certain loss into a comeback.

The special distinction is **a shared, visibly elastic surface plus a once-per-rally, timing-based edge recovery**, not a generic fighting game or traditional Pong. The surface should transmit *small, understandable* momentum effects between players; successful moves should read instantly without explanation.

This is **ONE complete game mode in ONE arena**. There are no levels, campaign, upgrades, character selection, alternate arena roster, online play, bots, or collectible systems.

## 2. Player fantasy and emotion

- **At 0 seconds:** Both players see their color, keys, and a large `PLAY` action. One press starts the match.
- **At 3 seconds:** Both characters are visibly airborne and steerable. A prominent cue shows how to time a bounce.
- **At 10 seconds:** Ideally someone has executed a timed bounce or a near-miss dive. Actions are legible and energetic.
- **At 20 seconds:** Stomp, counter-stomp, or dramatic edge recovery creates a laugh or reaction.
- **At 60–120 seconds:** A winner is crowned and a single key starts a rematch. These are design targets to verify, not promised timings.

### Three emotional beats
1. **Anticipation:** I can see my character dropping and time the next bounce.
2. **Surprise:** My opponent changes course or I turn a mistake into a counterattack.
3. **Mastery:** I know *why* I won and what to do differently next rally.

The game must be fun before particles, menus, and sound are added. A gorgeous but confusing physics prototype fails this design.

## 3. Arena

- Fixed logical canvas: **960×540**. Side view, one camera, no scrolling.
- Shared trampoline equilibrium surface approximately **y=410** spanning **x=180 to x=780**.
- Dark pits beyond either end. Players who fall entirely beneath the bottom of the arena lose the rally.
- Two elastic recovery bumpers positioned outboard of the net, one near each pit. They are not safe platforms; they offer **one skill-based recovery opportunity per player per rally**.
- Graphic-only backdrop: ink-black field, stylized stadium markings and sparse kinetic sports graphics. Do not obscure collisions with visual clutter.
- No platforms, moving hazards, lasers, pickups, environmental damage, or random stage events.
- After a long rally, **Overdrive** telegraphs that the trampoline's safe span is narrowing; it discourages indefinite avoidance without randomly assigning a winner.

The main surface bends and sends damped lateral waves in response to both landings. The collision surface and drawing must agree to within a small tolerance.

## 4. Input and competitive actions

| Action | Coral (P1) | Mint (P2) | Intent |
|---|---|---|---|
| Move horizontally | `A` / `D` | `←` / `→` | Position a landing, escape, chase, or stomp |
| Timed bounce | Tap `W` | Tap `↑` | Build bounce tier by pressing shortly before trampoline contact |
| Dive | Hold `S` | Hold `↓` | Descend sooner; stronger threat if a stomp connects |
| Snapback Save | Tap `W` at an edge bumper | Tap `↑` at an edge bumper | One high-stakes recovery when threatened by the pit |

Only four movement keys per player. No mouse required. The same bounce key handles timed bouncing and recovery, but **the recovery window takes priority** when the player is in an eligible bumper contact situation. This prevents one press from triggering two unrelated actions.

`Space` or `Enter`: start/rematch. `Escape`: pause/resume. `M`: toggle mute. Reduced motion toggled from the menu using a clearly labeled control or accessible key (e.g., `V`); no gameplay conflict.

## 5. Core systems

### 5.1 Automatic trampoline bouncing

- Every downward landing on a valid portion of the trampoline launches the character upward. There is **no stationary camping on the net**.
- Each character has bounce tier **1–5**, starting at **2** at the beginning of each rally.
- A freshly pressed bounce key during the final **12 simulation ticks** before surface contact counts as a **perfect bounce**. It raises tier by one (up to 5).
- An ordinary landing without eligible input reduces tier by one (minimum 1), but still produces a useful bounce. This is not a hard fail.
- Bounce keys are edge-triggered, require release before a fresh press, and have a short configurable anti-mash interval. Held buttons cannot trigger endless perfect bounces.
- An optional narrow visual landing marker/ring communicates the perfect window. Do not make it necessary to read small numbers or count frames.
- Higher tiers create more height and tactical opportunity; avoid bouncing above the visible screen for long periods.

### 5.2 Air control and dive

- Players can steer while airborne. Air acceleration must support corrections, not instantaneous teleporting.
- Holding dive increases downward acceleration and can set up a surprise stomp, but reduces the player's ability to escape vertically until they release the key.
- Diving onto the trampoline generates a stronger **net wave**. It is a tactical risk: a dive can speed up a shared rebound or expose the diver to a counter.
- Dive is **not** an instant-attack button and cannot directly knock an opponent away without contact or a small, visible net-wave interaction.

### 5.3 Stomp and counterplay

- A stomp occurs only when a falling character crosses the opponent's upper collision region with sufficient downward **relative** velocity.
- A valid stomp launches the defender sideways, **away from the attacker**, with a small downward component. The attacker's fall converts into an upward rebound and optionally one tier of momentum reward.
- A recently stomped player receives a short, visible anti-juggle protection interval. Stomps are not allowed to repeatedly retrigger every overlapping simulation tick.
- Side-to-side collisions separate players and impart a small, symmetric impulse. Side contact is not automatically a stomp.
- Simultaneous ambiguous top collisions resolve as a fair body bump rather than two contradictory stomps.
- The knockback should be threatening but rarely an unavoidable knockout from the exact center of the net. Position, skill, and the recovery bumper matter.

### 5.4 The signature mechanic: Snapback Save

**Design purpose:** a reversible-feeling, skillful last-second comeback consistent with the theme.

- When a character is knocked toward the outside of the trampoline and approaches a designated elastic **side bumper**, its bumper highlights. Both colors can use either bumper; a player's **personal save charge** is the limit.
- The player gets **one charge per rally**, visible as a tiny ring icon alongside their bounce pips.
- A bounce-key tap within the configurable pre-contact window (with a very short post-contact grace) converts contact into a **Snapback Save**: a strong, controlled launch inward and upward.
- If the timing is missed, there is **no automatic strong rescue**. A soft contact may slow the fall but cannot safely return the player without a well-timed press.
- Consumed charge stays unavailable until next rally, even if the player reenters the main net. No infinite edge bouncing.
- Recovery must not trigger automatically on any wall or from the center of the arena; it requires a genuine bumper contact on the correct side.
- A successful save displays a restrained `SNAPBACK!` shout, a distinct warm impact sound, and a very short effect—without freezing player controls.
- The opponent should have a chance to respond. An edge comeback must be exciting, not a guaranteed immediate stomp.

**Fairness rule:** do not give automatic bonus protection, teleports, invulnerability, or rubber-band score manipulation to the losing player. Anyone can make a save; it is *skill-based*, not pity balancing.

### 5.5 Shared trampoline wave

- The trampoline is physically shared, not two separate launch pads drawn as one line.
- Landings deform several neighboring membrane samples and propagate a damped wave across the surface.
- Bounce outcomes may receive a **small bounded** modifier from the net's local upward velocity at landing, capped so timing tier and player decisions remain the dominant factors.
- A particularly strong dive landing produces a more pronounced wave; an opponent who times their bounce near a rising crest can gain a small advantage.
- Wave effects are always visible and measurable. They should not fling a distant opponent off the arena without meaningful, readable contact.

### 5.6 Pits and scoring

- If a player's entire body crosses below the bottom-of-screen knockout plane after falling, the **other player earns exactly one point**.
- Prevent double scoring if both cross the loss plane in the same tick. Resolve simultaneous knockouts with a **no-point replay** and quick fresh rally.
- First player to **three** points wins the match (best of five rallies). No random tie-breaks.
- After a scored knockout: short hit-stop in the **presentation layer**, a clear one-point score animation, then an automatic new rally after about 0.6 seconds. Never wait a full second just to continue.
- At match end, show one bold winner screen with `REMATCH — SPACE / ENTER`. Rematch must be immediate and fully reset score, state, controls, and timers.
- Keep a small non-persistent session win counter if it improves rematch excitement; **do not build progression or save-game systems**. Persistence is unnecessary.

### 5.7 Rally pacing / Overdrive

To prevent endless evasive play:
- After approximately **25 seconds of uninterrupted rally**, clearly announce `OVERDRIVE` with a short, readable visual (do not obscure gameplay).
- Over the following approximately **12 seconds**, the usable trampoline endpoints contract inward symmetrically by a limited amount (e.g., up to ~70 px on each side), leaving ample room for skill and recovery.
- Display the contracting safe area; do not secretly change collisions.
- The narrowed net persists until the rally resolves; it should not continue shrinking forever.
- Both players are affected equally. Do not artificially declare a knockout on a timer.
- If this creates unpredictable or unfair losses during testing, simplify or remove Overdrive; document why. Core gameplay quality takes precedence.

## 6. Match state machine

`TITLE` → `COUNT_IN` (brief, skippable/less than a second) → `RALLY` → `POINT_FREEZE` → (`COUNT_IN` or `MATCH_OVER`).

`PAUSED` overlays any running match state and freezes the entire simulation, timers, and input edge consumption; resume must not count stale held inputs. `MATCH_OVER` → `COUNT_IN` on Space/Enter, resetting full match state.

Blur/tab-hidden must automatically pause and clear held controls. Menus must never leak input into a new rally. The winner, point, and double-knockout decision should be computed **once**, not in render code.

## 7. Feedback hierarchy

1. **Necessary:** which player is which; where the trampoline is; whether an input qualifies as perfect; which way a knockback went; where the recovery bumper is; match score.
2. **Rewarding:** tier pips pop on perfect bounce, squash-and-stretch character pose, membrane ripple, crisp contact sound, modest screen nudge on stomp.
3. **Expressive:** comic-style `PERFECT`, `STOMP!`, `SNAPBACK!`, `OVERDRIVE`, winner typography; never spam words so players cannot see the arena.

Use minimal particle count and limit shake/flash; reduced-motion mode eliminates camera shake and decorative particles.

## 8. Balance targets (hypotheses, not established facts)

- New players should understand movement and objective in **<15 seconds** with on-screen controls.
- A correct timing press should produce noticeably greater apex height than a missed press.
- Stomps should require intentional position and descent; glancing side bumps should not mistakenly count.
- A Snapback Save should have a visible opportunity, a meaningful timing challenge, and real failure conditions.
- Typical match target: approximately **1–3 minutes**, not mandatory or guaranteed.
- Late-rally state should prevent recurring stalemates without overriding player skill.
- The player who wins should usually feel they earned it, not that collision bugs decided it.

Prototype with two humans. If humans find a mechanic unfair, change it even if synthetic tests pass. Never claim human enjoyment was tested without human observers.

## 9. Scope restrictions

**Required:** polished single arena, two-player controls, fixed-step physics, timed tiers, dive, stomp, shared trampoline wave, Snapback Save, pit knockout scoring, short best-of-five match, Overdrive if validated, title/pause/winner screens, procedural visuals/audio, responsive browser embed, QA evidence.

**Explicitly excluded:** levels, campaigns, AI opponent, online multiplayer, matchmaking, upgrades, collectibles, weapons, health bars, store, skins, character roster, excessive menus, external dependencies, gamepad, touch/mobile controls, sophisticated background music, and paid assets.

A game that is exceptional for one match is the finished product.
