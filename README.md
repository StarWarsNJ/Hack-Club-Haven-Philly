# PARADOX HEIST

A single-player, top-down time-loop puzzle game in Godot 4 standard / typed GDScript. Record up to 30 seconds, bank a route, and work with up to four non-physical Echoes of your past attempts.

The source includes all eight missions, a deterministic pose recorder/replay system, baseline resets, Timeline Director with safe replacement/removal/undo, local campaign progress, settings, hints, original vector/audio presentation, and a skippable finale showcase. Milestones 0–13 have completed implementation and available automated checks; see docs/DEVELOPMENT_PROGRESS.md for evidence and human acceptance limitations.

## Run
1. Open project.godot in the configured Godot 4 editor (development checks used 4.7.2 standard).
2. Press F5. Play starts M1 on a fresh profile; Continue selects the next unlocked mission later.
3. Read the short in-game instructions. The first bank has an instantly skippable Echo introduction.

Compatibility rendering and 60 physics ticks/sec are configured. Windows and itch.io Web are targets; actual exports/browser behavior and sustained 60 FPS have not been verified. No dependencies or addons are required to play in Godot.

## Controls
| Input | Action |
|---|---|
| WASD / arrows | Normalized movement |
| Shift | Short dash, introduced in M3; blocked by walls and not invulnerable |
| E | Activate an eligible terminal within its marked range |
| Space | Temporal pulse, introduced in M4 |
| Q | Bank with confirmation; full bank asks which slot to replace |
| R | Discard/retry the live attempt, preserving saved Echoes |
| Tab | Paused Timeline Director |
| H / Hint | Optional progressive nudges |
| Esc | Pause/resume, cancel a prompt, or skip a story/showcase |

Echoes follow saved poses and never collide with geometry or hazards. Only specifically compatible devices respond to their recorded actions. Only LIVE Rook can complete objectives. Tapes remain within the current mission and are cleared on mission exit/replay; stars, unlocks, best times and settings are saved locally.

## Progress and grades
One star for a clear; two for meeting the published Echo budget; three for that efficient clear at or before 25.0s in the successful live run. Failed retries do not affect grades. Progress uses user://paradox_heist_v1.json. Corrupt data is backed up before recovery; unsupported newer schemas are not overwritten. Browser storage persistence still needs a real browser check.

## Verification
- docs/LEVEL_SOLUTIONS.md records actual programmatic routes and observed win ticks for M1–M8.
- docs/SIMULATION_CONTRACT.md defines tick boundaries, action ordering, resets and presentation isolation.
- docs/TEST_PLAN.md is the original acceptance checklist. Human gameplay/audio/accessibility/visual acceptance remains UNVERIFIED.
- The optional dependency-free tools/validate.mjs runner uses an existing Node.js runtime and the local Godot console executable from .vscode/settings.json (or GODOT_PATH). It imports, starts the game and runs every GDScript test with isolated profiles; fixed-frame harnesses do not benchmark FPS.
- tools/validate_rates.mjs checks Echo/M1 tick behavior at 30 and 144 fixed render FPS with 60 Hz physics; it is not a performance benchmark.
- tools/render_checks.mjs captures native Compatibility frames into ignored .godot/validation/renders with muted transient profiles. This is not a browser/export test.
- assets/README.md inventories original assets; tools/generate_audio.mjs reproduces the PCM sources using existing Node.js only.

Milestone 14, release/export preparation, third-party installation, publishing and remote pushes are outside the current authorized work. Git commits are left to the user.
