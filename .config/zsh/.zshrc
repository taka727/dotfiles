# --- Homebrew Path ---
eval "$(/opt/homebrew/bin/brew shellenv)"

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

PROMPT='$(inline_nix_status)%F{cyan}%n%f:%F{yellow}%~%f ${vcs_info_msg_0_}$ '

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
