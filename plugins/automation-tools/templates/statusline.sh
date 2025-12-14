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
WHITE='\033[0;37m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# 설정 파일 경로
CONFIG_FILE="${HOME}/.claude/statusline.yaml"

# YAML 설정 읽기 함수
# 간단한 YAML 파싱 (중첩 키 지원: parent.child)
read_yaml_config() {
    local key="$1"
    local default="$2"

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "$default"
        return
    fi

    # yq가 있으면 사용 (가장 정확함)
    if command -v yq &> /dev/null; then
        local value=$(yq -r ".$key" "$CONFIG_FILE" 2>/dev/null)
        # yq는 존재하지 않는 키에 대해 "null" 반환
        if [ "$value" = "null" ] || [ -z "$value" ]; then
            echo "$default"
        else
            echo "$value"
        fi
        return
    fi

    # yq 없을 때 grep fallback
    # 단일 필드 (예: display.language)
    local parent="${key%%.*}"
    local child="${key#*.}"

    if [[ "$key" == "$parent" ]]; then
        # 중첩 없는 단일 키
        local value=$(grep -E "^${key}:" "$CONFIG_FILE" | sed 's/.*:[[:space:]]*//' | tr -d '"' | tr -d "'")
        echo "${value:-$default}"
    else
        # 중첩 키 (예: context.enabled)
        # parent 섹션 찾은 후 child 키 검색
        local in_section=false
        local value=""
        while IFS= read -r line; do
            # 빈 줄 또는 주석 무시
            [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

            # 새 섹션 시작 (들여쓰기 없는 키)
            if [[ "$line" =~ ^[a-zA-Z] ]]; then
                if [[ "$line" =~ ^${parent}: ]]; then
                    in_section=true
                else
                    in_section=false
                fi
                continue
            fi

            # 섹션 내에서 child 키 검색
            if [ "$in_section" = true ]; then
                if [[ "$line" =~ ^[[:space:]]+${child}: ]]; then
                    value=$(echo "$line" | sed 's/.*:[[:space:]]*//' | tr -d '"' | tr -d "'")
                    break
                fi
            fi
        done < "$CONFIG_FILE"
        echo "${value:-$default}"
    fi
}

# JSON 파싱 함수 - jq 우선, 없으면 grep/sed fallback
parse_json_field() {
    local json="$1"
    local field="$2"  # 예: "model.display_name" 또는 "cwd"

    # jq가 있으면 사용 (가장 정확함)
    if command -v jq &> /dev/null; then
        echo "$json" | jq -r ".$field // empty" 2>/dev/null
        return
    fi

    # jq 없을 때 fallback
    # 단일 필드
    if [[ "$field" != *.* ]]; then
        echo "$json" | grep -o "\"$field\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | sed 's/.*:[[:space:]]*"//' | tr -d '"'
        return
    fi

    # 중첩 필드 (예: model.display_name)
    local parent="${field%%.*}"
    local child="${field#*.}"
    local section=$(echo "$json" | grep -o "\"$parent\"[[:space:]]*:[[:space:]]*{[^}]*}" | head -1)
    echo "$section" | grep -o "\"$child\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | sed 's/.*:[[:space:]]*"//' | tr -d '"'
}

# 숫자 필드 파싱
parse_json_number() {
    local json="$1"
    local field="$2"  # 예: "context_window.total_input_tokens"

    # jq가 있으면 사용
    if command -v jq &> /dev/null; then
        echo "$json" | jq -r ".$field // 0" 2>/dev/null
        return
    fi

    # jq 없을 때 fallback
    if [[ "$field" != *.* ]]; then
        echo "$json" | grep -o "\"$field\"[[:space:]]*:[[:space:]]*[0-9]*" | sed 's/.*:[[:space:]]*//'
        return
    fi

    # 중첩 필드
    local parent="${field%%.*}"
    local child="${field#*.}"
    local section=$(echo "$json" | grep -o "\"$parent\"[[:space:]]*:[[:space:]]*{[^}]*}" | head -1)
    echo "$section" | grep -o "\"$child\"[[:space:]]*:[[:space:]]*[0-9]*" | sed 's/.*:[[:space:]]*//'
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

# 경로 최대 길이 (고정값 사용)
# 경로가 이 값보다 짧으면 전체 표시, 길면 이 값으로 축약
# CLAUDE_TERM_WIDTH 환경변수로 오버라이드 가능
calculate_path_max_length() {
    if [ -n "$CLAUDE_TERM_WIDTH" ] && [ "$CLAUDE_TERM_WIDTH" -gt 0 ] 2>/dev/null; then
        echo "$CLAUDE_TERM_WIDTH"
    else
        echo "150"
    fi
}

# 경로 축약 (동적 길이) - 프로젝트명 우선 보존
shorten_path() {
    local path="$1"
    local max_length=${2:-$(calculate_path_max_length)}

    # ~ 로 홈 디렉토리 축약
    path="${path/#$HOME/~}"

    local path_len=${#path}

    # 길이가 max_length 이하면 그대로 반환
    if [ "$path_len" -le "$max_length" ]; then
        echo "$path"
        return
    fi

    # 프로젝트명(마지막 디렉토리)과 나머지 분리
    local base=$(basename "$path")
    local parent=$(dirname "$path")
    local base_len=${#base}

    # 프로젝트명이 max_length의 70% 이상이면 프로젝트명도 축약
    local max_base=$((max_length * 70 / 100))
    if [ "$base_len" -gt "$max_base" ]; then
        base="${base:0:$((max_base - 3))}..."
        base_len=${#base}
    fi

    # 남은 공간으로 앞부분 표시
    # ".../" = 4자
    local prefix_space=$((max_length - base_len - 4))

    if [ "$prefix_space" -ge 3 ]; then
        # 앞부분 일부 + ... + 프로젝트명
        # 예: ~/Wo.../claude-integration
        local prefix="${parent:0:$prefix_space}"
        path="${prefix}.../${base}"
    else
        # 공간 부족시 .../ + 프로젝트명만
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

# Git 상태 정보 가져오기
# + = staged, ! = modified, ? = untracked, * = stash
get_git_status_info() {
    local cwd="$1"
    local git_cmd="git"
    if [ -n "$cwd" ] && [ -d "$cwd" ]; then
        git_cmd="git -C $cwd"
    fi

    local status_output=$($git_cmd status --porcelain 2>/dev/null)
    local stash_count=$($git_cmd stash list 2>/dev/null | wc -l | tr -d ' ')

    # 카운트 계산
    local staged=0
    local modified=0
    local untracked=0

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        local index_status="${line:0:1}"
        local worktree_status="${line:1:1}"

        # Staged (index에 변경사항)
        if [[ "$index_status" =~ [MADRC] ]]; then
            ((staged++))
        fi
        # Modified (worktree에 변경사항)
        if [[ "$worktree_status" =~ [MD] ]]; then
            ((modified++))
        fi
        # Untracked
        if [ "$index_status" = "?" ]; then
            ((untracked++))
        fi
    done <<< "$status_output"

    # 출력 구성
    local result=""
    if [ "$staged" -gt 0 ]; then
        result+="+${staged}"
    fi
    if [ "$modified" -gt 0 ]; then
        [ -n "$result" ] && result+=" "
        result+="!${modified}"
    fi
    if [ "$untracked" -gt 0 ]; then
        [ -n "$result" ] && result+=" "
        result+="?${untracked}"
    fi
    if [ "$stash_count" -gt 0 ]; then
        [ -n "$result" ] && result+=" "
        result+="*${stash_count}"
    fi

    echo "$result"
}

# 메인 함수
main() {
    # stdin에서 JSON 읽기
    local input
    read -r input

    # JSON 파싱 (새 함수 사용)
    # model은 중첩 객체이므로 model.display_name 또는 model.id 사용
    local model_display=$(parse_json_field "$input" "model.display_name")
    local model_id=$(parse_json_field "$input" "model.id")
    local model="${model_display:-$model_id}"

    # cwd는 단일 필드
    local cwd=$(parse_json_field "$input" "cwd")

    # 컨텍스트 윈도우 정보 파싱
    # context_window.total_input_tokens + context_window.total_output_tokens = 사용량
    # context_window.context_window_size = 제한
    local input_tokens=$(parse_json_number "$input" "context_window.total_input_tokens")
    local output_tokens=$(parse_json_number "$input" "context_window.total_output_tokens")
    local context_limit=$(parse_json_number "$input" "context_window.context_window_size")

    # 사용량 계산 (input + output)
    local context_used=0
    if [ -n "$input_tokens" ] && [ "$input_tokens" -gt 0 ] 2>/dev/null; then
        context_used=$((input_tokens))
    fi
    if [ -n "$output_tokens" ] && [ "$output_tokens" -gt 0 ] 2>/dev/null; then
        context_used=$((context_used + output_tokens))
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

    # 3. Git 브랜치 및 상태
    local branch=$(get_git_branch "$cwd")
    if [ -n "$branch" ]; then
        if [ -n "$output" ]; then
            output+=" ${DIM}│${RESET} "
        fi
        output+="${GREEN}🌿 ${branch}${RESET}"

        # Git 상태 (Starship 표준: +staged !modified ?untracked $stash)
        local git_status=$(get_git_status_info "$cwd")
        if [ -n "$git_status" ]; then
            output+=" ${DIM}│${RESET} ${YELLOW}${git_status}${RESET}"
        fi
    fi

    # 4. 컨텍스트 윈도우 사용량 (설정에 따라 표시)
    local context_enabled=$(read_yaml_config "context.enabled" "true")
    if [ "$context_enabled" = "true" ]; then
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
            # 남은 퍼센트 표시 (터미널 기본색)
            output+="${bar} ${remaining_percent}%남음 (${used_k}/${limit_k})"
        fi
    fi

    echo -e "$output"
}

# 실행
main
