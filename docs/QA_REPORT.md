# Snapback — QA Report

**2026-11-14 — implementation and available automated/browser review complete.**

The game is ready for user review as a self-contained HTML5 artifact. Human fun, physical-keyboard rollover, audible/device quality, sustained target-machine FPS, and an actual hosted itch.io upload are **NOT RUN**. No publication is implied.

## Version and environment

- Final `index.html` SHA256: `3ce462b09556f05be1880ad3e8b3c7f51e1db037763bbad29475e92acdf01e27`.
- Windows host; existing Node.js `v24.22.1`; installed Chrome `157.0.8103.79` and Edge `157.0.4341.57`.
- Node was invoked by its existing absolute executable path under the Codex runtime because it is not on PATH. No runtime, package, browser, asset, or system dependency was installed.
- The interactive computer/browser host failed discovery, retry, and reset/retry with missing native pipe/browser access host. Headless browser CLI checks were available and used instead. They use isolated ignored profiles, no CDP/UI automation, and no security-disabling flags. An initial sandboxed Chrome launch failed GPU subprocess access; normal local access succeeded with browser sandbox protections retained.
- Runtime remains one HTML file. Godot, export presets, VS Code configuration, Git history, and unrelated settings are unchanged.

## Commands actually executed

`node` below denotes the existing executable at `C:\Users\aryan\AppData\Local\OpenAI\Codex\runtimes\cua_node\bbc9141fe9f920ac\bin\node.exe`.

| Command/check | Observed result |
|---|---|
| `node --test tools/test-snapback.mjs` | Final source: 46/46 PASS, exit 0; final run 13.061 seconds. |
| `node tools/browser-check.mjs` | Full Chrome review snapshot: 22/22 cases PASS, 71 assertions, 13 verified scenario captures. |
| `node tools/browser-check.mjs --quick` | Final source: actual direct-file boot marker plus 17/17 DOM/browser checks PASS, exit 0. |
| `node tools/browser-check.mjs --only-captures=pause,winner` | Final source: 2/2 targeted captures PASS, exit 0. |
| `node tools/browser-check.mjs --edge --quick` | Final source: Edge direct-file boot plus 17/17 DOM/browser checks PASS, exit 0. |
| Browser-tool syntax checks | PASS. |
| `git diff --check` | PASS. |
| Runtime resource/dependency inspection | No external assets, scripts, stylesheets, fonts, network API calls, or build/runtime dependencies. |
| Review ZIP inspection | Exactly one entry, `index.html`; contained SHA256 equals final source. |
| Preserved-infrastructure diff check | Godot/export/VS Code/Git configuration and starter icon unchanged. |

The full Chrome run used source `05fb03b977ca8ef86099a48247d76e8450de5a9e6c520694acd1436d640b8c58`. The subsequent change only suppresses arena/body drawing beneath opaque PAUSED/MATCH overlays to remove clipped pit/body fragments. A source comparison proved everything outside the renderer byte-identical. The final source reran the complete simulation suite, Chrome/Edge core checks, and affected screenshots. Thus older full-run evidence is attributed precisely rather than mislabeled as a final-source full run.

## Automated mechanics coverage — PASS

The harness extracts the real inline runtime into Node's VM with explicit test opt-in. It does not implement a separate fake physics model. Normal play exposes no test API or cheat keys.

