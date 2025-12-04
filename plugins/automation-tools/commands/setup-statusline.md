---
name: automation-tools:setup-statusline
description: 'YAML 설정 기반 status line 환경 구성'
allowed-tools: Read, Write, Bash(cp *), Bash(chmod *), Bash(mkdir *), Bash(uname *)
model: claude-opus-4-5-20251101
---

# Setup Status Line

## MISSION

Configure Claude Code status line with YAML-based Single Source of Truth architecture.
Platform-specific scripts (Bash for Unix, PowerShell for Windows) read shared YAML config.

**Args**: $ARGUMENTS

---

## PHASE 1: Detect Platform

```
DETECTION LOGIC:
├─ IF $env:OS == "Windows_NT" → PLATFORM = "windows"
├─ IF $OSTYPE contains "msys/mingw/cygwin" → PLATFORM = "windows"
├─ IF uname -s starts with "MINGW" → PLATFORM = "windows"
├─ IF uname -r contains "microsoft" → PLATFORM = "unix" (WSL uses bash)
└─ ELSE → PLATFORM = "unix"

⚠️ Windows: Use PowerShell, NOT Git Bash (PATH issues with cat/jq)
```

---

## PHASE 2: Find Plugin Templates

```
SEARCH ORDER:
├─ ~/.claude/plugins/marketplaces/claude-integration/templates/
├─ ~/.claude/plugins/claude-integration@claude-integration/templates/
├─ ~/.claude/plugins/*/templates/statusline.sh
└─ ./templates/ (local plugin directory)

ACTION: Glob ~/.claude/plugins/**/templates/statusline.sh
IF empty → ERROR "plugin_not_found"
```

---

## PHASE 3: Copy Templates (Platform-Specific)

### Unix (macOS/Linux/WSL):
```
FILES:
├─ statusline.sh → ~/.claude/statusline.sh
└─ statusline-config.yaml → ~/.claude/statusline.yaml

COMMANDS:
  mkdir -p ~/.claude
  cp {plugin_dir}/templates/statusline.sh ~/.claude/statusline.sh
  chmod +x ~/.claude/statusline.sh
  cp {plugin_dir}/templates/statusline-config.yaml ~/.claude/statusline.yaml

⚠️ Copy templates AS-IS without modifications!
```

### Windows:
```
FILES:
├─ statusline.ps1 → ~/.claude/statusline.ps1
└─ statusline-config.yaml → ~/.claude/statusline.yaml

NOTE: Use Write tool (not cp). No chmod needed for PowerShell.
```

---

## PHASE 4: Update settings.json

```
READ ~/.claude/settings.json (create if missing)

MERGE statusLine config:

Unix:
{
  "statusLine": {
    "type": "command",
    "command": "/bin/bash ~/.claude/statusline.sh"
  }
}

Windows:
{
  "statusLine": {
    "type": "command",
    "command": "powershell.exe -NoProfile -ExecutionPolicy Bypass -File %USERPROFILE%\\.claude\\statusline.ps1"
  }
}

PRESERVE existing settings, only update statusLine key.
```

---

## PHASE 5: Verify Installation

```
TEST COMMAND:

Unix:
  echo '{"model":"claude-opus-4-5-20251101","cwd":"/test"}' | ~/.claude/statusline.sh

Windows:
  '{"model":"claude-opus-4-5-20251101","cwd":"C:\\test"}' | powershell.exe -NoProfile -ExecutionPolicy Bypass -File $HOME\.claude\statusline.ps1

EXPECTED: Colored output with emoji (🤖 Opus 4.5 │ 📂 /test │ ...)
IF output invalid → ERROR "test_failed"
```

---

## PHASE 6: Report (Korean)

```markdown
## ✅ Status Line 설정 완료

| 항목 | 경로 |
|------|------|
| 스크립트 | `~/.claude/statusline.{sh|ps1}` |
| 설정 파일 | `~/.claude/statusline.yaml` |
| Claude 설정 | `~/.claude/settings.json` |

### 적용 방법
Claude Code를 **재시작**하면 활성화됩니다.

### 커스터마이징
`~/.claude/statusline.yaml` 수정 → 즉시 적용 (재시작 불필요)

| 플랫폼 | 스크립트 | 상태 |
|--------|----------|------|
| macOS/Linux | statusline.sh | ✅ |
| Windows | statusline.ps1 | ✅ |
| WSL | statusline.sh | ✅ |
```

---

## PHASE 7: Follow-up TUI

```
AskUserQuestion:
  question: "Status line 설정이 완료되었습니다. 다음 작업을 선택하세요."
  header: "후속"
  options:
    - label: "설정 커스터마이징"
      description: "statusline.yaml 파일을 열어 설정을 수정합니다"
    - label: "테스트 재실행"
      description: "status line 스크립트를 다시 테스트합니다"
    - label: "완료"
      description: "작업을 종료합니다"
```

---

## ERROR HANDLING

| Error | Detection | Response |
|-------|-----------|----------|
| plugin_not_found | Glob returns empty | "플러그인 템플릿을 찾을 수 없습니다. 수동 설치 가이드를 확인하세요." |
| settings_missing | File not exists | "settings.json이 없습니다. 새로 생성합니다." |
| permission_denied | Write/chmod fails | "권한 오류: 적절한 권한으로 다시 실행하세요." |
| test_failed_unix | Script output invalid | "테스트 실패: 스크립트 문법 검증이 필요합니다." |
| test_failed_windows | PowerShell error | "테스트 실패: PowerShell 실행 정책을 확인하세요." |
| copy_failed | cp/Write fails | "템플릿 복사 실패: 디스크 공간 및 권한을 확인하세요." |

---

## EXECUTE NOW

```
1. DETECT platform (Windows vs Unix)
2. GLOB find plugin templates
3. READ template files
4. IF Windows:
   ├─ WRITE statusline.ps1 → ~/.claude/
   └─ WRITE statusline.yaml → ~/.claude/
5. IF Unix:
   ├─ WRITE statusline.sh → ~/.claude/
   ├─ BASH chmod +x ~/.claude/statusline.sh
   └─ WRITE statusline.yaml → ~/.claude/
6. READ ~/.claude/settings.json (or create empty {})
7. WRITE merged settings.json with statusLine config
8. TEST script (platform-specific)
9. REPORT in Korean
10. SHOW follow-up TUI ← REQUIRED
```
