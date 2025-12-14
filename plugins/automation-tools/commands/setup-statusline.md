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

**Args**: $ARGUMENTS (옵션: `--user`, `--project`, `--reset`, `--update`, `--disable`)

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

## PHASE 1.5: Handle --reset or --disable Flag

```
IF $ARGUMENTS contains "--disable":
  ⚠️ statusLine 설정만 제거 (스크립트 파일은 유지)
  1. Remove statusLine key from ~/.claude/settings.json (if exists)
  2. Remove statusLine key from ./.claude/settings.local.json (if exists)
  3. REPORT "Status line이 비활성화되었습니다. 스크립트 파일은 유지됩니다."
  4. EXIT

IF $ARGUMENTS contains "--reset":
  ⚠️ 모든 설정과 파일 완전 삭제
  1. Remove statusLine key from ~/.claude/settings.json (if exists)
  2. Remove statusLine key from ./.claude/settings.local.json (if exists)
  3. Delete ~/.claude/statusline.sh (or .ps1)
  4. Delete ~/.claude/statusline.yaml
  5. Delete ~/.claude/statusline-debug.sh (if exists)
  6. Delete ~/.claude/statusline-input.log (if exists)
  7. REPORT "Status line 설정이 완전히 초기화되었습니다."
  8. EXIT
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
├─ Unix: ~/.claude/statusline.sh → SCRIPT_EXISTS?
└─ Windows: ~/.claude/statusline.ps1 → SCRIPT_EXISTS?

⚠️ CRITICAL: 기존 스크립트 버전 비교
IF SCRIPT_EXISTS:
  1. READ template file (from plugin)
  2. READ installed file (from ~/.claude/)
  3. COMPARE contents:
     ├─ IF different → NEEDS_UPDATE = true
     └─ IF same → NEEDS_UPDATE = false
  4. IF NEEDS_UPDATE:
     SHOW "기존 설치된 스크립트가 템플릿과 다릅니다."
     AskUserQuestion:
       question: "설치된 스크립트를 최신 템플릿으로 업데이트하시겠습니까?"
       header: "업데이트"
       options:
         - label: "업데이트 (Recommended)"
           description: "최신 기능(Context Window 표시 등)을 사용합니다"
         - label: "현재 버전 유지"
           description: "기존 설치된 스크립트를 그대로 사용합니다"
         - label: "취소"
           description: "설치를 취소합니다"
     IF "취소" selected → EXIT
     IF "현재 버전 유지" selected → SKIP_SCRIPT_COPY = true

IF HAS_USER_STATUSLINE OR HAS_PROJECT_STATUSLINE:
  SHOW current configuration summary

DETERMINE SCOPE from $ARGUMENTS or ASK:
├─ IF "--user" in $ARGUMENTS → SCOPE = "user"
├─ IF "--project" in $ARGUMENTS → SCOPE = "project"
├─ IF "--update" in $ARGUMENTS → FORCE_UPDATE = true (기존 스크립트 무조건 덮어쓰기)
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

⚠️ IF SKIP_SCRIPT_COPY == true → SKIP script copy, only copy YAML if missing

### Unix (macOS/Linux/WSL):
```
IF NOT SKIP_SCRIPT_COPY:
  FILES:
  ├─ statusline.sh → ~/.claude/statusline.sh
  └─ statusline.yaml → ~/.claude/statusline.yaml

  COMMANDS:
    mkdir -p ~/.claude
    cp {plugin_dir}/templates/statusline.sh ~/.claude/statusline.sh
    chmod +x ~/.claude/statusline.sh
    cp {plugin_dir}/templates/statusline.yaml ~/.claude/statusline.yaml

⚠️ Copy templates AS-IS without modifications!
```

### Windows:
```
IF NOT SKIP_SCRIPT_COPY:
  FILES:
  ├─ statusline.ps1 → ~/.claude/statusline.ps1
  └─ statusline.yaml → ~/.claude/statusline.yaml

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
⚠️ CRITICAL: 테스트 방법은 플랫폼별로 다름

TEST JSON (실제 Claude Code 스키마):
{
  "session_id": "test-session",
  "cwd": "/test",
  "model": {
    "id": "claude-opus-4-5-20251101",
    "display_name": "Opus 4.5"
  },
  "workspace": {
    "current_dir": "/test",
    "project_dir": "/test"
  },
  "version": "2.0.69",
  "context_window": {
    "total_input_tokens": 50000,
    "total_output_tokens": 10000,
    "context_window_size": 200000
  }
}

⚠️ NOTE: context_window 값은 /context 명령어와 다를 수 있음
  - context_window: API 호출 토큰 (total_input + total_output)
  - /context: 전체 컨텍스트 (시스템+도구+MCP+메모리+메시지)

---

### Unix (macOS/Linux/WSL) 테스트:

방법 1: 직접 파이프 (권장)
  echo '{"cwd":"/test","model":{"id":"claude-opus-4-5-20251101","display_name":"Opus 4.5"},"context_window":{"total_input_tokens":50000,"total_output_tokens":10000,"context_window_size":200000}}' | ~/.claude/statusline.sh

방법 2: 임시 파일 사용 (파이프 문제 시)
  1. WRITE test JSON to /tmp/statusline-test.json
  2. cat /tmp/statusline-test.json | ~/.claude/statusline.sh
  3. rm /tmp/statusline-test.json

---

### Windows 테스트 (임시 스크립트 방식 필수):

