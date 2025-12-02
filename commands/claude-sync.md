---
name: claude-sync
description: '코드베이스 변경 감지 및 CLAUDE.md 자동 동기화'
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
model: claude-opus-4-5-20251101
---

# CLAUDE.md Auto-Sync

## MISSION

Scan codebase structure, compare with existing CLAUDE.md files, detect differences, and automatically synchronize.
Single command execution - no arguments needed.

---

## PHASE 1: Scan Codebase

```
SCAN directories:
├─ Glob("*") → root directories
├─ Glob("commands/*.md") → command files
├─ Glob("agents/**/*.md") → agent files
├─ Glob("agent_docs/*.md") → doc files
└─ Glob("**/CLAUDE.md") → all CLAUDE.md files

EXTRACT codebase state:
CODEBASE = {
  directories: [list of top-level dirs],
  commands: { count: N, files: [...] },
  agents: {
    backend: { count: N, files: [...] },
    frontend: { count: N, files: [...] },
    infrastructure: { count: N, files: [...] }
  },
  agent_docs: { count: N, files: [...] }
}
```

---

## PHASE 2: Parse CLAUDE.md

```
FOR each CLAUDE.md found:
  READ file content
  EXTRACT:
  ├─ "프로젝트 구조" section → listed directories
  ├─ "주요 커맨드" section → listed commands
  ├─ "상세 문서" section → doc links
  └─ line_count

  CLAUDE_STATE = {
    directories: [parsed dirs],
    commands: [parsed commands],
    doc_links: [parsed links],
    line_count: N
  }
```

---

## PHASE 3: Compare and Detect

```
DIFF = compare(CODEBASE, CLAUDE_STATE)

CHANGES = {
  added: [],      # in codebase but not in CLAUDE.md
  removed: [],    # in CLAUDE.md but not in codebase
  outdated: [],   # count mismatch
  broken_links: [] # invalid agent_docs links
}

DETECTION RULES:
├─ Significant (require update):
│   ├─ New top-level directory
│   ├─ Directory removed
│   ├─ New/removed command files
│   ├─ New/removed agent files
│   ├─ agent_docs files changed
│   └─ Broken links detected
└─ Ignore:
    ├─ Source code changes (*.ts, *.js, *.py)
    ├─ Test file changes
    └─ Config changes (except package.json scripts)

DECISION:
├─ No CLAUDE.md exists → ACTION = CREATE
├─ CHANGES not empty → ACTION = UPDATE
└─ CHANGES empty → ACTION = SKIP
```

---

## PHASE 4: Report Findings

**Output format (Korean):**

```markdown
## 🔄 동기화 분석 결과

| 항목 | 코드베이스 | CLAUDE.md | 상태 |
|------|-----------|-----------|------|
| commands/ | {N}개 | {M}개 기재 | {status} |
| agents/backend/ | {N}개 | {M}개 기재 | {status} |
| agent_docs/ | {N}개 | {M}개 링크 | {status} |

### 필요한 변경
{numbered list of required changes}
```

**Status icons:**
- ✅ 동기화됨 (no diff)
- ⚠️ 업데이트 필요 (count mismatch)
- ❌ 누락 (missing entirely)

---

## PHASE 5: User Confirmation

```
IF ACTION == SKIP:
  OUTPUT: "✅ CLAUDE.md가 최신 상태입니다"
  → END

IF ACTION == CREATE or UPDATE:
  AskUserQuestion:
    question: "위 변경사항을 적용하시겠습니까?"
    header: "적용"
    options:
      - label: "적용"
        description: "자동으로 CLAUDE.md 업데이트"
      - label: "미리보기"
        description: "변경될 내용 먼저 확인"
      - label: "건너뛰기"
        description: "변경 안함"
```

---

## PHASE 6: Apply Changes

```
IF user selected "적용":

  IF ACTION == CREATE:
    ├─ Generate CLAUDE.md using WHAT/WHY/HOW framework
    ├─ Target: <60 lines
    └─ Create agent_docs/ if complex project

  IF ACTION == UPDATE:
    ├─ Edit only changed sections
    ├─ Preserve user custom content
    ├─ Update structure section if directories changed
    ├─ Update doc links if agent_docs changed
    └─ Validate line count after edit

IF user selected "미리보기":
  ├─ Show proposed changes as diff
  └─ Return to PHASE 5

IF user selected "건너뛰기":
  → END
```

---

## PHASE 7: Quality Validation

```
AFTER any CREATE/UPDATE:

Line count check:
├─ <60: ✅ IDEAL
├─ 60-150: ✅ GOOD
├─ 150-300: ⚠️ → suggest restructure
└─ >300: ❌ → auto-restructure to agent_docs/

WHAT/WHY/HOW check:
├─ WHAT: tech stack, structure present?
├─ WHY: project purpose present?
└─ HOW: essential commands present?

Link validation:
└─ All agent_docs/ links resolve to existing files?

Anti-pattern check:
├─ No code style guides (should use linter)
├─ No inline code snippets
└─ No conditional instructions
```

---

## PHASE 8: Completion Report

**Output format (Korean):**

```markdown
## ✅ 동기화 완료

| 파일 | 작업 | 라인 수 |
|------|------|---------|
| CLAUDE.md | {CREATE/UPDATE} | {N}줄 {status} |

다음 작업: `/git-commit`으로 커밋
```

---

## ERROR HANDLING

| Error | Response (Korean) |
|-------|-------------------|
| No CLAUDE.md found | "CLAUDE.md가 없습니다. 생성하시겠습니까?" → CREATE flow |
| Git not initialized | "Git 저장소가 아닙니다. 구조 분석만 수행합니다." |
| Line count > 300 | "⚠️ 300줄 초과 - agent_docs/로 분리합니다" → auto-restructure |
| Broken links found | "⚠️ 깨진 링크 감지: {links}" → suggest fix |
| Permission denied | "파일 권한이 없습니다: {path}" |

---

## EXECUTE NOW

1. Scan codebase with Glob (commands/, agents/, agent_docs/)
2. Parse existing CLAUDE.md files
3. Compare states and detect differences
4. Output report table (Korean)
5. Ask user confirmation if changes needed
6. Apply changes (CREATE/UPDATE/SKIP)
7. Validate quality (line count, links, anti-patterns)
8. Report completion (Korean)
