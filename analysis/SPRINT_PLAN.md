# SPRINT_PLAN — ccplugin-voice-input

Date: 2026-04-22
Based on: MASTER_ANALYSIS.md

## Sprint 1 — Language flag + configurable duration + metadata (Run 1)

Goal: User can choose language; duration is configurable; plugin.json is marketplace-ready.

| # | Task | File(s) | Est |
|---|------|---------|-----|
| T1 | Add `VOICE_LANG` env var to `apple_speech.swift` — use `VOICE_LANG` locale or default `tr-TR` | `apple_speech.swift` | 20m |
| T2 | Add `VOICE_LANG` support to `transcribe.sh` — pass `--language` arg to whisper-cpp/openai | `scripts/transcribe.sh` | 15m |
| T3 | Add `VOICE_DURATION` env var to `record.sh` — configurable default duration | `scripts/record.sh` | 10m |
| T4 | Add lang argument to `voice.sh` — `bash voice.sh [lang]` sets `VOICE_LANG` | `scripts/voice.sh` | 15m |
| T5 | Update plugin.json — English description + add `VOICE_LANG` / `VOICE_DURATION` to env docs | `.claude-plugin/plugin.json` | 10m |

## Sprint 2 — Auth preflight + CLAUDE.md + path fixes (Run 2)

Goal: Better onboarding; Apple auth handled gracefully; paths robust.

| # | Task | File(s) | Est |
|---|------|---------|-----|
| T1 | Apple auth preflight check — run swift check-auth before record, guide user if denied | `scripts/transcribe.sh` or `apple_speech_check.swift` | 30m |
| T2 | Add `CLAUDE.md` — skill documentation for in-project agents | `CLAUDE.md` (if missing or redirector only — check) | 15m |
| T3 | Fix `commands/mic.md` — use `$ARGUMENTS` for language selection (`/mic en`, `/mic tr`) | `commands/mic.md` | 15m |
| T4 | Fix path resolution in `transcribe.sh` — use `realpath` or absolute SCRIPT_DIR | `scripts/transcribe.sh` | 10m |
| T5 | Add CHANGELOG.md | `CHANGELOG.md` | 15m |

## Sprint 3 — Clipboard abstraction + whisper auto-lang (Run 3)

Goal: Clipboard works without ccplugin-clipboard; whisper handles multi-language automatically.

| # | Task | File(s) | Est |
|---|------|---------|-----|
| T1 | Abstract clipboard: try pbcopy → xclip → xsel → write to /tmp/voice-last.txt as fallback | `scripts/voice.sh` | 20m |
| T2 | Whisper auto-language: when `VOICE_LANG=auto`, omit `--language` flag from whisper-cpp | `scripts/transcribe.sh` | 10m |
| T3 | Update install.sh — write `VOICE_LANG` + `VOICE_DURATION` to `.env` | `install.sh` | 15m |
| T4 | Update README — language selection, duration config, install check one-liner | `README.md` | 20m |
| T5 | Forge summary | `forge/run-1-summary.md` | 15m |
