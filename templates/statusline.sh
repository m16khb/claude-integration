#!/bin/bash
# Claude Code Status Line Script
# Reads YAML config directly - Single Source of Truth
#
# Supported: macOS, Linux, Windows (Git Bash/WSL)
# Config: ~/.claude/statusline.yaml (optional)

set -o pipefail

# =============================================================================
# CONFIGURATION PATH
# =============================================================================
CONFIG_FILE="${STATUSLINE_CONFIG:-$HOME/.claude/statusline.yaml}"

# =============================================================================
# YAML PARSER (Pure Bash - No external dependencies)
# Parses simple YAML key: value pairs
# =============================================================================
yaml_get() {
    local file="$1" key="$2" default="$3"
    local value=""

    if [[ ! -f "$file" ]]; then
        echo "$default"
        return
    fi

    # Handle nested keys (e.g., "show.model", "colors.staged")
    if [[ "$key" == *.* ]]; then
        local parent="${key%%.*}"
        local child="${key#*.}"
        local in_section=false

        while IFS= read -r line || [[ -n "$line" ]]; do
            # Skip comments and empty lines
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${line// /}" ]] && continue

            # Check section start (no leading spaces)
            if [[ "$line" =~ ^([a-zA-Z_]+): ]]; then
                if [[ "${BASH_REMATCH[1]}" == "$parent" ]]; then
                    in_section=true
                else
                    in_section=false
                fi
                continue
            fi

            # In section, look for child key (with leading spaces)
            if $in_section && [[ "$line" =~ ^[[:space:]]+${child}:[[:space:]]*(.*)$ ]]; then
                value="${BASH_REMATCH[1]}"
                # Remove inline comments first (before quote removal)
                value="${value%%#*}"
                # Trim trailing whitespace (POSIX compatible)
                value="${value%"${value##*[![:space:]]}"}"
                # Remove quotes
                value="${value#\"}"
                value="${value%\"}"
                value="${value#\'}"
                value="${value%\'}"
                break
            fi
        done < "$file"
    else
        # Top-level key
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            if [[ "$line" =~ ^${key}:[[:space:]]*(.*)$ ]]; then
                value="${BASH_REMATCH[1]}"
                # Remove inline comments first (before quote removal)
                value="${value%%#*}"
                # Trim trailing whitespace (POSIX compatible)
                value="${value%"${value##*[![:space:]]}"}"
                # Remove quotes
                value="${value#\"}"
                value="${value%\"}"
                value="${value#\'}"
                value="${value%\'}"
                break
            fi
        done < "$file"
    fi

    echo "${value:-$default}"
}

# =============================================================================
# LOAD CONFIGURATION
# =============================================================================
load_config() {
    # Feature toggles
    COLORS_ENABLED=$(yaml_get "$CONFIG_FILE" "colors_enabled" "true")
    EMOJI_ENABLED=$(yaml_get "$CONFIG_FILE" "emoji_enabled" "true")

    # Display settings
    SHOW_MODEL=$(yaml_get "$CONFIG_FILE" "show.model" "true")
    SHOW_DIRECTORY=$(yaml_get "$CONFIG_FILE" "show.directory" "true")
    SHOW_BRANCH=$(yaml_get "$CONFIG_FILE" "show.branch" "true")
    SHOW_GIT_STATUS=$(yaml_get "$CONFIG_FILE" "show.git_status" "true")
    SHOW_COST=$(yaml_get "$CONFIG_FILE" "show.cost" "false")

    # Colors
    COLOR_MODEL=$(yaml_get "$CONFIG_FILE" "colors.model" "38;5;33")
    COLOR_SEP=$(yaml_get "$CONFIG_FILE" "colors.separator" "38;5;240")
    COLOR_COST=$(yaml_get "$CONFIG_FILE" "colors.cost" "38;5;220")
    COLOR_STAGED=$(yaml_get "$CONFIG_FILE" "colors.staged" "38;5;46")
    COLOR_MODIFIED=$(yaml_get "$CONFIG_FILE" "colors.modified" "38;5;208")
    COLOR_UNTRACKED=$(yaml_get "$CONFIG_FILE" "colors.untracked" "38;5;196")
    COLOR_BRANCH_MAIN=$(yaml_get "$CONFIG_FILE" "colors.branch_main" "38;5;46")
    COLOR_BRANCH_DEVELOP=$(yaml_get "$CONFIG_FILE" "colors.branch_develop" "38;5;51")
    COLOR_BRANCH_FEATURE=$(yaml_get "$CONFIG_FILE" "colors.branch_feature" "38;5;226")
    COLOR_BRANCH_HOTFIX=$(yaml_get "$CONFIG_FILE" "colors.branch_hotfix" "38;5;196")
    COLOR_BRANCH_RELEASE=$(yaml_get "$CONFIG_FILE" "colors.branch_release" "38;5;208")
    COLOR_BRANCH_STAGING=$(yaml_get "$CONFIG_FILE" "colors.branch_staging" "38;5;141")
    COLOR_BRANCH_DEFAULT=$(yaml_get "$CONFIG_FILE" "colors.branch_default" "38;5;33")

    # Emoji
    EMOJI_MODEL=$(yaml_get "$CONFIG_FILE" "emoji.model" "🤖")
    EMOJI_DIR=$(yaml_get "$CONFIG_FILE" "emoji.directory" "📂")
    EMOJI_BRANCH=$(yaml_get "$CONFIG_FILE" "emoji.branch" "🌿")
    EMOJI_COST=$(yaml_get "$CONFIG_FILE" "emoji.cost" "💰")

    # Format
    MAX_DIR_LENGTH=$(yaml_get "$CONFIG_FILE" "format.max_dir_length" "30")
    MAX_BRANCH_LENGTH=$(yaml_get "$CONFIG_FILE" "format.max_branch_length" "25")
    TRUNCATE_CHAR=$(yaml_get "$CONFIG_FILE" "format.truncate_char" "…")
    SEPARATOR=$(yaml_get "$CONFIG_FILE" "format.separator" " │ ")

    # Cache
    GIT_CACHE_TTL=$(yaml_get "$CONFIG_FILE" "cache.git_ttl" "5")
}

# =============================================================================
# CROSS-PLATFORM HELPERS
# =============================================================================

# Cache directory (cross-platform)
get_cache_dir() {
    if [[ -n "$TMPDIR" ]]; then
        echo "${TMPDIR%/}/claude-statusline"
    elif [[ -n "$TEMP" ]]; then
        echo "$TEMP/claude-statusline"
    else
        echo "/tmp/claude-statusline"
    fi
}

# File modification time (seconds since epoch)
get_mtime() {
    local file="$1"
    case "$(uname -s)" in
        Darwin)  stat -f %m "$file" 2>/dev/null ;;
        *)       stat -c %Y "$file" 2>/dev/null ;;
    esac
}

# Simple hash for cache keys
get_hash() {
    if command -v md5sum &>/dev/null; then
        echo "$1" | md5sum | cut -c1-8
    elif command -v md5 &>/dev/null; then
        echo "$1" | md5 | cut -c1-8
    else
        echo "$1" | cksum | cut -d' ' -f1
    fi
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

color() {
    if [[ "$COLORS_ENABLED" == "true" ]]; then
        printf '\033[%sm%s\033[0m' "$1" "$2"
    else
        printf '%s' "$2"
    fi
}

emoji() {
    [[ "$EMOJI_ENABLED" == "true" ]] && printf '%s ' "$1"
}

truncate() {
    local str="$1" max="$2"
    if [[ ${#str} -gt $max ]]; then
        echo "${str:0:$((max-1))}${TRUNCATE_CHAR}"
    else
        echo "$str"
    fi
}

cached() {
    local key="$1" ttl="$2"
    shift 2
    local cmd="$*"
    local cache_dir cache_file

    cache_dir=$(get_cache_dir)
    mkdir -p "$cache_dir" 2>/dev/null
    cache_file="$cache_dir/$key"

    if [[ -f "$cache_file" ]]; then
        local mtime now age
        mtime=$(get_mtime "$cache_file")
        now=$(date +%s)
        age=$((now - mtime))
        [[ $age -lt $ttl ]] && { cat "$cache_file"; return; }
    fi

    local result
    result=$(eval "$cmd" 2>/dev/null)
    echo "$result" > "$cache_file" 2>/dev/null
    echo "$result"
}

# =============================================================================
# DATA EXTRACTION
# =============================================================================

INPUT=$(cat)

get_model() {
    local model_id display_name

    if echo "$INPUT" | jq -e '.model | type == "object"' &>/dev/null; then
        model_id=$(echo "$INPUT" | jq -r '.model.id // empty')
        display_name=$(echo "$INPUT" | jq -r '.model.display_name // empty')
    else
        model_id=$(echo "$INPUT" | jq -r '.model // empty')
    fi

    [[ -n "$display_name" ]] && { echo "$display_name"; return; }

    case "$model_id" in
        *opus-4-5*)    echo "Opus 4.5" ;;
        *sonnet-4-5*)  echo "Sonnet 4.5" ;;
        *haiku-4-5*)   echo "Haiku 4.5" ;;
        *sonnet-4-*)   echo "Sonnet 4" ;;
        *sonnet-3-5*)  echo "Sonnet 3.5" ;;
        *opus-3*)      echo "Opus 3" ;;
        *haiku-3*)     echo "Haiku 3" ;;
        *)             echo "${model_id:-Claude}" ;;
    esac
}

