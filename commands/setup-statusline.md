---
name: setup-statusline
description: 'YAML 설정 기반 status line 환경 구성'
allowed-tools: Read, Write, Edit, Bash(chmod *), Bash(mkdir *)
model: claude-opus-4-5-20251101
---

# Setup Status Line

## MISSION

YAML 설정 파일을 기반으로 Claude Code status line 환경을 자동 구성합니다.

**Args**: $ARGUMENTS

- 인자 없음: 기본 템플릿으로 설정
- config-path: 지정된 YAML 설정 파일 사용

---

## PHASE 1: Configuration Discovery

```
LOGIC:
1. Check if config path provided in $ARGUMENTS
   ├─ IF provided → use that path
   └─ IF not provided → check common locations:
       ├─ ./statusline-config.yaml
       ├─ ./.claude/statusline-config.yaml
       └─ ~/.claude/statusline-config.yaml

2. IF no config found:
   → Use default template from plugin:
     @templates/statusline-config.yaml

3. Parse YAML config and validate structure
```

Read the configuration file or use default values.

---

## PHASE 2: Generate Status Line Script

Based on the YAML configuration, generate a customized bash script.

**Script location**: `~/.claude/statusline.sh`

```
GENERATE script with these sections:

1. CONFIGURATION BLOCK
   - Extract all values from YAML
   - Set as environment variables with defaults
   - Apply color palette from config

2. HELPER FUNCTIONS
   - color(): ANSI color wrapper
   - truncate(): String truncation
   - cached(): Cache wrapper for git commands

3. DATA EXTRACTION
   - get_model(): Parse model name from JSON input
   - get_directory(): Extract workspace directory
   - get_branch(): Get current git branch (cached)
   - get_git_status(): Count staged/modified/untracked (cached)

4. OUTPUT GENERATION
   - Build status line based on display settings
   - Apply mode-specific formatting (extended/compact/minimal)
   - Join sections with configured separator
```

Use the template from `@templates/statusline.sh` as base, then customize:

```bash
# Configuration values from YAML
MODE="<from config: statusline.mode>"
COLORS_ENABLED="<from config: statusline.colors.enabled>"

# Color palette
COLOR_MODEL="<from config: statusline.colors.palette.model>"
COLOR_FEATURE="<from config: statusline.colors.palette.feature_branch>"
# ... (all colors from config)

# Display settings
SHOW_MODEL="<from config: statusline.display.model>"
SHOW_DURATION="<from config: statusline.display.duration>"
# ... (all display settings)

# Format settings
MAX_DIR_LENGTH="<from config: statusline.format.max_dir_length>"
MAX_BRANCH_LENGTH="<from config: statusline.format.max_branch_length>"
SEPARATOR="<from config: statusline.format.separator>"
```

---

## PHASE 3: Update Settings

Update `~/.claude/settings.json` to enable the status line.

```
LOGIC:
1. Read existing ~/.claude/settings.json (or create new)
2. Add/update statusLine configuration:
   {
     "statusLine": {
       "type": "command",
       "command": "~/.claude/statusline.sh"
     }
   }
3. Preserve other existing settings
4. Write back to file
```

**Important**: Do NOT overwrite existing settings, merge them.

---

## PHASE 4: Set Permissions

```bash
chmod +x ~/.claude/statusline.sh
```

---

## PHASE 5: Verify Installation

Test the status line script:

```bash
echo '{"model":"claude-opus-4-5-20251101","workspaceDirs":["/test/project"]}' | ~/.claude/statusline.sh
```

---

## PHASE 6: Report (Korean)

```markdown
## ✅ Status Line 설정 완료

| 항목 | 내용 |
|------|------|
| 스크립트 | `~/.claude/statusline.sh` |
| 설정 파일 | `~/.claude/settings.json` |
| 모드 | <mode from config> |
| 표시 항목 | 모델, 디렉토리, 브랜치, Git 상태 |

### 적용 방법

Claude Code를 재시작하면 status line이 활성화됩니다.

### 커스터마이징

`statusline-config.yaml` 파일을 수정한 후 다시 `/setup-statusline`을 실행하세요.
```

---

## PHASE 7: Follow-up TUI

```
AskUserQuestion:
  question: "Status line 설정이 완료되었습니다. 다음 작업을 선택하세요."
  header: "후속"
  options:
    - label: "테스트 실행"
      description: "현재 설정으로 status line 미리보기"
    - label: "설정 파일 복사"
      description: "프로젝트에 statusline-config.yaml 복사"
    - label: "완료"
      description: "설정을 종료합니다"
```

### Handle Selection:

```
SWITCH selection:
  "테스트 실행":
    → Run test command and show output
    → echo '{"model":"claude-opus-4-5-20251101","workspaceDirs":["'$(pwd)'"]}' | ~/.claude/statusline.sh

  "설정 파일 복사":
    → Copy template to current project
    → cp @templates/statusline-config.yaml ./statusline-config.yaml
    → Report: "statusline-config.yaml이 프로젝트에 복사되었습니다"

  "완료":
    → Exit
```

---

## ERROR HANDLING

| Error | Response (Korean) |
|-------|-------------------|
| YAML parse error | "설정 파일 형식 오류: {details}. YAML 문법을 확인하세요" |
| Permission denied | "권한 오류: `chmod +x ~/.claude/statusline.sh` 실행 필요" |
| jq not installed | "jq가 필요합니다: `brew install jq` 또는 `apt install jq`" |
| settings.json invalid | "기존 settings.json 형식 오류. 백업 후 새로 생성합니다" |

---

## EXECUTE NOW

1. Find or use default configuration (PHASE 1)
2. Generate customized statusline.sh script (PHASE 2)
3. Update ~/.claude/settings.json (PHASE 3)
4. Set executable permissions (PHASE 4)
5. Verify installation (PHASE 5)
6. Report results in Korean (PHASE 6)
7. **Show follow-up TUI** (PHASE 7)
