#!/bin/bash
PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_AUDIO="/tmp/voice_input_$(date +%s).wav"

# Load backend config
source "$PLUGIN_DIR/.env" 2>/dev/null

echo "🎙️  Voice Input — Whisper Transkript"
echo "Backend: ${VOICE_BACKEND:-whisper-cpp}"
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
CLIPBOARD_SCRIPT="$HOME/.claude/plugins/clipboard/scripts/clipboard.sh"
if [ -f "$CLIPBOARD_SCRIPT" ]; then
  echo "$TEXT" | bash "$CLIPBOARD_SCRIPT" copy
else
  # Fallback: pbcopy (macOS)
  echo "$TEXT" | pbcopy 2>/dev/null && echo "✅ Clipboard'a kopyalandı"
fi
