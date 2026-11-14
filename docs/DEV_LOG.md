# Snapback — Development and Tuning Log

**Status:** Design files created; gameplay implementation pending.

Codex should log dated changes with:
- What was implemented or changed and which files were touched.
- Why the change improves feel, fairness, presentation, or reliability.
- Any modified `CONFIG` values (old → new and reason).
- Test commands actually run, with PASS/FAIL/NOT RUN.
- Known limitations and next highest-impact issue.

## Initial decisions

- Two-player local multiplayer, WASD versus arrows.
- Exactly one arena and one competitive best-of-five mode.
- Timed auto-bounce, dive, stomp, physical shared net, one-use Snapback Save.
- One browser-native, self-contained `index.html` runtime; old Godot infrastructure unused.
- Retro kinetic sports-poster art and user-gesture-enabled synthesized audio.
- No levels, AI, internet gameplay, or paid assets.

## Progress

- **Not started.**
