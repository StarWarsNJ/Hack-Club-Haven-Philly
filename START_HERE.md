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
