#!/bin/bash
# Whisper backend seç
INPUT="${1:-/tmp/voice_input.wav}"
# Robust SCRIPT_DIR — resolves symlinks
SCRIPT_DIR="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$PLUGIN_DIR/.env" 2>/dev/null
BACKEND="${VOICE_BACKEND:-apple}"
# Language: VOICE_LANG env var (default tr, auto=detect)
LANG_CODE="${VOICE_LANG:-tr-TR}"

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
    # auto-detect: omit --language flag; explicit: pass it
    if [ "$LANG_CODE" = "auto" ]; then
      whisper-cpp --model base "$INPUT" -otxt -of "$RESULT_BASE" 2>/dev/null
    else
      # whisper-cpp uses 2-letter code (tr, en, de…)
      WHISPER_LANG="${LANG_CODE%%-*}"
      whisper-cpp --language "$WHISPER_LANG" --model base "$INPUT" -otxt -of "$RESULT_BASE" 2>/dev/null
    fi
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
    _OAI_LANG="$LANG_CODE"
    [ "$_OAI_LANG" = "auto" ] && _OAI_LANG=""
    # OpenAI uses 2-letter BCP-47 language codes
    [ -n "$_OAI_LANG" ] && _OAI_LANG="${_OAI_LANG%%-*}"
    python3 -c "
import openai, sys, os
client = openai.OpenAI(api_key=os.environ.get('OPENAI_API_KEY'))
lang = '$_OAI_LANG'
kwargs = {'model': 'whisper-1', 'file': open('$INPUT', 'rb')}
if lang:
    kwargs['language'] = lang
try:
    result = client.audio.transcriptions.create(**kwargs)
    print(result.text)
except Exception as e:
    print(f'Hata: {e}', file=sys.stderr)
    sys.exit(1)
"
    ;;
  apple)
    SWIFT_SCRIPT="$PLUGIN_DIR/apple_speech.swift"
    AUTH_CHECK="$PLUGIN_DIR/scripts/check_apple_auth.swift"
    if [ ! -f "$SWIFT_SCRIPT" ]; then
      echo "❌ apple_speech.swift bulunamadı: $SWIFT_SCRIPT" >&2
      exit 1
    fi
    # Preflight auth check (fast, no dialog on authorized)
    if [ -f "$AUTH_CHECK" ]; then
      AUTH_STATUS=$(swift "$AUTH_CHECK" 2>/dev/null)
      AUTH_EXIT=$?
      if [ $AUTH_EXIT -eq 1 ]; then
        echo "❌ Apple Speech Recognition access denied." >&2
        echo "   Fix: System Settings > Privacy & Security > Speech Recognition > enable for Terminal" >&2
        exit 1
      fi
      # exit 0 (authorized) or 2 (not_determined, will prompt) — proceed either way
    fi
    # Pass VOICE_LANG to Swift via env (already exported) or as argument
    swift "$SWIFT_SCRIPT" "$INPUT" "$LANG_CODE"
    ;;
  *)
    echo "❌ Bilinmeyen backend: $BACKEND (whisper-cpp | openai | apple)" >&2
    exit 1
    ;;
esac
