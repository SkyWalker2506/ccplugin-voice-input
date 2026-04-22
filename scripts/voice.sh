#!/bin/bash
PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_AUDIO="/tmp/voice_input_$(date +%s).wav"

# Load backend config
source "$PLUGIN_DIR/.env" 2>/dev/null

# Language: first arg > VOICE_LANG env > default tr-TR
# Normalize: "en" -> "en-US", "tr" -> "tr-TR", full codes pass through
if [ -n "$1" ]; then
  case "$1" in
    en|EN) export VOICE_LANG="en-US" ;;
    tr|TR) export VOICE_LANG="tr-TR" ;;
    auto)  export VOICE_LANG="auto" ;;
    *-*)   export VOICE_LANG="$1" ;;   # full code e.g. en-US, de-DE
    *)     export VOICE_LANG="${1}-${1^^}" ;;  # best effort
  esac
fi
VOICE_LANG="${VOICE_LANG:-tr-TR}"
export VOICE_LANG

echo "🎙️  Voice Input — Whisper Transkript"
echo "Backend: ${VOICE_BACKEND:-apple} | Lang: ${VOICE_LANG}"
echo ""

bash "$PLUGIN_DIR/scripts/record.sh" "$TMP_AUDIO"
if [ $? -ne 0 ]; then
  exit 1
fi

echo "⏳ Transkript ediliyor..."
TEXT=$(bash "$PLUGIN_DIR/scripts/transcribe.sh" "$TMP_AUDIO" 2>&1)
EXIT_CODE=$?
rm -f "$TMP_AUDIO"

if [ $EXIT_CODE -ne 0 ]; then
  echo "$TEXT" >&2
  exit 1
fi

if [ -z "$TEXT" ]; then
  echo "⚠️  Ses algılanamadı — lütfen tekrar deneyin"
  exit 1
fi

echo ""
echo "📝 $TEXT"

# Clipboard abstraction — try multiple methods
copy_to_clipboard() {
  local text="$1"
  local CLIPBOARD_SCRIPT="$HOME/.claude/plugins/clipboard/scripts/clipboard.sh"

  if [ -f "$CLIPBOARD_SCRIPT" ]; then
    echo "$text" | bash "$CLIPBOARD_SCRIPT" copy && echo "✅ Clipboard'a kopyalandı (ccplugin-clipboard)" && return 0
  fi

  if command -v pbcopy &>/dev/null; then
    echo "$text" | pbcopy && echo "✅ Clipboard'a kopyalandı (pbcopy)" && return 0
  fi

  if command -v xclip &>/dev/null; then
    echo "$text" | xclip -selection clipboard && echo "✅ Clipboard'a kopyalandı (xclip)" && return 0
  fi

  if command -v xsel &>/dev/null; then
    echo "$text" | xsel --clipboard --input && echo "✅ Clipboard'a kopyalandı (xsel)" && return 0
  fi

  # Last resort: write to temp file
  local LAST="/tmp/voice-last.txt"
  echo "$text" > "$LAST"
  echo "⚠️  Clipboard aracı bulunamadı — metin $LAST dosyasına yazıldı"
  return 1
}

copy_to_clipboard "$TEXT"
