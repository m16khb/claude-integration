---
name: automation-tools:factory
description: 'Agent, Skill, Command 컴포넌트 생성기 (WebFetch 기반 문서 분석)'
argument-hint: '[type] [name]'
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - Bash(mkdir *)
  - WebFetch
  - WebSearch
model: claude-opus-4-5-20251101
---

# Component Factory

## MISSION

Generate Claude Code components (agent, skill, command) following Anthropic 2025 schema and best practices. Support research-driven generation via WebFetch and orchestrator composition from existing experts.

**Input**: $ARGUMENTS

---

## MCP INTEGRATION

```
COMPONENT GENERATION:
├─ Context7 MCP 호출 (스키마 및 best-practice)
│   ├─ resolve-library-id("claude-code")
│   ├─ get-library-docs(topic="agent skill command schema")
│   └─ 최신 Anthropic 스키마 확인
│
├─ Sequential-Thinking MCP 호출 (생성 로직)
│   ├─ 요청 분석 → 컴포넌트 타입 결정
│   ├─ 기존 컴포넌트 분석 → 패턴 추출
│   ├─ 템플릿 선택 및 커스터마이징
│   └─ 검증 체크리스트 순회
│
└─ 적용 시점:
    ├─ 새로운 에이전트 생성 시
    ├─ 스킬/커맨드 생성 시
    └─ 오케스트레이터 구성 시
```

---

## PHASE 1: Parse Arguments

```
PARSE $ARGUMENTS:
├─ IF empty → show type selection TUI
├─ IF "command [name]" → type=command, extract name
├─ IF "skill [name]" → type=skill, extract name
├─ IF "agent [name]" → type=agent, extract name
└─ ELSE → show error, suggest valid formats

DEFAULTS:
├─ type: null (require selection)
├─ name: null (require input)
├─ location: "project" (.claude/)
└─ model: "default" (inherit user setting)
```

**TUI (when no args):**

```
AskUserQuestion:
  question: "어떤 유형의 컴포넌트를 만드시겠습니까?"
  header: "유형"
  options:
    - label: "Command"
      description: "/name으로 명시적 호출하는 슬래시 커맨드"
    - label: "Skill"
      description: "관련 작업 시 자동으로 활성화되는 스킬"
    - label: "Agent"
      description: "독립 컨텍스트에서 전문 작업 수행하는 에이전트"
```

---

## PHASE 2: Collect Basic Info

### 2.1 Name Collection

```
IF name not provided:
  AskUserQuestion:
    question: "컴포넌트 이름을 입력하세요 (예: code-review, tdd-guide)"
    header: "이름"
    options:
      - label: "직접 입력"
        description: "kebab-case 형식 권장"

VALIDATE name:
├─ Must be kebab-case (lowercase, hyphens)
├─ No spaces or special characters
├─ 3-30 characters length
└─ IF invalid → show error "이름은 kebab-case 형식이어야 합니다", ask again
```

### 2.2 Purpose Collection

```
AskUserQuestion:
  question: "이 컴포넌트의 주요 목적은 무엇인가요?"
  header: "목적"
  options:
    - label: "직접 입력"
      description: "예: 코드 리뷰 자동화, TDD 사이클 안내"
```

---

## PHASE 3: Research & Documentation Analysis

```
PURPOSE: Gather best practices and code examples before generation.
BENEFIT: Research-informed components are more accurate and useful.
```

### 3.1 Research Decision

```
AskUserQuestion:
  question: "관련 문서를 검색하여 분석할까요?"
  header: "리서치"
  options:
    - label: "예, 공식문서 분석"
      description: "WebSearch/WebFetch로 최신 베스트 프랙티스 수집"
    - label: "예, GitHub 예제 분석"
      description: "유사 에이전트/스킬 예제 검색"
    - label: "아니오, 바로 생성"
      description: "리서치 없이 바로 생성"
```

### 3.2 Documentation Research

```
IF user selected "공식문서 분석":
  EXTRACT keywords from {name} and {purpose}

  SEARCH_QUERIES:
  ├─ "{keyword} official documentation 2025"
  ├─ "{keyword} best practices tutorial"
  ├─ "{keyword} NestJS/React/etc integration"
  └─ "Claude Code {type} {keyword} example"

  FOR EACH query:
    WebSearch → collect top 3-5 relevant URLs

  FOR EACH relevant URL:
    WebFetch → extract:
    ├─ Installation commands
    ├─ Configuration examples
    ├─ API patterns and code snippets
    ├─ Common pitfalls and solutions
    └─ Version-specific notes

  COMPILE research_context:
  ├─ official_docs: [extracted summaries]
  ├─ code_examples: [relevant snippets]
  ├─ dependencies: [required packages]
  └─ best_practices: [key recommendations]
```

