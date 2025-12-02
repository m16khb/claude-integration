---
name: setup-statusline
description: 'YAML 설정 기반 status line 환경 구성'
allowed-tools: Read, Write, Bash(cp *), Bash(chmod *), Bash(mkdir *)
model: claude-opus-4-5-20251101
---

# Setup Status Line

## MISSION

Configure Claude Code status line environment with YAML-based Single Source of Truth.

**Args**: $ARGUMENTS

---

## ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────────┐
│  Single Source of Truth Architecture                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ~/.claude/statusline.yaml  ←── User edits this file           │
│           │                                                     │
│           ↓                                                     │
│  ~/.claude/statusline.sh    ←── Reads YAML directly (no vars)  │
│           │                                                     │
│           ↓                                                     │
│  settings.json              ←── Executes the script             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

BENEFITS:
├─ One config file to edit
├─ YAML changes take effect immediately
├─ No intermediate conversion step
└─ Predictable behavior
```

---

## CRITICAL RULES

```
⚠️ DO NOT write statusline.sh code manually!
⚠️ ALWAYS copy templates exactly as-is!
⚠️ YAML is the only file users should edit!
```

---

## PHASE 1: Find Plugin Directory

```
SEARCH ORDER:
├─ ~/.claude/plugins/marketplaces/claude-integration/templates/
├─ ~/.claude/plugins/claude-integration@claude-integration/templates/
├─ ~/.claude/plugins/*/templates/statusline.sh
└─ Local: ./templates/ (if in plugin directory)

USE Glob: ~/.claude/plugins/**/templates/statusline.sh
```

---

## PHASE 2: Copy Template Files

```
ACTION: Copy both template files to ~/.claude/

FILES:
├─ statusline.sh   → ~/.claude/statusline.sh
└─ statusline-config.yaml → ~/.claude/statusline.yaml

COMMANDS:
  mkdir -p ~/.claude
  cp {plugin_dir}/templates/statusline.sh ~/.claude/statusline.sh
  chmod +x ~/.claude/statusline.sh
  cp {plugin_dir}/templates/statusline-config.yaml ~/.claude/statusline.yaml

⚠️ Copy files AS-IS without any modifications!
```

---

## PHASE 3: Update settings.json

```
READ ~/.claude/settings.json
MERGE statusLine config:

{
  "statusLine": {
    "type": "command",
    "command": "/bin/bash ~/.claude/statusline.sh"
  }
}

PRESERVE existing settings, only update statusLine key.
```

---

## PHASE 4: Verify Installation

```bash
# Test command
echo '{"model":"claude-opus-4-5-20251101","cwd":"/test"}' | ~/.claude/statusline.sh
```

Expected: Colored output with emoji (🤖 Opus 4.5 │ 📂 /test │ ...)

---

## PHASE 5: Report (Korean)

```markdown
## ✅ Status Line 설정 완료

| 항목 | 경로 |
|------|------|
| 스크립트 | `~/.claude/statusline.sh` |
| 설정 파일 | `~/.claude/statusline.yaml` |
| Claude 설정 | `~/.claude/settings.json` |

### 적용 방법

Claude Code를 **재시작**하면 status line이 활성화됩니다.

### 커스터마이징

`~/.claude/statusline.yaml` 파일을 직접 수정하세요:

\`\`\`yaml
# 디렉토리 숨기기
show:
  directory: false

# 이모지 비활성화
emoji_enabled: false

# 색상 변경
colors:
  model: "38;5;196"  # 빨간색
\`\`\`

변경 후 **Claude Code 재시작** 불필요 - 즉시 적용됩니다.

### 지원 플랫폼

- macOS ✅
- Linux ✅
- Windows (Git Bash/WSL) ✅
```

---

## PHASE 6: Follow-up TUI (Required)

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
| Plugin not found | Glob returns empty | "플러그인 템플릿을 찾을 수 없습니다. 수동 설치 가이드를 확인하세요." |
| settings.json missing | File not exists | "settings.json이 없습니다. 새로 생성합니다." |
| Permission denied | Write/chmod fails | "권한 오류: 적절한 권한으로 다시 실행하세요." |
| Test fails | Script output invalid | "테스트 실패: jq 설치 확인 및 스크립트 문법 검증이 필요합니다." |
| Template copy fails | cp command fails | "템플릿 복사 실패: 디스크 공간 및 권한을 확인하세요." |

---

## EXECUTE NOW

```
1. GLOB find plugin templates directory
2. READ template files from plugin
3. WRITE templates to ~/.claude/ (exact copy)
4. BASH chmod +x the script
5. READ existing ~/.claude/settings.json
6. WRITE merged settings.json with statusLine config
7. BASH test the script
8. REPORT in Korean
9. SHOW follow-up TUI ← REQUIRED
```
