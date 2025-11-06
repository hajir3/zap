# commands.zsh
# Main zap command implementation

# 📝 Öffnet globale .commands mit Template
__zap_edit_global() {
  if [[ ! -f "$HOME/.commands" ]]; then
    cp "$ZAP_PLUGIN_DIR/templates/global.commands" "$HOME/.commands"
    echo "✨ Created ~/.commands file"
  fi
  ${EDITOR:-nano} "$HOME/.commands"
}

# 📝 Öffnet lokale .commands mit Template
__zap_edit_local() {
  if [[ ! -f "$PWD/.commands" ]]; then
    cp "$ZAP_PLUGIN_DIR/templates/local.commands" "$PWD/.commands"
    echo "✨ Created .commands with template"
  fi
  ${EDITOR:-nano} "$PWD/.commands"
}

# 📌 Zeigt aktuelle Version
__zap_show_version() {
  local version=$(git -C "$ZAP_PLUGIN_DIR" tag -l --sort=-version:refname | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | head -1 2>/dev/null)
  echo "zap $version"
}

# ℹ️ Zeigt Hilfe
__zap_show_help() {
  echo "Available zap commands:"
  echo "  zap upgrade     Pull latest plugin updates"
  echo "  zap --version   Show current version"
  echo "  zap global      Edit global .commands file"
  echo "  zap set         Edit local .commands file"
}

# ➕ zap Hauptkommando
zap() {
  case "$1" in
    upgrade)
      __zap_upgrade
      ;;
    --version)
      __zap_show_version
      ;;
    global)
      __zap_edit_global
      ;;
    set)
      __zap_edit_local
      ;;
    "" | help)
      __zap_show_help
      ;;
    *)
      echo "Unknown command: $1"
      echo "Available commands: upgrade, --version, global, set, help"
      return 1
      ;;
  esac
}
