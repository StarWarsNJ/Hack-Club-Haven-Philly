# PARADOX HEIST — Codex repository guidance

## Project
A complete, single-player, 2D top-down time-loop puzzle-action game in Godot 4, written in typed GDScript. Intended for Windows and itch.io HTML5 (WebGL 2). The game is fictional, playful, non-graphic, and uses abstract sci-fi systems rather than real-world security mechanics.

## Source of truth
- `docs/GAME_DESIGN.md`: gameplay rules, story, world, UI, level specs, and scope.
- `docs/TEST_PLAN.md`: expected behavior and verification scenarios.
- `docs/CODEX_PROMPTS.md`: ordered milestones; implement only the requested milestone.
If requirements conflict, ask before changing the core loop/echo contract. Keep this document short; don't duplicate the whole design here.

## Tech and architecture
- Godot 4 standard build; GDScript only; Compatibility renderer; no C# or native extensions.
- Main input: keyboard; mouse optional for menus. 60 physics ticks/second; target smooth 60 FPS.
- Top-down single-screen levels. Use `CharacterBody2D` for live player; visual/kinematic projections for recorded Echoes.
- Game logic (timing, recording, playback, switches, mission state) must be independent of presentation (HUD, particles, sound, animations).
- Use typed GDScript, signals, reusable scenes/resources, descriptive names, and small cohesive scripts.
- Store tunable values in clearly named constants or resources. Avoid circular autoload dependencies.
- Make fixed-tick time-loop playback deterministic and testable; recorded Echo poses are authoritative; no ghost physics re-simulation.
- Echoes do not collide with world, hazards, or each other; they activate only specifically Echo-compatible devices and replay accepted actions.
- All mission-mutating world state resets to its baseline between loops. Recorded Echo tapes persist until replaced or mission exit.

## Workflow and permissions
- Read relevant files and project design sections before changing an area. Scope work to one milestone.
- Preserve working scenes, scripts, and any user-authored files. Do not delete, overwrite unrelated work, or run destructive shell commands.
- Do not install packages, download third-party assets, introduce plugins, use online APIs, publish, or push to GitHub without explicit permission.
- No external asset with uncertain license. Placeholder/vector/procedural art is acceptable early; document needed replacements.
- Do not create Git commits unless asked; report a suggested commit message after a verified milestone.
- Run relevant checks (Godot editor import/parse, headless startup, tests when available). If Godot executable is inaccessible, explain exactly what you could not test; never claim unobserved success.
- For milestone output, report changed files, gameplay behavior, checks and observed results, known issues, and a manual test checklist. Stop, do not start the next milestone.

## Quality bar
- Fun, readable, accessible, responsive. No confusing rewind behavior or hidden timing rules.
- FPS is a target, not a guarantee. Avoid unnecessary `_process` polling; use events and fixed tick logic where appropriate.
- Pausing/menus must freeze mission clocks. Browser-focus loss should pause rather than consume time.
- Clear visual distinctions for live player versus four Echo slots, also labeled by numbers, not color alone.
- Every introduced mechanic needs an in-game teaching moment and at least one solvable level.
- A feature is not 'done' until it is playable and manually verifiable; tests cannot substitute for gameplay inspection.

## Current phase
Follow the current task prompt. Do NOT build the full game in one pass. Begin with docs/project skeleton and a tiny vertical slice, then expand milestone by milestone.
