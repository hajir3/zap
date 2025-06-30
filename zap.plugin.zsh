# ~/.oh-my-zsh/plugins/zap/zap.plugin.zsh

# ZAP – Projektbasierte dynamische Aliase

typeset -gA __zap_aliases           # speichert aktive Aliase
typeset -gA __zap_command_wrappers  # Tool-Ersetzungen

# 🔁 Tools, die automatisch ersetzt werden
__zap_command_wrappers=(
  gradle '$(git rev-parse --show-toplevel)/gradlew --project-dir $(git rev-parse --show-toplevel)'
  npm    'npm --prefix $(git rev-parse --show-toplevel)/frontend'
)

# 🔄 Entfernt alte Aliase
zap_clear_aliases() {
  for name in "${(@k)__zap_aliases}"; do
    unalias "$name" 2>/dev/null
  done
  __zap_aliases=()
}

# 📥 Lädt globale und lokale .commands
zap_load() {
  zap_clear_aliases

  for config_file in "$HOME/.commands" "$PWD/.commands"; do
    [[ -f "$config_file" ]] || continue

    while IFS="=" read -r name cmd; do
      [[ -n "$name" && -n "$cmd" ]] || continue

      local tool="${cmd%% *}"
      local rest="${cmd#"$tool"}"

      local resolved_cmd="$cmd"
      if [[ -n "${__zap_command_wrappers[$tool]}" ]]; then
        resolved_cmd="${__zap_command_wrappers[$tool]}${rest}"
      fi

      alias "$name"="$resolved_cmd"
      __zap_aliases["$name"]=1
    done < "$config_file"
  done
}

# 🔼 Manuelles Update
zap_upgrade() {
  local plugin_dir="${0:a:h}"
  git -C "$plugin_dir" pull --quiet && echo "✅ ZAP updated."
  [[ -f "$plugin_dir/VERSION" ]] && <"$plugin_dir/VERSION" > "$HOME/.zap_version"
  rm -f "$HOME/.zap_version_seen"
}

# 🔔 Automatische Update-Erinnerung
zap_check_version() {
  local plugin_dir="${0:a:h}"
  local version_file="$plugin_dir/VERSION"
  local seen_file="$HOME/.zap_version_seen"
  local current_file="$HOME/.zap_version"

  [[ -f "$version_file" ]] || return

  local latest=$(git -C "$plugin_dir" describe --tags --abbrev=0 2>/dev/null)
  local seen=""
  [[ -f "$seen_file" ]] && seen=$(<"$seen_file")
  local current=""
  [[ -f "$current_file" ]] && current=$(<"$current_file")

  if [[ "$latest" != "$seen" && "$latest" != "$current" ]]; then
    echo "\n⚡ ZAP update $latest available."
    echo -n "Update now? (y/n): "
    read -r reply
    if [[ "$reply" == [Yy] ]]; then
      zap_upgrade
    else
      echo "$latest" > "$seen_file"
    fi
    echo ""
  fi
}

# ➕ zap upgrade Subcommand
zap() {
  case "$1" in
    upgrade) zap_upgrade ;;
    *) echo "Usage: zap upgrade" ;;
  esac
}

# 🔄 Automatisch bei Verzeichniswechsel laden
autoload -U add-zsh-hook
add-zsh-hook chpwd zap_load

# 🟢 Initiales Laden
zap_load
zap_check_version
