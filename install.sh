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

if ! command -v sox &>/dev/null; then
  echo "📦 sox kuruluyor..."
  brew install sox
else
  echo "✓ sox zaten kurulu"
fi

echo ""
echo "Whisper backend seçin:"
echo "  1) whisper.cpp (local, ücretsiz, önerilen)"
echo "  2) OpenAI Whisper API (cloud, API key gerekli)"
echo "  3) Apple Speech Recognition (local, ek kurulum yok)"
echo ""
read -p "Seçim [1/2/3, default: 1]: " CHOICE
CHOICE="${CHOICE:-1}"

BACKEND=""
case "$CHOICE" in
  1)
    BACKEND="whisper-cpp"
    if ! command -v whisper-cpp &>/dev/null; then
      echo "📦 whisper-cpp kuruluyor..."
      brew install whisper-cpp
      echo ""
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
  2)
    BACKEND="openai"
    if ! python3 -c "import openai" &>/dev/null; then
      pip3 install openai
    fi
    SECRETS_FILE="$HOME/.claude/secrets/secrets.env"
    if ! grep -q "OPENAI_API_KEY" "$SECRETS_FILE" 2>/dev/null; then
      read -p "OpenAI API key girin (sk-...): " API_KEY
      if [ -n "$API_KEY" ]; then
        mkdir -p "$(dirname "$SECRETS_FILE")"
        echo "export OPENAI_API_KEY=\"$API_KEY\"" >> "$SECRETS_FILE"
        echo "✓ API key eklendi"
      fi
    fi
    ;;
  3)
    BACKEND="apple"
    echo "✓ Apple Speech — ek kurulum yok"
    ;;
  *)
    echo "❌ Geçersiz seçim"; exit 1
    ;;
esac

echo ""
echo "📁 Kopyalanıyor: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR/scripts" "$INSTALL_DIR/commands" "$INSTALL_DIR/.claude-plugin"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "$SCRIPT_DIR/scripts/"*.sh "$INSTALL_DIR/scripts/"
cp "$SCRIPT_DIR/commands/"*.md "$INSTALL_DIR/commands/"
cp "$SCRIPT_DIR/.claude-plugin/plugin.json" "$INSTALL_DIR/.claude-plugin/"
[ -f "$SCRIPT_DIR/apple_speech.swift" ] && cp "$SCRIPT_DIR/apple_speech.swift" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/scripts/"*.sh

echo "export VOICE_BACKEND=\"$BACKEND\"" > "$INSTALL_DIR/.env"

echo ""
echo "✅ Kurulum tamamlandı!"
echo "Kullanım: /voice (Claude Code'da)"
echo "Backend: $BACKEND"
