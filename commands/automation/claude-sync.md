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
  - Task
  - AskUserQuestion
model: claude-opus-4-5-20251101
---

# CLAUDE.md Auto-Sync (Hierarchical Orchestration)

## MISSION

Build and synchronize hierarchical documentation orchestration system.
Scan project → identify modules → create/update CLAUDE.md and agent-docs → parallel document-builder invocation.

---

## ARCHITECTURE OVERVIEW

```
                      ┌─────────────────┐
                      │  Root CLAUDE.md │  ← Top-level orchestrator
                      └────────┬────────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
                ▼              ▼              ▼
      ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
      │ commands/   │ │ agents/     │ │ templates/  │
      │ CLAUDE.md   │ │ CLAUDE.md   │ │ CLAUDE.md   │
      └──────┬──────┘ └──────┬──────┘ └─────────────┘
             │               │
             ▼               ▼
      ┌─────────────┐ ┌─────────────┐
      │ agent-docs/ │ │ backend/    │
      │ (optional)  │ │ CLAUDE.md   │
      └─────────────┘ └──────┬──────┘
                             │
                             ▼
                      ┌─────────────┐
                      │ agent-docs/ │
                      │ (optional)  │
                      └─────────────┘
```

---

## PHASE 1: Hierarchical Scan

```
EXECUTE PARALLEL:
├─ Glob("*") → root directories
├─ Glob("**/CLAUDE.md") → existing CLAUDE.md files
├─ Glob("**/agent-docs") → existing agent-docs dirs
├─ Glob("*/package.json") → level-1 modules
├─ Glob("*/*/package.json") → level-2 submodules
└─ Glob("**/*.md") → all markdown files

COLLECT → HIERARCHY:
{
  root: {
    path: "/",
    has_claude_md: boolean,
    has_agent_docs: boolean,
    children: ["commands", "agents", "templates"]
  },
  modules: [
    {
      path: "commands",
      type: "MODULE",
      has_claude_md: boolean,
      has_agent_docs: boolean,
      files: ["*.md"],
      children: []
    },
    {
      path: "agents",
      type: "MODULE",
      has_claude_md: boolean,
      has_agent_docs: boolean,
      children: ["backend", "frontend", "infrastructure"]
    }
  ],
  submodules: [
    {
      path: "agents/backend",
      type: "SUBMODULE",
      parent: "agents",
      has_claude_md: boolean,
      has_agent_docs: boolean,
      files: ["*.md"]
    }
  ]
}
```

---

## PHASE 2: Gap Analysis

```
FOR each item in HIERARCHY:
  ANALYZE:
  ├─ CLAUDE.md exists?
  ├─ CLAUDE.md line count (if exists)
  ├─ agent-docs/ exists?
  ├─ Parent CLAUDE.md referenced?
  ├─ Child modules linked?
  └─ Content up-to-date?

  LINE COUNT RULES:
  ├─ ROOT CLAUDE.md: max 150 lines
  ├─ MODULE CLAUDE.md: max 80 lines
  └─ SUBMODULE CLAUDE.md: max 50 lines

  IF line_count > limit:
    CLASSIFY as NEEDS_AGENT_DOCS
    ├─ Extract reference sections to agent-docs/
    ├─ Keep only summaries in CLAUDE.md
    └─ Add links to detailed docs

  CLASSIFY:
  ├─ CREATE_CLAUDE_MD: CLAUDE.md missing
  ├─ CREATE_AGENT_DOCS: agent-docs/ needed but missing
  ├─ NEEDS_AGENT_DOCS: CLAUDE.md too large, needs refactoring
  ├─ UPDATE_CLAUDE_MD: file structure changed
  ├─ UPDATE_LINKS: reference links broken
  └─ OK: up-to-date

BUILD TASK_QUEUE:
[
  {
    action: "CREATE",
    target: { path: "commands", type: "MODULE" },
    priority: 1,  // MODULE before SUBMODULE
    context: { ... }
  },
  {
    action: "CREATE",
    target: { path: "agents/backend", type: "SUBMODULE" },
    priority: 2,
    context: { parent_claude_md: "agents/CLAUDE.md", ... }
  },
  {
    action: "REFACTOR_TO_AGENT_DOCS",
    target: { path: "commands", type: "MODULE" },
    priority: 3,  // After CLAUDE.md exists
    context: {
      current_lines: 95,
      max_lines: 80,
      sections_to_extract: ["detailed-guide", "examples"]
    }
  }
]
```

---

## PHASE 2.5: Agent-docs Auto-generation

