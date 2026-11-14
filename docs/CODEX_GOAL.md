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
