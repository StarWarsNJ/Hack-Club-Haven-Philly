# Snapback — Release Review Checklist

**2026-11-14: local review artifact prepared; not published.** See QA_REPORT.md for source hashes, commands, failures/fixes, and evidence scope.

## Implemented and programmatically verified

- [x] One self-contained index.html, direct-file boot in installed Chrome and Edge, no runtime external assets or build/server dependency.
- [x] One arena and one two-human same-keyboard match, first to three, instant rematch.
- [x] Movement, normal/perfect tiers, dive, stomp, shared net, saves, pits and scoring: final 46/46 real-logic deterministic tests pass.
- [x] Input edges/repeats, pause/focus, scrolling, settings and rematch: final Chrome and Edge each pass 17/17 DOM/browser checks.
- [x] No known critical/high defect remains from the executed checks; identified collision/reset/audio bugs are repaired with regressions.
- [x] Runtime source and review ZIP contain no CDN, external image/font/audio, framework, analytics, account service, or Godot dependency.
- [x] README, implementation notes, DEV_LOG and QA_REPORT match the current source and distinguish evidence from human acceptance.

## Presentation and browser review

- [x] AI inspected original title, live silhouettes/HUD, perfect/stomp/save/save-ready/wave/reduced/high/Overdrive, point, pause and winner Canvas captures.
- [x] Score, tiers, save charge, pits, and shape/number-based player identities are visible in inspected captures.
- [x] Final pause/winner screenshots remove the clipped pit/body fragments found during review.
- [x] Actual game in measured localhost iframes: 960×540, 1280×720, 640×400, 640×360; aspect/bounds/input/focus checks pass.
- [x] Gesture-only initialization, mute, silent fallback, audio-node cleanup, voice bound and distinct required cue scheduling have programmatic evidence.
- [x] Reduced motion toggles, retains essential net/labels, and does not change authoritative physics.
- [ ] Actual audible device quality, latency and balance — NOT RUN; needs listening with real trusted user input.
- [ ] Human accessibility/legibility acceptance and sustained actual-device FPS — NOT RUN.

## Human and publication gates

- [x] Actual results, failures/fixes and evidence paths are in QA_REPORT.md; headless/synthetic input is labeled accurately.
- [x] Two-person playtesting is plainly marked NOT RUN; the scorecard contains no invented people or findings.
- [ ] Three real two-person matches, physical-keyboard chords/rollover, fun/fairness, natural match duration and voluntary rematch interest.
- [ ] Hands-on 15-minute browser session and target-laptop performance measurement.
- [ ] Firefox/Safari or another available browser engine; current Chrome/Edge both use Chromium.
- [ ] Actual itch.io hosted draft/iframe/fullscreen test — NOT RUN and no upload authorized.

## Prepared artifact

`builds/Snapback-review.zip` contains exactly one root entry, `index.html`, with no docs, test helpers, cache, Git metadata, or secrets. The archive entry's SHA256 matches final source `3ce462b09556f05be1880ad3e8b3c7f51e1db037763bbad29475e92acdf01e27`. The ZIP is ignored by Git and has not been uploaded.

itch.io accepts a self-contained HTML file or a ZIP with index.html at its root. After explicit upload authorization, use HTML game mode and review a 960×540/responsive embed, focus, audio unlock and fullscreen behavior in the real draft. Local packaging alone does not establish hosted behavior.

Do not upload, publish, push, or create commits without explicit approval. Keep the remaining human gates visible before announcing a public release.
