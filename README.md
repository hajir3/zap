# zap

**Project-based aliases**, driven by a simple `.commands` file.
This plugin automatically loads commands when you change directories and makes them available as shell commands.

---

## 🔧 Features

- Automatic alias generation
- Local `.commands` file per project
- Global support via `~/.commands`
- Smart wrappers for `gradle`, `npm`, and more

---

## 📦 Installation

### Manual (Oh My Zsh)

```bash
git clone https://github.com/hajir3/zap ~/.oh-my-zsh/custom/plugins/zap
```

Add zap to the plugins in your ~/.zshrc:

```bash
plugins=(... zap)
```

Reload the configuration:

```bash
source ~/.zshrc
```

## ✅ License

MIT © 2025 [[hajir3](https://github.com/hajir3)]
