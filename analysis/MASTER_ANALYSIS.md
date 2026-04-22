# MASTER_ANALYSIS — ccplugin-voice-input

Date: 2026-04-22
Scope: Full plugin codebase audit — v1.0.2

## Current footprint

- **Plugin:** `voice-input` v1.0.2 — macOS only
- **Entry:** `scripts/voice.sh` — orchestrates record → transcribe → clipboard copy
- **Record:** `scripts/record.sh` — sox (`rec`) or ffmpeg, interactive or timed
- **Transcribe:** `scripts/transcribe.sh` — selects backend (apple/whisper-cpp/openai)
- **Swift backend:** `apple_speech.swift` — Apple Speech Framework, TR locale
- **Command:** `commands/mic.md` — `/mic` trigger, one-liner bash call
- **Install:** `install.sh` — multi-backend installer with interactive backend selection
- **Config:** `.env` in install dir — `VOICE_BACKEND=apple|whisper-cpp|openai`

## What works

- Apple Speech backend — no external deps, works offline on macOS
- whisper-cpp backend — local, requires `brew install whisper-cpp` + model download
- OpenAI backend — cloud fallback, requires `OPENAI_API_KEY`
- Interactive/non-interactive record mode via sox
- Clipboard copy via ccplugin-clipboard or pbcopy fallback

## Weak-point inventory

### HIGH severity

- **W1 — `apple_speech.swift` authorizes speech every run.** `SFSpeechRecognizer.requestAuthorization` is called each invocation — on first run this shows a system dialog. Subsequent runs re-check, but there's no graceful guide if user clicks "Deny".
- **W2 — No language detection or language flag.** Turkish locale is hardcoded (`tr-TR`) in `apple_speech.swift`. User has no way to switch to English or other language without editing source.
- **W3 — `voice.sh` clipboard dependency fragile.** Looks for `ccplugin-clipboard` at a hardcoded path (`~/.claude/plugins/clipboard/scripts/clipboard.sh`). Falls back to `pbcopy` only on macOS. Linux/no-clipboard = silent success with no paste.
- **W4 — No `CLAUDE.md` documentation** of the `/mic` skill or voice pipeline for in-project agents.

### MEDIUM severity

- **W5 — Record duration fixed at 10s** (`DURATION=10` default). No way to configure via env or arg without editing script.
- **W6 — `ffmpeg` avfoundation input device `:0`** — works on most Macs but wrong device index on multi-input setups (e.g., external audio interface). No graceful enumeration.
- **W7 — `transcribe.sh` uses `$PLUGIN_DIR` via `$(dirname "$0")/../`** — breaks if symlinked or called from arbitrary dir.
- **W8 — No CHANGELOG.** v1.0.2 with no history.
- **W9 — `commands/mic.md` is a one-liner with hardcoded install path** — if plugin is installed under a different name, command breaks.

### LOW severity

- **W10 — No multi-language support** beyond TR/EN switch. No Spanish, German, etc.
- **W11 — plugin.json description in Turkish** — marketplace listing will show non-English text.
- **W12 — No `--language` flag** for manual override when Apple SR misidentifies language.

## New-area candidates

1. **Language flag** — `VOICE_LANG=tr-TR` env var (or `/mic en` arg) to switch locale. **High value, low effort.**
2. **Configurable duration** — `VOICE_DURATION=10` env var. **High value, very low effort.**
3. **CLAUDE.md** — project-local agent instructions. **Medium value, trivial effort.**
4. **CHANGELOG** — version history. **Medium value, trivial effort.**
5. **English plugin.json description** — trust signal for marketplace. **Low value, trivial effort.**
6. **`/mic en` / `/mic tr` shorthand** — pass lang to `/mic`. **High value, low effort.**
7. **`--list-devices` flag** for ffmpeg device enumeration. **Medium value, medium effort.**
8. **Whisper auto-language detection** — remove forced `--language tr` when backend=whisper-cpp. **Medium value, low effort.**

## 3-run plan

| Run | Addresses | Deliverable |
|-----|-----------|-------------|
| 1 | W2, W5, W11, W12 | Language flag (`VOICE_LANG` + `/mic [lang]`); configurable duration; english plugin.json; CHANGELOG |
| 2 | W1, W4, W9 | Apple auth preflight check; CLAUDE.md; robust `commands/mic.md` with lang arg; W7 path fix |
| 3 | W3, W8, whisper auto-lang | Clipboard dep abstraction; whisper auto-language detect; CHANGELOG v1.1.0 |
