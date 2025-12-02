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

## PHILOSOPHY: CLAUDE.md Writing Principles

> Reference: https://www.humanlayer.dev/blog/writing-a-good-claude-md

```
CORE PREMISE:
├─ "LLMs are stateless functions"
├─ CLAUDE.md is the ONLY file included in every conversation
└─ Therefore: include ONLY essential information

ONBOARDING STRUCTURE (WHAT-WHY-HOW):
├─ WHAT: tech stack, project structure, codebase map
├─ WHY: project purpose, business context
└─ HOW: commands for test/build/deploy

RULES:
├─ Less is More: 150-200 instructions = LLM stable limit
├─ <300 lines (ideally <60 lines)
├─ Universal applicability only
├─ Pointers over Copies: file:line references instead of snippets
└─ Progressive Disclosure: details in agent_docs/

ANTI-PATTERNS (NEVER include):
├─ Code style guides → use linter/formatter
├─ Auto-generation (/init) → craft manually
├─ Task-specific instructions → move to agent_docs/
├─ Inline code snippets → use file references
└─ Conditional instructions → universal rules only

PROGRESSIVE DISCLOSURE:
├─ CLAUDE.md (root, <60 lines)
│   ├─ Project overview (WHAT/WHY)
│   ├─ Core commands (HOW)
│   └─ Links to detailed docs
└─ agent_docs/ (details)
    ├─ architecture.md
    ├─ testing.md
    └─ conventions.md
```

---

## SUB-CLAUDE.md Creation Principles

```
MUST_CREATE (when ANY applies):
├─ 1. Independent deployment unit
│   └─ Separate package.json + own build/test scripts
├─ 2. Different tech stack
│   └─ Different language/framework than root
│   └─ e.g., root=TypeScript, submodule=Python
├─ 3. Independent domain context
│   └─ Completely different business logic area
│   └─ e.g., packages/billing vs packages/auth
└─ 4. Git Submodule
    └─ External repository managed module

MUST_NOT_CREATE:
├─ Simple folder structures (src/components/, src/utils/)
├─ Shared libraries with same stack as root
├─ Config/infra folders (.github/, docker/, scripts/)
├─ Test folders (__tests__/, test/, e2e/)
└─ node_modules/, dist/, build/

SUB_CLAUDE_CHECKLIST (score-based):
├─ Has independent README.md? (+1)
├─ Has independent package.json/pyproject.toml? (+1)
├─ Has different build command? (+1)
├─ Has different test command? (+1)
├─ Uses different tech stack? (+1)
└─ Has separate team ownership (CODEOWNERS)? (+1)

DECISION:
├─ score >= 5 → MUST create sub-CLAUDE.md
├─ score >= 3 → CONSIDER creating
└─ score < 3 → SKIP (one-line description in root is enough)

SUB_CLAUDE_RULES:
├─ <30 lines (shorter than root)
├─ NO duplicate content from root
├─ Module-specific info only
├─ Parent link required
└─ Own agent_docs/ = last resort
```

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

2. SUB_CLAUDE_CHECKLIST scoring:
   FOR each candidate in (packages/*, apps/*, libs/*, modules/*):
     score = 0
     IF has README.md → score++
     IF has package.json/pyproject.toml/Cargo.toml → score++
     IF has different build command than root → score++
     IF has different test command than root → score++
     IF has different tech stack than root → score++
     IF has separate team ownership (CODEOWNERS) → score++

     IF score >= 5 → MUST push(dir + "/CLAUDE.md")
     IF score >= 3 → CONSIDER push(dir + "/CLAUDE.md")
     IF score < 3 → SKIP (one-line in root is enough)

3. Git Submodules (.gitmodules):
   FOR each → push(submodule + "/CLAUDE.md")

4. Different tech stack detection:
   IF dir uses different language/framework than root:
     → push(dir + "/CLAUDE.md")

SKIP_ALWAYS (never create sub-CLAUDE.md):
├─ src/components/, src/utils/ (simple folders)
├─ __tests__/, test/, e2e/ (test folders)
├─ .github/, docker/, scripts/ (infra folders)
├─ Shared utilities with same stack as root
└─ node_modules/, dist/, build/

COMPARE:
MISSING = REQUIRED - existing
ORPHAN = existing - REQUIRED (candidates for deletion)
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
