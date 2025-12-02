# Claude Code Status Line Script (Windows PowerShell)
# Reads YAML config directly - Single Source of Truth
#
# Platform: Windows (PowerShell 5.1+)
# Config: ~/.claude/statusline.yaml (optional)

param(
    [Parameter(ValueFromPipeline=$true)]
    [string]$InputJson
)

# =============================================================================
# CONFIGURATION PATH
# =============================================================================
$ConfigFile = if ($env:STATUSLINE_CONFIG) {
    $env:STATUSLINE_CONFIG
} else {
    Join-Path $HOME ".claude\statusline.yaml"
}

# =============================================================================
# YAML PARSER (Pure PowerShell - No external dependencies)
# =============================================================================
function Get-YamlValue {
    param(
        [string]$File,
        [string]$Key,
        [string]$Default
    )

    if (-not (Test-Path $File)) {
        return $Default
    }

    $content = Get-Content $File -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return $Default }

    $lines = $content -split "`n"

    # Handle nested keys (e.g., "show.model", "colors.staged")
    if ($Key -match '\.') {
        $parts = $Key -split '\.'
        $parent = $parts[0]
        $child = $parts[1]

        $inSection = $false
        foreach ($line in $lines) {
            # Skip comments and empty lines
            if ($line -match '^\s*#' -or $line -match '^\s*$') { continue }

            # Check section start (no leading spaces)
            if ($line -match '^([a-zA-Z_]+):') {
                if ($matches[1] -eq $parent) {
                    $inSection = $true
                } else {
                    $inSection = $false
                }
                continue
            }

            # In section, look for child key
            if ($inSection -and $line -match "^\s+${child}:\s*(.*)$") {
                $value = $matches[1]
                # Remove inline comments
                $value = ($value -split '#')[0].Trim()
                # Remove quotes
                $value = $value -replace '^["'']|["'']$', ''
                return $value
            }
        }
    } else {
        # Top-level key
        foreach ($line in $lines) {
            if ($line -match '^\s*#') { continue }
            if ($line -match "^${Key}:\s*(.*)$") {
                $value = $matches[1]
                $value = ($value -split '#')[0].Trim()
                $value = $value -replace '^["'']|["'']$', ''
                return $value
            }
        }
    }

    return $Default
}