get_directory() {
    local dir
    dir=$(echo "$INPUT" | jq -r '.workspace.current_dir // .cwd // .workspaceDirs[0] // empty' 2>/dev/null)
    [[ -n "$dir" ]] && truncate "${dir/#$HOME/~}" "$MAX_DIR_LENGTH"
}

get_branch() {
    local cache_key
    cache_key="branch_$(get_hash "$(pwd)")"
    cached "$cache_key" "$GIT_CACHE_TTL" \
        "git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null"
}

get_branch_color() {
    case "$1" in
        main|master)    echo "$COLOR_BRANCH_MAIN" ;;
        dev|develop)    echo "$COLOR_BRANCH_DEVELOP" ;;
        feature/*)      echo "$COLOR_BRANCH_FEATURE" ;;
        hotfix/*)       echo "$COLOR_BRANCH_HOTFIX" ;;
        release/*)      echo "$COLOR_BRANCH_RELEASE" ;;
        stg|staging)    echo "$COLOR_BRANCH_STAGING" ;;
        *)              echo "$COLOR_BRANCH_DEFAULT" ;;
    esac
}

get_git_status() {
    local cache_key status
    cache_key="status_$(get_hash "$(pwd)")"
    status=$(cached "$cache_key" "$GIT_CACHE_TTL" "git status --porcelain 2>/dev/null")

    [[ -z "$status" ]] && return

    local staged=0 modified=0 untracked=0
    while IFS= read -r line; do
        local x="${line:0:1}" y="${line:1:1}"
        [[ "$x" =~ [MADRC] ]] && ((staged++))
        [[ "$y" == "M" ]] && ((modified++))
        [[ "$x" == "?" ]] && ((untracked++))
    done <<< "$status"

    local result=""
    [[ $staged -gt 0 ]] && result+="$(color "$COLOR_STAGED" "+$staged")"
    [[ $modified -gt 0 ]] && result+="$(color "$COLOR_MODIFIED" "!$modified")"
    [[ $untracked -gt 0 ]] && result+="$(color "$COLOR_UNTRACKED" "?$untracked")"
    echo "$result"
}

get_cost() {
    local cost
    cost=$(echo "$INPUT" | jq -r '.cost.total_cost_usd // .costs.total // empty' 2>/dev/null)
    [[ -n "$cost" && "$cost" != "0" ]] && printf "\$%.2f" "$cost"
}

# =============================================================================
# OUTPUT GENERATION
# =============================================================================

build_statusline() {
    local parts=()
    local sep
    sep=$(color "$COLOR_SEP" "$SEPARATOR")

    # Model
    if [[ "$SHOW_MODEL" == "true" ]]; then
        local model
        model=$(get_model)
        [[ -n "$model" ]] && parts+=("$(emoji "$EMOJI_MODEL")$(color "$COLOR_MODEL" "$model")")
    fi

    # Directory
    if [[ "$SHOW_DIRECTORY" == "true" ]]; then
        local dir
        dir=$(get_directory)
        [[ -n "$dir" ]] && parts+=("$(emoji "$EMOJI_DIR")$dir")
    fi

    # Branch
    if [[ "$SHOW_BRANCH" == "true" ]]; then
        local branch branch_color display_branch
        branch=$(get_branch)
        if [[ -n "$branch" ]]; then
            branch_color=$(get_branch_color "$branch")
            display_branch=$(truncate "$branch" "$MAX_BRANCH_LENGTH")
            parts+=("$(emoji "$EMOJI_BRANCH")$(color "$branch_color" "$display_branch")")
        fi
    fi

    # Git status
    if [[ "$SHOW_GIT_STATUS" == "true" ]]; then
        local git_status
        git_status=$(get_git_status)
        [[ -n "$git_status" ]] && parts+=("$git_status")
    fi

    # Cost
    if [[ "$SHOW_COST" == "true" ]]; then
        local cost
        cost=$(get_cost)
        [[ -n "$cost" ]] && parts+=("$(emoji "$EMOJI_COST")$(color "$COLOR_COST" "$cost")")
    fi

    # Join parts
    local output="" first=true
    for part in "${parts[@]}"; do
        if $first; then
            output="$part"
            first=false
        else
            output+="${sep}${part}"
        fi
    done

    printf '%s' "$output"
}

# =============================================================================
# MAIN
# =============================================================================

exec 2>/dev/null
load_config
build_statusline || printf ''
