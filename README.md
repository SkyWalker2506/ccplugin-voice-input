# ccplugin-voice-input

Voice-to-text for Claude Code — record via microphone, transcribe with Whisper, copy to clipboard. Turkish and multilingual.

## Features

- macOS microphone recording (sox or ffmpeg)
- 3 Whisper backends: **Apple Speech** (local, no setup), **whisper-cpp** (local/free), **OpenAI API** (cloud)
- Multilingual: Turkish (default), English, German, auto-detect
- Result copied to clipboard → Cmd+V into Claude Code
- `/mic [language]` command — `/mic en`, `/mic tr`, `/mic auto`
- **`Ctrl+Shift+M`** keyboard shortcut — push-to-talk directly in Claude Code terminal
- Configurable duration via `VOICE_DURATION` env var

## Install (5 steps)

```bash
git clone https://github.com/SkyWalker2506/ccplugin-voice-input
cd ccplugin-voice-input
bash install.sh
```

Select backend when prompted (default: Apple Speech — no extra setup):
```
1) whisper.cpp (local, free, recommended for best accuracy)
2) OpenAI Whisper API (cloud, needs OPENAI_API_KEY)
3) Apple Speech Recognition (local, no setup required)  ← default
```

## Usage

```
/mic          # Turkish (default)
/mic en       # English
/mic auto     # Auto-detect language (whisper-cpp/openai only)
/mic de-DE    # German (full BCP-47)
```

Or directly:
```bash
bash ~/.claude/plugins/voice-input/scripts/voice.sh en
```

## Configuration

Edit `~/.claude/plugins/voice-input/.env`:

```bash
export VOICE_BACKEND="apple"    # apple | whisper-cpp | openai
export VOICE_LANG="tr-TR"       # default language (tr-TR | en-US | auto | ...)
export VOICE_DURATION="10"      # max recording seconds
```

## Language support

| `/mic` arg | Language |
|-----------|----------|
| (none) | Turkish (tr-TR) |
| `tr` | Turkish |
| `en` | English (en-US) |
| `de` | German |
| `auto` | Auto-detect (whisper-cpp / openai only) |
| `fr-FR` | Full BCP-47 code |

> **Note:** Apple Speech `auto` is not supported — falls back to tr-TR. Use whisper-cpp for auto-detect.

## Apple Speech auth

First run shows a system dialog. If you clicked "Don't Allow":
- System Settings > Privacy & Security > Speech Recognition > enable Terminal (or your terminal app)

## whisper-cpp model download

```bash
# base model (~140MB) — sufficient for most languages
curl -L -o "$(brew --prefix)/share/whisper-cpp/models/ggml-base.bin" \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin
```

## Install check

```bash
swift ~/.claude/plugins/voice-input/scripts/check_apple_auth.swift
# Expected: "authorized"
```

## Requirements

- macOS 12+
- Homebrew (`brew install sox` for interactive recording)
- Backend: whisper-cpp (`brew install whisper-cpp`) or `pip3 install openai`

## License

MIT © Musab Kara

## Part of

- [claude-config](https://github.com/SkyWalker2506/claude-config) — Multi-Agent OS for Claude Code
- [Plugin Marketplace](https://github.com/SkyWalker2506/claude-marketplace) — Browse & install all plugins
- [ClaudeHQ](https://github.com/SkyWalker2506/ClaudeHQ) — Claude ecosystem HQ
