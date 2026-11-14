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

## 11. Implemented presentation — 2026-11-14

The runtime now contains original Canvas paths, polygons, lines, circles, and locally synthesized Web Audio. It has no external image, font, audio, stylesheet, or script requests. System font fallbacks provide typography; the title wordmark is letter-positioned with a restrained elastic bend. The specification above remains the creative reference, while this section records implemented facts rather than certifying subjective polish.

- Coral has an angular crest/headband; Mint has a rounded visor/antenna. Numbered names and diamond/circle tier pips distinguish players beyond color. The HUD shows all five tier pips, a save-charge icon with SAVE/USED, the score, and first-to-three/rally labels.
- The net cord and under-mesh are drawn from the authoritative physics samples. Gold anchor posts follow the active Overdrive endpoints. Dark side pits and visibly positioned vertical save bands mark the arena; a charged athlete approaching a physically plausible contact receives a player-specific W/Up prompt.
- Title, active rally, point/draw, pause, and match-winner views share the ink/ivory/coral/mint/gold palette. The title has an animated decorative net/athlete demonstration; starting play does not wait for it. The pause view repeats controls and current audio/motion settings. The winner view offers immediate Space/Enter rematch.
- Landing squash, aerial stretch/lean, short dive/save trails, a visible anti-juggle outline, directional impact marks, and concise PERFECT/STOMP/SNAPBACK notices derive from committed state. Essential net motion and event labels remain when reduced motion suppresses shake, decorative trails/impact marks, lean, and squash/stretch. No gameplay input is frozen for decorative hit-stop.
- `CONFIG.audio` defines local oscillator/envelope cues for ordinary/perfect bounce, stomp, save, scoring, victory, Overdrive, and a throttled dive entry. Sound is user-gesture enabled, can be muted, and has a silent fallback. Pause/mute stop voices, all oscillator/gain nodes release on completion or failure, and a 20-voice cap bounds scheduling. No background music file or downloaded sample is used.

Executed automated audio checks distinguish all six required cue signatures and cover lazy initialization, blocked/unavailable devices, resume rejection, voice bounds, natural completion, mute/pause, and partial-node failure cleanup. This proves scheduling/lifecycle behavior in a fake audio graph, not audible balance, latency, speaker output, or human preference.

Final screenshot inspection at multiple sizes, audio-device listening, physical keyboard use, and two-person reactions are separate verification tasks. Consult `docs/QA_REPORT.md` for what actually ran; do not infer a visual or audible pass from these implementation notes.
