#!/bin/bash
# Sessizlik tespiti ile kayıt — sox varsa sox, yoksa afrecord (macOS built-in)
OUTPUT="${1:-/tmp/voice_input.wav}"
DURATION="${2:-30}"  # max saniye

echo "🎤 Konuşun... (Enter ile bitir, max ${DURATION}s)"

if command -v sox &>/dev/null; then
  # sox: sessizlik tespiti destekli
  sox -d -r 16000 -c 1 "$OUTPUT" silence 1 0.1 1% 1 1.5 1% trim 0 "$DURATION" &
  REC_PID=$!
  read -r
  kill $REC_PID 2>/dev/null
  wait $REC_PID 2>/dev/null
else
  # afrecord: macOS built-in, sox gerekmez
  afrecord -d "$DURATION" -f WAVE -c 1 -r 16000 "$OUTPUT" &
  REC_PID=$!
  read -r
  kill $REC_PID 2>/dev/null
  wait $REC_PID 2>/dev/null
fi

if [ ! -f "$OUTPUT" ] || [ ! -s "$OUTPUT" ]; then
  echo "❌ Ses kaydı başarısız" >&2
  exit 1
fi

echo "✓ Kayıt tamamlandı"
