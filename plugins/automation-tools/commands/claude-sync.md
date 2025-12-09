---
name: automation-tools:claude-sync
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
  # Sequential Thinking for analysis
  - mcp__sequential-thinking__sequentialthinking
  # Context7 for best practices
  - mcp__context7__resolve-library-id
  - mcp__context7__get-library-docs
model: claude-opus-4-5-20251101
---

# CLAUDE.md Auto-Sync (Hierarchical Orchestration)

## MISSION

Build and synchronize hierarchical documentation orchestration system.
Scan project → identify modules → create/update CLAUDE.md and agent-docs → parallel document-builder invocation.

**핵심 원칙:**
- 모듈마다 CLAUDE.md 작성 (모듈식 아키텍처)
- LOC 초과 시 agent-docs로 분할 (간결성 유지)
- 모든 CLAUDE.md는 상위에서 참조 (계층적 연결)
- 고아 파일 0개 (무결성 보장)

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

## PHASE 0: Component Registry Sync (routing-table.json)

**Sequential Thinking으로 컴포넌트 분석:**

```
mcp__sequential-thinking__sequentialthinking:
  thought: "프로젝트 컴포넌트를 분석합니다.
    1. agents, skills, commands 파일 탐색
    2. 각 컴포넌트의 메타데이터 추출
    3. routing-table.json 갱신 필요성 판단
    4. 변경된 컴포넌트 목록 생성"
  thoughtNumber: 1
  totalThoughts: 6
  nextThoughtNeeded: true
```

```
EXECUTE PARALLEL:
├─ Glob("**/agents/*.md") → agent definitions
├─ Glob("**/skills/**/SKILL.md") → skill definitions
└─ Glob("**/commands/*.md") → command definitions

FOR each component file:
  READ file
  EXTRACT:
  ├─ name (from frontmatter)
  ├─ model (from frontmatter)
  ├─ triggers (from ## TRIGGERS section or frontmatter)
  └─ path (relative to project root)

BUILD component_registry:
{
  agents: {
    "typeorm-expert": {
      path: "plugins/backend-development/agents/typeorm-expert.md",
      model: "opus",
      role: "expert",
      triggers: { primary: [...], secondary: [...], context: [...] }
    }
  },
  skills: { ... },
  commands: { ... }
}

UPDATE .claude-plugin/routing-table.json:
├─ Merge new components
├─ Update last_synced timestamp
├─ Remove deleted components
└─ Validate all paths exist
```

---

## PHASE 0.5: Best Practices Reference (Context7)

**Context7로 최신 CLAUDE.md 베스트 프랙티스 조회:**

```
mcp__sequential-thinking__sequentialthinking:
  thought: "CLAUDE.md 베스트 프랙티스를 Context7에서 조회합니다.
    1. Claude Code 공식 문서 검색
    2. 계층적 문서화 패턴 확인
    3. LOC 제한 및 분할 기준 파악
    4. 프로젝트 기술 스택에 맞는 가이드라인 적용"
  thoughtNumber: 2
  totalThoughts: 6
  nextThoughtNeeded: true
```

```
# Context7 베스트 프랙티스 조회
mcp__context7__resolve-library-id:
  libraryName: "Claude Code CLAUDE.md"

mcp__context7__get-library-docs:
  context7CompatibleLibraryID: "{resolved_id}"
  topic: "CLAUDE.md hierarchical documentation"
  mode: "info"
```

### CLAUDE.md 베스트 프랙티스 (2025 기준)

```
BEST PRACTICES (Anthropic Official + Community):
├─ 간결성
│   ├─ CLAUDE.md는 시스템 프롬프트에 포함됨
│   ├─ 정보를 별도 markdown 파일로 분리하고 참조
│   └─ 민감 정보 포함 금지
│
├─ 계층적 구조
│   ├─ ~/.claude/CLAUDE.md (전역)
│   ├─ parent directories (상위)
│   └─ project root (프로젝트)
│
├─ 모듈식 아키텍처
│   ├─ 단일 monolithic 대신 모듈별 분리
│   ├─ "Use nested CLAUDE.md files for different development areas"
│   └─ context-specific files: backend/, frontend/, database/
│
├─ LOC 제한 (Line of Code)
│   ├─ ROOT: max 150 lines
│   ├─ MODULE: max 80 lines
│   └─ SUBMODULE: max 50 lines
│
└─ 참조 규칙
    ├─ 중복 방지: 각 가이드라인은 한 곳에만
    ├─ 외부 문서 링크 활용, 복사 금지
    └─ 하위 CLAUDE.md는 상위에서 참조
```

