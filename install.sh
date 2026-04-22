#!/bin/bash
set -e

PLUGIN_NAME="voice-input"
INSTALL_DIR="$HOME/.claude/plugins/$PLUGIN_NAME"

echo "🎤 ccplugin-voice-input kurulum başlıyor..."
echo ""

if [ "$(uname)" != "Darwin" ]; then
  echo "❌ Bu plugin yalnızca macOS destekler."
  exit 1
fi

# Backend argümandan veya env'den al, yoksa interaktif sor
BACKEND="${VOICE_BACKEND:-${1:-}}"

if [ -z "$BACKEND" ]; then
  if [ -t 0 ]; then
    # İnteraktif terminal
    echo "Whisper backend seçin:"
    echo "  1) whisper.cpp (local, ücretsiz, önerilen)"
    echo "  2) OpenAI Whisper API (cloud, API key gerekli)"
    echo "  3) Apple Speech Recognition (local, ek kurulum yok)"
    echo ""
    read -p "Seçim [1/2/3, default: 3]: " CHOICE
    CHOICE="${CHOICE:-3}"
    case "$CHOICE" in
      1) BACKEND="whisper-cpp" ;;
      2) BACKEND="openai" ;;
      3) BACKEND="apple" ;;
      *) echo "❌ Geçersiz seçim"; exit 1 ;;
    esac
  else
    # Non-interaktif — Apple Speech varsayılan
    BACKEND="apple"
    echo "ℹ️  Non-interaktif mod — Apple Speech backend seçildi"
    echo "   Değiştirmek için: VOICE_BACKEND=whisper-cpp bash install.sh"
  fi
fi

# Backend kurulumu
case "$BACKEND" in
  whisper-cpp)
    if ! command -v sox &>/dev/null; then brew install sox; fi
    if ! command -v whisper-cpp &>/dev/null; then
      echo "📦 whisper-cpp kuruluyor..."
      brew install whisper-cpp
      echo "📥 Türkçe base model indiriliyor (~140MB)..."
      MODEL_DIR="$(brew --prefix)/share/whisper-cpp/models"
      mkdir -p "$MODEL_DIR"
      if [ ! -f "$MODEL_DIR/ggml-base.bin" ]; then
        curl -L -o "$MODEL_DIR/ggml-base.bin" \
          "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin"
      fi
    else
      echo "✓ whisper-cpp zaten kurulu"
    fi
    ;;
  openai)
    if ! command -v sox &>/dev/null; then brew install sox; fi
    python3 -c "import openai" 2>/dev/null || pip3 install openai
    SECRETS_FILE="$HOME/.claude/secrets/secrets.env"
    if ! grep -q "OPENAI_API_KEY" "$SECRETS_FILE" 2>/dev/null; then
      if [ -t 0 ]; then
        read -p "OpenAI API key girin (sk-...): " API_KEY
        if [ -n "$API_KEY" ]; then
          mkdir -p "$(dirname "$SECRETS_FILE")"
          echo "export OPENAI_API_KEY=\"$API_KEY\"" >> "$SECRETS_FILE"
          echo "✓ API key eklendi"
        fi
      else
        echo "⚠️  OPENAI_API_KEY secrets.env'e ekleyin"
      fi
    fi
    ;;
  apple)
    echo "✓ Apple Speech — ek kurulum yok"
    ;;
esac

echo ""
echo "📁 Kopyalanıyor: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR/scripts" "$INSTALL_DIR/commands" "$INSTALL_DIR/.claude-plugin"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Aynı dizinse kopyalamaya gerek yok (marketplace zaten cloneladı)
if [ "$SCRIPT_DIR" != "$INSTALL_DIR" ]; then
  cp "$SCRIPT_DIR/scripts/"*.sh "$INSTALL_DIR/scripts/"
  # Copy Swift scripts
  for swf in "$SCRIPT_DIR/scripts/"*.swift; do
    [ -f "$swf" ] && cp "$swf" "$INSTALL_DIR/scripts/"
  done
  cp "$SCRIPT_DIR/commands/"*.md "$INSTALL_DIR/commands/"
  cp "$SCRIPT_DIR/.claude-plugin/plugin.json" "$INSTALL_DIR/.claude-plugin/"
  [ -f "$SCRIPT_DIR/apple_speech.swift" ] && cp "$SCRIPT_DIR/apple_speech.swift" "$INSTALL_DIR/"
fi
chmod +x "$INSTALL_DIR/scripts/"*.sh

LANG_DEFAULT="${VOICE_LANG:-tr-TR}"
DURATION_DEFAULT="${VOICE_DURATION:-10}"
cat > "$INSTALL_DIR/.env" <<EOF
export VOICE_BACKEND="$BACKEND"
export VOICE_LANG="${LANG_DEFAULT}"
export VOICE_DURATION="${DURATION_DEFAULT}"
EOF

echo ""
echo "✅ Kurulum tamamlandı! Backend: $BACKEND"
echo "Kullanım: /mic (Claude Code'da)"
