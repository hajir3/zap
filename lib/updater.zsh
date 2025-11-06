# updater.zsh
# Plugin update functionality

# 🔼 Manuelles Update
__zap_upgrade() {
  git -C "$ZAP_PLUGIN_DIR" fetch --tags --quiet
  git -C "$ZAP_PLUGIN_DIR" pull --quiet && echo "✅ ZAP updated."
  local version=$(git -C "$ZAP_PLUGIN_DIR" tag -l --sort=-version:refname | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | head -1 2>/dev/null)
  [[ -n "$version" ]] && echo "$version" > "$HOME/.zap_version"
  rm -f "$HOME/.zap_version_seen"
}

# 🔔 Automatische Update-Erinnerung
__zap_check_version() {
  git -C "$ZAP_PLUGIN_DIR" fetch --tags --quiet 2>/dev/null
  local latest=$(git -C "$ZAP_PLUGIN_DIR" tag -l --sort=-version:refname | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | head -1 2>/dev/null)
  local seen_file="$HOME/.zap_version_seen"
  local current_file="$HOME/.zap_version"
  local seen=""
  [[ -f "$seen_file" ]] && seen=$(<"$seen_file")
  local current=""
  [[ -f "$current_file" ]] && current=$(<"$current_file")

  if [[ "$latest" != "$seen" && "$latest" != "$current" ]]; then
    echo "\n⚡ ZAP update $latest available."
    echo -n "Update now? (y/n): "
    read -r reply
    if [[ "$reply" == [Yy] ]]; then
      __zap_upgrade
    else
      echo "$latest" > "$seen_file"
      echo "💡 You can update anytime with: zap upgrade"
    fi
    echo ""
  fi
}
