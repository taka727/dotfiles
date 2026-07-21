# dotfiles

macOS の設定ファイルを管理するリポジトリ。

## 管理対象

| パス | 内容 |
|------|------|
| `.config/aerospace/` | AeroSpace (ウィンドウマネージャー) |
| `.config/bin/` | 自作スクリプト（`gcal-watch` など） |
| `.config/borders/` | JankyBorders (フォーカス中ウィンドウの枠線) |
| `.config/karabiner/` | Karabiner-Elements (キーリマップ) |
| `.config/lazygit/` | lazygit |
| `.config/nvim/` | Neovim |
| `.config/sketchybar/` | SketchyBar |
| `.config/wezterm/` | WezTerm |
| `.config/zsh/` | Zsh (`.zshrc`, `.zprofile`) |
| `.zshenv` | Zsh 起動時に `ZDOTDIR` を設定 |
| `Brewfile` | `brew bundle` でインストールするパッケージ・アプリ一覧 |
| `.claude/` | Claude Code の設定・スクリプト |

## 管理対象外（ホームに直接置く）

| ファイル | 理由 |
|----------|------|
| `~/.gitconfig` | メールアドレス等の個人情報を含むため |
| `~/.config/gh/` | GitHub CLI のトークンを含むため |
| `~/.config/vscode/` | 拡張機能トークン等を含む可能性があるため |
| `~/.config/zsh/.zsh_history` | シェルの実行履歴を含むため |
| `~/.config/karabiner/automatic_backups/` | Karabiner-Elements が自動生成するバックアップのため |

## 新しい Mac でのセットアップ手順

### 1. Homebrew をインストール

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. このリポジトリをクローン

```bash
git clone https://github.com/taka727/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. brew bundle でパッケージ・アプリを一括インストール

`Brewfile` に GNU Stow、CLI ツール、AeroSpace / SketchyBar / JankyBorders / WezTerm / Ghostty / Karabiner-Elements・フォントまで全て定義されている。

```bash
brew bundle
```

### 4. Stow でシンボリックリンクを作成

```bash
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

### 6. GUI アプリの初回起動と権限付与

AeroSpace / SketchyBar / JankyBorders / Karabiner-Elements は初回起動時に
アクセシビリティ・入力監視などの権限をシステム設定から手動で許可する必要がある。

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
