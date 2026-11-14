# PARADOX HEIST — Codex-ready design kit

This folder contains **design and coding instructions, not a playable game**.

- `AGENTS.md` — Short, durable instructions for Codex. Replace/update the `AGENTS.md` at your existing Godot project root, after reviewing your custom instructions.
- `docs/GAME_DESIGN.md` — Canonical game vision, mechanics, strict Echo replay/reset rules, 8 levels, story, UX, visuals, architecture, scope.
- `docs/TEST_PLAN.md` — Testing and completion checklist.
- `docs/CODEX_PROMPTS.md` — Fourteen sequential build milestones (0 through 14) and bug-fix prompt.

## Install into your existing Godot project
1. **Back up your existing `AGENTS.md`** (if you want to preserve personal rules) and inspect the provided file before replacing or merging. Do not overwrite `project.godot`.
2. Copy `AGENTS.md` into the same directory as your existing `project.godot`.
3. Copy the `docs/` directory there as well.
4. Keep your Godot project as-is; this kit does **not** include any engine-generated project files or gameplay code.
5. Stage and commit the new design files after verifying them.
6. Paste only the **Milestone 0** prompt into Codex. Inspect its read-only architecture proposal. Then start Milestone 1.

## Notes
The browser version should use Godot 4 Compatibility and the default single-threaded Web export, with a release ZIP whose root contains `index.html`. Test real browser exports early after the first playable level if possible. Actual 60 FPS depends on hardware and scene optimization.

These plans are a creative specification, not tested implementations. They can be modified after playtesting, with deliberate changes to the GDD and matching test cases.
