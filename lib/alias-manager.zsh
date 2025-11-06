# alias-manager.zsh
# Manages dynamic aliases

typeset -gA __zap_aliases

# 🔄 Entfernt alte Aliase
__zap_clear_aliases() {
  for name in "${(@k)__zap_aliases}"; do
    unalias "$name" 2>/dev/null
  done
  __zap_aliases=()
}

# 📥 Lädt globale und lokale .commands
__zap_load_aliases() {
  __zap_clear_aliases

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