---

## PHASE 1: Hierarchical Scan

**Sequential Thinking으로 계층 구조 분석:**

```
mcp__sequential-thinking__sequentialthinking:
  thought: "프로젝트 계층 구조를 분석합니다.
    1. 루트 디렉토리 및 모듈 탐색
    2. 기존 CLAUDE.md 파일 위치 파악
    3. agent-docs 디렉토리 존재 여부 확인
    4. 모듈 간 관계 및 의존성 파악
    5. 누락된 CLAUDE.md 위치 식별"
  thoughtNumber: 3
  totalThoughts: 6
  nextThoughtNeeded: true
```

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

**Sequential Thinking으로 갭 분석:**

```
mcp__sequential-thinking__sequentialthinking:
  thought: "CLAUDE.md 갭 분석을 수행합니다.
    1. 각 모듈의 CLAUDE.md 존재 여부 확인
    2. 기존 CLAUDE.md의 LOC 측정
    3. agent-docs 필요성 판단
    4. 상위/하위 참조 무결성 검사
    5. 작업 큐 우선순위 결정"
  thoughtNumber: 4
  totalThoughts: 6
  nextThoughtNeeded: true
```

```
FOR each item in HIERARCHY:
  ANALYZE:
  ├─ CLAUDE.md exists?
  ├─ CLAUDE.md line count (if exists)
  ├─ agent-docs/ exists?
  ├─ Parent CLAUDE.md referenced? ← 상위에서 이 모듈을 참조하는가?
  ├─ Child modules linked? ← 하위 모듈을 참조하는가?
  ├─ agent-docs linked? ← agent-docs를 참조하는가?
  └─ Content up-to-date?

  LINE COUNT RULES (LOC 제한 - 유연한 가이드라인):
  ┌─────────────────┬───────────┬───────────┬─────────────────────────────┐
  │ Level           │ Soft Limit│ Hard Limit│ Rationale                   │
  ├─────────────────┼───────────┼───────────┼─────────────────────────────┤
  │ ROOT CLAUDE.md  │ 300       │ 500       │ 네비게이션 허브, 전체 개요   │
  │ MODULE CLAUDE.md│ 200       │ 350       │ 모듈별 핵심 정보            │
  │ SUBMODULE       │ 150       │ 250       │ 세부 컴포넌트 설명          │
  └─────────────────┴───────────┴───────────┴─────────────────────────────┘

  SOFT LIMIT: 경고 표시, agent-docs 분할 권장
  HARD LIMIT: 강제 분할 필요, agent-docs 생성 필수

  IF line_count > HARD_LIMIT:
    CLASSIFY as NEEDS_AGENT_DOCS (강제)
    ├─ Extract reference sections to agent-docs/
    ├─ Keep only summaries in CLAUDE.md
    └─ Add links to detailed docs

  ELIF line_count > SOFT_LIMIT:
    CLASSIFY as RECOMMEND_AGENT_DOCS (권장)
    ├─ 경고 표시
    ├─ 분할 제안
    └─ 사용자 선택에 따라 진행

  CLASSIFY:
  ├─ CREATE_CLAUDE_MD: CLAUDE.md 누락
  ├─ CREATE_AGENT_DOCS: agent-docs/ 필요하지만 없음
  ├─ NEEDS_AGENT_DOCS: HARD_LIMIT 초과, 강제 분할 필요
  ├─ RECOMMEND_AGENT_DOCS: SOFT_LIMIT 초과, 분할 권장
  ├─ UPDATE_CLAUDE_MD: 파일 구조 변경됨
  ├─ UPDATE_LINKS: 참조 링크 깨짐
  ├─ ADD_PARENT_LINK: 상위 참조 누락
  ├─ ADD_CHILD_LINK: 하위 모듈 참조 누락
  └─ OK: 최신 상태

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

**Sequential Thinking으로 분할 결정:**

```
mcp__sequential-thinking__sequentialthinking:
  thought: "CLAUDE.md 분할 전략을 결정합니다.
    1. LOC 초과 CLAUDE.md 식별
    2. 추출 가능한 섹션 분류
    3. agent-docs 파일 구조 설계
    4. 참조 링크 생성 계획
    5. 분할 후 LOC 검증"
  thoughtNumber: 5
  totalThoughts: 6
  nextThoughtNeeded: true
