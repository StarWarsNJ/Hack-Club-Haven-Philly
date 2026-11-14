# Snapback — Browser Release Checklist

Complete **only after implementing and testing** the actual game. This document does not authorize publishing.

## Code / gameplay
- [ ] `index.html` contains all runtime code/styles, opens standalone.
- [ ] One working two-player match (P1 WASD, P2 arrows).
- [ ] Keyboard input, timed bounce, dive, stomp, Snapback Save, wave coupling, pits, three-point win, pause, mute, rematch pass real tests.
- [ ] No known critical/high bugs.
- [ ] No calls to external fonts, CDNs, analytics, remote scripts, or images.
- [ ] Docs match actual behavior.

## Presentation
- [ ] Title controls legible at typical laptop size.
- [ ] Score, tiers, save charge, pits, and players visually distinct.
- [ ] Sound begins only after gesture and can be muted.
- [ ] Reduced motion works.
- [ ] Resize and iframe work without aspect distortion.
- [ ] Title, rally, stomp, save, pause, point, winner screenshots inspected if tools available.

## QA / human testing
- [ ] Actual test results are in `docs/QA_REPORT.md`.
- [ ] Two-person playtest performed, or plainly marked NOT RUN.
- [ ] Test physical keyboard for common simultaneous P1/P2 key chords.
- [ ] Real Chromium-based browser tested; another browser if available.
- [ ] No unexpected page scrolling, sticky input after tab switch, or repeated scoring.
- [ ] Match rematch confirmed.

## itch.io

itch.io supports a **single self-contained HTML file** upload, or a ZIP containing `index.html` at archive root. If using ZIP, include no development secrets, `.git/`, docs, or unnecessary artifacts. Configure the game as an HTML game with an embed around 960×540 (responsive allowed). Verify the actual iframe after upload **only when the user authorizes upload**. Review fullscreen settings; avoid focus/keyboard conflicts.

Do **not** upload/publish or push code without explicit user approval.
