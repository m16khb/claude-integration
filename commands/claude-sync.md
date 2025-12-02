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

Scan codebase, detect where CLAUDE.md files should exist, compare with existing files, and synchronize.
Build hierarchical tree structure with parent-child links between CLAUDE.md files.
Single command execution - no arguments needed.

---

## PHASE 1: Scan Codebase

```
SCAN:
├─ Glob("*") → root directories
├─ Glob("commands/*.md") → commands
├─ Glob("agents/**/*.md") → agents
├─ Glob("agent_docs/*.md") → docs
├─ Glob("**/CLAUDE.md") → existing CLAUDE.md
├─ Glob("**/package.json") → modules
├─ Glob("**/README.md") → documented modules
└─ Read .gitmodules → submodules

CODEBASE = {
  directories: [...],
  commands: { count, files },
  agents: { backend, frontend, infrastructure },
  agent_docs: { count, files },
  existing_claude_mds: [...],
  modules: [...]
}
```

---

## PHASE 2: Detect CLAUDE.md Locations

```
REQUIRED_LOCATIONS = []

1. Root (always):
   └─ push("./CLAUDE.md")

2. Monorepo (packages/*, apps/*):
   IF exists → FOR each with package.json/README:
     push(dir + "/CLAUDE.md")

3. Libraries (libs/*, modules/*, core/*):
   IF exists → FOR each significant module:
     push(dir + "/CLAUDE.md")

4. Submodules (.gitmodules):
   FOR each → push(submodule + "/CLAUDE.md")

5. Complex directories:
   IF meets_threshold → push(dir + "/CLAUDE.md")

COMPLEXITY THRESHOLD:
├─ Has package.json/pyproject.toml/Cargo.toml
├─ Has README.md
├─ >10 source files
├─ Has test directory
└─ Has config files (tsconfig, eslint)

COMPARE:
MISSING = REQUIRED - existing
ORPHAN = existing - REQUIRED
```

---

## PHASE 3: Parse Existing CLAUDE.md

```
FOR each CLAUDE.md:
  EXTRACT:
  ├─ structure section → directories
  ├─ commands section → commands
  ├─ docs section → links
  └─ line_count

  CLAUDE_STATE[path] = { directories, commands, doc_links, line_count }
```

---

## PHASE 4: Compare and Detect

```
FOR each location in REQUIRED:
  IF in MISSING:
    ACTIONS.push({ path, action: CREATE, reason: "missing" })
  ELSE:
    DIFF = compare(CODEBASE, CLAUDE_STATE[location])
    IF DIFF not empty:
      ACTIONS.push({ path, action: UPDATE, changes: DIFF })
    ELSE:
      ACTIONS.push({ path, action: SKIP })

DIFF structure:
{ added: [], removed: [], outdated: [], broken_links: [] }

SIGNIFICANT CHANGES:
├─ New/removed top-level directory
├─ New/removed command/agent files
├─ agent_docs changes
└─ Broken links

IGNORE:
├─ Source code changes (*.ts, *.js, *.py)
├─ Test file changes
└─ Config changes (except scripts)
```

---

## PHASE 5: Report Findings

**Output (Korean):**
```markdown
## 🔄 동기화 분석 결과

### CLAUDE.md 위치별 상태
| 위치 | 상태 | 작업 | 이유 |
|------|------|------|------|

### 루트 CLAUDE.md 상세
| 항목 | 코드베이스 | CLAUDE.md | 상태 |
|------|-----------|-----------|------|

### 필요한 작업
{numbered list}
```

**Status:** ✅ SKIP / ⚠️ UPDATE / ❌ CREATE

---

## PHASE 6: User Confirmation

```
IF all SKIP:
  OUTPUT: "✅ CLAUDE.md가 최신 상태입니다"
  → END

IF CREATE or UPDATE needed:
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

## PHASE 7: Apply Changes

```
IF "적용":
  FOR each action:
    IF CREATE:
      ├─ Analyze directory structure
      ├─ Read README.md for WHY
      ├─ Detect tech stack from config
      ├─ Generate CLAUDE.md (WHAT/WHY/HOW, <60 lines)
      └─ Create agent_docs/ if complex

    IF UPDATE:
      ├─ Edit only changed sections
      ├─ Preserve user content
      └─ Validate line count

  → Execute PHASE 8

IF "미리보기":
  Show diff → Return to PHASE 6

IF "건너뛰기":
  → END
```

---

## PHASE 8: Build Tree Structure

```
TREE PRINCIPLE:
├─ Each CLAUDE.md references only DIRECT children
├─ Each CLAUDE.md links back to DIRECT parent only
└─ Hierarchical navigation (not flat)

BUILD:
1. Identify all CLAUDE.md locations
2. Build parent-child by path depth
3. FOR each: find direct children + direct parent

UPDATE EACH:

FOR parent_md:
  ADD "하위 모듈" section:
  | 모듈 | 설명 |
  |------|------|
  | [name](path/CLAUDE.md) | description |

FOR child_md (except root):
  ADD "상위 문서" section:
  - [상위 모듈](../CLAUDE.md)

INTERMEDIATE NODE:
IF child at packages/api/CLAUDE.md
BUT packages/CLAUDE.md NOT exists:
  → CREATE packages/CLAUDE.md as group node

VALIDATE:
├─ Every non-root has one parent link
├─ Every non-leaf has children section
├─ No broken links
├─ Fully connected (no orphans)
└─ Max depth 3-4 levels
```

---

## PHASE 9: Quality Validation

```
FOR each CREATE/UPDATE:

Line count:
├─ <60: ✅ IDEAL
├─ 60-150: ✅ GOOD
├─ 150-300: ⚠️ suggest restructure
└─ >300: ❌ auto-restructure

WHAT/WHY/HOW:
├─ WHAT: tech stack, structure?
├─ WHY: purpose?
└─ HOW: commands?

Links: all agent_docs/ valid?

Anti-patterns:
├─ No code style guides
├─ No inline snippets
└─ No conditional instructions
```

---

## PHASE 10: Completion Report

**Output (Korean):**
```markdown
## ✅ 동기화 완료

### 처리된 CLAUDE.md 파일
| 위치 | 작업 | 라인 수 | 상태 |
|------|------|---------|------|

### 구조화 결과
- 루트: 하위 모듈 섹션 추가됨
- 서브: 상위 문서 링크 추가됨
- 트리 검증: ✅ 완료

다음 작업: `/git-commit`으로 커밋
```

---

## ERROR HANDLING

| Error | Response (Korean) |
|-------|-------------------|
| No CLAUDE.md | "CLAUDE.md가 없습니다. 생성하시겠습니까?" |
| Git not init | "Git 저장소가 아닙니다. 구조 분석만 수행합니다." |
| >300 lines | "⚠️ 300줄 초과 - agent_docs/로 분리합니다" |
| Broken links | "⚠️ 깨진 링크 감지: {links}" |
| Permission | "파일 권한이 없습니다: {path}" |

---

## EXECUTE NOW

1. Scan codebase (directories, modules, packages)
2. Detect where CLAUDE.md should exist
3. Parse existing CLAUDE.md files
4. Compare required vs existing
5. Output report (Korean)
6. Ask user confirmation
7. Apply changes (CREATE/UPDATE/SKIP)
8. Build tree structure (parent-child links)
9. Create intermediate nodes if needed
10. Validate tree
11. Report completion (Korean)
