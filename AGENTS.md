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
