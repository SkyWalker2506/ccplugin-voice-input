#!/bin/bash
# Whisper backend seç
INPUT="${1:-/tmp/voice_input.wav}"
BACKEND="${VOICE_BACKEND:-whisper-cpp}"  # whisper-cpp | openai | apple

if [ ! -f "$INPUT" ]; then
  echo "❌ Ses dosyası bulunamadı: $INPUT" >&2
  exit 1
fi

case "$BACKEND" in
  whisper-cpp)
    if ! command -v whisper-cpp &>/dev/null; then
      echo "❌ whisper-cpp kurulu değil. Kurmak için: brew install whisper-cpp" >&2
      exit 1
    fi
    RESULT_BASE="/tmp/voice_result_$$"
    whisper-cpp --language tr --model base "$INPUT" -otxt -of "$RESULT_BASE" 2>/dev/null
    if [ -f "${RESULT_BASE}.txt" ]; then
      cat "${RESULT_BASE}.txt"
      rm -f "${RESULT_BASE}.txt"
    else
      echo "❌ Transkript başarısız" >&2
      exit 1
    fi
    ;;
  openai)
    source ~/.claude/secrets/secrets.env 2>/dev/null
    if [ -z "$OPENAI_API_KEY" ]; then
      echo "❌ OPENAI_API_KEY bulunamadı — ~/.claude/secrets/secrets.env kontrol et" >&2
      exit 1
    fi
    python3 -c "
import openai, sys, os
client = openai.OpenAI(api_key=os.environ.get('OPENAI_API_KEY'))
try:
    with open('$INPUT', 'rb') as f:
        result = client.audio.transcriptions.create(model='whisper-1', file=f, language='tr')
    print(result.text)
except Exception as e:
    print(f'Hata: {e}', file=sys.stderr)
    sys.exit(1)
"
    ;;
  apple)
    SWIFT_SCRIPT="$(dirname "$0")/../apple_speech.swift"
    if [ ! -f "$SWIFT_SCRIPT" ]; then
      echo "❌ apple_speech.swift bulunamadı" >&2
      exit 1
    fi
    swift "$SWIFT_SCRIPT" "$INPUT"
    ;;
  *)
    echo "❌ Bilinmeyen backend: $BACKEND (whisper-cpp | openai | apple)" >&2
    exit 1
    ;;
esac
