---
name: automation-tools:setup-statusline
description: 'YAML 설정 기반 status line 환경 구성'
allowed-tools: Read, Write, Bash(cp *), Bash(chmod *), Bash(mkdir *), Bash(uname *), Bash(ls *), Bash(test *), AskUserQuestion
model: claude-opus-4-5-20251101
---

# Setup Status Line

## MISSION

Configure Claude Code status line with YAML-based Single Source of Truth architecture.
Platform-specific scripts (Bash for Unix, PowerShell for Windows) read shared YAML config.

**Args**: $ARGUMENTS (옵션: `--user`, `--project`, `--reset`)

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

## PHASE 1.5: Handle --reset Flag

```
IF $ARGUMENTS contains "--reset":
  1. Remove statusLine from ~/.claude/settings.json (if exists)
  2. Remove statusLine from ./.claude/settings.local.json (if exists)
  3. Delete ~/.claude/statusline.sh (or .ps1)
  4. Delete ~/.claude/statusline.yaml
  5. REPORT "Status line 설정이 초기화되었습니다."
  6. EXIT
```

---

## PHASE 2: Find Plugin Templates

```
⚠️ CRITICAL: Glob 도구는 현재 작업 디렉토리 기준으로만 검색합니다.
   ~/.claude/plugins/ 경로를 검색하려면 반드시 path 파라미터에 절대 경로를 명시해야 합니다!

SEARCH ORDER (Unix & Windows 공통):
├─ 1. ~/.claude/plugins/ 하위 전체 검색 (path 파라미터 필수!)
│     ├─ cache/claude-integration/automation-tools/*/templates/
│     └─ marketplaces/claude-integration/plugins/automation-tools/templates/
├─ 2. 현재 작업 디렉토리의 ./plugins/automation-tools/templates/
└─ 3. ./templates/ (local fallback)

ACTION SEQUENCE:
1. DETECT HOME_DIR:
   ├─ Unix: $HOME (예: /Users/username)
   └─ Windows: $env:USERPROFILE (예: C:\Users\username)

2. GLOB with absolute path parameter:
   ├─ Unix:   Glob(pattern: "**/statusline.sh", path: "$HOME/.claude/plugins")
   └─ Windows: Glob(pattern: "**/statusline.ps1", path: "$HOME/.claude/plugins")

3. IF results found → SELECT latest version from cache/ or marketplaces/
   IF empty → Glob(pattern: "**/templates/statusline.*", path: ".")
   IF still empty → ERROR "plugin_not_found"

EXPECTED PATHS:
├─ ~/.claude/plugins/cache/claude-integration/automation-tools/{version}/templates/
├─ ~/.claude/plugins/marketplaces/claude-integration/plugins/automation-tools/templates/
└─ ./plugins/automation-tools/templates/ (개발 환경)
```

---

## PHASE 2.5: Check Existing Installation & Confirm Scope

```
CHECK EXISTING:
├─ ~/.claude/settings.json → HAS_USER_STATUSLINE = statusLine exists?
├─ ./.claude/settings.local.json → HAS_PROJECT_STATUSLINE = statusLine exists?
└─ ~/.claude/statusline.sh → SCRIPT_EXISTS?

IF HAS_USER_STATUSLINE OR HAS_PROJECT_STATUSLINE:
  SHOW current configuration summary

DETERMINE SCOPE from $ARGUMENTS or ASK:
├─ IF "--user" in $ARGUMENTS → SCOPE = "user"
├─ IF "--project" in $ARGUMENTS → SCOPE = "project"
└─ ELSE → AskUserQuestion

AskUserQuestion:
  question: "Status line을 어느 범위에 적용하시겠습니까?"
  header: "적용 범위"
  options:
    - label: "사용자 레벨 (Recommended)"
      description: "~/.claude/settings.json - 모든 프로젝트에 적용"
    - label: "프로젝트 레벨"
      description: "./.claude/settings.local.json - 현재 프로젝트에만 적용"
    - label: "취소"
      description: "설치를 취소합니다"

IF "취소" selected → EXIT with message "설치가 취소되었습니다."
```

---

## PHASE 3: Copy Templates (Always to ~/.claude/)

스크립트 파일은 항상 `~/.claude/`에 저장 (scope와 무관)

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

## PHASE 4: Update settings.json (Scope-Dependent)

