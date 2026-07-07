# --- Homebrew Path ---
eval "$(/opt/homebrew/bin/brew shellenv)"

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
