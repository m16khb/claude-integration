#!/bin/bash
# Claude Code Status Line - Context Window Usage Display
# https://github.com/m16khb/claude-integration
#
# 컨텍스트 윈도우 사용량을 진행률 바 형태로 표시
# 사용량: 초록(0-60%) → 노랑(60-85%) → 빨강(85%+)
# 100% 초과 시 "압축됨" 표시

# ANSI 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# 설정 파일 경로
CONFIG_FILE="${HOME}/.claude/statusline.yaml"

# JSON 파싱 함수 (jq 없이도 동작)
parse_json() {
    local json="$1"
    local key="$2"
    echo "$json" | grep -o "\"$key\"[[:space:]]*:[[:space:]]*[^,}]*" | sed 's/.*:[[:space:]]*//' | tr -d '"' | tr -d ' '
}

# 숫자 파싱 (중첩 객체용)
parse_nested_json() {
    local json="$1"
    local parent="$2"
    local key="$3"
    local section=$(echo "$json" | grep -o "\"$parent\"[[:space:]]*:[[:space:]]*{[^}]*}" | head -1)
    echo "$section" | grep -o "\"$key\"[[:space:]]*:[[:space:]]*[0-9]*" | sed 's/.*:[[:space:]]*//'
}

# 진행률 바 생성
generate_progress_bar() {
    local percent=$1
    local width=${2:-10}
    local filled=$((percent * width / 100))
    local empty=$((width - filled))

    # 색상 결정
    local color
    if [ "$percent" -ge 100 ]; then
        color=$RED
    elif [ "$percent" -ge 85 ]; then
        color=$RED
    elif [ "$percent" -ge 60 ]; then
        color=$YELLOW
    else
        color=$GREEN
    fi

    # 바 생성
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar+="█"
    done
    for ((i=0; i<empty; i++)); do
        bar+="░"
    done

    echo -e "${color}[${bar}]${RESET}"
}

# 토큰 수를 K 단위로 변환
format_tokens() {
    local tokens=$1
    if [ -z "$tokens" ] || [ "$tokens" -eq 0 ] 2>/dev/null; then
        echo "0K"
        return
    fi
    local k=$((tokens / 1000))
    echo "${k}K"
}

# 모델명 축약
shorten_model() {
    local model="$1"
    case "$model" in
        *"opus-4-5"*|*"opus"*)
            echo "Opus 4.5"
            ;;
        *"sonnet-4"*|*"sonnet"*)
            echo "Sonnet 4"
            ;;
        *"haiku"*)
            echo "Haiku"
            ;;
        *)
            echo "${model:0:15}"
            ;;
    esac
}

# 경로 축약
shorten_path() {
    local path="$1"
    local max_length=${2:-30}

    # ~ 로 홈 디렉토리 축약
    path="${path/#$HOME/~}"

    # 길이가 max_length를 초과하면 축약
    if [ ${#path} -gt $max_length ]; then
        local dir=$(dirname "$path")
        local base=$(basename "$path")
        if [ ${#base} -gt $((max_length - 4)) ]; then
            base="${base:0:$((max_length - 7))}..."
        fi
        path=".../${base}"
    fi

    echo "$path"
}

# Git 브랜치 이름 가져오기
get_git_branch() {
    local cwd="$1"
    if [ -n "$cwd" ] && [ -d "$cwd" ]; then
        git -C "$cwd" branch --show-current 2>/dev/null
    else
        git branch --show-current 2>/dev/null
    fi
}

# Git 변경사항 수 가져오기
get_git_changes() {
    local cwd="$1"
    local count=0
    if [ -n "$cwd" ] && [ -d "$cwd" ]; then
        count=$(git -C "$cwd" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    else
        count=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    fi
    echo "${count:-0}"
}

# 메인 함수
main() {
    # stdin에서 JSON 읽기
    local input
    read -r input

    # JSON 파싱
    local model=$(parse_json "$input" "model")
    local cwd=$(parse_json "$input" "cwd")

    # 컨텍스트 윈도우 정보 파싱
    local context_used=$(parse_nested_json "$input" "contextWindow" "used")
    local context_limit=$(parse_nested_json "$input" "contextWindow" "limit")

    # 대체 키 이름 시도
    if [ -z "$context_used" ]; then
        context_used=$(parse_json "$input" "contextUsed")
    fi
    if [ -z "$context_limit" ]; then
        context_limit=$(parse_json "$input" "contextLimit")
    fi

    # 기본값 설정 (200K 토큰)
    context_limit=${context_limit:-200000}
    context_used=${context_used:-0}

    # 퍼센트 계산
    local percent=0
    local remaining_percent=100
    if [ "$context_limit" -gt 0 ] 2>/dev/null; then
        percent=$((context_used * 100 / context_limit))
        remaining_percent=$((100 - percent))
        if [ $remaining_percent -lt 0 ]; then
            remaining_percent=0
        fi
    fi

    # 출력 구성
    local output=""

    # 1. 모델명 (있는 경우)
    if [ -n "$model" ]; then
        local short_model=$(shorten_model "$model")
        output+="${CYAN}🤖 ${short_model}${RESET}"
    fi

    # 2. 현재 디렉토리 (있는 경우)
    if [ -n "$cwd" ]; then
        local short_path=$(shorten_path "$cwd")
        if [ -n "$output" ]; then
            output+=" ${DIM}│${RESET} "
        fi
        output+="${BLUE}📂 ${short_path}${RESET}"
    fi

    # 3. Git 브랜치 및 변경사항
    local branch=$(get_git_branch "$cwd")
    if [ -n "$branch" ]; then
        if [ -n "$output" ]; then
            output+=" ${DIM}│${RESET} "
        fi
        output+="${GREEN}🌿 ${branch}${RESET}"

        # 변경사항 수
        local changes=$(get_git_changes "$cwd")
        if [ "$changes" -gt 0 ] 2>/dev/null; then
            output+=" ${DIM}│${RESET} ${YELLOW}+${changes}${RESET}"
        fi
    fi

    # 4. 컨텍스트 윈도우 사용량
    if [ -n "$output" ]; then
        output+=" ${DIM}│${RESET} "
    fi

    local bar=$(generate_progress_bar $percent)
    local used_k=$(format_tokens $context_used)
    local limit_k=$(format_tokens $context_limit)

    if [ "$percent" -ge 100 ]; then
        # 100% 초과 시 압축됨 표시
        output+="${bar} ${RED}${BOLD}압축됨${RESET} (${used_k}/${limit_k})"
    else
        # 남은 퍼센트 표시
        output+="${bar} ${remaining_percent}%남음 (${used_k}/${limit_k})"
    fi

    echo -e "$output"
}

# 실행
main
