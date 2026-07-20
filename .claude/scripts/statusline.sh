#!/bin/bash
# Claude Code statusLine script
# Claude Code passes session context as JSON via stdin

context=$(cat 2>/dev/null)

parts=()

if command -v jq &>/dev/null && [ -n "$context" ]; then
  # --- モデル名 ---
  model=$(echo "$context" | jq -r '.model.display_name // ""' 2>/dev/null)
  [ -n "$model" ] && parts+=("⬡ ${model}")

  # --- レート制限使用率（Pro/Max プランのみ。セッション初回応答後から入る）---
  five_h=$(echo "$context" | jq -r '.rate_limits.five_hour.used_percentage // ""' 2>/dev/null)
  seven_d=$(echo "$context" | jq -r '.rate_limits.seven_day.used_percentage // ""' 2>/dev/null)
  five_reset=$(echo "$context" | jq -r '.rate_limits.five_hour.resets_at // ""' 2>/dev/null)

  if [ -n "$five_h" ]; then
    limits=$(printf '5h %.0f%%' "$five_h")
    if [ -n "$five_reset" ]; then
      reset_hm=$(date -r "${five_reset%.*}" '+%H:%M' 2>/dev/null)
      [ -n "$reset_hm" ] && limits+=" (→${reset_hm})"
    fi
    [ -n "$seven_d" ] && limits+="  $(printf '7d %.0f%%' "$seven_d")"
    parts+=("$limits")
  fi
fi

# --- 時刻 ---
parts+=("$(date '+%H:%M')")

# --- Git ブランチ ---
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
[ -n "$branch" ] && parts+=(" $branch")

# --- 起動中 Docker コンテナ数 ---
if command -v docker &>/dev/null; then
  count=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
  [ "$count" -gt 0 ] && parts+=("🐳 ×${count}")
fi

# --- Node バージョン ---
if command -v node &>/dev/null; then
  node_ver=$(node -v 2>/dev/null)
  [ -n "$node_ver" ] && parts+=(" ${node_ver}")
fi

# 区切り文字で結合して出力
printf '%s' "$(IFS='  '; echo "${parts[*]}")"