⚠️ Bash에서 PowerShell 직접 호출 시 이스케이프 충돌 발생
   → 반드시 임시 .ps1 테스트 스크립트 생성 후 실행

STEP 1: 임시 테스트 스크립트 생성
  Write to: ~/.claude/test-statusline.ps1
  Content:
  ```powershell
  # Temporary test script
  $json = '{"cwd":"C:\\test","model":{"id":"claude-opus-4-5-20251101","display_name":"Opus 4.5"},"context_window":{"total_input_tokens":50000,"total_output_tokens":10000,"context_window_size":200000}}'
  $json | & "$env:USERPROFILE\.claude\statusline.ps1"
  ```

STEP 2: 테스트 실행
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/test-statusline.ps1"

  또는 Git Bash에서:
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$USERPROFILE\.claude\test-statusline.ps1"

STEP 3: 임시 파일 정리
  Remove-Item ~/.claude/test-statusline.ps1 (또는 rm 명령)

---

EXPECTED OUTPUT:
🤖 Opus 4.5 │ 📂 /test │ [███░░░░░░░] 70%남음 (60K/200K)

(Git 브랜치는 테스트 경로가 Git 저장소가 아니면 표시되지 않음)

EXPECTED OUTPUT (context.enabled: false):
🤖 Opus 4.5 │ 📂 /test │ 🌿 main

(Context window bar가 표시되지 않음)

FEATURES TO VERIFY:
├─ 모델명 표시 (색상: cyan)
├─ 경로 표시 (색상: blue, 동적 길이)
├─ Git 브랜치 (색상: green) - 해당 경로가 Git 저장소인 경우만
├─ Git 상태 (색상: yellow) - 변경사항이 있는 경우만
├─ 진행률 바 (색상: 사용량에 따라 green/yellow/red)
└─ 남은 퍼센트 (터미널 기본색)

IF output invalid → ERROR "test_failed"
IF PowerShell execution policy error → "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" 안내
```

### 스크립트 기능

| 기능 | 설명 |
|------|------|
| 공식 JSON 스키마 | `context_window.total_input_tokens` + `total_output_tokens` |
| 경로 최대 길이 | 기본 150자 (짧은 경로는 전체 표시, CLAUDE_TERM_WIDTH로 오버라이드) |
| 크로스 플랫폼 | Unix (Bash) / Windows (PowerShell) 동일 기능 |
| 하위 호환성 | 레거시 `contextWindow` 필드도 지원 |
| Context 표시 On/Off | `~/.claude/statusline.yaml`의 `context.enabled` 설정으로 제어 |

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

**Context Window Bar 비활성화 방법:**
\`\`\`yaml
# ~/.claude/statusline.yaml
context:
  enabled: false  # true → false로 변경
\`\`\`

**주요 설정 옵션:**
| 설정 | 기본값 | 설명 |
|------|--------|------|
| `context.enabled` | `false` | Context window bar 표시 여부 |
| `display.path_max_length` | `30` | 경로 최대 길이 |
| `display.bar_width` | `10` | 진행률 바 너비 |
| `display.language` | `ko` | 언어 (ko/en) |

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
2. IF "--disable" in $ARGUMENTS → REMOVE statusLine from settings, REPORT, EXIT
3. IF "--reset" in $ARGUMENTS → EXECUTE PHASE 1.5 (full cleanup) and EXIT
4. DETECT HOME_DIR:
   ├─ Unix: echo $HOME (또는 ~)
   └─ Windows: echo $env:USERPROFILE
5. GLOB find plugin templates with absolute path:
   ├─ Glob(pattern: "**/statusline.*", path: "$HOME/.claude/plugins")
   └─ IF empty → Glob(pattern: "**/templates/statusline.*", path: ".")
6. CHECK existing installation (PHASE 2.5):
   a. CHECK script file exists (statusline.sh or statusline.ps1)
   b. IF exists:
      ├─ READ template content
      ├─ READ installed content
      ├─ COMPARE contents
      └─ IF different → ASK "업데이트하시겠습니까?" (AskUserQuestion)
   c. IF "--update" in $ARGUMENTS → FORCE_UPDATE (덮어쓰기)
7. DETERMINE SCOPE:
   ├─ IF "--user" in $ARGUMENTS → SCOPE = "user"
   ├─ IF "--project" in $ARGUMENTS → SCOPE = "project"
   └─ ELSE → AskUserQuestion (PHASE 2.5) ← REQUIRED
8. IF "취소" selected → EXIT with message
9. READ template files
10. IF NOT SKIP_SCRIPT_COPY:
    a. IF Windows:
       ├─ WRITE statusline.ps1 → ~/.claude/
       └─ WRITE statusline.yaml → ~/.claude/
    b. IF Unix:
       ├─ WRITE statusline.sh → ~/.claude/
       ├─ BASH chmod +x ~/.claude/statusline.sh
       └─ WRITE statusline.yaml → ~/.claude/
11. DETERMINE TARGET:
    ├─ IF SCOPE == "user" → TARGET = ~/.claude/settings.json
    └─ IF SCOPE == "project" → TARGET = ./.claude/settings.local.json
12. READ TARGET (or create empty {})
13. WRITE merged TARGET with statusLine config
14. TEST script (platform-specific):
    ├─ Unix: echo JSON | ~/.claude/statusline.sh
    └─ Windows: CREATE test-statusline.ps1 → EXECUTE → DELETE
15. REPORT in Korean (with SCOPE info)
16. SHOW follow-up TUI ← REQUIRED
```