```

### 분할 기준 및 규칙

```
WHEN CLAUDE.md exceeds line limit:

  FILE NAMING STRATEGY (의미 기반 파일명):
  ├─ 콘텐츠의 핵심 주제를 반영
  └─ 예: typeorm.md, dayjs.md, module-naming.md, api-design.md

  IDENTIFY extractable sections by TOPIC (주제별 분류):
  ┌────────────────────┬───────────┬───────────────────────────────────┐
  │ Content Category   │ Threshold │ File Naming Rule                  │
  ├────────────────────┼───────────┼───────────────────────────────────┤
  │ Library/Framework  │ > 30 lines│ {library-name}.md                 │
  │                    │           │ 예: typeorm.md, dayjs.md          │
  │ Design Pattern     │ > 25 lines│ {pattern-name}.md                 │
  │                    │           │ 예: module-naming.md, cqrs.md     │
  │ API/Endpoint       │ > 30 lines│ {api-domain}.md                   │
  │                    │           │ 예: user-api.md, payment-api.md   │
  │ Configuration      │ > 20 lines│ {config-topic}.md                 │
  │                    │           │ 예: env-setup.md, docker-config.md│
  │ Integration        │ > 25 lines│ {integration-target}.md           │
  │                    │           │ 예: redis-integration.md          │
  │ Workflow/Process   │ > 20 lines│ {workflow-name}.md                │
  │                    │           │ 예: deployment-flow.md, ci-cd.md  │
  └────────────────────┴───────────┴───────────────────────────────────┘

  CREATE agent-docs/ at SAME LEVEL as CLAUDE.md:
  ├─ {module}/CLAUDE.md
  ├─ {module}/agent-docs/           ← 같은 레벨!
  │   ├─ {topic-1}.md               ← 의미 있는 파일명
  │   ├─ {topic-2}.md
  │   ├─ {topic-3}.md
  │   └─ [as many as needed by content]
  │
  └─ Directory structure mirrors CLAUDE.md level
```

### CLAUDE.md 필수 구조 (분할 후)

```markdown
# {Module Name}

{1-2문장 개요}

## 핵심 기능
{간결한 기능 설명}

## 주요 구성요소
| 이름 | 역할 | 설명 |
|------|------|------|

## 빠른 시작
{필수 명령어만}

## 상세 문서
{의미 기반 파일명으로 분리된 문서들}
- [{topic-1}](agent-docs/{topic-1}.md) - {topic-1 설명}
- [{topic-2}](agent-docs/{topic-2}.md) - {topic-2 설명}
- [{topic-3}](agent-docs/{topic-3}.md) - {topic-3 설명}

예시:
- [TypeORM 가이드](agent-docs/typeorm.md) - Entity, Repository 패턴
- [날짜 처리](agent-docs/dayjs.md) - dayjs 사용법
- [모듈 네이밍](agent-docs/module-naming.md) - 명명 규칙
- [API 설계](agent-docs/api-design.md) - RESTful 설계 원칙

## 하위 모듈 (있을 경우)
- [submodule/](submodule/CLAUDE.md) - 설명

[parent](../CLAUDE.md)  ← 필수! (root 제외)
```

### agent-docs 파일 헤더 템플릿

```markdown
# {Title}

> 이 문서는 [{parent_module}/CLAUDE.md](../CLAUDE.md)의 상세 문서입니다.

## 개요
{섹션 개요}

## 상세 내용
{추출된 상세 내용}

---
[← CLAUDE.md로 돌아가기](../CLAUDE.md)
```

### 분할 실행 규칙

```
EXTRACTION RULES:
├─ Keep in CLAUDE.md:
│   ├─ Overview (개요)
│   ├─ Quick Start (빠른 시작)
│   ├─ Key Components table (주요 구성요소 테이블)
│   └─ Links to agent-docs and child modules
│
├─ Extract to agent-docs/:
│   ├─ Detailed guides (> 20 lines)
│   ├─ Full code examples (> 10 lines)
│   ├─ Reference materials
│   ├─ Architecture deep-dives
│   └─ Troubleshooting guides
│
└─ MANDATORY:
    ├─ All extracted content MUST be linked from CLAUDE.md
    ├─ All agent-docs files MUST link back to CLAUDE.md
    └─ No orphan files allowed
