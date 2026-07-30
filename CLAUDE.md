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
- `lua/plugins/` — 関心ごとにファイル分割: `colorscheme`、`editor`（Telescope + Treesitter）、`lsp`（Mason → mason-lspconfig → nvim-lspconfig + nvim-cmp）、`git`、`markdown`、`terminal`、`ime`（im-select で挿入モード離脱時に英字入力へ切替）
- LSP サーバーは Mason で管理: `lua_ls`、`ts_ls`、`pyright`

### WezTerm (`.config/wezterm/`)
- `wezterm.lua` がエントリポイント。6つのモジュールを `require()` して config builder に適用する
- AeroSpace の有効/無効切り替えは `keymaps.lua` の `LEADER+a`（`aerospace enable toggle`）で手動操作する

### SketchyBar (`.config/sketchybar/`)
- 設定は SbarLua（Lua バインディング）で書かれている。`sketchybarrc` が `~/.local/share/sketchybar_lua/sketchybar.so` を `require` し、`init.lua` → `bar.lua`/`default.lua`/`items/init.lua` を読み込む
- SbarLua本体とビルド済み `lua` インタープリタはリポジトリ管理外（マシンごとにソースからビルドが必要、手順は README 参照）
- テーマ: Tokyo Night（背景 `#1a1b26`、アイコン `#7aa2f7`）
- レイアウト: スペース（左、AeroSpaceのワークスペースと連動）→ フロントアプリ名（中央）→ 時計 / バッテリー / 音量（右）
- AeroSpace側の `exec-on-workspace-change` / `after-startup-command`（`.config/aerospace/aerospace.toml`）と連携している

### AeroSpace (`.config/aerospace/`)
- ウィンドウマネージャー。モニターフォーカス・ノード移動（`alt-left/right`、`alt-shift-left/right`）に加えて、フルスクリーン切替（`alt-f`）、リサイズモード（`alt-r`）、新規ワークスペースへの移動（`alt-shift-n`）、直前のワークスペースに戻る（`alt-shift-b`）を設定
- `after-startup-command` で起動時に SketchyBar を起動、`exec-on-workspace-change` でワークスペース切り替えを SketchyBar に通知（`.config/sketchybar/items/spaces.lua` が購読）

## 管理対象外のファイル

| ファイル / ディレクトリ | 理由 |
|------------------------|------|
| `~/.gitconfig` | 氏名・メールアドレス等の個人情報を含む |
| `~/.config/gh/` | GitHub CLI のトークンを含む |
| `~/.config/vscode/` | 拡張機能トークン等を含む可能性がある |
| `~/.config/zsh/.zsh_history` | シェルの実行履歴。コマンドに含まれる情報が漏れる可能性がある |
| `~/.config/zsh/.zcompdump`、`.zcompcache/` | zsh の補完キャッシュ。環境ごとに自動生成される |
| `~/.config/karabiner/automatic_backups/` | Karabiner-Elements が自動生成するバックアップ |