### 3.3 GitHub Examples Research

```
IF user selected "GitHub 예제 분석":
  SEARCH_QUERIES:
  ├─ "site:github.com claude-code {type} {keyword}"
  ├─ "site:github.com anthropic skills {keyword}"
  └─ "site:github.com {keyword}-expert agent"

  FOR EACH GitHub repo found:
    WebFetch raw.githubusercontent.com URLs:
    ├─ README.md → understand structure
    ├─ agents/*.md → extract patterns
    ├─ skills/*/SKILL.md → extract triggers
    └─ commands/*.md → extract phases

  ANALYZE patterns:
  ├─ Common frontmatter fields
  ├─ Section structures
  ├─ Trigger keyword patterns
  └─ Output format conventions
```

### 3.4 Research Summary

```
DISPLAY research summary (Korean):
┌─────────────────────────────────────────┐
│ 📚 리서치 결과 요약                      │
├─────────────────────────────────────────┤
│ 공식 문서: {count}개 분석               │
│ 코드 예제: {count}개 수집               │
│ 권장 패키지: {packages}                  │
│ 주요 패턴: {patterns}                    │
└─────────────────────────────────────────┘

AskUserQuestion:
  question: "리서치 결과를 컴포넌트에 반영할까요?"
  header: "반영"
  options:
    - label: "전체 반영"
      description: "모든 분석 결과를 컴포넌트에 포함"
    - label: "선택 반영"
      description: "특정 섹션만 선택하여 반영"
    - label: "참고만"
      description: "리서치 결과는 참고만 하고 기본 생성"
```

---

## PHASE 4: Advanced Settings

### 4.1 Installation Location

```
AskUserQuestion:
  question: "설치 위치를 선택하세요"
  header: "위치"
  options:
    - label: "프로젝트"
      description: ".claude/ 디렉토리 (팀과 공유)"
    - label: "사용자"
      description: "~/.claude/ 디렉토리 (개인용)"
    - label: "플러그인"
      description: "현재 플러그인 디렉토리 (배포용)"

LOCATION_MAP:
├─ "프로젝트" → base_path = ".claude"
├─ "사용자" → base_path = "~/.claude"
└─ "플러그인" → base_path = "."
```

### 4.2 Model Selection (Command/Agent only)

```
IF type IN ["command", "agent"]:
  AskUserQuestion:
    question: "사용할 모델을 선택하세요"
    header: "모델"
    options:
      - label: "기본값"
        description: "사용자 설정 모델 사용"
      - label: "Opus"
        description: "복잡한 분석/생성 작업"
      - label: "Sonnet"
        description: "균형잡힌 성능"
      - label: "Haiku"
        description: "빠른 응답, 간단한 작업"

MODEL_MAP:
├─ "기본값" → omit model field
├─ "Opus" → model: claude-opus-4-5-20251101
├─ "Sonnet" → model: claude-sonnet-4-20250514
└─ "Haiku" → model: claude-haiku-4-20250414
```

### 4.3 Tool Selection (Command/Agent only)

```
IF type IN ["command", "agent"]:
  AskUserQuestion:
    question: "필요한 도구를 선택하세요"
    header: "도구"
    multiSelect: true
    options:
      - label: "Read"
        description: "파일 읽기"
      - label: "Write"
        description: "파일 쓰기"
      - label: "Grep/Glob"
        description: "코드 검색"
      - label: "Bash"
        description: "명령어 실행"

TOOL_MAP:
├─ "Read" → "Read"
├─ "Write" → "Write"
├─ "Grep/Glob" → "Grep", "Glob"
└─ "Bash" → "Bash(*)"
```

---

## PHASE 5: Component Composition (Agent only)

```
PURPOSE: Enable orchestrator creation by composing existing expert agents.
BENEFIT: Reuse specialized experts for complex multi-domain tasks.
```

### 5.1 Composition Decision

