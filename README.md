# dotfiles

macOS の設定ファイルを管理するリポジトリ。

## 管理対象

| パス | 内容 |
|------|------|
| `.config/aerospace/` | AeroSpace (ウィンドウマネージャー) |
| `.config/nvim/` | Neovim |
| `.config/sketchbar/` | SketchyBar |
| `.config/wezterm/` | WezTerm |
| `.config/zsh/` | Zsh (`.zshrc`, `.zprofile`) |
| `.zshenv` | Zsh 起動時に `ZDOTDIR` を設定 |

## 管理対象外（ホームに直接置く）

| ファイル | 理由 |
|----------|------|
| `~/.gitconfig` | メールアドレス等の個人情報を含むため |
| `~/.config/gh/` | GitHub CLI のトークンを含むため |
| `~/.config/vscode/` | 拡張機能トークン等を含む可能性があるため |

## 新しい Mac でのセットアップ手順

### 1. Homebrew をインストール

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. このリポジトリをクローン

```bash
git clone https://github.com/taka727/dotfiles.git ~/dotfiles
```

### 3. GNU Stow をインストール

```bash
brew install stow
```

### 4. Stow でシンボリックリンクを作成

```bash
cd ~/dotfiles
stow . --target=$HOME
```

これで `~/dotfiles/.config/` 以下のディレクトリが `~/.config/` にリンクされ、
`~/.zshenv` も `~/dotfiles/.zshenv` へのリンクになる。

### 5. gitconfig を設定

管理対象外のため手動で設定する。

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### 6. フォントをインストール

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

### 7. アプリをインストール

```bash
brew install --cask ghostty wezterm
```

## Stow の使い方

新しい設定ファイルを追加したあとにリンクを更新する場合:

```bash
cd ~/dotfiles
stow . --target=$HOME --restow
```

特定のディレクトリだけリンクしたい場合（dotfiles 直下のディレクトリを指定）:

```bash
stow .config/wezterm --target=$HOME/.config
```
