# --- Homebrew Path ---
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- mise (ランタイムのバージョン管理) ---
# Homebrew より後に評価して、mise 管理のツールを PATH の先頭に置く
# ディレクトリ移動時に mise.toml を読んでバージョンを自動切替する
eval "$(mise activate zsh)"

# --- WezTerm Shell Integration (ScrollToPromptを有効化) ---
if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
  local _wsi="/Applications/WezTerm.app/Contents/Resources/shell-integration.sh"
  [[ -f "$_wsi" ]] && source "$_wsi"
fi

# --- Zsh Auto Suggestions ---
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# --- Git Prompt Settings ---
autoload -Uz vcs_info
autoload -Uz compinit
compinit
precmd_vcs_info() { vcs_info }
precmd_functions+=(precmd_vcs_info)
setopt prompt_subst
zstyle ':vcs_info:git:*' formats '%F{green}(%b)%f'

if [ -n "$IN_NIX_SHELL" ]; then
  precmd_functions+=(precmd_vcs_info)
fi

# --- Prompt Customization (With Nix Detection) ---
# Nix環境内なら (nix) を頭に付け、外なら何も付けない動的プロンプト
inline_nix_status() {
  if [ -n "$IN_NIX_SHELL" ]; then
    echo "(nix)"
  fi
}

PROMPT='$(inline_nix_status)%F{cyan}%n%f:%F{yellow}%1~%f ${vcs_info_msg_0_}$ '

# --- Git Aliases ---
alias gs='git status'
alias gb='git branch'
alias gl='git log --oneline -n 10'

# --- Git TUI ---
alias lg='lazygit'

# --- GitHub CLI Aliases ---
alias prl='gh pr list'
alias prd='gh pr diff'
alias prv='gh pr view'
alias prc='gh pr create'
alias prco='gh pr checkout'

# --- Better CLI Tools ---
if command -v fzf &>/dev/null; then
  eval "$(fzf --zsh)"
fi
command -v bat &>/dev/null && alias cat='bat --paging=never'
command -v eza &>/dev/null && alias ls='eza --icons'
command -v eza &>/dev/null && alias ll='eza -la --icons --git'
command -v eza &>/dev/null && alias lt='eza --tree --icons -L 2'

# --- Startup Display ---
command -v fastfetch &>/dev/null && fastfetch

# --- Git Repo Info on cd ---
_last_git_root=""

_show_git_repo_info() {
  local git_root
  git_root=$(git rev-parse --show-toplevel 2>/dev/null)

  if [ -n "$git_root" ] && [ "$git_root" != "$_last_git_root" ]; then
    _last_git_root="$git_root"
    echo ""
    echo "\033[33m── $(basename "$git_root") $(printf '─%.0s' {1..40})\033[0m" | head -c 60
    echo "\033[0m"
    git log --oneline -5 2>/dev/null
    local memory_dir="$HOME/.claude/projects/$(echo "$git_root" | tr '/' '-')/memory"
    if [ -f "$memory_dir/MEMORY.md" ]; then
      echo ""
      echo "\033[35m── Claude Memory ──\033[0m"
      grep '^-' "$memory_dir/MEMORY.md" 2>/dev/null | head -8
    fi
    echo ""
  elif [ -z "$git_root" ] && [ -n "$_last_git_root" ]; then
    _last_git_root=""
  fi
}

chpwd_functions+=(_show_git_repo_info)
# 起動時にすでに git ディレクトリにいる場合も表示
_show_git_repo_info

# --- Herdr ---
# ~/Herdr を起点に起動する（プラグイン・スクリプト等は ~/Herdr、config.toml は ~/.config/herdr）
herd() { cd "$HOME/Herdr" && herdr "$@"; }

# --- Docker Aliases ---
alias ld='lazydocker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dlog='docker logs -f'
alias dex='docker exec -it'
alias dcp='docker compose'
alias dcup='docker compose up -d'
alias dcdn='docker compose down'
alias dcrst='docker compose down && docker compose up -d'

# --- agy Review Helpers (Greptile substitute) ---
# 使い方:
#   agy-review [追加の指示]   … ステージ済み差分 (git diff --cached) のクロスファイル影響レビュー
#   agy-pr-review [base]       … base ブランチ（省略時は origin/HEAD → main → master）からの PR 前レビュー
_agy_review_base() {
  local b
  if b=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null); then
    echo "$b"; return 0
  fi
  for b in main master; do
    git rev-parse --verify --quiet "$b" >/dev/null && { echo "$b"; return 0; }
  done
  return 1
}

agy-review() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "agy-review: git リポジトリ内で実行してください" >&2; return 1; }
  if git diff --cached --quiet; then
    echo "agy-review: ステージされた変更がありません（先に git add してください）" >&2; return 1
  fi
  agy --dangerously-skip-permissions -p "git diff --cached の変更点を読み取り、AGENTS.md のレビューガイドラインに従って、リポジトリ全体への波及影響や破壊的変更がないか厳格にレビューしてください。変更されたシンボルの呼び出し元はリポジトリ内を検索して確認してください。コードは一切編集せず、指摘のみを出力してください。${*:+ 追加の指示: $*}"
}

agy-pr-review() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "agy-pr-review: git リポジトリ内で実行してください" >&2; return 1; }
  local base mb
  base=${1:-$(_agy_review_base)} || { echo "agy-pr-review: base ブランチを特定できません（引数で指定してください）" >&2; return 1; }
  mb=$(git merge-base "$base" HEAD) || { echo "agy-pr-review: $base との merge-base が見つかりません" >&2; return 1; }
  if git diff --quiet "$mb" HEAD; then
    echo "agy-pr-review: $base からの差分がありません" >&2; return 1
  fi
  agy --dangerously-skip-permissions -p "git diff ${mb}..HEAD（${base} からの分岐点〜HEAD の全変更）と git log --oneline ${mb}..HEAD を調査し、AGENTS.md のレビューガイドラインに従って、潜在的なバグ・型不整合・リポジトリ全体との不整合・アーキテクチャ上の懸念を網羅的にレビューしてレポートしてください。コードは一切編集せず、指摘のみを出力してください。"
}
