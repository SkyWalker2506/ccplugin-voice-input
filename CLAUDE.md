# ccplugin-voice-input

Claude Code plugin — macOS sesli giriş. Mikrofon kaydı (sox) + Whisper transkript → clipboard.

## Komutlar

- `/voice` — Sesi kaydet, transkript et, clipboard'a kopyala

## Backend seçenekleri

| Backend | Açıklama | Kurulum |
|---------|----------|---------|
| `whisper-cpp` | Local, ücretsiz, önerilen | `brew install whisper-cpp` |
| `openai` | Cloud API, yüksek doğruluk | `pip3 install openai` + API key |
| `apple` | macOS built-in | — |

Backend değiştirmek için: `~/.claude/plugins/voice-input/.env` dosyasında `VOICE_BACKEND`.
