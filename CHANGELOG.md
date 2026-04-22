# Changelog — ccplugin-voice-input

## [1.1.0] — 2026-04-22

### Added
- **Language flag**: `VOICE_LANG` env var + `/mic en` / `/mic tr` / `/mic auto` argument
- **Configurable duration**: `VOICE_DURATION` env var (default 10s)
- **Apple auth preflight**: `scripts/check_apple_auth.swift` — detects denied state before recording, gives actionable error
- **Better auth error messages** in `apple_speech.swift` (denied vs restricted vs not_determined)
- **Language availability check** in `apple_speech.swift` — graceful error for unsupported locale
- `commands/mic.md`: language argument support, configuration table
- `CHANGELOG.md`
- English `plugin.json` description + env var docs
- `analysis/MASTER_ANALYSIS.md` + `SPRINT_PLAN.md`

### Changed
- `scripts/transcribe.sh`: robust `SCRIPT_DIR` via `realpath`; absolute `apple_speech.swift` path; `--language` flag supports whisper auto-detect
- `scripts/voice.sh`: lang argument normalization; shows lang in startup output
- `plugin.json`: version 1.0.2 → 1.1.0

### Fixed
- Apple backend now uses absolute path for swift script (W7)
- `transcribe.sh` no longer breaks when called from arbitrary directory

## [1.0.2] — 2026-03-28

### Fixed
- `pbcopy` fallback when ccplugin-clipboard not installed

## [1.0.1] — 2026-03-20

### Fixed
- sox record exits cleanly on non-interactive shells

## [1.0.0] — 2026-03-15

### Added
- Initial release: Apple Speech + whisper-cpp + OpenAI backends
- `install.sh` with interactive backend selection
- `/mic` command
- Turkish locale default