```
WHEN CLAUDE.md exceeds line limit:

  IDENTIFY extractable sections:
  ├─ Detailed guides (> 20 lines)
  ├─ Code examples (> 10 lines)
  ├─ Reference tables (> 15 rows)
  └─ Architecture diagrams

  CREATE agent-docs/ at same level:
  ├─ {module}/agent-docs/
  │   ├─ detailed-guide.md      # Extracted detailed content
  │   ├─ examples.md            # Code examples
  │   └─ references.md          # External links, resources
  │
  └─ Directory structure mirrors CLAUDE.md level

  UPDATE CLAUDE.md:
  ├─ Replace detailed sections with summaries
  ├─ Add links: "상세 내용은 [agent-docs/detailed-guide.md](agent-docs/detailed-guide.md) 참조"
  └─ Verify line count within limit

  EXTRACTION RULES:
  ├─ Keep: Overview, Quick Start, Essential info
  ├─ Extract: Detailed guides, Full examples, References
  └─ Link: All extracted content must be linked from CLAUDE.md

EXAMPLE:
  commands/CLAUDE.md (95 lines) → exceeds 80 line limit

  EXTRACT:
  ├─ "## 커맨드 작성 상세 가이드" → commands/agent-docs/command-writing.md
  └─ "## 예제 모음" → commands/agent-docs/examples.md

  RESULT:
  ├─ commands/CLAUDE.md (52 lines) ✅
  └─ commands/agent-docs/
      ├─ command-writing.md
      └─ examples.md
```

---

## PHASE 3: Report & Confirm

**TUI Output (Korean):**

```markdown
## 🔄 계층적 문서 동기화 분석

### 현재 구조
```
claude-integration/
├── CLAUDE.md ✅
├── agent-docs/ ✅
├── commands/
│   ├── CLAUDE.md ❌ (생성 필요)
│   └── agent-docs/ ⚠️ (선택)
├── agents/
│   ├── CLAUDE.md ❌ (생성 필요)
│   └── backend/
│       ├── CLAUDE.md ❌ (생성 필요)
│       └── agent-docs/ ⚠️ (선택)
└── templates/
    └── CLAUDE.md ❌ (생성 필요)
```

### 작업 계획

| 우선순위 | 경로 | 작업 | 유형 |
|---------|------|------|------|
| 1 | commands/CLAUDE.md | 생성 | MODULE |
| 1 | agents/CLAUDE.md | 생성 | MODULE |
| 1 | templates/CLAUDE.md | 생성 | MODULE |
| 2 | agents/backend/CLAUDE.md | 생성 | SUBMODULE |

### 병렬 처리 계획
- 그룹 1 (동시 실행): commands, agents, templates
- 그룹 2 (그룹 1 완료 후): agents/backend
```

---

## PHASE 4: User Confirmation

```
AskUserQuestion:
  question: "위 계획대로 문서를 생성/수정하시겠습니까?"
  header: "동기화"
  options:
    - label: "전체 적용"
      description: "모든 작업 실행 (병렬 처리)"
    - label: "선택 적용"
      description: "작업별로 확인 후 진행"
    - label: "미리보기"
      description: "생성될 내용 먼저 확인"
    - label: "취소"
      description: "변경 없이 종료"
```

---

## PHASE 5: Parallel Execution

```
IF "전체 적용" OR "선택 적용":

  GROUP_BY_PRIORITY(TASK_QUEUE)

  FOR each priority_group:
    # Same priority = parallel execution
    PARALLEL_EXECUTE:
      FOR each task in priority_group:
        Task(
          subagent_type="document-builder",
          prompt="""
          Hierarchical CLAUDE.md creation/modification task:

          Action: {task.action}
          Target Path: {task.target.path}
          Target Type: {task.target.type}

          Context:
          - Project Name: {context.project_name}
          - Module Purpose: {context.module_purpose}
          - Existing Files: {context.existing_files}
          - Parent CLAUDE.md: {context.parent_claude_md}
          - Tech Stack: {context.tech_stack}

          Requirements:
          1. Create CLAUDE.md following template
          2. Create agent-docs/ if needed
          3. Set parent/child reference links
          4. Respect line count limits
          """
        )

    WAIT for all tasks in group
    VALIDATE results
    CONTINUE to next priority_group
```

### Parallel Execution Example

```
# Priority 1: MODULE level (parallel)
SINGLE MESSAGE with MULTIPLE Task calls:
├─ Task(subagent_type="document-builder", prompt="commands/CLAUDE.md...")
├─ Task(subagent_type="document-builder", prompt="agents/CLAUDE.md...")
└─ Task(subagent_type="document-builder", prompt="templates/CLAUDE.md...")

# Wait for all Priority 1 tasks

# Priority 2: SUBMODULE level (sequential - parent dependency)
├─ Task(subagent_type="document-builder", prompt="agents/backend/CLAUDE.md...")
└─ Task(subagent_type="document-builder", prompt="agents/frontend/CLAUDE.md...")
```

