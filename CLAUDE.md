# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

GNU Stow で管理する macOS dotfiles。リポジトリルートで `stow . --target=$HOME` を実行すると、`~/dotfiles/.config/` が `~/.config/` に、`~/dotfiles/.zshenv` が `~/.zshenv` にシンボリックリンクされる。

## Stow コマンド

```bash
# 初回セットアップ・ファイル追加後にリンクを作成
stow . --target=$HOME

# ファイル追加・移動後にリンクを更新
stow . --target=$HOME --restow

# 特定のサブディレクトリだけリンク
stow .config/wezterm --target=$HOME/.config
```

## パッケージインストール

```bash
brew bundle
```

## アーキテクチャ

### Zsh
- `.zshenv` — 全シェル起動時に最初に読まれる。`ZDOTDIR=$HOME/.config/zsh` のみ設定
- `.config/zsh/.zprofile` — ログインシェル用（Homebrew パス設定）
- `.config/zsh/.zshrc` — インタラクティブシェル用。プロンプト、エイリアス、プラグイン読み込み、`chpwd` フックでディレクトリ移動時に git ログと Claude Memory を表示

### Neovim (`.config/nvim/`)
- `init.lua` が lazy.nvim をブートストラップし、`config/` と `plugins/` を読み込む
- `lua/config/options.lua` / `lua/config/keymaps.lua` — 基本設定。`<Leader>` は `<Space>`
- `lua/plugins/` — 関心ごとにファイル分割: `colorscheme`、`editor`（Telescope + Treesitter）、`lsp`（Mason → mason-lspconfig → nvim-lspconfig + nvim-cmp）、`git`、`markdown`、`terminal`
- LSP サーバーは Mason で管理: `lua_ls`、`ts_ls`、`pyright`

### WezTerm (`.config/wezterm/`)
- `wezterm.lua` がエントリポイント。6つのモジュールを `require()` して config builder に適用する
- AeroSpace の起動・終了は WezTerm の `gui-startup` / `gui-shutdown` / `window-close-requested` イベント経由で制御

### SketchyBar (`.config/sketchybar/`)
- `sketchybarrc` は bash スクリプト。プラグインスクリプトは `plugins/` 以下
- テーマ: Tokyo Night（背景 `#1a1b26`、アイコン `#7aa2f7`）
- レイアウト: スペース（左）→ フロントアプリ名（中央）→ 時計 / バッテリー / 音量（右）

### AeroSpace (`.config/aerospace/`)
- ウィンドウマネージャー。モニターフォーカスとノード移動のバインドのみ設定（`alt-left/right`、`alt-shift-left/right`）

## 管理対象外のファイル

| ファイル / ディレクトリ | 理由 |
|------------------------|------|
| `~/.gitconfig` | 氏名・メールアドレス等の個人情報を含む |
| `~/.config/gh/` | GitHub CLI のトークンを含む |
| `~/.config/vscode/` | 拡張機能トークン等を含む可能性がある |
