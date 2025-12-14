# Claude Code Status Line - Context Window Usage Display
# https://github.com/m16khb/claude-integration
#
# 컨텍스트 윈도우 사용량을 진행률 바 형태로 표시
# 사용량: 초록(0-60%) → 노랑(60-85%) → 빨강(85%+)
# 100% 초과 시 "압축됨" 표시

# ANSI 색상 코드
$ESC = [char]27
$RED = "$ESC[0;31m"
$GREEN = "$ESC[0;32m"
$YELLOW = "$ESC[0;33m"
$BLUE = "$ESC[0;34m"
$MAGENTA = "$ESC[0;35m"
$CYAN = "$ESC[0;36m"
$WHITE = "$ESC[0;37m"
$DIM = "$ESC[2m"
$BOLD = "$ESC[1m"
$RESET = "$ESC[0m"

# 진행률 바 생성
function Get-ProgressBar {
    param(
        [int]$Percent,
        [int]$Width = 10
    )

    $filled = [math]::Floor($Percent * $Width / 100)
    $empty = $Width - $filled

    # 색상 결정
    if ($Percent -ge 100) {
        $color = $RED
    } elseif ($Percent -ge 85) {
        $color = $RED
    } elseif ($Percent -ge 60) {
        $color = $YELLOW
    } else {
        $color = $GREEN
    }

    # 바 생성
    $bar = ""
    for ($i = 0; $i -lt $filled; $i++) {
        $bar += [char]0x2588  # █
    }
    for ($i = 0; $i -lt $empty; $i++) {
        $bar += [char]0x2591  # ░
    }

    return "${color}[${bar}]${RESET}"
}

# 토큰 수를 K 단위로 변환
function Format-Tokens {
    param([int]$Tokens)

    if ($Tokens -eq 0) {
        return "0K"
    }
    $k = [math]::Floor($Tokens / 1000)
    return "${k}K"
}

# 모델명 축약
function Get-ShortModel {
    param([string]$Model)

    if ($Model -match "opus-4-5|opus") {
        return "Opus 4.5"
    } elseif ($Model -match "sonnet-4|sonnet") {
        return "Sonnet 4"
    } elseif ($Model -match "haiku") {
        return "Haiku"
    } else {
        return $Model.Substring(0, [Math]::Min(15, $Model.Length))
    }
}

# 터미널 너비에 따른 동적 경로 길이 계산
function Get-PathMaxLength {
    $termWidth = 0

    # 1. 사용자 지정 환경변수 (최우선)
    #    PowerShell 프로필에 $env:CLAUDE_TERM_WIDTH = 120 설정 가능
    if ($env:CLAUDE_TERM_WIDTH) {
        try {
            $termWidth = [int]$env:CLAUDE_TERM_WIDTH
        } catch {
            $termWidth = 0
        }
    }

    # 2. $env:COLUMNS 환경변수
    if ($termWidth -eq 0 -and $env:COLUMNS) {
        try {
            $termWidth = [int]$env:COLUMNS
        } catch {
            $termWidth = 0
        }
    }

    # 3. PowerShell 호스트에서 터미널 너비 가져오기
    if ($termWidth -eq 0) {
        try {
            $termWidth = $Host.UI.RawUI.WindowSize.Width
            if (-not $termWidth) { $termWidth = 0 }
        } catch {
            $termWidth = 0
        }
    }

    # 4. 기본값 (Claude Code 터미널은 보통 넓으므로 150)
    if ($termWidth -eq 0 -or $termWidth -lt 80) {
        $termWidth = 150
    }

    # 다른 컴포넌트들의 실제 길이 (이모지는 2칸 차지)
    # 🤖(2) + " Opus 4.5"(9) = 11
    # " │ "(3)
    # 📂(2) + " "(1) = 3  (경로는 별도)
    # " │ "(3)
    # 🌿(2) + " main"(5) = 7 (브랜치 ~10자 가정)
    # " │ "(3) + git_status(~8) = 11
    # " │ "(3)
    # "[██░░░░░░░░]"(12) + " 87%남음"(8) + " (26K/200K)"(12) = 32
    # 총: 11+3+3+3+10+11+3+32 = 76 (여유 포함 ~60)
    $fixedLength = 60

    # 남은 공간을 경로에 할당 (최소 25)
    $available = $termWidth - $fixedLength
    if ($available -lt 25) {
        $available = 25
    }

    return $available
}

# 경로 축약 (동적 길이) - 프로젝트명 우선 보존
function Get-ShortPath {
    param(
        [string]$Path,
        [int]$MaxLength = 0
    )

    # 동적 길이 계산
    if ($MaxLength -eq 0) {
        $MaxLength = Get-PathMaxLength
    }

    # 홈 디렉토리를 ~ 로 축약
    $homePath = $env:USERPROFILE
    if ($Path.StartsWith($homePath)) {
        $Path = "~" + $Path.Substring($homePath.Length)
    }

    # 길이가 MaxLength 이하면 그대로 반환
    if ($Path.Length -le $MaxLength) {
        return $Path
    }

    # 프로젝트명(마지막 디렉토리)과 나머지 분리
    $base = Split-Path $Path -Leaf
    $parent = Split-Path $Path -Parent
    $baseLen = $base.Length

    # 프로젝트명이 MaxLength의 70% 이상이면 프로젝트명도 축약
    $maxBase = [math]::Floor($MaxLength * 0.7)
    if ($baseLen -gt $maxBase) {
        $base = $base.Substring(0, $maxBase - 3) + "..."
        $baseLen = $base.Length
    }

    # 남은 공간으로 앞부분 표시
    # "...\" = 4자
    $prefixSpace = $MaxLength - $baseLen - 4

    if ($prefixSpace -ge 3) {
        # 앞부분 일부 + ... + 프로젝트명
        # 예: ~\Wo...\claude-integration
        $prefix = $parent.Substring(0, [Math]::Min($prefixSpace, $parent.Length))
        $Path = "$prefix...\$base"
    } else {
        # 공간 부족시 ...\ + 프로젝트명만
        $Path = "...\$base"
    }

    return $Path
}

