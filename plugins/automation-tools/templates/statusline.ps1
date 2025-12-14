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
    try {
        $termWidth = $Host.UI.RawUI.WindowSize.Width
        if (-not $termWidth -or $termWidth -eq 0) {
            $termWidth = 80
        }
    } catch {
        $termWidth = 80
    }

    # 다른 컴포넌트들의 대략적인 길이
    # 🤖 Opus 4.5 (12) + | (3) + 📂 (3) + | (3) + 🌿 branch (15) + | (3) + git_status (10) + | (3) + progress_bar (30)
    $fixedLength = 82

    # 남은 공간을 경로에 할당 (최소 20)
    $available = $termWidth - $fixedLength
    if ($available -lt 20) {
        $available = 20
    }

    return $available
}

# 경로 축약 (동적 길이)
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

    # 길이 초과 시 축약
    if ($Path.Length -gt $MaxLength) {
        $base = Split-Path $Path -Leaf
        if ($base.Length -gt ($MaxLength - 4)) {
            $base = $base.Substring(0, $MaxLength - 7) + "..."
        }
        $Path = "...\" + $base
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
