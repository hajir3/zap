# file-finder.zsh
# Utilities for finding project files

# 🔍 Findet Datei im aktuellen oder in Child-Verzeichnissen
__zap_find_project_file() {
  local target_file="$1"
  local search_dir="${2:-$PWD}"

  # Erst im aktuellen Verzeichnis suchen
  if [[ -f "$search_dir/$target_file" ]]; then
    echo "$search_dir"
    return 0
  fi

  # Dann in direkten Child-Verzeichnissen suchen
  local found_dir
  found_dir=$(find "$search_dir" -maxdepth 2 -type f -name "$target_file" 2>/dev/null | head -1)
  if [[ -n "$found_dir" ]]; then
    echo "${found_dir:h}"
    return 0
  fi
  
  return 1
}
