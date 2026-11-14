> Historical specification-kit installation guide. This repository now contains the implemented index.html; open it directly to play. README.md and docs/QA_REPORT.md describe the current game and actual validation. Future-tense setup text below describes the original kit.

# Installing the Snapback Multiplayer Codex Kit

This kit is a **specification and instruction package**. It does not contain a game yet. Codex will create `index.html` after you give it the Goal.

## 1. Protect the previous project

Keep a Git branch or independent copy of the previous Paradox Heist and single-player Snapback experiment if you may want it. Check `git status` and commit or back up changes you intend to retain **before** replacing docs. Do not delete `.git/`.

## 2. Copy files into your existing `hackathon` folder

Extract this ZIP, then copy its `AGENTS.md`, `README.md`, and `docs/` into the repository root **alongside the existing `.git/` and `project.godot`**, replacing older design files. You can copy `SETUP_INSTRUCTIONS.md` too, but it is not needed by Codex.

The project will be HTML5/JavaScript now. The old Godot config may remain untouched but is not part of the runtime. **Do not ask Codex to follow old Godot or single-player Snapback specs.**

Expected structure:

```text
hackathon/
├── .git/
├── .gitignore
├── project.godot          # optional old config; unused
├── AGENTS.md
├── README.md
├── docs/
│   ├── GAME_DESIGN.md
│   ├── PHYSICS_AND_CONTROLS.md
│   ├── ART_AND_AUDIO.md
│   ├── TEST_PLAN.md
│   ├── IMPLEMENTATION_PLAN.md
│   ├── CODEX_GOAL.md
│   ├── PLAYTEST_SCORECARD.md
│   ├── QA_REPORT.md
│   ├── DEV_LOG.md
│   └── RELEASE_CHECKLIST.md
└── index.html              # Codex creates this
```

## 3. Start ONE Codex Goal

Open the repository root in VS Code. In a Codex session that supports Goal mode, use `/goal`, then paste the following:

> Build and fully test the two-player local arcade game Snapback according to `docs/CODEX_GOAL.md`. First read `AGENTS.md` and all design, implementation, and QA documents referenced there. Create a complete self-contained `index.html`, not a Godot game. Work autonomously through the whole implementation and polish cycle, continuously testing and updating `docs/DEV_LOG.md` and `docs/QA_REPORT.md`. Do not add levels, AI, network play or unrelated features. Do not commit, push, or publish. Continue until all executable acceptance criteria pass, or report an actual blocker and any honest manual-testing limitations.

If Goal mode is unavailable, paste the exact same instruction as a regular Codex task with autonomy as permitted by the installed Codex version; long-term continuation can be interrupted by budgets, tool approvals, or context limits.

## 4. Verify the actual result

After Codex reports work complete:

1. Open `index.html` in a desktop browser.
2. Put two people on one keyboard and play a full best-of-five match, including a rematch.
3. Check timed bounce, dive, top-down stomp, save from both sides, pause, audio toggle, keyboard rollover, window resize and match end.
4. Open `docs/QA_REPORT.md`; check what is really tested versus NOT RUN.
5. Only after successful human review, prepare an itch.io upload (single HTML file works).

This package **cannot guarantee a hackathon win**. The best leverage is responsive controls, unexpected but fair last-second recoveries, very fast replay, and cohesive visuals.
