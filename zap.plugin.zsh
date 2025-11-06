# ~/.oh-my-zsh/plugins/zap/zap.plugin.zsh

# ZAP – Projektbasierte dynamische Aliase

typeset -gA __zap_aliases
typeset -gA __zap_command_wrappers

# 🔍 Findet Datei via Breadth-First Search (aufwärts)
__zap_find_project_file() {
  local target_file="$1"
  local search_dir="${2:-$PWD}"

  while [[ "$search_dir" != "/" ]]; do
    if [[ -f "$search_dir/$target_file" ]]; then
      echo "$search_dir"
      return 0
    fi
    search_dir="${search_dir:h}"
  done
  return 1
}

# 🔁 Tools, die automatisch ersetzt werden
__zap_command_wrappers=(
  gradle '$(__zap_find_project_file build.gradle)/gradlew --project-dir $(__zap_find_project_file build.gradle)'
  npm    'npm --prefix $(__zap_find_project_file package.json)'
)

# 📂 Plugin-Verzeichnis ermitteln (zur Laufzeit)
ZAP_PLUGIN_DIR="$(cd -- "${${(%):-%x}:a:h}" && pwd)"

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
  git -C "$ZAP_PLUGIN_DIR" fetch --tags --quiet
  git -C "$ZAP_PLUGIN_DIR" pull --quiet && echo "✅ ZAP updated."
  local version=$(git -C "$ZAP_PLUGIN_DIR" tag -l --sort=-version:refname | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | head -1 2>/dev/null)
  [[ -n "$version" ]] && echo "$version" > "$HOME/.zap_version"
  rm -f "$HOME/.zap_version_seen"
}

# 🔔 Automatische Update-Erinnerung
zap_check_version() {
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
      zap_upgrade
    else
      echo "$latest" > "$seen_file"
      echo "💡 You can update anytime with: zap upgrade"
    fi
    echo ""
  fi
}

# ➕ zap Subcommand
zap() {
  case "$1" in
    upgrade)
      zap_upgrade
      ;;
    --version)
      local version=$(git -C "$ZAP_PLUGIN_DIR" tag -l --sort=-version:refname | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | head -1 2>/dev/null)
      echo "zap $version"
      ;;
    global)
      # Erstelle Template, falls .commands nicht existiert
      if [[ ! -f "$HOME/.commands" ]]; then
        cat > "$HOME/.commands" <<'EOF'
# ZAP - Project-based Dynamic Aliases
# ZSH Plugin
# https://github.com/hajir3/zap
# Alias Format: alias_name=command

# === Gradle Commands ===
build=gradle build
test=gradle test
boot=gradle bootRun
clean=gradle clean
cbuild=gradle clean build

# === npm Commands ===
run=npm run dev
lint=npm run lint
format=npm run format
check=npm run check

# === Git Commands ===
dev=git checkout dev && git pull
main=git checkout main && git pull
status=git status
cout=git checkout
pull=git pull
push=git push
EOF
        echo "✨ Created ~/.commands file"
      fi
      nano "$HOME/.commands"
      ;;
    set)
      # Erstelle Template für lokales .commands, falls nicht existiert
      if [[ ! -f "$PWD/.commands" ]]; then
        cat > "$PWD/.commands" <<'EOF'
              # ZAP - Project-based Dynamic Aliases
              # ZSH Plugin
              # https://github.com/hajir3/zap
              # Alias Format: alias_name=command

EOF
        echo "✨ Created .commands with template"
      fi
      nano "$PWD/.commands"
      ;;
    "" | help)
      echo "Available zap commands:"
      echo "  zap upgrade     Pull latest plugin updates"
      echo "  zap --version   Show current version"
      echo "  zap global      Edit global .commands file"
      echo "  zap set         Edit local .commands file"
      ;;
    *)
      echo "Unknown command: $1"
      echo "Available commands: upgrade, --version, global, set, help"
      ;;
  esac
} 

# 🔄 Automatisch bei Verzeichniswechsel laden
autoload -U add-zsh-hook
add-zsh-hook chpwd zap_load

# 🟢 Initiales Laden
zap_load
zap_check_version
