---
name: mic
description: "Record voice, transcribe with Whisper, copy to clipboard. Triggers: mic, microphone, voice, speak, dictate, sesli giriş, mikrofon, konuş. Optional language: /mic en (English), /mic tr (Turkish, default), /mic auto (detect)."
argument-hint: "[en|tr|de|auto|<lang-code>]"
allowed-tools: [Bash]
---

# /mic — Voice Input

Record from microphone and transcribe to text.

## What this does

1. Records audio from microphone (default 10s, or press Enter to stop)
2. Transcribes using Whisper (backend: Apple Speech / whisper-cpp / OpenAI)
3. Copies transcript to clipboard

## Usage

```bash
# Default (Turkish, 10s max)
bash ~/.claude/plugins/voice-input/scripts/voice.sh

# With language argument from $ARGUMENTS
bash ~/.claude/plugins/voice-input/scripts/voice.sh "$ARGUMENTS"
```

## Language selection

| Argument | Language |
|----------|----------|
| (none) | Turkish (tr-TR) |
| `tr` | Turkish |
| `en` | English (en-US) |
| `de` | German |
| `auto` | Auto-detect (whisper-cpp/openai only) |
| `fr-FR` | French (full BCP-47 code) |

## Configuration

Set in `~/.claude/plugins/voice-input/.env`:
```bash
VOICE_BACKEND=apple      # apple | whisper-cpp | openai
VOICE_LANG=tr-TR         # default language
VOICE_DURATION=10        # max recording seconds
```
