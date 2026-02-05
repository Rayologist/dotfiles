#!/bin/bash

# ============================================================================
# Claude Code Status Line Script
# ============================================================================
# Displays a two-line status showing:
# Line 1: Model, project path, and git information
# Line 2: Context usage progress bar, percentage, token counts, and cost
# ============================================================================

# --- Input Capture ---
payload=$(cat)

# Debug Mode: Uncomment to dump payload for debugging
# echo "$payload" > /tmp/claude_payload_dump.json

# --- Color Definitions ---
C_BLUE="\033[34m"
C_MAGENTA="\033[35m"
C_CYAN="\033[36m"
C_DARK_GRAY="\033[90m"
C_MEDIUM_GRAY="\033[38;2;115;121;148m"
C_GIT_SAND="\033[38;2;249;226;175m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_RED="\033[31m"
C_WHITE="\033[97m"
RESET="\033[0m"

# --- Extract Project Information ---
raw_path=$(echo "$payload" | jq -r '.workspace.project_name // .workspace.current_dir // "No Project"')
project_name="${raw_path/#$HOME/~}"

# --- Extract Git Information ---
branch=$(git branch --show-current 2>/dev/null)
git_info=""

if [ -n "$branch" ]; then
    git_render="${branch}"

    # Add dirty indicator if uncommitted changes exist
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        git_render="${git_render}*"
    fi

    # Add stash count if stashes exist
    stash_count=$(git stash list 2>/dev/null | wc -l)
    if [ "$stash_count" -gt 0 ]; then
        git_render="${git_render}${C_DARK_GRAY}  ${stash_count}${C_GIT_SAND}"
    fi
    
    # Ahead/Behind
    upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [ -n "$upstream" ]; then
        behind=$(git rev-list --count HEAD.."$upstream" 2>/dev/null || echo 0)
        ahead=$(git rev-list --count "$upstream"..HEAD 2>/dev/null || echo 0)
        arrow_str=""
        
        if [ "$behind" -gt 0 ] && [ "$ahead" -gt 0 ]; then
            arrow_str=" 󰹹 "
        elif [ "$behind" -gt 0 ]; then
            arrow_str="  "
        elif [ "$ahead" -gt 0 ]; then
            arrow_str="   "
        fi
        
        if [ -n "$arrow_str" ]; then
            git_render="${git_render}${C_CYAN}${arrow_str}${C_GIT_SAND}"
        fi
    fi
    git_info="${C_GIT_SAND}${git_render}${RESET}"
fi

# --- Extract Model Name ---
model=$(echo "$payload" | jq -r '.model.display_name // "Unknown"')

# --- Extract Token Usage and Cost ---
tokens_input=$(echo "$payload" | jq -r '.context_window.current_usage.input_tokens // 0')
tokens_output=$(echo "$payload" | jq -r '.context_window.current_usage.output_tokens // 0')
cache_creation=$(echo "$payload" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$payload" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
tokens_used=$((tokens_input + tokens_output + cache_creation + cache_read))
tokens_total=$(echo "$payload" | jq -r '.context_window.context_window_size // 0')
cost=$(echo "$payload" | jq -r '.cost.total_cost_usd // 0')

# --- Build Progress Bar ---
# Calculate percentage with safety check for division by zero
if [ "$tokens_total" -eq 0 ]; then
    pct=0
else
    pct=$((tokens_used * 100 / tokens_total))
fi
# Cap percentage at 100%
if [ "$pct" -gt 100 ]; then
    pct=100
fi

# Select bar color based on usage percentage
if [ "$pct" -lt 50 ]; then
    bar_color="$C_GREEN"
elif [ "$pct" -lt 80 ]; then
    bar_color="$C_YELLOW"
else
    bar_color="$C_RED"
fi

# Construct progress bar (20 characters wide)
bar_width=20
filled=$((pct * bar_width / 100))
empty=$((bar_width - filled))
bar_filled=$(printf "%${filled}s" | tr ' ' '━')
bar_empty=$(printf "%${empty}s" | tr ' ' '━')
progress_bar="${bar_color}${bar_filled}${C_DARK_GRAY}${bar_empty}${RESET}"

# --- Helper Function: Format Large Numbers (with decimal) ---
format_number_decimal() {
    local num=$1
    if [ "$num" -ge 1000000 ]; then
        printf "%.1fM" "$(echo "scale=1; $num / 1000000" | bc)"
    elif [ "$num" -ge 1000 ]; then
        printf "%.1fK" "$(echo "scale=1; $num / 1000" | bc)"
    else
        echo "$num"
    fi
}

# --- Helper Function: Format Large Numbers (no decimal) ---
format_number_int() {
    local num=$1
    if [ "$num" -ge 1000000 ]; then
        echo "$((num / 1000000))M"
    elif [ "$num" -ge 1000 ]; then
        echo "$((num / 1000))K"
    else
        echo "$num"
    fi
}

# --- Build Usage and Cost Displays ---
# Get daily usage from ccusage (if available)
daily_cost="0"
daily_tokens="0"
if command -v ccusage &> /dev/null; then
    daily_json=$(ccusage daily --json --since "$(date +%Y%m%d)" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$daily_json" ]; then
        daily_cost=$(echo "$daily_json" | jq -r '.totals.totalCost // 0' 2>/dev/null)
        daily_tokens=$(echo "$daily_json" | jq -r '.totals.totalTokens // 0' 2>/dev/null)
    fi
fi

# Token usage format: [used/total]
tokens_used_fmt=$(format_number_decimal "$tokens_used")
tokens_total_fmt=$(format_number_int "$tokens_total")
usage_display="${C_MEDIUM_GRAY}[${tokens_used_fmt}/${tokens_total_fmt}]${RESET}"

# Daily tokens display
daily_display=""
if [ "$daily_tokens" != "0" ] && [ "$daily_tokens" != "null" ] && [ -n "$daily_tokens" ]; then
    daily_tokens_fmt=$(format_number_decimal "$daily_tokens")
    daily_display=" ${C_MEDIUM_GRAY}❯${RESET} ${C_MEDIUM_GRAY}${daily_tokens_fmt} daily${RESET}"
fi

# Cost display: $session / $daily
# Always display cost, even when it's 0
if [ "$cost" = "null" ] || [ -z "$cost" ]; then
    cost="0"
fi
if [ "$daily_cost" = "null" ] || [ -z "$daily_cost" ]; then
    daily_cost="0"
fi
session_cost=$(printf "%.2f" "$cost")
daily_cost_fmt=$(printf "%.2f" "$daily_cost")
cost_display=" ${C_MEDIUM_GRAY}❯${RESET} ${C_MEDIUM_GRAY}\$${session_cost} / \$${daily_cost_fmt}${RESET}"

# --- Assemble Final Output ---
# Line 1: 󰚩 [model] [project] [git]
line1="${C_MAGENTA}󰚩 ${model}${RESET}"
line1="${line1}  ${C_BLUE}${project_name}${RESET}"

if [ -n "$git_info" ]; then
    line1="${line1} ${git_info}"
fi

# Line 2: Progress bar, percentage, token usage, daily tokens, cost
line2="${progress_bar} ${C_WHITE}${pct}%${RESET} ${usage_display}${daily_display}${cost_display}"

# Output both lines with newline
echo -e "${line1}\n${line2}"
