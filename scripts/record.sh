#!/bin/bash
# Kayıt — sox(rec) veya ffmpeg
OUTPUT="${1:-/tmp/voice_input.wav}"
DURATION="${2:-10}"

if command -v rec &>/dev/null; then
  if [ -t 0 ]; then
    # Interactive: Enter ile bitir
    echo "🎤 Konuşun... (Enter ile bitir, max ${DURATION}s)"
    rec -r 16000 -c 1 "$OUTPUT" trim 0 "$DURATION" &
    REC_PID=$!
    read -r
    kill $REC_PID 2>/dev/null
    wait $REC_PID 2>/dev/null
  else
    # Non-interactive: sabit süre
    echo "🎤 Kayıt başlıyor... (${DURATION}s)"
    rec -r 16000 -c 1 "$OUTPUT" trim 0 "$DURATION"
  fi
elif command -v ffmpeg &>/dev/null; then
  echo "🎤 Kayıt başlıyor... (${DURATION}s)"
  ffmpeg -f avfoundation -i ":0" -ar 16000 -ac 1 -t "$DURATION" "$OUTPUT" -y 2>/dev/null
else
  echo "❌ Kayıt aracı bulunamadı (sox veya ffmpeg gerekli)" >&2
  exit 1
fi

if [ ! -f "$OUTPUT" ] || [ ! -s "$OUTPUT" ]; then
  echo "❌ Ses kaydı başarısız" >&2
  exit 1
fi

echo "✓ Kayıt tamamlandı"
