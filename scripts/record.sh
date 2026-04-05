#!/bin/bash
# Kayıt — sox(rec), ffmpeg veya python sounddevice
OUTPUT="${1:-/tmp/voice_input.wav}"
DURATION="${2:-30}"

echo "🎤 Konuşun... (Enter ile bitir, max ${DURATION}s)"

if command -v rec &>/dev/null; then
  # sox rec komutu
  rec -r 16000 -c 1 "$OUTPUT" trim 0 "$DURATION" &
  REC_PID=$!
elif command -v ffmpeg &>/dev/null; then
  # ffmpeg ile mikrofon kaydı
  ffmpeg -f avfoundation -i ":0" -ar 16000 -ac 1 -t "$DURATION" "$OUTPUT" -y 2>/dev/null &
  REC_PID=$!
else
  echo "❌ Kayıt aracı bulunamadı (sox veya ffmpeg gerekli)" >&2
  exit 1
fi

read -r
kill $REC_PID 2>/dev/null
wait $REC_PID 2>/dev/null

if [ ! -f "$OUTPUT" ] || [ ! -s "$OUTPUT" ]; then
  echo "❌ Ses kaydı başarısız" >&2
  exit 1
fi

echo "✓ Kayıt tamamlandı"