```
DETERMINE TARGET FILE:
├─ IF SCOPE == "user" → TARGET = ~/.claude/settings.json
└─ IF SCOPE == "project" → TARGET = ./.claude/settings.local.json

READ TARGET (create if missing with {})

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

⚠️ Project-level settings override user-level settings
```

---

## PHASE 5: Verify Installation

```
TEST COMMAND:

Unix:
  echo '{"model":"claude-opus-4-5-20251101","cwd":"/test","context_window":{"total_input_tokens":50000,"total_output_tokens":0,"context_window_size":200000}}' | ~/.claude/statusline.sh

Windows:
  '{"model":"claude-opus-4-5-20251101","cwd":"C:\\test","context_window":{"total_input_tokens":50000,"total_output_tokens":0,"context_window_size":200000}}' | powershell.exe -NoProfile -ExecutionPolicy Bypass -File $HOME\.claude\statusline.ps1

EXPECTED OUTPUT:
🤖 Opus 4.5 │ 📂 /test │ 🌿 main │ [██░░░░░░░░] 75%남음 (50K/200K)

FEATURES TO VERIFY:
├─ 모델명 표시 (색상: cyan)
├─ 경로 표시 (색상: blue, 동적 길이)
├─ Git 브랜치 (색상: green)
├─ Git 상태 (색상: yellow)
├─ 진행률 바 (색상: 사용량에 따라 변경)
└─ 남은 퍼센트 (터미널 기본색)

IF output invalid → ERROR "test_failed"
```

### 스크립트 기능

| 기능 | 설명 |
|------|------|
| 공식 JSON 스키마 | `context_window.total_input_tokens` + `total_output_tokens` |
| 경로 최대 길이 | 기본 150자 (짧은 경로는 전체 표시, CLAUDE_TERM_WIDTH로 오버라이드) |
| 크로스 플랫폼 | Unix (Bash) / Windows (PowerShell) 동일 기능 |
| 하위 호환성 | 레거시 `contextWindow` 필드도 지원 |

---

## PHASE 6: Report (Korean, Scope-Aware)

```markdown
## ✅ Status Line 설정 완료

### 적용 범위: {SCOPE}

| 항목 | 경로 |
|------|------|
| 스크립트 | `~/.claude/statusline.{sh|ps1}` |
| 설정 파일 | `~/.claude/statusline.yaml` |
| Claude 설정 | `{TARGET}` |

### 적용 방법
Claude Code를 **재시작**하면 활성화됩니다.

### 범위별 설명

**사용자 레벨** (`~/.claude/settings.json`):
- 모든 프로젝트에 적용
- 프로젝트 레벨 설정이 없으면 기본 적용

**프로젝트 레벨** (`./.claude/settings.local.json`):
- 현재 프로젝트에만 적용
- 사용자 레벨 설정보다 우선

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
2. IF "--reset" in $ARGUMENTS → EXECUTE PHASE 1.5 and EXIT
3. DETECT HOME_DIR:
   ├─ Unix: echo $HOME (또는 ~)
   └─ Windows: echo $env:USERPROFILE
4. GLOB find plugin templates with absolute path:
   ├─ Glob(pattern: "**/statusline.*", path: "$HOME/.claude/plugins")
   └─ IF empty → Glob(pattern: "**/templates/statusline.*", path: ".")
5. CHECK existing installation
6. DETERMINE SCOPE:
   ├─ IF "--user" in $ARGUMENTS → SCOPE = "user"
   ├─ IF "--project" in $ARGUMENTS → SCOPE = "project"
   └─ ELSE → AskUserQuestion (PHASE 2.5) ← REQUIRED
7. IF "취소" selected → EXIT with message
8. READ template files
9. IF Windows:
   ├─ WRITE statusline.ps1 → ~/.claude/
   └─ WRITE statusline.yaml → ~/.claude/
10. IF Unix:
    ├─ WRITE statusline.sh → ~/.claude/
    ├─ BASH chmod +x ~/.claude/statusline.sh
    └─ WRITE statusline.yaml → ~/.claude/
11. DETERMINE TARGET:
    ├─ IF SCOPE == "user" → TARGET = ~/.claude/settings.json
    └─ IF SCOPE == "project" → TARGET = ./.claude/settings.local.json
12. READ TARGET (or create empty {})
13. WRITE merged TARGET with statusLine config
14. TEST script (platform-specific)
15. REPORT in Korean (with SCOPE info)
16. SHOW follow-up TUI ← REQUIRED
```
