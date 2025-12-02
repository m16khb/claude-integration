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

Scan codebase and synchronize CLAUDE.md files based on Claude Code's official loading behavior.
Optimize placement using cwd-based hierarchical loading and @import mechanism.

---

## CONTEXT: Loading Behavior

```
LOADING RULES:
├─ Claude Code walks UP from cwd to project root
├─ Only ancestor path CLAUDE.md files are auto-loaded
├─ Sub-directory CLAUDE.md = loaded ONLY when cwd is in that directory
└─ @import syntax = explicit inclusion regardless of cwd

@IMPORT SYNTAX:
├─ @path/to/file.md → include at parse time
├─ Supports relative/absolute paths
├─ Max 5 recursive hops
└─ Not evaluated inside code blocks

DECISION: Sub-CLAUDE.md vs @import
├─ Always needed everywhere → @import in root
└─ Context-specific (only when working there) → sub-CLAUDE.md
```

---

## PHASE 1: Scan Codebase

```
EXECUTE:
├─ Glob("*") → root directories
├─ Glob("**/CLAUDE.md") → existing files
├─ Glob("**/package.json") → potential modules
├─ Glob("**/README.md") → documented modules
└─ Read .gitmodules → submodules (if exists)

COLLECT → CODEBASE:
{
  root_dirs: [...],
  existing_mds: [...],
  modules: [...],
  submodules: [...]
}
```

---

## PHASE 2: Classify Locations

```
FOR each directory in (root, packages/*, apps/*, libs/*):
  EVALUATE:
  ├─ Has own package.json/pyproject.toml? (+2)
  ├─ Different tech stack than root? (+2)
  ├─ Independent build/test commands? (+1)
  ├─ Frequently used as cwd? (+1)
  └─ Git submodule? (+3)

  CLASSIFY by score:
  ├─ score >= 4 → SUB_NEEDED (create sub-CLAUDE.md)
  ├─ score 2-3 → CONSIDER (suggest, let user decide)
  └─ score < 2 → SKIP (root is sufficient)

ALWAYS SKIP:
├─ src/*, lib/* (simple code folders)
├─ __tests__/, test/, e2e/ (test dirs)
├─ .github/, docker/, scripts/ (config dirs)
└─ node_modules/, dist/, build/ (generated)
```

---

## PHASE 3: Detect Changes

```
CHANGES = []

FOR ROOT (./CLAUDE.md):
  IF not exists:
    CHANGES.push({ path: "./CLAUDE.md", action: "CREATE" })
  ELSE:
    DIFF = compare(CODEBASE.root_dirs, parsed_structure_section)
    IF DIFF.added.length OR DIFF.removed.length:
      CHANGES.push({ path: "./CLAUDE.md", action: "UPDATE", diff: DIFF })

FOR each SUB_NEEDED location:
  IF CLAUDE.md not exists:
    CHANGES.push({ path, action: "CREATE", reason: "independent module" })
  ELSE IF outdated:
    CHANGES.push({ path, action: "UPDATE" })

FOR each existing sub-CLAUDE.md NOT in SUB_NEEDED:
  CHANGES.push({ path, action: "REVIEW", reason: "may not be loaded" })

FOR @import validation:
  FOR each @import in root CLAUDE.md:
    IF target file not exists:
      CHANGES.push({ path, action: "FIX_IMPORT", target })
```

---

## PHASE 4: Report

**TUI Output (Korean):**

```markdown
## 🔄 CLAUDE.md 동기화 분석

### 로딩 방식 요약
- cwd 기준 상위 경로만 자동 로드
- @import로 명시적 포함 가능

### 현재 상태
| 위치 | 상태 | 로딩 조건 | 권장 |
|------|------|----------|------|
| ./CLAUDE.md | {status} | 항상 | {recommendation} |
| {path} | {status} | cwd={dir} | {recommendation} |

### 필요한 작업
1. {action description}
2. {action description}
```

---

## PHASE 5: User Confirmation

```
IF CHANGES.length == 0:
  OUTPUT: "✅ CLAUDE.md가 최신 상태입니다"
  → END

IF CHANGES.length > 0:
  AskUserQuestion:
    question: "위 변경사항을 적용하시겠습니까?"
    header: "적용"
    options:
      - label: "적용"
        description: "CLAUDE.md 자동 업데이트"
      - label: "미리보기"
        description: "변경될 내용 먼저 확인"
      - label: "건너뛰기"
        description: "변경 없이 종료"

  IF "미리보기":
    FOR each change: show diff
    → Return to this PHASE

  IF "건너뛰기":
    → END
```

---

## PHASE 6: Apply Changes

```
IF "적용" selected:

  FOR each CREATE action:
    IF root:
      Generate using WHAT/WHY/HOW structure:
      ├─ WHAT: tech stack, project structure
      ├─ WHY: project purpose (from README.md)
      ├─ HOW: build/test/deploy commands
      └─ Links to agent_docs/ if exists
      CONSTRAINT: <60 lines ideal, <150 max

    IF sub:
      Generate minimal content:
      ├─ Module-specific tech stack
      ├─ Module-specific commands
      └─ Parent reference link
      CONSTRAINT: <30 lines

  FOR each UPDATE action:
    Edit only changed sections:
    ├─ Preserve user-written content
    ├─ Update structure section with new dirs
    ├─ Fix broken @import paths
    └─ Maintain line count limits

  FOR each FIX_IMPORT action:
    ├─ Remove broken @import line
    └─ OR suggest alternative path
```

---

## PHASE 7: Validate & Report

```
VALIDATE all modified files:
├─ All @import paths resolve?
├─ Line counts within limits?
├─ No duplicate content between root and subs?
├─ WHAT/WHY/HOW structure present in root?
└─ No anti-patterns (inline code, style guides)?

IF validation fails:
  OUTPUT warnings and auto-fix if possible
```

**TUI Output (Korean):**

```markdown
## ✅ 동기화 완료

### 처리 결과
| 위치 | 작업 | 라인 수 | 상태 |
|------|------|---------|------|
| {path} | {action} | {lines} | ✅ |

### @import 구조
- 루트 @import: {list}
- 서브 CLAUDE.md: {list}

### 검증 결과
- ✅ 모든 링크 유효
- ✅ 라인 수 제한 준수

다음 작업: `/git-commit`으로 커밋
```

---

## ERROR HANDLING

| Error | Response |
|-------|----------|
| No root CLAUDE.md | "루트 CLAUDE.md가 없습니다. 생성하시겠습니까?" → offer CREATE |
| @import target missing | "⚠️ @import 대상 없음: {path}" → suggest remove or fix |
| Root >150 lines | "⚠️ 150줄 초과 - @import로 분리 권장" → suggest refactor |
| Sub >30 lines | "⚠️ 서브 30줄 초과 - 간소화 필요" → suggest trim |
| Orphan sub-CLAUDE.md | "⚠️ 로드되지 않는 위치: {path}" → suggest delete or explain |
| Permission denied | "파일 권한 없음: {path}" → skip with warning |

---

## EXECUTE NOW

1. Scan codebase (Glob for dirs, modules, existing CLAUDE.md)
2. Classify each location (SUB_NEEDED / CONSIDER / SKIP)
3. Detect required changes (CREATE / UPDATE / REVIEW / FIX_IMPORT)
4. Report findings (Korean)
5. Ask user confirmation
6. Apply approved changes
7. Validate and report completion (Korean)
