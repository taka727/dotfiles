
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

export PATH="$HOME/.local/bin:$PATH"

# mise のシムを PATH に追加（非対話シェルや GUI から起動したツールでも mise 管理の node 等を使えるようにする）
# 対話シェルでは .zshrc の `mise activate` が上書きする
eval "$(/opt/homebrew/bin/mise activate zsh --shims)"