```

### 분할 예시

```
EXAMPLE 1 - Backend Module:
  backend/CLAUDE.md (280 lines) → exceeds 200 line soft limit

  ANALYZE CONTENT TOPICS:
  ├─ TypeORM 사용법 (45 lines) → 별도 문서 가치 있음
  ├─ Redis 캐싱 전략 (35 lines) → 별도 문서 가치 있음
  ├─ API 설계 원칙 (40 lines) → 별도 문서 가치 있음
  └─ 환경 설정 (30 lines) → 별도 문서 가치 있음

  EXTRACT (의미 기반 파일명):
  ├─ TypeORM 관련 → backend/agent-docs/typeorm.md
  ├─ Redis 관련 → backend/agent-docs/redis-caching.md
  ├─ API 설계 → backend/agent-docs/api-design.md
  └─ 환경 설정 → backend/agent-docs/env-config.md

  RESULT:
  ├─ backend/CLAUDE.md (130 lines) ✅ LOC 준수
  └─ backend/agent-docs/
      ├─ typeorm.md           ← Entity, Repository, Migration
      ├─ redis-caching.md     ← 캐시 전략, TTL 설정
      ├─ api-design.md        ← RESTful 원칙, 응답 형식
      └─ env-config.md        ← 환경변수, Docker 설정

EXAMPLE 2 - Frontend Module:
  frontend/CLAUDE.md (220 lines) → exceeds 200 line soft limit

  EXTRACT (의미 기반 파일명):
  ├─ 상태 관리 → frontend/agent-docs/state-management.md
  ├─ 컴포넌트 패턴 → frontend/agent-docs/component-patterns.md
  └─ 스타일링 → frontend/agent-docs/styling-guide.md

  RESULT:
  ├─ frontend/CLAUDE.md (95 lines) ✅ LOC 준수
  └─ frontend/agent-docs/
      ├─ state-management.md  ← Redux, Context API
      ├─ component-patterns.md ← HOC, Render Props, Hooks
      └─ styling-guide.md     ← CSS Modules, Styled Components
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

## PHASE 6.5: Orphan Detection & Auto-Fix (고아 방지)

**Sequential Thinking으로 고아 파일 탐지:**

```
mcp__sequential-thinking__sequentialthinking:
  thought: "고아 CLAUDE.md와 agent-docs를 탐지하고 수정합니다.
    1. 모든 CLAUDE.md 파일 수집
    2. 상위 CLAUDE.md에서 참조 여부 확인
    3. 모든 agent-docs 파일 수집
    4. 해당 CLAUDE.md에서 참조 여부 확인
    5. 누락된 참조 자동 추가"
  thoughtNumber: 6
  totalThoughts: 6
  nextThoughtNeeded: false
```

### 고아 정의 및 탐지

```
ORPHAN DEFINITIONS:
├─ 고아 CLAUDE.md: 상위 CLAUDE.md에서 참조되지 않는 CLAUDE.md
│   ├─ 예외: ROOT CLAUDE.md (최상위이므로 상위 없음)
│   └─ 해결: 상위에 [module/](module/CLAUDE.md) 링크 추가
│
├─ 고아 agent-docs: 해당 레벨 CLAUDE.md에서 참조되지 않는 agent-docs/*.md
│   └─ 해결: CLAUDE.md의 "상세 문서" 섹션에 링크 추가
│
└─ 역방향 고아: [parent](../CLAUDE.md) 링크가 없는 CLAUDE.md
    ├─ 예외: ROOT CLAUDE.md
    └─ 해결: 파일 끝에 [parent](../CLAUDE.md) 추가

DETECTION LOGIC:
FOR each CLAUDE.md file (excluding ROOT):
  parent_dir = dirname(dirname(CLAUDE.md))
  parent_claude = parent_dir + "/CLAUDE.md"

  IF parent_claude exists:
    content = READ(parent_claude)
    link_pattern = "[{module_name}/]({module_name}/CLAUDE.md)"

    IF link_pattern NOT IN content:
      CLASSIFY as ORPHAN_CLAUDE_MD
      FIX: Add link to parent's "하위 모듈" section

FOR each agent-docs/*.md file:
  parent_claude = dirname(agent-docs) + "/CLAUDE.md"

  IF parent_claude exists:
    content = READ(parent_claude)
    link_pattern = "[{filename}](agent-docs/{filename})"

    IF link_pattern NOT IN content:
      CLASSIFY as ORPHAN_AGENT_DOC
      FIX: Add link to parent's "상세 문서" section
```

### 자동 수정 로직

```
AUTO-FIX ORPHANS:

1. ORPHAN_CLAUDE_MD 수정:
   parent_claude = "../CLAUDE.md"

   IF "## 하위 모듈" section exists:
     APPEND link to section
   ELSE:
     CREATE "## 하위 모듈" section with link

   ADD to CLAUDE.md:
   ## 하위 모듈
   - [{module_name}/]({module_name}/CLAUDE.md) - {auto_generated_description}

2. ORPHAN_AGENT_DOC 수정:
   parent_claude = "../CLAUDE.md"

   IF "## 상세 문서" section exists:
     APPEND link to section
   ELSE:
     CREATE "## 상세 문서" section with link

   ADD to CLAUDE.md:
   ## 상세 문서
   - [{filename}](agent-docs/{filename}) - {auto_generated_description}

3. MISSING_PARENT_LINK 수정:
   IF "[parent]" NOT IN CLAUDE.md:
     APPEND "\n\n[parent](../CLAUDE.md)" to file end
```

