# Forge Run Summary — ccplugin-voice-input (Runs 1–3)

**Date:** 2026-04-22
**Runs:** 3 (Sprint 1–3)
**Commits:** 3

## Stats

- Files created: 6 (check_apple_auth.swift, CHANGELOG.md, analysis/MASTER_ANALYSIS.md, analysis/SPRINT_PLAN.md, forge/run-1-summary.md, + README rewrite)
- Files modified: 6 (apple_speech.swift, transcribe.sh, record.sh, voice.sh, mic.md, install.sh, plugin.json)
- Issues created: 3 (GitHub #1, #2, #3)

## Deliverables by Run

### Run 1 — Language flag + configurable duration
- `apple_speech.swift`: VOICE_LANG locale support; better auth error messages; availability check
- `scripts/transcribe.sh`: VOICE_LANG → whisper-cpp/openai --language; auto-detect mode; robust SCRIPT_DIR
- `scripts/record.sh`: VOICE_DURATION env var
- `scripts/voice.sh`: lang argument normalization (en → en-US, tr → tr-TR, auto)
- `plugin.json`: English description + env var documentation; version 1.1.0

### Run 2 — Auth preflight + CLAUDE.md + CHANGELOG
- `scripts/check_apple_auth.swift`: preflight check; denied → actionable error
- `scripts/transcribe.sh`: runs auth check before recording for apple backend
- `commands/mic.md`: language argument support, config table, argument-hint
- `CHANGELOG.md`

### Run 3 — Clipboard abstraction + install.sh + README
- `scripts/voice.sh`: clipboard abstraction (ccplugin-clipboard → pbcopy → xclip → xsel → /tmp/voice-last.txt)
- `install.sh`: writes VOICE_LANG + VOICE_DURATION to .env; copies Swift scripts
- `README.md`: complete rewrite — English, multilingual, 5-step install, config table, install check

## Lessons

1. **Language flexibility is table stakes** — hardcoding `tr-TR` in Swift forced source edits. A single env var + argument chain handles all use cases.
2. **Auth preflight saves user confusion** — Apple SR denied state shows a cryptic runtime error. A 50-line Swift check turns it into an actionable message.
3. **Clipboard abstraction matters for portability** — ccplugin-clipboard dependency is optional. Graceful fallback chain means the plugin works on fresh installs.
4. **Auto-detect clarification needed** — Apple Speech doesn't support `auto`; whisper-cpp does. Users need to know which backend supports what. README makes this explicit.
