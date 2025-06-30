# zap

**Projektbasierte Aliase in Zsh**, gesteuert über eine einfache `.commands` Datei.
Dieses Plugin lädt beim Verzeichniswechsel automatisch Kommandos und macht sie direkt als Shell-Befehle verfügbar.

---

## 🔧 Features

- Lokale `.commands` Datei pro Projekt
- Global auf `~/.commands`
- Automatische Alias-Erzeugung
- Intelligente Ersetzung für `gradle`, `npm` u. a.

---

## 📦 Installation

### Manuell (Oh My Zsh)

```bash
git clone https://github.com/hajir3/zap ~/.oh-my-zsh/custom/plugins/zap
```

Füge zap zu den Plugins in deiner ~/.zshrc hinzu:

```bash
plugins=(... zap)
```

Lade die Konfiguration neu:
```bash
source ~/.zshrc
```


## ✅ Lizenz

MIT © 2025 [[hajir3](https://github.com/hajir3)]
