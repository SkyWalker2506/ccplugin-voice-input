# ccplugin-voice-input

Claude Code plugin — macOS mikrofon + Whisper transkript. Türkçe destekli. Sonuç clipboard'a kopyalanır.

## Özellikler

- macOS mikrofon kaydı (sox, sessizlik tespiti ile otomatik dur)
- 3 Whisper backend: **whisper.cpp** (local/ücretsiz), **OpenAI API**, **Apple Speech**
- Türkçe dil desteği (tüm backend'lerde `language=tr`)
- Sonuç otomatik clipboard'a kopyalanır → Cmd+V ile Claude'a yapıştır
- `/voice` Claude Code komutu

## Kurulum

```bash
# Önkoşul: Homebrew
brew install sox

# Repo'yu klonla ve kur
git clone https://github.com/SkyWalker2506/ccplugin-voice-input.git
cd ccplugin-voice-input
bash install.sh
```

Kurulum sırasında backend seçmeniz istenir:

```
Whisper backend seçin:
  1) whisper.cpp (local, ücretsiz, önerilen)
  2) OpenAI Whisper API (cloud, API key gerekli)
  3) Apple Speech Recognition (local, ek kurulum yok)
```

### whisper.cpp model indirme

```bash
# base model (~140MB) — Türkçe için yeterli
curl -L -o $(brew --prefix)/share/whisper-cpp/models/ggml-base.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin

# daha doğru (yavaş) — medium model (~460MB)
curl -L -o $(brew --prefix)/share/whisper-cpp/models/ggml-medium.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.bin
```

## Kullanım

Claude Code'da:
```
/voice
```

Veya direkt:
```bash
bash ~/.claude/plugins/voice-input/scripts/voice.sh
```

1. "Konuşun..." mesajı çıkar
2. Konuşun (sessizlik algılayınca veya Enter'a basınca durur)
3. Transkript terminale yazılır ve clipboard'a kopyalanır
4. Claude Code'da Cmd+V ile yapıştırın

## Backend değiştirme

```bash
# Kurulum sonrası backend değiştirmek için:
echo 'export VOICE_BACKEND="openai"' > ~/.claude/plugins/voice-input/.env
# seçenekler: whisper-cpp | openai | apple
```

## Gereksinimler

- macOS 12+
- Homebrew
- `sox` (`brew install sox`)
- Backend'e göre: `whisper-cpp` veya `openai` Python paketi

## Lisans

MIT © Musab Kara
