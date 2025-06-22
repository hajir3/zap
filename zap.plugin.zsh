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

# 📥 Lädt lokale oder globale .commands und setzt Aliase
zap_load() {
  local config_file

  if [[ -f "$PWD/.commands" ]]; then
    config_file="$PWD/.commands"
  elif [[ -f "$HOME/.commands" ]]; then
    config_file="$HOME/.commands"
  else
    return
  fi

  zap_clear_aliases

  while IFS="=" read -r name cmd; do
    [[ -n "$name" && -n "$cmd" ]] || continue

    local tool="${cmd%% *}"     # Erstes Wort
    local rest="${cmd#"$tool"}" # Rest

    local resolved_cmd="$cmd"
    if [[ -n "${__zap_command_wrappers[$tool]}" ]]; then
      resolved_cmd="${__zap_command_wrappers[$tool]}${rest}"
    fi

    alias "$name"="$resolved_cmd"
    __zap_aliases["$name"]=1
  done < "$config_file"
}

# 🔄 Automatisch bei Verzeichniswechsel laden
autoload -U add-zsh-hook
add-zsh-hook chpwd zap_load

# 🟢 Beim Start direkt laden
zap_load

