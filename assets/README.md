# Original project assets

All new visuals are native Godot geometry or the original vector clock icon. All new audio is original deterministic PCM synthesis from tools/generate_audio.mjs; no third-party samples, assets, fonts, plugins or downloads were added.

| Asset | Purpose |
|---|---|
| audio/echo_1.wav | Cyan E1 descending percussive cue |
| audio/echo_2.wav | Violet E2 harmonic pluck |
| audio/echo_3.wav | Amber E3 bass cue |
| audio/echo_4.wav | Mint E4 inharmonic chime |
| audio/sync.wav | Brief original consonant SYNC chord |
| audio/imprint.wav | First/new bank arpeggio, after resuming the loop |
| audio/clockwork_loop.wav | Quiet original eight-second clockwork music loop |
| ui/paradox_icon.svg | Original four-Echo clock icon |

Audio is mono 22,050Hz, 16-bit PCM, tapered to avoid abrupt file boundaries. Music loops on a duplicated playback resource; gameplay never depends on audio. Headless tests are deliberately silent; native/Web sound quality and latency require human inspection.

The starter icon.svg and icon.svg.import at the repository root are preserved. Godot's bundled fallback font remains the only font. No new third-party licensing obligations were introduced; project distribution licensing is a separate release decision.
