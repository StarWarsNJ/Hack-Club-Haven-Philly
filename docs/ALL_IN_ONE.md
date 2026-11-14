# Snapback — ALL IN ONE specification

This is a readable consolidation of every file in the full kit. Extract individual files from the ZIP if possible; otherwise copy the corresponding sections into your existing project.



---

# FILE: START_HERE.md

# START HERE — Snapback multiplayer kit

This kit defines **Snapback**, a one-screen, competitive, two-human, one-keyboard browser game for the theme *Bounce Back*.

## Recommended installation (existing `hackathon` Git repository)

1. Preserve the Git repository and make a personal backup of work you want to keep. Check `git status` before overwriting anything.
2. Copy **AGENTS.md**, **README.md**, and **docs/** from this kit into your repo. Do not copy the containing kit folder itself; the files should sit at the repo root.
3. **Do not delete `.git/`, `.gitignore`, or your existing `project.godot`.** The Godot file is dormant; the new game is vanilla HTML5 and runs through `index.html`.
4. Open VS Code in that repository, then open Codex. Give it the prompt in `CODEX_SINGLE_PROMPT.md` (self-contained), or ask it to follow `docs/CODEX_GOAL.md` plus all the project docs.
5. Codex must create `index.html`. It must not stop at a prototype; it must implement and verify the full match loop, visuals, sound, and recovery mechanics.
6. Test in a desktop browser by opening `index.html`; use an HTTP server for itch.io-like embedding checks. Confirm **two people can use the physical keyboard simultaneously**—software cannot fix keyboard rollover/ghosting.
7. After Codex finishes, read `docs/QA_REPORT.md`, run several two-person matches, tune where needed, then export an itch.io ZIP with `index.html` at its root. Do not publish without approval.

## Minimal-copy alternative

If you cannot use download links or cannot extract the ZIP, copy the complete prompt in `CODEX_SINGLE_PROMPT.md` (also supplied in ChatGPT's answer) into Codex. It is **self-contained** and instructs Codex to generate missing project documentation itself. Do not tell Codex to read missing files and then stop.

## Nonnegotiables

- No levels, story, shops, skins, online features, AI opponent, or extra game modes.
- Shared trampoline is functional, not merely a drawn decoration.
- Timed bounce tiers, fair aerial stomps, skill-based one-use Snapback Save, first-to-three scoring, immediate rematches.
- Distinctive hand-authored Canvas graphics, optional original Web Audio, accessible feedback, high contrast.
- One shipped **`index.html`** with no external assets/dependencies. Development docs/tests may be extra files.
- Test evidence must be real; human playtesting and hardware compatibility remain unverified until actually performed.



---

# FILE: CODEX_SINGLE_PROMPT.md

# Single complete Codex prompt — Snapback multiplayer

**ROLE AND AUTONOMOUS OBJECTIVE**
Build **Snapback** into a complete, polished, instantly understandable, highly replayable, two-person local browser game for the theme **Bounce Back**. This is a full implementation, testing, and refinement assignment; do not stop after planning or a bare prototype. Take ownership of gameplay feel, reliability, art direction, and quality. Nothing can guarantee a hackathon win; optimize for a striking first interaction, fair skill, natural comedic reversals, and instant rematches.

**REPOSITORY AND DELIVERY**
Inspect the existing repository, `git status`, and all supplied `AGENTS.md` and `docs/` files first. They are authoritative if present and consistent with this prompt. If some documentation is missing, create it; do **not** stop for missing docs. Do not destroy uncommitted user work. Keep `.git/` and `project.godot` untouched. The game is **not Godot**: ship a single self-contained `index.html` using HTML, CSS, vanilla JavaScript, Canvas 2D and procedural Web Audio, with **no** CDN, framework, network fetch, external images, fonts, audio, npm, build step, or runtime server. It must open by double-clicking in a modern desktop browser, and be packageable as an itch.io HTML5 ZIP. Development markdown and optional standalone test files may exist outside the shipped single-file game.

**THE ENTIRE GAME IN ONE SENTENCE**
Two small expressive rivals automatically bounce on **one physically shared elastic trampoline**; each steers, times a higher rebound, and dives to stomp the other into a side pit, while a one-use **Snapback Save** lets a skillful player escape a near knockout and counterattack.

**SCOPE**
Exactly two local human players and one symmetrical side-view arena. No levels, campaign, AI, online multiplayer, ball/hoop mode, random powerups, weapons, health meters, shop, unlocks, story, ads or tutorial wall. One 1–3-minute best-of-five match (first to three points), then immediate rematch. Prioritize a satisfying single match over feature count.

**INPUT — ONE KEYBOARD, NO MOUSE DURING MATCH**
P1 coral: `A` left, `D` right, tap `W` to time a bounce OR trigger a valid edge save, hold `S` to dive. P2 mint: arrows left/right, tap up to bounce/save, hold down to dive. Space/Enter start/rematch; Escape pause/resume; M mute; V reduced-motion toggle. Display input instructions elegantly on title/pause screens and optional small HUD. Use `KeyboardEvent.code`, independent held-key state for both players, keydown edges for bounce/save, ignore repeats, `preventDefault` on keys that scroll, clear state on blur/visibility change, and auto-pause to prevent desync. Some physical keyboards ghost key combinations; disclose that and test with real hardware if possible.

**STAGE AND PHYSICS FOUNDATION**
Logical Canvas 960×540; scale uniformly with letterboxing, high-DPI crisp rendering; no distortion or click-coordinate mismatch. Physics fixed at 60 Hz with a clamped accumulator and bounded catch-up updates, independent of `requestAnimationFrame` refresh. Use top-left-origin pixels with positive y downward. Put *all tunable values* in one grouped `CONFIG` object near the top; keep state/input/physics/score/graphics/audio functions separate. Render must not mutate game state. Make the real simulation available to automated tests. All numbers below are starting values to tune, not proven balance.

**STARTING CONFIG**
Canvas 960×540. Player collider approximately 28×40. Gravity `+0.48 px/tick²`; steer acceleration `0.48 px/tick²`; max horizontal speed `5.8 px/tick`; idle air drag `0.96`; dive gravity bonus `+0.32 px/tick²`; cap downward vy at `19 px/tick`. Trampoline active initially from x=180 to x=780, rest y=410, approximately 25 spring-connected samples, locally displaced on impacts; stiffness `0.035`, lateral coupling `0.11`, damping `0.91`, maximum visible deflection 38 px. Players start at x≈360 and x≈600, above net, bounce tier 2. Initial bounce upwards impulse magnitude = `8 + tier×2` pixels per tick; tier 1–5. Perfect input window = last 12 physics ticks before net contact, cue shown visually; anti-mash window ≈15 ticks; don't let cooldown wrongly suppress a legitimate next bounce or a bumper save. Apply bounded net-upward-wave bonus <=1.2 px/tick. All constants may be retuned and changes documented.

**AUTO BOUNCE / SKILL**
Every downward crossing of the trampoline from above bounces the player upward; no standing/camping. Fresh W/up press during the last 12 ticks before precise contact produces `PERFECT`, increment tier by one (cap 5), then uses resulting tier for launch. Missing the timing decreases tier by one (floor 1), but still gives a useful bounce. Holding or spamming W/up never grants repeated perfects; show five tiny pips and a compact, readable approach cue. Top-tier jumps must stay on screen long enough for both players to anticipate encounters.

**DIVE / STOMP / SIDE BUMP**
Holding S/down while airborne makes the player descend faster to set up attacks, but does not instantly hurt anyone. Stomp only if a falling attacker contacts the opponent's top region **from above** with meaningful downward relative velocity (begin threshold around 2.5 px/tick). Award one impact, sideways knock the defender *away from attacker* (start 7 px/tick plus limited extra from fall speed, cap ≈11), give a small downward component, reset defender's bounce tier to 1, and bounce attacker upward (start impulse around 13). Apply short anti-juggle immunity (~16 ticks) and ensure one contact cannot retrigger each frame. Mirrored collisions must resolve symmetrically; side-on contact should push both bodies apart mildly instead of counting as a stomp. If both arrive from ambiguous angles at once, resolve as a fair bump. Use continuous/swept enough collision handling to prevent tunneling and ensure stable interactions at fast velocity.

**THE MOST IMPORTANT TWIST — SNAPBACK SAVE**
Place two visually obvious elastic recovery bumpers in the pit entry region, initially around x=90 and x=870, with active vertical span roughly y=270..435. Both players may use either bumper. A player who is being knocked off and reaches a bumper while still within its contact range can tap **their normal bounce key** during a 12-tick pre-contact window or approximately 5-tick post-contact grace to consume their ONE save charge per rally and launch inward/upward (start 9.5 px/tick inward, -13 upward). Show a distinct but restrained `SNAPBACK!` cue. No teleport, no save from midair or from the trampoline center, no automatic rescue, no infinite bumper bounces, no invulnerability or unfair score-based assist. A mistimed bumper hit should slow the player briefly but not guarantee escape. Give the opponent a real opportunity to counter a successful save. When near valid bumper contact, **save action has priority** over normal bounce on that same key press. Save consumption resets at each new rally.

**TRULY SHARED TRAMPOLINE**
One net formed from spring-coupled local samples. It bends beneath actual landing points, carries damped waves across, and changes the next launch by only a small bounded amount derived from local upward net velocity. The collision height sampled at the player x must correspond to the displayed net, within small smoothing tolerances; no decorative-only sine curve disconnected from physics. A dive can create a more dramatic shared wave but may not automatically launch a distant opponent into the pit. Cap impulses and stabilize spring integration; if the sample model proves unstable, replace with a simpler physically meaningful wave design and document why.

**SCORING / MATCH FLOW**
Two open side pits outside the trampoline. When a character's entire collider falls below the screen, opponent earns exactly one point. If both cross on the same tick, no-point replay with rapid reset. First to 3 points wins (best of five). Short readable scoring beat (~0.6 sec), then auto-start next rally. Title -> brief count-in -> rally -> point beat -> rally / match over -> rematch. No long countdowns, no multi-second dead time. Space/Enter instantly rematches after win and fully resets state. Escape pauses physics and timers; blur auto-pauses. Round scoring must be idempotent, and stale held inputs must not leak across rounds. Optional Overdrive if long rallies stall: after ≈25 seconds telegraph a symmetrical net narrowing over ≈12 seconds, capped around 70 px inward per end; do not force arbitrary winners. **Remove Overdrive if it hurts fairness.**

**FIRST 15 SECONDS — DESIRED EXPERIENCE**
Start from a simple title screen with two large player silhouettes, 4 concise control hints, and `SPACE TO PLAY`. Within one second, both athletes bounce automatically. Within a few jumps, someone can time `PERFECT`, dive, collide, and send the other toward an obvious recovery bumper. A successful save should feel like a highlight of the match. Both players should know which side lost, why, and how to improve. No unskippable tutorials.

**LOOK — HANDCRAFTED, NOT GENERIC UI**
Art direction: *retro kinetic sports poster*, warm, graphic, expressive. Palette: background ink `#151B20`, ivory `#F6EEDF`, coral `#D86751` for P1, mint `#8DD0CF` for P2, trampoline gold `#EEDC96`. Flat filled silhouettes with deliberate asymmetries: P1 angular tuft/headband, P2 curved visor/antenna, readable faces and squash/stretch; shapes distinguish players without relying solely on color. Clear trampoline, pits, bumper brackets, one central big score at top, 5 bounce pips + one save ring near each player's HUD. A few purposeful vector accents and hand-arranged typography. Canvas-drawn original art; avoid default rectangles as final characters, glassmorphism, neon everywhere, AI-looking rounded cards, emoji icon packs, random gradients, excessive particles, unreadable HUD. World feedback: brief squash/stretch on landing, elastic string deformation tied to physics, subtle 2–4 px stomp camera nudge with reduced-motion option, restrained word popups (`PERFECT`, `STOMP`, `SNAPBACK`), score punch, tiny freeze-frame affecting presentation but not allowing scores to mutate twice. No flashing effects or visual clutter. The title, active match, pause, point, and results should look like one coherent designed product.

**AUDIO**
Use original Web Audio oscillators/envelopes/noise without external requests. Distinct elastic bounce, perfect, stomp, save, point, win cues; volume conservative and short, no musical plagiarism. Start audio only after a valid user gesture, allow `M` mute, fail silently if Web Audio unavailable. Audio is optional to understand events. Reduced motion doesn't change game physics.

**TESTS — REAL EXECUTION, NOT CLAIMS**
Implement a reproducible deterministic test mode or development harness reusing the real physics/game functions. Verify normal and perfect bounce tiers; keydown edge and cooldown; simultaneous players; stomp from both directions, side bump, ambiguous overlap, anti-juggle; spring stability; both bumper saves for both players; spent/failed saves; same-tick simultaneous KO; exact single-point accounting; first-to-three winner, reset/rematch; pause/focus/visibility; long runs with no NaNs or tunneling; 60/120/144 Hz simulation consistency; zero external network dependencies. Run many deterministic rallies and inspect results. Where browser automation tools exist, open the real `index.html`, press simultaneous inputs, inspect console errors, take screenshots of title, rally, perfect, stomp, save, and winner states, test resizing and an itch.io-style iframe. If no browser test tooling, accurately mark it NOT RUN. Human two-player enjoyment, fairness, actual physical keyboard rollover, and subjective polish **cannot** be certified by code tests; put a clear human playtest checklist in the QA report and never invent passes.

**ACCEPTANCE GATES**
(1) The self-contained `index.html` runs locally with no console error or missing files; (2) both people can play simultaneously using specified keys; (3) movement, tiered bounce, dives, stomps, side contacts and knockback are stable, deterministic, and readable; (4) visibly shared net couples landings; (5) save works once each rally for either player on either side with meaningful timing; (6) scoring/KO/rematch are rock solid; (7) elegant cohesive title/pause/HUD/winner presentation and accessible control cues; (8) audio/mute/reduced-motion supported; (9) physics and browser tests executed where feasible and exact evidence recorded; (10) no known critical bugs or dead states; (11) no levels or unrelated modes; (12) docs accurately reflect implementation.

**WORK PROCESS AND AUTHORIZATION**
Do a brief code audit, then implement a complete playable 2-player match first; then deepen timing and counterplay; then shared net, rescue, visuals, sound, and tests. Regularly replay regression scenarios. If a mechanic feels uncontrollable, prioritize tuning/simplifying it rather than adding features. Maintain `docs/DEV_LOG.md` with changes, balance choices and reasons and `docs/QA_REPORT.md` with actual PASS/FAIL/NOT RUN evidence; create missing docs, `README.md`, and `AGENTS.md` consistent with this prompt. No broad destructive cleanup, no Git commits/push, no publishing, no installs or paid external assets without permission. Continue autonomously until the game and test evidence meet the gates or you reach a real blocker. Report remaining manual two-person testing plainly.



---

# FILE: AGENTS.md

# AGENTS.md — Snapback

## Mission
Build **Snapback**, a complete, polished, one-screen, local two-player arcade game for the **Bounce Back** theme. Two players share a deformable trampoline; each controls a bouncing character and tries to stomp the other into a side pit. Timed bounces create mastery; a once-per-rally **Snapback Save** creates dramatic recoveries. Prioritize immediate fun, readable physics, fast rematches, and distinctive visual/audio craft.

This repository previously contained unrelated Godot/Paradox Heist and single-player Snapback experiments. **Do not restore or build those games.** This game's authoritative specifications are the current files in `docs/`.

## Canonical decisions
- **One arena. One main mode. Two human players on the same keyboard.** No levels, campaign, AI player, network multiplayer, accounts, character progression, or random power-ups.
- **Player 1:** `A`/`D` move, `W` press to time a bounce or perform a Snapback Save, hold `S` to dive.
- **Player 2:** `ArrowLeft`/`ArrowRight` move, `ArrowUp` to bounce/save, hold `ArrowDown` to dive.
- Additional noncombat keys: `Space`/`Enter` start or rematch, `Escape` pause/resume, `M` toggle audio; all visible in the UI. Neither player needs a mouse.
- **Delivery:** a self-contained **`index.html`** containing vanilla HTML/CSS/JavaScript and HTML5 Canvas. No CDN, framework, bundler, build step, external image/font/audio requests, or internet needed to play. Web Audio synthesized locally, silent fallback. No arbitrary code-line limit; favor readable small functions.
- **Canvas logical size:** 960×540; fit responsively with uniform scaling and letterboxing. Fixed 60 Hz simulation separated from `requestAnimationFrame` rendering.
- **No replacement of `project.godot` is necessary.** It belongs to the prior Godot setup; preserve the existing Git repository and other unrelated settings. `index.html` is the game entry point.
- **Source of truth:** `docs/GAME_DESIGN.md` (experience and match rules), `docs/PHYSICS_AND_CONTROLS.md` (numerical defaults and simulation contracts), `docs/ART_AND_AUDIO.md` (art direction), `docs/TEST_PLAN.md` (verification), `docs/IMPLEMENTATION_PLAN.md` (autonomous process), `docs/CODEX_GOAL.md` (completion objective).

## Priority order
1. Functional, fun, fair **two-player interaction** and immediate rematches.
2. Responsive fixed-step physics, readable bounce timing, stomp/counterplay, and reliable pit scoring.
3. A meaningful **Snapback Save** that allows a dramatic yet skill-based comeback.
4. The trampoline as a genuinely shared physical system (visible wave and bounded influence on the other player's bounce), not merely a decorative curve.
5. Original, confident visual identity and tight generated audio.
6. Thorough reproducible tests, real browser inspection when available, and itch.io-ready packaging.

## Nonnegotiable design guardrails
- Do **not** add levels, alternate arenas, a ball/hoop mode, story screens, cutscenes, online features, shops, bot opponents, ads, or feature creep.
- Keep the screen understandable within five seconds of the first match. The game should not force users through a long tutorial or wait for long countdowns.
- Make outcomes physically legible: show anticipation and impact, telegraph comeback bumpers, and never create invisible/random knockback.
- Treat accessibility as a design feature: high contrast, distinguish players by shape as well as color, clear pause/mute/reduced-motion settings, and restrained screen shake/flash.
- Avoid generic generated UI aesthetics: no glassmorphism, gradient dashboard cards, neon-everywhere, emoji decorations, mismatched icon packs, or random particle storms.
- **All tunable numbers** go into a named top-level `CONFIG` object (grouped by feature); no magic physics constants in logic. `CONFIG` defaults come from the physics document and are starting hypotheses to tune based on actual playtesting.
- Input must use physical `KeyboardEvent.code`, a held-key state map, and edge-triggered presses. Simultaneous keys must work as far as hardware permits. Ignore OS key repeat. Prevent scrolling for game keys; clear held keys on blur/visibility changes.
- Keep collision, scoring, and rendering distinct. Make the gameplay step callable from a deterministic test harness. Do not tie simulation speed to monitor refresh rate.
- Make round resolution idempotent: exactly one winner/point per knockout. Suppress repeated stomps during cooldown. Reset all per-rally ability state on each rally.
- No unsafe operations or silent destructive cleanup. Preserve Git history; do not push, publish, or commit unless explicitly authorized.

## Workflow
1. Read the docs and inspect existing files and Git status. If user content/conflicting implementations exist, protect them; report blockers rather than overwrite valuable work.
2. Get one complete playable rally working with real keyboard input before polishing UI.
3. Implement timing mastery, stomp, Snapback Save, shared trampoline wave, short best-of-five match, then polish and tests. Iterate on the **same main game**, not unrelated modes.
4. Run automated tests after meaningful changes; exercise actual browsers and both local players wherever tooling permits. A test is only 'passed' if genuinely executed.
5. Update `docs/DEV_LOG.md` as changes occur. Put actual results and limitations in `docs/QA_REPORT.md`; never fabricate playtest data, FPS, or browser passes.
6. Stop when the explicit `docs/CODEX_GOAL.md` acceptance criteria are supported, or when blocked. Identify what still needs a person with a real keyboard.

## Completion standard
Starting a match, simultaneous WASD/arrow movement, skill-based bounce tiers, dives, stomps, shared trampoline motion, one-use Snapback Saves, pits, best-of-five scoring, pause, audio toggle, results, instant rematch, responsive drawing, and reliable tests **all work**. No known critical startup, scoring, or collision bugs. One complete polished arena is better than several incomplete ideas.



---

# FILE: README.md

# Snapback

**One trampoline. Two rivals. Every fall is a chance for a comeback.**

Snapback is a fast, local two-player browser game built for the **Bounce Back** theme. Two elastic little athletes continually bounce on one shared trampoline. Build height with well-timed bounces, dive onto the other player to send them toward a pit, and time a once-per-rally **Snapback Save** off a side bumper when nearly knocked out. First to three rally wins takes the match.

**Status:** Design and Codex instructions supplied; `index.html` will be generated by Codex. Do not describe the game as implemented before verifying it.

## Controls

| Action | Player 1 — Coral | Player 2 — Mint |
|---|---|---|
| Move left/right | `A` / `D` | `←` / `→` |
| Timed bounce | `W` (tap before trampoline contact) | `↑` (tap before contact) |
| Dive | Hold `S` while airborne | Hold `↓` while airborne |
| Snapback Save | `W` while approaching a lit recovery bumper | `↑` while approaching a lit recovery bumper |

`Space` or `Enter`: start / rematch. `Esc`: pause / resume. `M`: mute / unmute. Controls are displayed in-game. The game is designed for **two people at one keyboard**; some physical keyboards cannot detect every key combination, so test on the intended hardware.

## How a match works
1. Both players auto-bounce on a shared trampoline; no jump key is needed to leave the surface.
2. Time a bounce press shortly before landing for a stronger launch, building through five bounce tiers.
3. Steer in midair and hold dive to descend faster. A clean landing on the opponent from above knocks them sideways toward a pit.
4. If knocked toward the edge, use your one **Snapback Save** per rally at the elastic bumper to recover and counterattack.
5. Falling below the screen scores one point for the opponent. First to **three** points wins. Rematch immediately.

The shared trampoline visibly bends and carries small, meaningful waves between the players. Late rallies enter telegraphed **Overdrive**, reducing the safe trampoline width to discourage endless stalling.

## Run (after Codex implements the game)

Open `index.html` in a modern desktop browser. There should be **no build step**, server dependency, or download required. For realistic embedded testing, also test through a local static server and the itch.io HTML5 embed. The game will scale to fit its iframe while maintaining a 960×540 logical aspect ratio.

## Project layout

```text
hackathon/
├── index.html                  # Complete shipped game (generated by Codex)
├── AGENTS.md                   # Instructions for Codex
├── README.md                   # This file
├── docs/
│   ├── GAME_DESIGN.md          # Rules and player experience
│   ├── PHYSICS_AND_CONTROLS.md # Detailed simulation and input contracts
│   ├── ART_AND_AUDIO.md        # Visual/audio direction
│   ├── TEST_PLAN.md            # Reproducible verification
│   ├── IMPLEMENTATION_PLAN.md  # Autonomous delivery order
│   ├── CODEX_GOAL.md           # One long-running objective
│   ├── PLAYTEST_SCORECARD.md   # Real two-person testing form
│   ├── QA_REPORT.md            # Actual execution evidence
│   ├── DEV_LOG.md              # Progress and decisions
│   └── RELEASE_CHECKLIST.md    # Publishing preparation
└── [existing Git / Godot files may remain unused]
```

## Philosophy
- **First five seconds:** players can start competing without studying instructions.
- **Skill and comedy:** simple inputs, clear results, fast knockouts, dramatic recoveries.
- **No dead time:** quick rally resets and instant rematches; no long cutscenes.
- **One polished game:** no levels, unlock grind, story, account systems, or online play.
- **Distinctive art:** ink-dark retro sports-poster style; original procedurally drawn shapes and synthesized audio.
- **Truthful QA:** automated tests and browser checks documented, never invented.

## Credits and release
Code and visuals should be newly authored for this project. Any addition of third-party material must be documented with its license; the default design requires **no external assets**. Do not publish without the user's permission. Itch.io accepts a single self-contained HTML file or a ZIP containing `index.html` at the root; test the final embedded build before announcing release.



---

# FILE: docs/ART_AND_AUDIO.md

# Snapback — Art Direction, UI, Animation, Audio

## 1. Visual statement

**Visual identity:** handcrafted kinetic sports poster: flat ink-dark backdrop, warm paper-white typography, two unmistakable athlete colors, elastic movement, and carefully placed geometric illustrations. Deliberate layout and animation over generic neon, glass panels, stock icons, emoji, or gradients for their own sake.

**Stylistic references (descriptive, not a request to copy):** vintage gymnasium posters, silk-screened sports graphics, graphic novel impact typography, clean arcade cabinets, playful motion design. Produce **original** artwork in Canvas shapes/paths. No external images, fonts, textures, or audio files required.

## 2. Color tokens

| Role | Hex | Use |
|---|---|---|
| Ink | `#151B20` | Arena and title ground |
| Deep ink | `#0C1114` | Pit silhouettes, shadow shapes |
| Warm ivory | `#F6EEDF` | Primary typography, net highlights |
| Coral | `#D86751` | Player 1, score accents, recovery effect |
| Mint | `#8DD0CF` | Player 2, score accents, recovery effect |
| Gold | `#EEDC96` | Elastic trampoline, perfect timing cue |
| Steel | `#65727B` | Secondary labels and quiet arena markings |

Do not use pure glowing cyan as an everything-accent. Differentiate players by **silhouette, facial mark, trail direction, and icon shape** in addition to color. Meet usable contrast; do not rely on color alone for required instructions.

## 3. Layout and hierarchy (logical 960×540)

- **Playfield:** occupies central 960×540; trampoline across bottom middle, pits clearly readable.
- **Score:** central, top 12–82 px; giant `1 : 2` mechanical digits in ivory; small `FIRST TO 3` label and subtle rally indicator.
- **Player identifiers:** lower left and right or beside score; small `CORAL · WASD` and `MINT · ARROWS`, readable without covering action.
- **Tier feedback:** five small outlined pips above each avatar; fill according to bounce tier. A tiny outlined save/return symbol shows a remaining Snapback charge. In reduced-motion mode, still clear.
- **Microcopy:** one concise line of instruction on title / first rally; never occupy more than 10% of gameplay height for tutorial text.
- **Notice typography:** `PERFECT!`, `STOMP!`, `SNAPBACK!`, `OVERDRIVE`, and `POINT!` appear for less than 0.6 s and do not obscure silhouettes or hazard regions.
- **Pause and match-over:** opaque, deliberate typography rather than a stack of dashboard cards. Keep scoreboard visible as context.
- **Window resizing:** uniform scaled viewport with letterboxing; retain sharp appearance at devicePixelRatio 1–2; avoid blur and misaligned click zones. Two-player play is desktop-first.

## 4. Character illustration

Not plain rectangles in the final game. Construct original compact characters from procedural shapes:
- Body proportions about 28×40 collision dimensions; body illustration may have flexible squash-and-stretch.
- Coral athlete: angular shoulders / off-center forehead mark, warm color, minimal expression.
- Mint athlete: slightly rounder head/side stripe, cool color; equally readable.
- Eyes react to falling, attacking, and comeback. A face is fun but not necessary for collision comprehension.
- Motion trails are short directional dashes, not giant glowing particle clouds.
- On high-speed descent: narrowed silhouette with tiny speed strokes. On stomp: impact star and small shock ring; keep the other player's trajectory visible.

**Animation timings:** Landing squash about 4–6 ticks, rebound stretch 5–8, stomp impact freeze about 2–4 **presentation** ticks (never accidentally disable important simulation input), score transition ~0.6 s, winner transition <1 s. These are starting values to tune.

## 5. Trampoline treatment

- A visible elastic gold/ivory cord with darker under-mesh and anchor posts.
- Render from the authoritative collision samples with gentle shape interpolation; visible position must closely match collision geometry.
- Landing visibly depresses local net; damped wave travels toward the other player.
- Place a tiny subtle impact ring exactly where the feet contact, not arbitrary screen-center particles.
- During Overdrive, end-posts contract inward with physical motion and clearly visible dashed warning marks. Collision endpoints and art must agree.

## 6. Bumpers and pits

- Pit entrances are dark and unmistakable; boundary guides make risk legible without heavy UI.
- Recovery bumpers resemble elastic vertical bands on the outer left and right. They glow/pulse **only when a player's charge is available and a save is physically possible**.
- Use small `[W]` or `[↑]` prompts near the appropriate avatar when a player is about to contact a bumper. They must not distract the other player.
- On a successful save: short inward motion line, `SNAPBACK!`, warm accent, unique sound. Do not obscure where the opponent is.

## 7. Screen specs

### Title screen
- Dominant custom-drawn `Snapback` wordmark in warm ivory, with one subtly bent letter/underline echoing elastic tension.
- A small **live animated trampoline demonstration** behind the wordmark, generated from the game's physics or a simple noninteractive illustration; no auto-advancing menus.
- Hero tagline: **“Every fall is a chance for a comeback.”**
- Two big columns labeled `CORAL / WASD` and `MINT / ARROWS`; move, timed bounce, dive keys illustrated as crisp text/keycaps.
- One large, legible `SPACE / ENTER — PLAY` instruction; `M` sound; optional `V` reduced motion.
- The match should start on the first key press, not after a multi-screen flow.

### In-game HUD
- Score centered; small player tier indicators; controls cue first few seconds only.
- No panels covering the arena, health meters, rotating objectives, or unnecessary numbers.

### Paused
- `PAUSED`, `ESC — RESUME`, `M — SOUND`, `V — REDUCED MOTION`; hold physics and audio scheduling appropriately. Dark overlay, no glass blur.

### Match over
- Huge `CORAL WINS` or `MINT WINS`, scoreboard, short tag line, `SPACE / ENTER — REMATCH` visible immediately; no forced delay. Optional session match-win counters in a small footer if implemented reliably.

## 8. Original audio

Synthesize short, restrained sounds using Web Audio oscillators and gain envelopes:
- Light trampoline contact: short woody/plucked note, pitch increases slightly with tier.
- Perfect bounce: clean two-note rising interval, never shrill.
- Dive: subtle wind hiss or pitch sweep while descending (throttled; no continuous loud generator).
- Stomp: muted punch + low drum transient, not realistic violent audio.
- Snapback Save: rubber twang with rising tone, unmistakably different from ordinary landing.
- Score: brief staccato brass-like chord; winner: short two-to-three-note payoff.
- Overdrive: a subtle rhythmic motif; avoid full background music if it complicates the build.

User gesture must initialize or resume AudioContext; never rely on sound autoplay at page load. Audio must work gracefully when blocked/unavailable, and no sound should play when muted. Avoid audio leaks: disconnect/stop short nodes, limit simultaneous voices, and respect pause.

## 9. Motion/accessibility

- Keep 60 Hz physics constant. Reduced motion disables screen shake, decorative flashes/trails and excessive wobble, not the meaningful trampoline state itself.
- All important events receive readable visual feedback even when muted.
- Keep camera stationary except minimal optionally disabled shake; never zoom during a competitive landing.
- Avoid bright fullscreen flash, strobe, or prolonged shake. No surprise audio on load.
- The scoreboard, instructions, and recovery availability must remain legible on common laptop browser dimensions.

## 10. Visual acceptance

Codex must inspect real browser screenshots or rendered gameplay if available: title, active rally, perfect bounce, stomp, Snapback Save, pause, point, and winner. Compare spacing, clipping, contrast, text size, silhouette overlap, and pit clarity. If screenshots or visual inspection cannot be executed in its environment, say so in `docs/QA_REPORT.md` and leave a precise manual inspection checklist. Passing source-code inspection **does not prove visual polish**.



---

# FILE: docs/CODEX_GOAL.md

# Codex Goal — Build the Complete Two-Player Snapback Game

## Your objective

Develop **Snapback** into a complete, distinctive, polished, highly replayable, **local two-player one-keyboard browser game** for the theme **Bounce Back**.

This is a **sustained autonomous objective**, not a request for a planning memo, an isolated prototype, or individual prompts. Work through audit, implementation, playability, testing, tuning, visual/audio polish, and release preparation in this repository without asking for routine approval after each stage. Keep reporting actual progress and blockers. Do not push, publish, or make Git commits without permission.

## First: read the source-of-truth files

Read these files completely before writing gameplay code:

- `AGENTS.md`
- `README.md`
- `docs/GAME_DESIGN.md`
- `docs/PHYSICS_AND_CONTROLS.md`
- `docs/ART_AND_AUDIO.md`
- `docs/TEST_PLAN.md`
- `docs/IMPLEMENTATION_PLAN.md`
- `docs/PLAYTEST_SCORECARD.md`

Inspect the actual repository and Git status. The older Paradox Heist and single-player Snapback specifications are obsolete. If old code or documents remain, keep valuable user data safe and reconcile conflicts; do not silently overwrite uncommitted work. `project.godot` may still exist from the previous setup but **do not implement Snapback in Godot** under this specification.

## Deliverable

Create a complete, self-contained **`index.html`** playable without external resources or build tools. Use original HTML, CSS, Canvas 2D rendering, vanilla JS, and optional Web Audio synthesis. Logical stage 960×540, uniformly scaled to fit browser/itch.io embed. Run fixed 60 Hz simulation independent of display refresh. Do not require Internet access or an installed npm project to play.

Keep functions small and code readable; ignore any old arbitrary 450-line cap. Place all tuneable values in a grouped `CONFIG` near the top of the script. Separate simulation from rendering and input. Make simulation state injectable/testable.

## The game — exact creative direction

Two small expressive athletes bounce automatically on **one genuinely shared deformable trampoline** in a single 2D side-view arena. Two pits sit outside its edges. **Player 1 (coral)** controls A/D steering, W timed bounce/recovery, S dive. **Player 2 (mint)** uses left/right arrows, up timed bounce/recovery, down dive. They compete to stomp each other off the trampoline and into the pits.

- Bounce timing raises one of five bounce tiers and creates higher jumps; poor timing lowers tier but never disables basic bouncing.
- Dive allows aggressive aerial attacks and stronger membrane waves; it also carries risk.
- A *real stomp from above* applies directional sideways knockback and rewards the attacker with a rebound. Side collisions are bumps, not free stomps.
- Each player can perform **one timed Snapback Save per rally** by reacting at either pit-side elastic bumper, launching back into the arena. The save must be physical, visible, possible, and missable. No free teleports or infinite saves.
- When players land, the shared membrane deforms and transmits visible, bounded waves that can slightly affect the other player's launch.
- If one player falls completely below the screen, the other receives exactly one point. First to **three** points wins; short auto-restarts and immediate rematches. Simultaneous KO = quick no-score replay.
- To prevent stalling, introduce a readable late-rally Overdrive narrowing of the trampoline *if it improves fairness during testing*.
- No levels, bots, online multiplayer, alternative sports modes, health bars, unlocks, skins, progression, item drops, story campaign, advertising, or unrelated game mechanics.

## Hook and delight

Aim for the players to start and understand the objective within seconds. The first rally should create immediate movement and risk. The critical engagement loop is: **anticipate landing → time perfect bounce → gain height → dive/stomp → attempt save → counterattack → score → rematch**.

Make every input give crisp feedback, and make the most exciting moments emerge from real physics interactions, not random scripted set pieces. Ensure players can react to near misses and can understand why they won or lost. Failures should resolve quickly without removing players from the match for long periods.

Do not confuse adding more features with increasing fun. Tune timing windows, gravity, steering, knockback, collision shapes, save geometry, and rally pacing based on tests. Report the exact CONFIG changes and reasons in the development log.

## Visual style — original and not generic

Follow `docs/ART_AND_AUDIO.md` closely. Use an original **retro kinetic sports-poster** identity: ink `#151B20`, ivory `#F6EEDF`, coral `#D86751`, mint `#8DD0CF`, gold trampoline `#EEDC96`. Draw playful, expressive non-rectangular silhouettes and purposeful typography/geometry. Create a clearly visible shared net that bends where players land. Show tier pips, remaining save charge, readable score, clean title, pause, winner/rematch, precise `PERFECT`, `STOMP`, `SNAPBACK` cues.

Avoid generic software-dashboard cards, excessive neon gradients, glassmorphism, emoji icons, random decoration, noisy particles, and inconsistent text hierarchy. Audio must be original Web Audio synthesis, user-gesture enabled, muted when asked, and optional for gameplay. Add reduced motion that removes unnecessary shake/flash without changing physics.

## Mandatory technical integrity

- Real fixed-step accumulator and correctly handled tab/focus pauses.
- Independent simultaneous keyboard input via `KeyboardEvent.code`, `keydown`/`keyup`, and edge-triggered timing input; no repeated key triggers or arrow-page scrolling.
- Stable collisions at fast movement: players cannot tunnel through net or one another.
- Predictable stomp direction, neutral resolution for ambiguous contacts, anti-juggle immunity.
- Exact point accounting; full rally reset; winner state cannot be scored after completion.
- Bumpers can save either player on either side, once per rally, only on valid timing.
- Trampoline graphics correspond to actual collision geometry; wave coupling remains bounded.
- Accessible, responsive drawing at common desktop and embedded sizes.
- Works without external files, fetch calls, third-party libraries, or system-wide installations.

## Test it — do not make claims without evidence

Execute `docs/TEST_PLAN.md`. Build actual deterministic unit/simulation scenarios using the implementation's real functions; include bounce boundaries, stomp both directions, net stability, saves both bumpers for both players, simultaneous knockouts, reset, pause/focus, controls, and full match simulation. Keep a repeatable testing method without adding a production dependency.

Where tooling allows, **open the actual game in a browser**, interact with it using automated or real keyboard input, inspect screenshots, look for clipping and console errors, check audio and resizing, and test an itch-style embedded view. Test multiple render frequencies as possible. Playtest with two real humans only if truly available; never fabricate such a test or subjective results.

Record exact tests, outcomes and limitations in `docs/QA_REPORT.md` and changes/tuning in `docs/DEV_LOG.md`. Mark unsupported tasks NOT RUN or BLOCKED. Passing syntax/automated tests does not prove the game is fun, beautiful, or universally keyboard compatible.

## Autonomous work policy

Proceed through `docs/IMPLEMENTATION_PLAN.md` autonomously. Test and repair before continuing. Prioritize serious gameplay defects before adding polish. Do not stop after the first minimally playable version or after a pretty title screen; finish the full match loop and refine it. Document blockers transparently and stop if necessary rather than inventing evidence.

No unrequested Git commit/push/publish, no unrelated file modifications, no replacing older code without first checking user changes, no downloads/paid assets, and no claims of guaranteed hackathon success.

## Acceptance criteria — require evidence

1. Starting `index.html` launches the complete game locally without missing dependencies.
2. P1 and P2 can simultaneously steer, time bounces, and dive with specified keys.
3. Normal and perfect bounces produce distinct, tested physical outcomes; tier progression and cooldowns work.
4. A shared net physically deforms and supports bounded wave interaction.
5. Stomps, side bumps, and knockbacks are directionally correct and fair; no duplicate hits.
6. A timed one-charge Snapback Save is possible at both pit bumpers for either player, and is not automatic/infinite.
7. Pits award one point correctly; a complete best-of-five match reaches a winner and immediately rematches.
8. Pause/resume, focus-loss protection, mute, reduced motion, and all visible controls work.
9. Title, gameplay, score, point, and match-over screens have a coherent handcrafted identity.
10. Browser resizing maintains the logical stage and readable UI.
11. Repeatable physics/scoring/input tests pass; no known critical/high issues remain.
12. Real browser, keyboard-hardware, visual, and two-human testing are executed **where available**, otherwise transparently listed as outstanding. There is no invented QA evidence.
13. README, progress log, and QA report accurately match the implemented project.
14. The project is ready to be reviewed for itch.io, but **not published**.

**Start by auditing the repo, build the core playable match, then keep iterating toward the completed experience. Do not build levels or new game modes. Finish with a concise verified report and any remaining human playtests.**



---

# FILE: docs/DEV_LOG.md

# Snapback — Development and Tuning Log

**Status:** Design files created; gameplay implementation pending.

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

- **Not started.**



---

# FILE: docs/GAME_DESIGN.md

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



---

# FILE: docs/IMPLEMENTATION_PLAN.md

# Snapback — Autonomous Implementation and Iteration Plan

This is **one sustained Codex project**, not a list of manual prompts. The goal document (`CODEX_GOAL.md`) authorizes Codex to carry out the stages below autonomously. The stages are **internal quality gates**; do not stop after each one unless blocked.

## Initial audit

1. Read every design document and `AGENTS.md`.
2. Inspect Git status, root files, previous experimental content, and available test/browser tools. Do not delete or overwrite valuable user work. Do not revive the retired Godot/Paradox Heist game.
3. Confirm the chosen deliverable: **one self-contained browser game in `index.html`**. The existing `project.godot` may remain unused.
4. Write initial observations and assumptions in `docs/DEV_LOG.md`.

## Stage A: Prove the core fun (highest priority)

- Render one arena and two distinct controllable player silhouettes.
- Fixed 60 Hz movement, gravity, steering, always-bouncing trampoline and pits.
- Correct simultaneous WASD/arrow input.
- Minimal center scoreboard, start/retry, and full rally reset.
- Make two humans able to play a short rally immediately. If human testing is unavailable, run browser/input tests and mark human fun **unverified**.

**Gate:** players can move and bounce simultaneously; single knockout produces exactly one point; first-to-three match can end and rematch.

## Stage B: Build the skill loop

- Timed bounce press with clear timing cue and five tiers; avoid mash/hold exploits.
- Descending dive; top-down stomp; side collisions; short anti-juggle protection.
- Correct loss/recovery physics and fair impulse directions.
- Tune CONFIG to keep all movement within the useful vertical field.

**Gate:** physics tests prove perfect vs missed bounce difference, correct stomps from both sides, and no high-speed pass-through.

## Stage C: The theme-defining comeback

- Implement **Snapback Save** at both side bumpers, one charge/player/rally.
- Add readable save-ready prompt, strict timing, launch inward/up, reset next rally.
- Ensure saves are possible when knocked toward the pits but can fail if mistimed.
- Implement coupled net waves so both players actually affect the same trampoline; cap interactions.

**Gate:** deterministic save tests pass on both sides for both players; no unlimited rescue; net remains stable over long simulation.

## Stage D: Pace and rematch polish

- Quick point freeze and instant rally reset; winner screen and rematch.
- Pause/resume, focus loss, mute, reduced motion.
- If rallies stall, add telegraphed Overdrive contraction; tune or omit if it produces unfair outcomes.
- Small screen-edge help that fades once players get moving, without clutter.

**Gate:** 50 scripted complete match resets stable; no repeated point award; no stale controls between rounds.

## Stage E: Designed visual and sonic identity

- Replace placeholder rectangles with original procedural athletes and deliberate title/HUD/winner layouts.
- Animate character squash/stretch and membrane deformations based on real state.
- Add concise generated audio, responsive and never required for gameplay.
- Tune typography, color contrast, visual timing, tiny effects, accessibility.
- Inspect screenshots at several viewport sizes when tools allow.

**Gate:** readable and cohesive; no invisible collisions, cut-off text, overflow, or obstructive screen effects. Visual inspection documented, not assumed.

## Stage F: Validation and release readiness

- Execute the full `TEST_PLAN.md`; fix critical/high defects, rerun regression.
- Browser check, resize check, pause/focus and keyboard chord check.
- Where possible test in real embedded browser conditions and prepare distribution instructions for itch.io.
- Finalize `README.md`, `DEV_LOG.md`, `QA_REPORT.md`, and any tunings; confirm one complete match loop works.

**Gate:** all objective, executable acceptance tests pass, and unsupported human/hardware tests are explicitly marked NOT RUN/BLOCKED. Report limitations; do not publish.

## Prioritization when something goes wrong

1. Restore ability to play from title to match result.
2. Repair unfair or nondeterministic collision/scoring behavior.
3. Repair Snapback Save and bounce timing.
4. Repair visuals/sound/accessibility.
5. Tune subtle effects and polish.

Do not bolt on new arenas, levels, multiplayer networking, complex menus, AI, or high-score progression to paper over a weak core loop. Refactor when necessary, but preserve project history.

## Iteration rule

**Inspect → implement → test → observe → retune → rerun regressions.** Maintain an honest record of what was tested. If no browser automation is available, state what happened and what needs manual verification rather than claiming visual or interaction checks passed.

## Stop criteria

Stop and present a final report only when:
- One complete match is functional and can rematch.
- All required mechanics and interface screens are finished and tested where possible.
- No known critical or high bugs remain.
- There is clear evidence for implemented mechanics and candid flags for human-only checks.
- Additional work would be cosmetic, unsupported by data, or unsafe without asking the user.

Do not claim the game is 'hackathon-winning'. Quality and user delight are objectives; judges and human players decide results.



---

# FILE: docs/PHYSICS_AND_CONTROLS.md

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



---

# FILE: docs/PLAYTEST_SCORECARD.md

# Snapback — Two-Person Playtest Scorecard

**Do not fill this out with imagined people or results.** A real playtest means two humans playing together on one physical keyboard with an observer taking notes. Codex should leave this document blank/NOT RUN when humans are not available.

## Session record

- Date and version/commit (if any): __________
- Browser / OS / hardware: __________
- Players' familiarity with arcade games: P1 ______ / P2 ______
- Observer: __________
- Physical keyboard rollover problems noticed? ______ (specify keys)
- Audio enabled? ______ Reduced motion? ______

## First 30 seconds

| Question | Observation / exact moment |
|---|---|
| Could both players start without explanation? | |
| Were WASD and arrows understood immediately? | |
| Could they identify who was coral and mint? | |
| Did they discover basic auto-bounce? | |
| Did anyone perform a perfect bounce? | |
| Did they understand what the perfect cue meant? | |
| Was the first stomp or near miss legible? | |

## Match enjoyment (ask after they finish)

Rate each 1–5 (1 poor, 5 excellent). Avoid leading questions.

| Prompt | P1 | P2 |
|---|---|---|
| My controls felt responsive. | | |
| I could understand why I gained or lost height. | | |
| Hits and knockouts felt fair. | | |
| I knew when a Snapback Save was available. | | |
| I enjoyed the match. | | |
| I would play a rematch. | | |

Additional observations:
- Number of rallies / approximate match duration: __________
- Snapback Save attempted? ______ Succeeded? ______ Why / why not? __________
- Any period where nothing meaningful was happening? __________
- Did either player voluntarily request a rematch? ______
- Funniest / most surprising emergent moment: __________
- Most frustrating moment: __________
- Did either player complain about a confusing stomp or inconsistent bounce? __________

## Behavioral evaluation

- **Excellent signal:** both players quickly understand controls, blame/take credit for outcomes, notice recoveries, and spontaneously request rematch.
- **Warning signal:** players only move randomly, think stomps are chance-based, or cannot tell when to press bounce.
- **Critical signal:** players frequently lose control, cannot use simultaneous keys, or matches drag without interaction.

## Design actions derived from real feedback

1. __________
2. __________
3. __________

Retest after adjusting mechanics. No single playtest proves that the game will win a competition or delight all players.



---

# FILE: docs/QA_REPORT.md

# Snapback — QA Report

**Status: NOT RUN — development has not begun.**

Codex: update this document with **actual** commands, logs, screenshots and results after implementation. Never claim a test passed without executing it. Do not claim human playtests unless people actually played.

## Build and startup

- Runtime file exists: NOT RUN
- Opened locally in browser: NOT RUN
- JavaScript/console: NOT RUN
- Dependencies/network: NOT RUN

## Automated simulation tests

| Test category | Result | Actual command / evidence | Notes |
|---|---|---|---|
| Input and simultaneous controls | NOT RUN | | |
| Timed bounce tiers | NOT RUN | | |
| Trampoline stability and waves | NOT RUN | | |
| Dive and stomp | NOT RUN | | |
| Snapback Save (both roles/sides) | NOT RUN | | |
| Pit KO / scoring / simultaneous KO | NOT RUN | | |
| Reset, pause, focus loss | NOT RUN | | |
| Overdrive | NOT RUN | | |
| Full match + rematch | NOT RUN | | |
| Long-run stability | NOT RUN | | |

## Visual and browser verification

| Scenario | Result | Evidence |
|---|---|---|
| Title and controls | NOT RUN | |
| Gameplay HUD / resizing | NOT RUN | |
| Perfect bounce / stomp feedback | NOT RUN | |
| Save bumpers / recovery indicator | NOT RUN | |
| Point and winner screens | NOT RUN | |
| Mute / reduced motion | NOT RUN | |
| Browser iframe / itch-style embedding | NOT RUN | |

## Human testing (distinct from browser automation)

**NOT RUN**. Requires two actual people using one keyboard. Refer to `docs/PLAYTEST_SCORECARD.md`.

## Known bugs / blockers

- Not evaluated yet.

## What remains to verify before publication

- Two humans on intended physical keyboard; graphics and sound in actual browser; itch.io embed; performance on target laptop; user approval to upload/publish.



---

# FILE: docs/RELEASE_CHECKLIST.md

# Snapback — Browser Release Checklist

Complete **only after implementing and testing** the actual game. This document does not authorize publishing.

## Code / gameplay
- [ ] `index.html` contains all runtime code/styles, opens standalone.
- [ ] One working two-player match (P1 WASD, P2 arrows).
- [ ] Keyboard input, timed bounce, dive, stomp, Snapback Save, wave coupling, pits, three-point win, pause, mute, rematch pass real tests.
- [ ] No known critical/high bugs.
- [ ] No calls to external fonts, CDNs, analytics, remote scripts, or images.
- [ ] Docs match actual behavior.

## Presentation
- [ ] Title controls legible at typical laptop size.
- [ ] Score, tiers, save charge, pits, and players visually distinct.
- [ ] Sound begins only after gesture and can be muted.
- [ ] Reduced motion works.
- [ ] Resize and iframe work without aspect distortion.
- [ ] Title, rally, stomp, save, pause, point, winner screenshots inspected if tools available.

## QA / human testing
- [ ] Actual test results are in `docs/QA_REPORT.md`.
- [ ] Two-person playtest performed, or plainly marked NOT RUN.
- [ ] Test physical keyboard for common simultaneous P1/P2 key chords.
- [ ] Real Chromium-based browser tested; another browser if available.
- [ ] No unexpected page scrolling, sticky input after tab switch, or repeated scoring.
- [ ] Match rematch confirmed.

## itch.io

itch.io supports a **single self-contained HTML file** upload, or a ZIP containing `index.html` at archive root. If using ZIP, include no development secrets, `.git/`, docs, or unnecessary artifacts. Configure the game as an HTML game with an embed around 960×540 (responsive allowed). Verify the actual iframe after upload **only when the user authorizes upload**. Review fullscreen settings; avoid focus/keyboard conflicts.

Do **not** upload/publish or push code without explicit user approval.



---

# FILE: docs/TEST_PLAN.md

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