---

## PHASE 6: Update Root CLAUDE.md

```
AFTER all document-builder tasks complete:

  READ current root CLAUDE.md

  UPDATE "모듈별 컨텍스트" section:
    FOR each MODULE with new CLAUDE.md:
      ADD row to table:
      | [module/](module/CLAUDE.md) | module description |

  VALIDATE:
  ├─ All module links resolve
  ├─ Line count < 150
  └─ No duplicate content

  WRITE updated root CLAUDE.md
```

---

## PHASE 7: Validation & Report

```
FINAL VALIDATION:
├─ All CLAUDE.md files exist
├─ All @import paths resolve
├─ All inter-document links work
├─ No orphan CLAUDE.md files
├─ Line counts within limits
└─ Hierarchy integrity maintained

IF validation_errors:
  REPORT errors
  SUGGEST fixes
ELSE:
  SUCCESS report
```

**TUI Output (Korean):**

```markdown
## ✅ 계층적 동기화 완료

### 생성된 문서
| 경로 | 유형 | 라인 수 | 상태 |
|------|------|---------|------|
| commands/CLAUDE.md | MODULE | 45 | ✅ |
| agents/CLAUDE.md | MODULE | 52 | ✅ |
| templates/CLAUDE.md | MODULE | 38 | ✅ |
| agents/backend/CLAUDE.md | SUBMODULE | 48 | ✅ |

### 계층 구조
```
Root CLAUDE.md
├── @import agent-docs/commands.md
├── 참조 → commands/CLAUDE.md
├── 참조 → agents/CLAUDE.md
│   └── 참조 → agents/backend/CLAUDE.md
└── 참조 → templates/CLAUDE.md
```

### 검증 결과
- ✅ 모든 링크 유효
- ✅ 라인 수 제한 준수
- ✅ 부모-자식 참조 무결성
```

---

## PHASE 8: Follow-up TUI

```
AskUserQuestion:
  question: "동기화가 완료되었습니다. 다음 작업을 선택하세요."
  header: "후속"
  options:
    - label: "커밋"
      description: "/git-commit으로 변경사항 커밋"
    - label: "문서 검토"
      description: "생성된 CLAUDE.md 파일 열기"
    - label: "재동기화"
      description: "변경사항 확인 후 다시 동기화"
    - label: "완료"
      description: "작업을 종료합니다"
```

---

## ERROR HANDLING

| Error | Response |
|-------|----------|
| document-builder failure | Skip module with warning |
| Parent CLAUDE.md missing | Create parent first, then retry |
| Circular reference detected | Report error, request manual fix |
| Permission error | Skip path with warning |
| Parallel task conflict | Re-execute sequentially |

---

## CONTEXT COLLECTION HELPERS

### Module Context Extraction

```
FOR MODULE at path:
  context = {
    project_name: from root CLAUDE.md,
    module_purpose: from README first line or infer from files,
    existing_files: Glob("{path}/*.md") + Glob("{path}/*.ts"),
    parent_claude_md: "../CLAUDE.md",
    tech_stack: infer from file extensions and imports
  }

  IF path == "commands":
    context.module_purpose = "slash command definitions"
    context.writing_guide = from agent-docs/command-writing.md

  IF path == "agents":
    context.module_purpose = "specialized agent definitions"
    context.writing_guide = from agent-docs/agents.md

  IF path == "templates":
    context.module_purpose = "generation templates"
```

### Submodule Context Extraction

```
FOR SUBMODULE at path:
  parent_path = dirname(path)

  context = {
    project_name: from root CLAUDE.md,
    module_purpose: infer from files,
    existing_files: Glob("{path}/*.md"),
    parent_claude_md: "{parent_path}/CLAUDE.md",
    specialization: infer from agent names
  }

  IF path == "agents/backend":
    context.specialization = "NestJS ecosystem expert agents"
    context.orchestrator = "nestjs-fastify-expert.md"
```

---

## EXECUTE NOW

1. **Phase 1**: Scan project hierarchy
2. **Phase 2**: Gap analysis and build task queue
3. **Phase 3**: Report analysis results (Korean)
4. **Phase 4**: Request user confirmation
5. **Phase 5**: Parallel/sequential document-builder invocation
6. **Phase 6**: Update root CLAUDE.md
7. **Phase 7**: Final validation and completion report (Korean)
8. **Phase 8**: Show follow-up TUI ← REQUIRED