### 검증 결과 리포트

```markdown
## 🔍 고아 파일 탐지 결과

### 탐지된 고아 파일
| 유형 | 파일 경로 | 문제점 | 자동 수정 |
|------|----------|--------|----------|
| CLAUDE.md | plugins/new-plugin/CLAUDE.md | 상위 참조 없음 | ✅ 추가됨 |
| agent-docs | commands/agent-docs/new-guide.md | CLAUDE.md 링크 없음 | ✅ 추가됨 |
| parent 링크 | plugins/test/CLAUDE.md | [parent] 누락 | ✅ 추가됨 |

### 수정 후 상태
- ✅ 모든 CLAUDE.md가 상위에서 참조됨
- ✅ 모든 agent-docs가 해당 CLAUDE.md에서 참조됨
- ✅ 모든 CLAUDE.md에 parent 링크 존재 (root 제외)
- ✅ 고아 파일: 0개
```

---

## PHASE 7: Validation & Report

```
FINAL VALIDATION:
├─ All CLAUDE.md files exist
├─ All @import paths resolve
├─ All inter-document links work
├─ No orphan CLAUDE.md files ← PHASE 6.5에서 처리됨
├─ No orphan agent-docs files ← PHASE 6.5에서 처리됨
├─ All parent links valid ← PHASE 6.5에서 처리됨
├─ Line counts within limits (soft/hard)
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
├── @import ../documentation-generation/agent-docs/commands.md
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

### Execution Flow (Sequential Thinking 기반)

```
0. **Phase 0**: Component Registry Sync
   └─ routing-table.json 자동 갱신

0.5. **Phase 0.5**: Best Practices Reference ← NEW
   ├─ Context7로 최신 CLAUDE.md 가이드라인 조회
   └─ 프로젝트 기술 스택에 맞는 베스트 프랙티스 적용

1. **Phase 1**: Hierarchical Scan (ST 1/6)
   ├─ 프로젝트 계층 구조 분석
   └─ 기존 CLAUDE.md/agent-docs 위치 파악

2. **Phase 2**: Gap Analysis (ST 2/6)
   ├─ LOC 측정 (Soft: 300/200/150, Hard: 500/350/250)
   ├─ 누락된 CLAUDE.md 식별
   └─ 참조 무결성 검사

2.5. **Phase 2.5**: Agent-docs Strategy (ST 3/6) ← ENHANCED
   ├─ LOC 초과 파일 분할 전략 수립
   ├─ 같은 레벨에 agent-docs/ 생성
   └─ 추출 섹션 및 링크 계획

3. **Phase 3**: Report & Confirm
   └─ 분석 결과 한글 리포트

4. **Phase 4**: User Confirmation
   └─ TUI로 작업 선택

5. **Phase 5**: Parallel Execution
   ├─ document-builder 에이전트 병렬 호출
   └─ 우선순위 기반 그룹 실행

6. **Phase 6**: Update Root CLAUDE.md
   └─ 새 모듈 링크 추가

6.5. **Phase 6.5**: Orphan Detection (ST 6/6) ← NEW
   ├─ 고아 CLAUDE.md 탐지 및 자동 수정
   ├─ 고아 agent-docs 탐지 및 자동 수정
   └─ parent 링크 누락 자동 추가

7. **Phase 7**: Validation & Report
   ├─ 전체 검증 (링크, LOC, 계층)
   └─ 완료 리포트 (Korean)

8. **Phase 8**: Follow-up TUI ← REQUIRED
   └─ 커밋, 검토, 재동기화 선택
```

### 핵심 보장 사항

```
✅ 모든 모듈에 CLAUDE.md 생성
✅ LOC 초과 시 agent-docs로 자동 분할
✅ 의미 기반 파일명 사용 (typeorm.md, dayjs.md 등)
✅ 모든 CLAUDE.md는 상위에서 참조됨
✅ 모든 agent-docs는 해당 CLAUDE.md에서 참조됨
✅ 고아 파일 0개 보장
✅ Sequential Thinking 6단계 분석
✅ Context7 베스트 프랙티스 적용
```
