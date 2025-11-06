# tool-wrappers.zsh
# Wrapper functions for build tools

# 🔧 Gradle Wrapper Helper
__zap_gradle() {
  local project_dir=$(__zap_find_project_file build.gradle)
  if [[ -z "$project_dir" ]]; then
    echo "❌ Error: No build.gradle found in current or child directories"
    return 1
  fi
  "$project_dir/gradlew" --project-dir "$project_dir" "$@"
}

# 🔧 npm Helper
__zap_npm() {
  local project_dir=$(__zap_find_project_file package.json)
  if [[ -z "$project_dir" ]]; then
    echo "❌ Error: No package.json found in current or child directories"
    return 1
  fi
  npm --prefix "$project_dir" "$@"
}

# 🔁 Tools, die automatisch ersetzt werden
typeset -gA __zap_command_wrappers
__zap_command_wrappers=(
  gradle '__zap_gradle'
  npm    '__zap_npm'
)