```
IF type = "agent":
  AskUserQuestion:
    question: "컴포넌트 조합 방식을 선택하세요"
    header: "아키텍처"
    options:
      - label: "단독 에이전트"
        description: "독립적으로 동작하는 전문가 에이전트"
      - label: "오케스트레이터"
        description: "여러 전문가를 조합하여 위임하는 에이전트"
      - label: "전문가 확장"
        description: "기존 전문가 에이전트를 확장"
```

### 5.2 Expert Selection (Orchestrator)

```
IF architecture = "오케스트레이터":
  SCAN existing experts:
  ├─ Glob: agents/backend/*.md
  ├─ Glob: agents/**/*-expert.md
  └─ Extract: name, description from frontmatter

  AskUserQuestion:
    question: "조합할 전문가 에이전트를 선택하세요"
    header: "전문가"
    multiSelect: true
    options: (dynamically generated from scan)

  STORE selected_experts for generation
```

### 5.3 Orchestration Pattern

```
IF selected_experts.length > 0:
  GENERATE orchestration sections:
  ├─ SPECIALIZED EXPERTS: list with triggers and paths
  ├─ ORCHESTRATION LOGIC: routing decision tree
  │   ├─ SINGLE_EXPERT: one expert handles entire task
  │   ├─ SEQUENTIAL: chain experts with context passing
  │   ├─ PARALLEL: concurrent execution for independent tasks
  │   └─ DIRECT: orchestrator handles core domain tasks
  ├─ ROUTING EXAMPLES: user request → expert mapping
  └─ DELEGATION EXAMPLES: Task() call patterns

  ADD to allowed-tools: Task
```

### 5.4 Expert Extension

```
IF architecture = "전문가 확장":
  AskUserQuestion:
    question: "확장할 기존 전문가를 선택하세요"
    header: "기반"
    options: (dynamically generated from scan)

  READ base_expert content
  GENERATE extended agent:
  ├─ Inherit: ROLE, CAPABILITIES from base
  ├─ Add: new capabilities, knowledge
  ├─ Reference: base expert in SOURCES
  └─ Optional: override specific sections
```

---

## PHASE 6: Content Generation Strategy

```
GENERATION_STRATEGY:
├─ IF research_context exists:
│   └─ Use research_context to enrich component
│       ├─ Add KEY KNOWLEDGE section with code examples
│       ├─ Include best practices from official docs
│       ├─ Add relevant dependencies to frontmatter
│       └─ Generate realistic EXAMPLES from research
├─ IF orchestrator with selected_experts:
│   └─ Generate orchestration structure
│       ├─ SPECIALIZED EXPERTS section
│       ├─ ORCHESTRATION LOGIC with routing
│       ├─ DELEGATION EXAMPLES
│       └─ Task tool in allowed-tools
├─ ELSE:
│   └─ Generate minimal skeleton based on:
│       ├─ Component type (command/skill/agent)
│       ├─ Name and purpose
│       └─ Selected tools and model

NO_TEMPLATE_REQUIRED:
├─ All content is dynamically generated
├─ Research results directly inform structure
├─ Code examples are fetched, not templated
├─ Orchestrator patterns from existing experts
└─ Patterns are learned from GitHub analysis
```

---

## PHASE 7: Generate Content

### 7.1 Build Output Path

```
PATH_RULES:
├─ command → {base_path}/commands/{name}.md
├─ skill → {base_path}/skills/{name}/SKILL.md
└─ agent → {base_path}/agents/{name}.md

CHECK path exists:
├─ IF exists → show overwrite confirmation TUI
└─ IF not exists → proceed
```

### 7.2 Generate File Content

```
FOR type = "command":
  GENERATE with:
  ├─ frontmatter: name, description, allowed-tools, model
  ├─ MISSION: purpose in English
  ├─ PHASES: English logic with tree notation
  ├─ TUI sections: Korean labels
  ├─ ERROR HANDLING: table format
  └─ EXECUTE NOW: action summary

FOR type = "skill":
  GENERATE with:
  ├─ frontmatter: name, description, license, triggers
  ├─ triggers: extract keywords from purpose
  │   └─ Split Korean/English, add variations
  ├─ ROLE: English description
  ├─ GUIDELINES: English instructions
  └─ EXAMPLES: input/output samples

FOR type = "agent":
  GENERATE with:
  ├─ frontmatter: name, description, model, allowed-tools
  ├─ ROLE: specialization area (English)
  ├─ CAPABILITIES: categorized task list (hierarchical)
  ├─ CONSTRAINTS: limitations
  ├─ KEY KNOWLEDGE: (IF research_context)
  │   ├─ Configuration examples from official docs
  │   ├─ Code snippets with Korean comments
  │   ├─ Common patterns and anti-patterns
  │   └─ Dependency installation commands
  ├─ INPUT/OUTPUT FORMAT: JSON schema
  ├─ EXECUTION FLOW: step-by-step sequence
  ├─ ERROR HANDLING: structured responses
  └─ EXAMPLES: realistic scenarios from research
```

