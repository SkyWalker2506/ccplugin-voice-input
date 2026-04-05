#!/bin/bash
# Sessizlik tespiti ile kayıt — Enter'a basınca da durur
OUTPUT="${1:-/tmp/voice_input.wav}"
DURATION="${2:-30}"  # max saniye

sox -d -r 16000 -c 1 "$OUTPUT" silence 1 0.1 1% 1 1.5 1% trim 0 "$DURATION" &
SOX_PID=$!

echo "🎤 Konuşun... (Enter ile bitir, max ${DURATION}s)"
read -r

kill $SOX_PID 2>/dev/null
wait $SOX_PID 2>/dev/null

if [ ! -f "$OUTPUT" ] || [ ! -s "$OUTPUT" ]; then
  echo "❌ Ses kaydı başarısız — sox kurulu mu? (brew install sox)" >&2
  exit 1
fi

echo "✓ Kayıt tamamlandı: $OUTPUT"