- **Input:** independent physical-code held maps, simultaneous P1/P2 steering/diving, edge consumption, repeat suppression, release/repress, order independence, recognized-key scroll prevention, and clearing across transitions.
- **Bounce:** normal auto-bounce, tier start/min/max, fresh-press ages 12 versus 13, one-time consumption, anti-mash, natural flight cycles, monotonic tier/apex behavior, and held-key failure to repeat perfects.
- **Net:** actual interpolated collision samples, swept fast crossings, no false upward/below-net or off-span landings, neighboring wave propagation/decay, bounded influence on another launch, simultaneous-contact snapshot symmetry, stronger diving impact, and 12,000 representative impact steps.
- **Body contact:** both roles and knock directions, exact-center tie convention, high-speed crossing, side/upward contacts, neutral overlap separation, positive overlap at diagonal corners, relative-speed threshold, protection against repeated hits, and no added energy in neutral upward contacts.
- **Save:** both players on both bumpers, inclusive 12-tick prebuffer and five-tick post-contact grace, too-early/late/spent misses, genuine first-touch anchoring, no automatic strong rescue or repeated-grace farming, ordinary-bounce cooldown independence, and actual subsequent landing on the fully narrowed net with inward steering.
- **Scoring:** entire-collider loss boundary, one point exactly once, no-score double KO, no scoring while paused/after match end, automatic point transition, full rally state/ability/net/input reset, third-point winner, and clean rematch.
- **Long run/fairness:** 50 movement-driven complete matches, 12,000 complete simulation steps, equivalent 600-tick outcomes at 60/75/120/144 render cadence, frame-gap cap, reset inside a frame callback, Overdrive warning/symmetric finite contraction/reset, and identical authoritative outcomes with reduced motion.
- **Mirror stress:** 20 × 1,200 paired role-swapped/reflected ticks (24,000 paired ticks), 26 stomps, 32 saves, 81 points; maximum mirrored position/velocity error `1.3927e-11`.
- **Audio:** lazy initialization, unavailable/throwing constructor, rejected resume/retry, six distinct required cue signatures, 20-voice limit, completion capacity recovery, immediate mute/pause stop and both-node disconnect, and partially constructed/start-failure cleanup. This uses a fake audio graph and does not prove audible quality.
- **Rendering:** read-only state in title/rally/pause/point/winner; drawing cannot change scores, physics, or input.

Technical bounce fixtures measured tier 1–5 launch speeds 10/12/14/16/18 px/tick, apex top-y 270.79/225.99/172.79/111.27/41.43, and flight lengths 41/50/58/66/74 ticks. Maximum rising-wave bonus gives 19.2 px/tick, top-y -4.41, and eight partially clipped ticks. These are actual simulation measurements, not human match-duration estimates. The 50 deliberately self-KO match traces lasted 312 ticks each; they stress reset flow and are not representative competitive pacing.

## Browser execution and visual review — PASS within stated scope

- Actual `index.html` opened using `file://` in Chrome and Edge, without server/build/assets. A nonvisual `data-ready=true` marker is set only after boot, resize, initial draw, and handler installation.
- Synthetic DOM `KeyboardEvent.code` input traversed the actual listeners: both players, held input/edges/repeat, scroll prevention, start/rematch, pause/resume, blur, visibility, input reset, M/V settings, focused-button Space/Enter default behavior, and immediate live-region status announcements.
- Captured page `error`, `unhandledrejection`, and console warnings: **zero** in instrumented cases. This is JavaScript/page instrumentation, not a claim that every browser-internal diagnostic was inspected in a GUI console.
- Exact HTTP iframe viewport checks: 960×540, 1280×720, 640×400, and 640×360; 20/20 checks passed. Native Windows headless frame dimensions vary, so exact-size claims use measured/sized iframes rather than assuming CLI outer-window dimensions equal the viewport.
- Local HTTP request inventory contained only the harness page, actual game HTML, and the browser's own favicon probe. No runtime external request or third-party asset is required. The temporary server closed after its checks.
- Thirteen real Canvas captures were checked for actual phase/event conditions: title, rally, perfect, stomp, save, save-ready prompt, real dive-induced wave, reduced motion, maximum-wave apex, Overdrive, pause, point, and winner. AI visual inspection checked layout, contrast, clipping, shapes, pits, labels, band prompts and net geometry. Final pause/winner captures confirm clipped pit fragments are gone.
- The real dive/net fixture produced `5.073335` px of visible local deflection. The band prompt lights only on a physically eligible charged approach; a used charge remains visibly marked USED.
- The 640×360 iframe screenshot retains uniform scaling, controls, score, and pause information. Subjective accessibility/legibility acceptance by people remains separate.

### Reproducible evidence paths (ignored local artifacts)

- `.godot/snapback_validation/simulation-final.tap` — final 46-test output.
- `.godot/snapback_browser/results_full.json` — full Chrome snapshot and source hash.
- `.godot/snapback_browser/results_core.json` — final Chrome startup and 17 checks.
- `.godot/snapback_browser/results_captures_pause_winner.json` — final targeted visual check.
- `.godot/snapback_browser/edge/results.json` — final Edge startup and 17 checks.
- `.godot/snapback_browser/capture_<scene>.canvas.png` — exact 960×540 Canvas exports.
- `.godot/snapback_browser/capture_<scene>.png` and `iframe_http_<size>.png` — whole-page/embedded screenshots.

## Failures found and fixed

