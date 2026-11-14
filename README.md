# Snapback

**One trampoline. Two rivals. Every fall is a chance for a comeback.**

Snapback is a fast, local two-player browser game built for the **Bounce Back** theme. Two elastic little athletes continually bounce on one shared trampoline. Build height with well-timed bounces, dive onto the other player to send them toward a pit, and time a once-per-rally **Snapback Save** off a side bumper when nearly knocked out. First to three rally wins takes the match.

**Status:** The complete single-file game is implemented. Deterministic simulation tests and actual browser DOM checks have been executed; see `docs/QA_REPORT.md` for the current evidence and remaining validation. Human two-person playtesting, physical-keyboard rollover, audible quality, and the actual itch.io embed remain **NOT RUN**.

## Controls

| Action | Player 1 — Coral | Player 2 — Mint |
|---|---|---|
| Move left/right | `A` / `D` | `←` / `→` |
| Timed bounce | `W` (tap before trampoline contact) | `↑` (tap before contact) |
| Dive | Hold `S` while airborne | Hold `↓` while airborne |
| Snapback Save | `W` while approaching a lit recovery bumper | `↑` while approaching a lit recovery bumper |

`Space` or `Enter`: start / rematch. `Esc`: pause / resume. `M`: mute / unmute. `V`: toggle reduced motion. Controls are displayed in-game. The game is designed for **two people at one keyboard**; some physical keyboards cannot detect every key combination, so test on the intended hardware.

## How a match works
1. Both players auto-bounce on a shared trampoline; no jump key is needed to leave the surface.
2. Time a bounce press shortly before landing for a stronger launch, building through five bounce tiers.
3. Steer in midair and hold dive to descend faster. A clean landing on the opponent from above knocks them sideways toward a pit.
4. If knocked toward the edge, use your one **Snapback Save** per rally at the elastic bumper to recover and counterattack.
5. Falling below the screen scores one point for the opponent. First to **three** points wins. Rematch immediately.

The shared trampoline visibly bends and carries small, meaningful waves between the players. Late rallies enter telegraphed **Overdrive**, reducing the safe trampoline width to discourage endless stalling.

## Run

Open `index.html` directly in a modern desktop browser, then press `Space` or `Enter`. There is **no build step, server requirement, dependency installation, or runtime network request**. Both players use the same keyboard.

The 960×540 logical stage scales uniformly with letterboxing. `Esc` pauses/resumes; losing focus pauses and clears held inputs. Audio initializes only after a real key/pointer interaction and falls back to silence if Web Audio is unavailable. Mute and reduced motion do not change the physics.

## Optional developer checks

Playing needs only a browser. With an existing Node.js 20.11+ runtime (checks here used Node 24.22.1), the dependency-free checks can be run from the repository root:

```powershell
node --test tools/test-snapback.mjs
node tools/browser-check.mjs --quick
node tools/browser-check.mjs
node tools/browser-check.mjs --edge
```

The simulation harness loads the actual inline game logic. Browser checks use an already-installed desktop Chrome/Edge executable; `SNAPBACK_BROWSER` can identify another existing compatible executable. The full browser runner creates a temporary localhost server for iframe checks and closes it afterward; this is a development check, not a requirement to play. Logs and captures are ignored under `.godot/snapback_browser/`. These tools do not install packages or publish anything.

Browser automation does not establish physical keyboard rollover, audible sound quality, subjective fun, or human match duration. Complete the three two-person matches in `docs/PLAYTEST_SCORECARD.md` on the intended keyboard before making those claims.

## Project layout

```text
hackathon/
├── index.html                  # Self-contained playable game
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
The game uses original Canvas-drawn visuals and local Web Audio synthesis, with system font fallbacks. No external images, fonts, audio, frameworks, or runtime downloads are required. Any future third-party material must be documented with its license. Do not publish without the user's permission. Itch.io accepts a single self-contained HTML file or a ZIP containing `index.html` at the root; test the final embedded build before announcing release.

## Local review package

The prepared local artifact is `builds/Snapback-review.zip`. It contains only `index.html` at the ZIP root; its bytes were checked against the current runtime. It is ignored by Git and has not been uploaded. The original dormant Godot/export/VS Code configuration remains unchanged.
