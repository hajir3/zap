#!/usr/bin/env zsh
# ZAP – Projektbasierte dynamische Aliase
# https://github.com/hajir3/zap

# 📂 Plugin-Verzeichnis ermitteln
ZAP_PLUGIN_DIR="${${(%):-%x}:a:h}"

# � Lade Module
source "$ZAP_PLUGIN_DIR/lib/file-finder.zsh"
source "$ZAP_PLUGIN_DIR/lib/tool-wrappers.zsh"
source "$ZAP_PLUGIN_DIR/lib/alias-manager.zsh"
source "$ZAP_PLUGIN_DIR/lib/updater.zsh"
source "$ZAP_PLUGIN_DIR/lib/commands.zsh"

# 🔄 Automatisch bei Verzeichniswechsel laden
autoload -U add-zsh-hook
add-zsh-hook chpwd __zap_load_aliases

# 🟢 Initiales Laden
__zap_load_aliases
__zap_check_version
