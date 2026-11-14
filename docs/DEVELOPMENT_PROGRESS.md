# PARADOX HEIST development progress

Updated: 2026-11-13. Goal scope: Milestones 0–13 in order. Milestone 14/release is excluded.
Local Git checkpoints are explicitly authorized by the current Goal. No third-party dependencies, publishing, or remote pushes.

## Status conventions
Implementation/automated validation can be complete while human acceptance remains UNVERIFIED. No entry in this log claims hands-on gameplay, visual/audio inspection, Windows export, browser export, or 60 FPS unless explicitly evidenced.

## Milestone 0 — completed audit (read-only)
- Read AGENTS.md, GAME_DESIGN.md, CODEX_PROMPTS.md, TEST_PLAN.md; inspected both startup scenes, project settings, exports, input map and clean Git status.
- Godot executable: C:/Users/aryan/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64.exe. Version check: 4.7.2.stable.official.ed1daf0bf.
- Architecture: persistent app shell; mission-local single fixed-tick coordinator; immutable pose tapes; non-colliding Echo projections; stable device IDs; aggregate pad occupancy; baseline world reinstantiation; presentation separated from logic; versioned local progress later.
- Tick convention: 0–1799 samples, initial spawn separate, 600 samples = 10 seconds, expired Echoes contribute no presence/events. Gate output after movement affects the next movement step. Record these boundaries in tests before gameplay expansion.
- Risks: gate close overlap; pause/discard confirmation; exact pulse targeting; 0.16s dash quantization; reset leaks; browser persistence/audio/focus. Preserve the strict Echo contract. Resolve only non-core implementation details autonomously; ask if a true core-rule conflict blocks implementation.
- Audit itself changed no files and had no checkpoint. This entry records it as part of Milestone 1.

## Milestone 1 — implementation and automated checks complete
- Reusing scenes/main.tscn UID; preserving root main.tscn and existing project/renderer/export settings.
- Adding reusable native UI, keyboard menu routes, functional mixer sliders, help and pausable M1 placeholder. No gameplay yet.
- Files: scenes/main.tscn; scenes/ui/{main_menu,settings,help}.tscn; scenes/game/mission_session.tscn; scripts/core/{app_controller,mission_controller}.gd; scripts/ui/{ui_factory,main_menu,settings,help}.gd; scripts/tests/test_shell.gd; tools/validate.mjs; this log. Generated script UIDs are tracked, .godot metadata is ignored.
- Validation: tools/validate.mjs using existing bundled Node and configured Godot console executable: PASS import, PASS startup (120 frames), PASS test_shell.gd, all exit 0 with zero diagnostics under normal Godot access. Test exercises menu/settings/help/mission routing, mute/volume and pause/resume/return.
- Environment: sandbox blocked certificate/editor data access; initial GUI import timed out. Console executable plus normal access completed cleanly. No security settings changed. Temporary fallback editor metadata moved under ignored .godot/validation.
- Human keyboard/mouse, visual/audio, resize and actual browser checks remain UNVERIFIED. No Echo/gameplay code in this checkpoint.
- Checkpoint BLOCKED: git add failed with Permission denied writing .git/objects/89/b20c233e961dd39d9326777923e96f92b9b382, including the normal-access attempt. No commit exists for this milestone yet; nothing is staged. Read-only ACL inspection shows explicit deny entries for the automation identity. No permissions/security settings were changed.
- Required human action: create the local commit in VS Code Source Control using subject: Milestone 1: add application shell and menu navigation. Then resume the Goal. Do not push.
- Milestone 2 has NOT started. Goal status: BLOCKED after three consecutive goal turns with the same checkpoint restriction. Latest read-only recheck: HEAD remains 5cae8ac; Milestone 1 files remain uncommitted; .git/objects retains explicit deny permissions. The previous continuation made no implementation progress because this restriction was unchanged. No security settings were changed. Human action is required to create the checkpoint or provide an approved way to write Git metadata. Milestone 2 has not started.

## Human acceptance backlog
- M1: F5; keyboard and mouse menu navigation; Play placeholder; Esc pause/resume and Return; mixer sliders and readable layout at common window sizes.
- Future: playtest timing tolerance, audio/visual quality, actual browser/Windows builds and sustained performance remain unverified.

## Validation commands
- tools/validate.mjs is a dependency-free optional runner using existing Node.js and the Godot console sibling of the executable configured in .vscode/settings.json. No runtime was installed.
- In this workstation Node is not on PATH; the existing Codex runtime was used: C:/Users/aryan/AppData/Local/OpenAI/Codex/runtimes/cua_node/bbc9141fe9f920ac/bin/node.exe tools/validate.mjs. Normal-access run completed with PASS import, PASS startup, PASS test_shell.gd; zero host/project diagnostics.
- Direct equivalents (using the configured Godot console executable): --headless --path . --import; --headless --path . --quit-after 120; --headless --path . --script res://scripts/tests/test_shell.gd.
- Detailed transient check output is under ignored .godot/validation/results.json.

## Milestone 1 human checklist (all UNVERIFIED)
1. F5 opens PARADOX HEIST. Use arrows/Tab and Enter to navigate; check visible focus.
2. Open Settings; adjust/mute each volume slider; return with Back or Esc. Audio assets are not introduced yet.
3. Open How to play; verify readable instructions and Back/Esc.
4. Play opens visible M1 staging placeholder. Esc pauses; Esc/Resume returns; Return to menu works from pause.
5. Resize the window and inspect readability. Actual browser Quit behavior is unverified.