### 7.3 Research-Enhanced Generation

```
IF research_context.code_examples:
  FOR EACH code_example:
    ├─ Add to KEY KNOWLEDGE section
    ├─ Include Korean comments for clarity
    └─ Reference source URL in comments

IF research_context.best_practices:
  FOR EACH practice:
    ├─ Add to CONSTRAINTS or GUIDELINES
    └─ Include rationale

IF research_context.dependencies:
  ├─ Add to frontmatter (if applicable)
  └─ Include installation instructions in KEY KNOWLEDGE

CITATION_FORMAT:
// Source: {source_url}
```

---

## PHASE 8: Write Files

```
ACTIONS:
1. Bash: mkdir -p {directory_path}
2. Write: {output_path} with generated content
3. IF location = "플러그인":
   └─ Update plugin.json (add to commands/skills/agents)

VERIFY:
├─ File created successfully
└─ Content matches expected structure
```

---

## PHASE 9: Report

```markdown
## ✅ 컴포넌트 생성 완료

| 항목 | 값      |
| ---- | ------- |
| 유형 | {type}  |
| 이름 | {name}  |
| 경로 | {path}  |
| 모델 | {model} |

### 생성된 파일

`{path}`

### 사용 방법

**Command인 경우:**
/{name} [args]

**Skill인 경우:**
관련 작업 요청 시 자동 활성화됩니다.
트리거 키워드: {triggers}

**Agent인 경우:**
Task tool에서 subagent_type으로 호출됩니다.

### 다음 단계

- [ ] 생성된 파일 내용 검토 및 수정
- [ ] 테스트 실행
- [ ] (플러그인인 경우) plugin.json에 등록
```

---

## PHASE 10: Follow-up TUI

```
AskUserQuestion:
  question: "다음 작업을 선택하세요"
  header: "다음"
  options:
    - label: "파일 열기"
      description: "생성된 파일 내용 확인"
    - label: "다른 컴포넌트 생성"
      description: "factory 재실행"
    - label: "plugin.json 업데이트"
      description: "플러그인 설정에 등록"
    - label: "완료"
      description: "작업 종료"
```

---

## ERROR HANDLING

| Error | Detection | Response |
|-------|-----------|----------|
| Invalid type | type NOT IN [command, skill, agent] | "유효한 유형: command, skill, agent" |
| Invalid name | regex test fails | "이름은 kebab-case 형식이어야 합니다 (예: my-command)" |
| Path exists | file already exists | Show overwrite confirmation TUI |
| Research timeout | WebFetch fails | "리서치 실패. 기본 생성으로 진행합니다." |
| Permission denied | Write fails | "권한 오류: {path}에 쓸 수 없습니다. 다른 위치를 선택하세요." |
| Directory creation fails | mkdir fails | "디렉토리 생성 실패: {error}" |
| plugin.json parse error | JSON.parse fails | "plugin.json 파싱 오류. 수동으로 수정하세요." |
| Expert scan empty | Glob returns empty | "기존 전문가가 없습니다. 단독 에이전트로 생성합니다." |

---

## EXECUTE NOW

```
1. PARSE $ARGUMENTS → extract type, name
2. IF missing info → AskUserQuestion (Korean TUI)
3. COLLECT purpose via TUI
4. ASK research preference (공식문서/GitHub/바로 생성)
5. IF research selected:
   ├─ WebSearch → collect relevant URLs
   ├─ WebFetch → extract documentation and examples
   └─ COMPILE research_context
6. DISPLAY research summary (Korean)
7. COLLECT location, model, tools via TUI
8. IF type = agent → ASK composition (단독/오케스트레이터/확장)
9. IF orchestrator → SCAN and SELECT experts
10. GENERATE content using research_context and composition
11. BASH mkdir -p {directory}
12. WRITE component file
13. IF plugin location → UPDATE plugin.json
14. REPORT completion (Korean)
15. SHOW follow-up TUI (Korean)
```
