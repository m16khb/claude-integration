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

## ERROR HANDLING

| Error | Response |
|-------|----------|
| Plugin not found | Glob search, show manual install guide |
| settings.json missing | Create new file with statusLine config |
| Permission denied | Guide user to run with appropriate permissions |
| Test fails | Check jq installation, verify script syntax |

---

## EXECUTE NOW

1. **Glob** find plugin templates directory
2. **Read** template files from plugin
3. **Write** templates to `~/.claude/` (exact copy)
4. **Bash** chmod +x the script
5. **Read** existing `~/.claude/settings.json`
6. **Write** merged settings.json with statusLine config
7. **Bash** test the script
8. **Report** in Korean