# =============================================================================
# CONFIGURATION
# =============================================================================
$Config = @{
    # Feature toggles
    ColorsEnabled = (Get-YamlValue $ConfigFile "colors_enabled" "true") -eq "true"
    EmojiEnabled = (Get-YamlValue $ConfigFile "emoji_enabled" "true") -eq "true"

    # Display settings
    ShowModel = (Get-YamlValue $ConfigFile "show.model" "true") -eq "true"
    ShowDirectory = (Get-YamlValue $ConfigFile "show.directory" "true") -eq "true"
    ShowBranch = (Get-YamlValue $ConfigFile "show.branch" "true") -eq "true"
    ShowGitStatus = (Get-YamlValue $ConfigFile "show.git_status" "true") -eq "true"
    ShowCost = (Get-YamlValue $ConfigFile "show.cost" "false") -eq "true"

    # Colors (ANSI codes)
    ColorModel = Get-YamlValue $ConfigFile "colors.model" "38;5;33"
    ColorSep = Get-YamlValue $ConfigFile "colors.separator" "38;5;240"
    ColorCost = Get-YamlValue $ConfigFile "colors.cost" "38;5;220"
    ColorStaged = Get-YamlValue $ConfigFile "colors.staged" "38;5;46"
    ColorModified = Get-YamlValue $ConfigFile "colors.modified" "38;5;208"
    ColorUntracked = Get-YamlValue $ConfigFile "colors.untracked" "38;5;196"
    ColorBranchMain = Get-YamlValue $ConfigFile "colors.branch_main" "38;5;46"
    ColorBranchDevelop = Get-YamlValue $ConfigFile "colors.branch_develop" "38;5;51"
    ColorBranchFeature = Get-YamlValue $ConfigFile "colors.branch_feature" "38;5;226"
    ColorBranchHotfix = Get-YamlValue $ConfigFile "colors.branch_hotfix" "38;5;196"
    ColorBranchRelease = Get-YamlValue $ConfigFile "colors.branch_release" "38;5;208"
    ColorBranchStaging = Get-YamlValue $ConfigFile "colors.branch_staging" "38;5;141"
    ColorBranchDefault = Get-YamlValue $ConfigFile "colors.branch_default" "38;5;33"

    # Emoji
    EmojiModel = Get-YamlValue $ConfigFile "emoji.model" "🤖"
    EmojiDir = Get-YamlValue $ConfigFile "emoji.directory" "📂"
    EmojiBranch = Get-YamlValue $ConfigFile "emoji.branch" "🌿"
    EmojiCost = Get-YamlValue $ConfigFile "emoji.cost" "💰"

    # Format
    MaxDirLength = [int](Get-YamlValue $ConfigFile "format.max_dir_length" "30")
    MaxBranchLength = [int](Get-YamlValue $ConfigFile "format.max_branch_length" "25")
    TruncateChar = Get-YamlValue $ConfigFile "format.truncate_char" "…"
    Separator = Get-YamlValue $ConfigFile "format.separator" " │ "
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================
function Write-Color {
    param([string]$ColorCode, [string]$Text)

    if ($Config.ColorsEnabled) {
        return "$([char]27)[${ColorCode}m${Text}$([char]27)[0m"
    }
    return $Text
}

function Write-Emoji {
    param([string]$Emoji)

    if ($Config.EmojiEnabled) {
        return "$Emoji "
    }
    return ""
}

function Get-Truncated {
    param([string]$Text, [int]$MaxLength)

    if ($Text.Length -gt $MaxLength) {
        return $Text.Substring(0, $MaxLength - 1) + $Config.TruncateChar
    }
    return $Text
}

# =============================================================================
# DATA EXTRACTION
# =============================================================================
function Get-ModelName {
    param($Data)

    $modelId = ""
    $displayName = ""

    if ($Data.model -is [PSCustomObject]) {
        $modelId = $Data.model.id
        $displayName = $Data.model.display_name
    } else {
        $modelId = $Data.model
    }

    if ($displayName) { return $displayName }

    switch -Regex ($modelId) {
        "opus-4-5"    { return "Opus 4.5" }
        "sonnet-4-5"  { return "Sonnet 4.5" }
        "haiku-4-5"   { return "Haiku 4.5" }
        "sonnet-4-"   { return "Sonnet 4" }
        "sonnet-3-5"  { return "Sonnet 3.5" }
        "opus-3"      { return "Opus 3" }
        "haiku-3"     { return "Haiku 3" }
        default       { return if ($modelId) { $modelId } else { "Claude" } }
    }
}

function Get-Directory {
    param($Data)

    $dir = $Data.workspace.current_dir
    if (-not $dir) { $dir = $Data.cwd }
    if (-not $dir -and $Data.workspaceDirs) { $dir = $Data.workspaceDirs[0] }

    if ($dir) {
        $dir = $dir -replace [regex]::Escape($HOME), "~"
        return Get-Truncated $dir $Config.MaxDirLength
    }
    return ""
}

function Get-GitBranch {
    try {
        $branch = & git branch --show-current 2>$null
        if (-not $branch) {
            $branch = & git rev-parse --short HEAD 2>$null
        }
        return $branch
    } catch {
        return ""
    }
}

function Get-BranchColor {
    param([string]$Branch)

    switch -Regex ($Branch) {
        "^(main|master)$"  { return $Config.ColorBranchMain }
        "^(dev|develop)$"  { return $Config.ColorBranchDevelop }
        "^feature/"        { return $Config.ColorBranchFeature }
        "^hotfix/"         { return $Config.ColorBranchHotfix }
        "^release/"        { return $Config.ColorBranchRelease }
        "^(stg|staging)$"  { return $Config.ColorBranchStaging }
        default            { return $Config.ColorBranchDefault }
    }
}

function Get-GitStatus {
    try {
        $status = & git status --porcelain 2>$null
        if (-not $status) { return "" }

        $staged = 0
        $modified = 0
        $untracked = 0

        foreach ($line in $status -split "`n") {
            if ($line.Length -lt 2) { continue }
            $x = $line[0]
            $y = $line[1]

            if ($x -match '[MADRC]') { $staged++ }
            if ($y -eq 'M') { $modified++ }
            if ($x -eq '?') { $untracked++ }
        }

        $result = ""
        if ($staged -gt 0) { $result += Write-Color $Config.ColorStaged "+$staged" }
        if ($modified -gt 0) { if ($result) { $result += " " }; $result += Write-Color $Config.ColorModified "!$modified" }
        if ($untracked -gt 0) { if ($result) { $result += " " }; $result += Write-Color $Config.ColorUntracked "?$untracked" }

        return $result
    } catch {
        return ""
    }
}

function Get-Cost {
    param($Data)

    $cost = $Data.cost.total_cost_usd
    if (-not $cost) { $cost = $Data.costs.total }

    if ($cost -and $cost -ne 0) {
        return "`${0:N2}" -f $cost
    }
    return ""
}

# =============================================================================
# MAIN
# =============================================================================
try {
    # Read input from pipeline or stdin
    if (-not $InputJson) {
        $InputJson = [Console]::In.ReadToEnd()
    }

    if (-not $InputJson) { exit 0 }

    $Data = $InputJson | ConvertFrom-Json -ErrorAction Stop

    $parts = @()
    $sep = Write-Color $Config.ColorSep $Config.Separator

    # Model
    if ($Config.ShowModel) {
        $model = Get-ModelName $Data
        if ($model) {
            $parts += (Write-Emoji $Config.EmojiModel) + (Write-Color $Config.ColorModel $model)
        }
    }

    # Directory
    if ($Config.ShowDirectory) {
        $dir = Get-Directory $Data
        if ($dir) {
            $parts += (Write-Emoji $Config.EmojiDir) + $dir
        }
    }

    # Branch
    if ($Config.ShowBranch) {
        $branch = Get-GitBranch
        if ($branch) {
            $branchColor = Get-BranchColor $branch
            $displayBranch = Get-Truncated $branch $Config.MaxBranchLength
            $parts += (Write-Emoji $Config.EmojiBranch) + (Write-Color $branchColor $displayBranch)
        }
    }

    # Git status
    if ($Config.ShowGitStatus) {
        $gitStatus = Get-GitStatus
        if ($gitStatus) {
            $parts += $gitStatus
        }
    }

    # Cost
    if ($Config.ShowCost) {
        $cost = Get-Cost $Data
        if ($cost) {
            $parts += (Write-Emoji $Config.EmojiCost) + (Write-Color $Config.ColorCost $cost)
        }
    }

    # Output
    Write-Host -NoNewline ($parts -join $sep)

} catch {
    # Silent fail
    exit 0
}