# Git 브랜치 가져오기
function Get-GitBranch {
    param([string]$Cwd)

    try {
        if ($Cwd -and (Test-Path $Cwd)) {
            Push-Location $Cwd
            $branch = git branch --show-current 2>$null
            Pop-Location
            return $branch
        } else {
            return git branch --show-current 2>$null
        }
    } catch {
        return $null
    }
}

# Git 상태 정보 가져오기
# + = staged, ! = modified, ? = untracked, * = stash
function Get-GitStatusInfo {
    param([string]$Cwd)

    try {
        $originalLocation = Get-Location
        if ($Cwd -and (Test-Path $Cwd)) {
            Set-Location $Cwd
        }

        $statusOutput = git status --porcelain 2>$null
        $stashCount = (git stash list 2>$null | Measure-Object -Line).Lines

        $staged = 0
        $modified = 0
        $untracked = 0

        if ($statusOutput) {
            foreach ($line in $statusOutput -split "`n") {
                if ([string]::IsNullOrEmpty($line)) { continue }

                $indexStatus = $line[0]
                $worktreeStatus = if ($line.Length -gt 1) { $line[1] } else { ' ' }

                # Staged (index에 변경사항)
                if ($indexStatus -match '[MADRC]') {
                    $staged++
                }
                # Modified (worktree에 변경사항)
                if ($worktreeStatus -match '[MD]') {
                    $modified++
                }
                # Untracked
                if ($indexStatus -eq '?') {
                    $untracked++
                }
            }
        }

        Set-Location $originalLocation

        # 출력 구성
        $result = @()
        if ($staged -gt 0) { $result += "+$staged" }
        if ($modified -gt 0) { $result += "!$modified" }
        if ($untracked -gt 0) { $result += "?$untracked" }
        if ($stashCount -gt 0) { $result += "*$stashCount" }

        return $result -join " "
    } catch {
        return ""
    }
}

# 메인 로직
try {
    # stdin에서 JSON 읽기
    $input = [Console]::In.ReadLine()

    # JSON 파싱
    $json = $input | ConvertFrom-Json

    $model = $json.model
    $cwd = $json.cwd

    # 컨텍스트 윈도우 정보 (공식 Claude Code 스키마)
    # context_window.total_input_tokens + context_window.total_output_tokens = 사용량
    # context_window.context_window_size = 제한
    $contextUsed = 0
    $contextLimit = 200000

    if ($json.context_window) {
        $inputTokens = $json.context_window.total_input_tokens
        $outputTokens = $json.context_window.total_output_tokens
        $contextLimit = $json.context_window.context_window_size

        if ($inputTokens) { $contextUsed += $inputTokens }
        if ($outputTokens) { $contextUsed += $outputTokens }
    }
    # 하위 호환성 (레거시 필드명)
    elseif ($json.contextWindow) {
        $contextUsed = $json.contextWindow.used
        $contextLimit = $json.contextWindow.limit
    }

    # 기본값 보장
    if (-not $contextLimit -or $contextLimit -eq 0) { $contextLimit = 200000 }
    if (-not $contextUsed) { $contextUsed = 0 }

    # 퍼센트 계산
    $percent = 0
    $remainingPercent = 100
    if ($contextLimit -gt 0) {
        $percent = [math]::Floor($contextUsed * 100 / $contextLimit)
        $remainingPercent = 100 - $percent
        if ($remainingPercent -lt 0) { $remainingPercent = 0 }
    }

    # 출력 구성
    $output = ""

    # 1. 모델명
    if ($model) {
        $shortModel = Get-ShortModel $model
        $output += "${CYAN}`u{1F916} ${shortModel}${RESET}"
    }

    # 2. 현재 디렉토리
    if ($cwd) {
        $shortPath = Get-ShortPath $cwd
        if ($output) {
            $output += " ${DIM}|${RESET} "
        }
        $output += "${BLUE}`u{1F4C2} ${shortPath}${RESET}"
    }

    # 3. Git 브랜치 및 상태
    $branch = Get-GitBranch $cwd
    if ($branch) {
        if ($output) {
            $output += " ${DIM}|${RESET} "
        }
        $output += "${GREEN}`u{1F33F} ${branch}${RESET}"

        # Git 상태 (+staged !modified ?untracked *stash)
        $gitStatus = Get-GitStatusInfo $cwd
        if ($gitStatus) {
            $output += " ${DIM}|${RESET} ${YELLOW}${gitStatus}${RESET}"
        }
    }

    # 4. 컨텍스트 윈도우 사용량
    if ($output) {
        $output += " ${DIM}|${RESET} "
    }

    $bar = Get-ProgressBar -Percent $percent
    $usedK = Format-Tokens $contextUsed
    $limitK = Format-Tokens $contextLimit

    if ($percent -ge 100) {
        # 100% 초과 시 압축됨 표시
        $output += "${bar} ${RED}${BOLD}압축됨${RESET} (${usedK}/${limitK})"
    } else {
        # 남은 퍼센트 표시
        $output += "${bar} ${remainingPercent}%남음 (${usedK}/${limitK})"
    }

    Write-Host $output
}
catch {
    Write-Host "${RED}Status line error${RESET}"
}