1. Zero-overlap swept corner could stomp: require positive horizontal overlap at time of contact; regression passes.
2. A reset inside the fixed-step callback could make the accumulator negative: generation invalidation discards old catch-up; regression passes.
3. Neutral vertical contact could leave the lower body at its endpoint and interpenetrate: resolve both at contact with bounded symmetric velocity sharing; both-role/energy regressions pass.
4. Audio start failure could retain a connected voice: release oscillator and gain on all failure/completion/mute/pause paths; lifecycle regressions pass.
5. Terminal event audio could redispatch during extra catch-up iterations: dispatch only when simulation advances.
6. Opaque point/winner/pause overlays exposed partial frozen bodies or pit labels: hide the covered world presentation in those phases; final captures inspected.
7. Initial test-event accounting expected ten preventDefault calls where the fixture emitted nine recognized events: corrected the test count, without weakening a gameplay invariant.
8. Headless native frame chrome varied between launches: exact iframe sizing replaced the fragile outer-window-size assertion. This was a harness issue, not a game distortion.

## Completion acceptance mapping

| Required outcome | Evidence |
|---|---|
| Standalone local launch / no external build or assets | Actual file boots; self-containment test; one-entry ZIP. |
| Two simultaneous specified control sets | Real browser listeners plus independent held/edge tests. |
| Correct trampoline and perfect/tier behavior | Swept real net fixtures, 12/13 boundary, apex measurements. |
| Reliable dive/stomp / bounded shared waves | Both-role CCD/neutral/anti-juggle tests; real wave capture and stability run. |
| One-use save for either player/either side | Four real recovery-to-narrowed-net routes and timing/charge misses. |
| Pits, exactly-one-point and first-to-three | Loss/draw/idempotence tests and 50 complete match/reset traces. |
| Full rematch and all screens | Actual Enter route, state reset tests, title/point/pause/winner captures. |
| Audio/accessibility/settings | Tested gesture gate, scheduling/lifecycle fallback, M/V, live announcements, pure motion toggles; listening still NOT RUN. |
| Responsive presentation / real available browsers | Chrome and Edge, measured iframe sizes, AI screenshot inspection. |
| Executed reliable tests / no known critical-high defects | 46 final simulation/audio tests; browser results; repaired regressions above. |
| Accurate docs and explicit manual backlog | Current README/DEV_LOG/QA; blank real-person scorecard; this report. |
| Itch.io review readiness without publication | Verified local review ZIP; actual hosted upload NOT RUN and not authorized. |
| Focused one-arena two-human scope | Runtime inspection: no levels, campaign, bots, network/account/progression or unrelated mode. |

## Known limitations and human-only work

**No known critical/high gameplay defect remains from the executed checks.** This is not a proof that every possible bug or exploit is absent.

- Low-priority visual/tuning note: the maximum-wave tier-5 fixture clips roughly 4.4 px of the athlete at its apex for 0.133 s. The body/HUD remain visible in the inspected capture. Reassess with human play rather than claiming the initial tuning is optimal.
- **NOT RUN:** three actual two-person matches, novice comprehension, fairness/enjoyment, typical human match duration, obvious human exploits, and voluntary rematch interest.
- **NOT RUN:** physical keyboard rollover/ghosting, trusted native key delivery, speaker output, audible balance/latency, and reduced-motion acceptance by people.
- **NOT RUN:** sustained actual-browser FPS, target-laptop thermal behavior/15-minute hands-on session, Firefox/Safari checks, and the real hosted itch.io embed/fullscreen behavior.
- Test-only state fixtures and synthetic inputs are not human play. Headless timing and Node throughput are not measured gameplay FPS.
- No services were purchased; no dependencies/security settings changed; no Git commits/pushes or upload/publication occurred.

### Exact human follow-up

1. Double-click `index.html`; two people start with Space/Enter and play three complete matches, swapping colors once. Use `PLAYTEST_SCORECARD.md`; record real observations only.
2. Test realistic simultaneous chords: `A+W+ArrowLeft+ArrowUp`, `D+S+ArrowRight+ArrowDown`, and mixed three-key chords. Record hardware ghosting instead of attributing it to physics.
3. Attempt saves on both sides, miss deliberately, spend a charge and try again. Judge visible timing, counterplay and stomp fairness.
4. Hear ordinary/perfect/stomp/save/point/victory cues; test M, V, Escape, tab-away and return. Check the two focused setting buttons using Tab/Space/Enter.
5. Resize and play at laptop/embedded sizes, run for 15 minutes, and record measured performance only if actually profiled.
6. Review/upload-test the ZIP on an itch.io draft only after explicit authorization. No upload has been performed by Codex.
