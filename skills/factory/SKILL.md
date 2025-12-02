---
name: factory
description: Generate production-ready Claude Code agents, skills, and commands following Anthropic 2025 schema. Auto-activates when user wants to create automation tools.
license: MIT
triggers:
  - "agent 만들"
  - "skill 생성"
  - "command 생성"
  - "커맨드 만들"
  - "에이전트 생성"
  - "스킬 만들"
  - "factory"
  - "create agent"
  - "create skill"
  - "create command"
  - "새 커맨드"
  - "새 스킬"
---

# Component Factory Skill

Generate production-ready Claude Code components (agent, skill, command) following Anthropic 2025 schema with enterprise-grade patterns.

---

## ROLE

```
WHEN user wants to create automation tools:
├─ Determine component type (agent/skill/command)
├─ Collect requirements via interactive TUI
├─ Apply best practices from:
│   ├─ MoAI-ADK (SPEC-First, Orchestrator-Worker pattern)
│   ├─ claude-code-skill-factory (5 factory systems)
│   └─ Anthropic official skills schema
├─ Generate production-ready files
└─ Guide installation and testing
```

---

## ARCHITECTURE: 3-Tier Component System

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMPONENT HIERARCHY                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐           │
│  │   COMMAND   │   │    SKILL    │   │    AGENT    │           │
│  │  (Explicit) │   │   (Auto)    │   │ (Isolated)  │           │
│  └──────┬──────┘   └──────┬──────┘   └──────┬──────┘           │
│         │                 │                 │                   │
│         ▼                 ▼                 ▼                   │
│  /name invocation   Trigger-based     Task tool call           │
│  User-initiated     Context-aware     Independent context      │
│  Direct control     Progressive       Single responsibility    │
│                     disclosure                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## COMPONENT TYPE DECISION MATRIX

| Criteria | Command | Skill | Agent |
|----------|---------|-------|-------|
| Invocation | Explicit `/name` | Auto on triggers | `Task` tool |
| Context | Shared | Shared | Isolated |
| Use Case | Repeatable tasks | Domain expertise | Complex delegation |
| Token Cost | Low (~100) | Medium (~500) | High (~2000) |
| Examples | `/commit`, `/review` | `tdd-guide`, `security-check` | `code-reviewer`, `architect` |

---

## COMPONENT SCHEMAS

### 1. Slash Command (Explicit Invocation)

```yaml
# FRONTMATTER (Required)
---
name: command-name              # kebab-case, 3-30 chars
description: '한글 설명'         # Shown in /help, search
argument-hint: <required> [opt] # Argument pattern
allowed-tools:                  # Minimal tool set
  - Read
  - Write
  - Bash(git *)                 # Scoped bash patterns
model: sonnet                   # opus|sonnet|haiku|omit
---

# BODY STRUCTURE
## MISSION
{English: 1-2 sentence clear purpose}

**Input**: $ARGUMENTS

## PHASE 1-N: {Step Name}
{English logic with tree notation (├─ └─)}

## TUI: {User Interaction}
{Korean labels in AskUserQuestion}

## ERROR HANDLING
| Error | Detection | Response |
{Table: English logic, Korean messages}

## EXECUTE NOW
{Numbered action summary}
```

**File Locations:**
```
├─ Project: .claude/commands/{name}.md
├─ User: ~/.claude/commands/{name}.md
└─ Plugin: ./commands/{name}.md
```

**Namespace Pattern (Optional):**
```
/dev:code-review      # Development
/test:generate-cases  # Testing
/deploy:prepare       # Deployment
/docs:generate-api    # Documentation
```

---

### 2. Skill (Auto-Activation)

```yaml
# FRONTMATTER (Required)
---
name: skill-name
description: {English: function and activation conditions}
license: MIT
triggers:                       # Keywords for auto-activation
  - "한글 키워드"
  - "english keyword"
  - "variation"
---

# BODY STRUCTURE (Progressive Disclosure)
## ROLE
{English: What this skill does}

## GUIDELINES
{English: Instructions Claude follows}

## EXAMPLES
{Input/Output samples}

## CONSTRAINTS
{Limitations and rules}
```

**Progressive Disclosure Pattern:**
```
LOADING SEQUENCE:
├─ Phase 1: Frontmatter only (~100 tokens)
│   └─ name, description for matching
├─ Phase 2: SKILL.md body (~500-2000 tokens)
│   └─ Full instructions when activated
└─ Phase 3: Helper files (on-demand)
    └─ Templates, scripts, references
```

**File Structure:**
```
skills/{skill-name}/
├─ SKILL.md           # Main instructions
├─ templates/         # Optional: generation templates
├─ examples/          # Optional: sample outputs
└─ scripts/           # Optional: helper scripts
```

---

### 3. Agent (Subagent/Isolated Context)

```yaml
# FRONTMATTER (Required)
---
name: agent-name
description: '{English: agent specialization}'
model: sonnet                   # opus for complex, haiku for simple
allowed-tools:                  # Scoped tool access
  - Read
  - Grep
  - Glob
---

# BODY STRUCTURE
## ROLE
{English: Domain expertise area}

## CAPABILITIES
- {Task 1 this agent can perform}
- {Task 2}
- {Task 3}

## CONSTRAINTS
- {Limitation 1}
- {Limitation 2}
- Single responsibility principle

## INPUT FORMAT
{Expected input structure}

## OUTPUT FORMAT
```json
{
  "status": "success|error",
  "summary": "Brief result description",
  "details": { /* structured data */ },
  "recommendations": [ /* next steps */ ]
}
```

## EXECUTION FLOW
1. {Step 1: Validation}
2. {Step 2: Analysis}
3. {Step 3: Result generation}
```

**Agent Tiers (MoAI-ADK Pattern):**
```
TIER SYSTEM:
├─ Tier 1: Domain Experts
│   └─ expert-backend, expert-security, expert-frontend
├─ Tier 2: Workflow Managers
│   └─ manager-spec, manager-tdd, manager-docs
├─ Tier 3: Meta Generators
│   └─ builder-agent, builder-skill, builder-command
├─ Tier 4: Integration Specialists
│   └─ mcp-context7, mcp-playwright
└─ Tier 5: AI Services
    └─ Specialized AI integrations
```

---

## GENERATION WORKFLOW

### Phase 1: Type Determination

```
IF user intent unclear:
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

### Phase 2: Requirements Collection

```
COLLECT via TUI:
├─ name: kebab-case identifier
├─ purpose: Korean description of functionality
├─ location: project | user | plugin
├─ model: default | opus | sonnet | haiku (command/agent only)
└─ tools: Read | Write | Grep | Glob | Bash (command/agent only)

EXTRACT triggers (skill only):
├─ Split purpose into keywords
├─ Add Korean/English variations
└─ Include common synonyms
```

### Phase 3: Template Selection

```
LOCATE templates:
├─ Glob: ~/.claude/plugins/**/templates/*.template
├─ Glob: ./templates/*.template
└─ Fallback: inline default templates

SELECT based on type:
├─ command → command.md.template
├─ skill → skill.md.template
└─ agent → agent.md.template
```

### Phase 4: Content Generation

```
GENERATE following rules:
├─ MISSION/ROLE: English, clear purpose
├─ PHASES/GUIDELINES: English logic, tree notation
├─ TUI sections: Korean labels
├─ ERROR HANDLING: English logic, Korean messages
└─ Apply Progressive Disclosure for skills

VALIDATE:
├─ Frontmatter completeness
├─ Required sections present
├─ Korean TUI labels
└─ English internal logic
```

### Phase 5: File Creation

```
ACTIONS:
1. mkdir -p {directory_path}
2. Write component file
3. IF location = plugin:
   └─ Update plugin.json

VERIFY:
├─ File created successfully
├─ No syntax errors in YAML frontmatter
└─ Content matches expected structure
```

### Phase 6: Report (Korean)

```markdown
## ✅ 컴포넌트 생성 완료

| 항목 | 값 |
|------|-----|
| 유형 | {type} |
| 이름 | {name} |
| 경로 | {path} |
| 모델 | {model} |

### 사용 방법

**Command**: `/{name} [args]`
**Skill**: 트리거 키워드 사용 시 자동 활성화
**Agent**: Task tool에서 subagent_type으로 호출

### 다음 단계

- [ ] 생성된 파일 내용 검토 및 수정
- [ ] 테스트 실행
- [ ] plugin.json에 등록 (플러그인인 경우)
```

---

## BEST PRACTICES

### Command Best Practices

```
DO:
├─ Use $ARGUMENTS for parameter handling
├─ Provide TUI options for user choices
├─ Include follow-up action selection
├─ Minimize allowed-tools (principle of least privilege)
├─ Write MISSION in English
└─ Write TUI labels in Korean

DON'T:
├─ Auto-execute destructive actions
├─ Skip user confirmation for critical operations
├─ Use broad Bash permissions (Bash(*))
└─ Mix languages in internal logic
```

### Skill Best Practices

```
DO:
├─ Diversify triggers (Korean + English + variations)
├─ Apply Progressive Disclosure
├─ Follow single responsibility principle
├─ Keep frontmatter under 100 tokens
└─ Write guidelines in English

DON'T:
├─ Load all content upfront
├─ Create skills for one-time tasks
├─ Overlap triggers with other skills
└─ Include implementation code in SKILL.md
```

### Agent Best Practices

```
DO:
├─ Define clear OUTPUT FORMAT (JSON schema)
├─ Scope tool access narrowly
├─ Design for independent completion
├─ Use appropriate model tier
└─ Include validation in EXECUTION FLOW

DON'T:
├─ Create agents for simple tasks
├─ Allow unrestricted tool access
├─ Depend on parent context
└─ Omit error handling
```

---

## ADVANCED PATTERNS

### Orchestrator-Worker Pattern

```
USE WHEN: Complex multi-step workflows

STRUCTURE:
├─ Orchestrator: Decision logic, delegation
│   └─ Coordinates multiple workers
├─ Worker: Atomic task execution
│   └─ Template-based generation
└─ Coordinator: Mid-level orchestration
    └─ Context assembly, progressive loading

EXAMPLE:
  /workflow:full-review
  ├─ Orchestrator: review-coordinator
  │   ├─ Worker: lint-checker
  │   ├─ Worker: security-scanner
  │   └─ Worker: performance-analyzer
  └─ Output: Aggregated review report
```

### SPEC-First TDD Pattern

```
USE WHEN: Feature development with clear requirements

PHASES:
├─ PLAN: Generate EARS-format specification
│   └─ Requirements, Constraints, Success Criteria
├─ RED: Write failing tests first
├─ GREEN: Minimal implementation to pass
├─ REFACTOR: Optimize while tests pass
└─ SYNC: Auto-generate documentation
```

### Progressive Disclosure Pattern

```
USE WHEN: Token-efficient skill loading

LEVELS:
├─ L0: Name + Description (~50 tokens)
│   └─ Matching phase only
├─ L1: Full SKILL.md (~500 tokens)
│   └─ When skill activated
├─ L2: Helper files (~1000+ tokens)
│   └─ On-demand during execution
└─ Total savings: ~5000 tokens/session
```

---

## ERROR HANDLING

| Error | Detection | Response |
|-------|-----------|----------|
| Invalid type | type NOT IN [command, skill, agent] | "유효한 유형: command, skill, agent" |
| Invalid name | Not kebab-case or length invalid | "이름은 kebab-case 형식 (3-30자)이어야 합니다" |
| Path exists | File already exists at location | Show overwrite confirmation TUI |
| Template missing | Glob returns empty | Use inline default template |
| Permission denied | Write operation fails | "권한 오류. 다른 위치를 선택하세요." |
| plugin.json error | JSON parse fails | "plugin.json 수동 수정 필요" |

---

## REFERENCES

```
SOURCES:
├─ Anthropic Skills Schema: github.com/anthropics/skills
├─ MoAI-ADK: github.com/modu-ai/moai-adk
├─ Skill Factory: github.com/alirezarezvani/claude-code-skill-factory
├─ Production Skills: github.com/levnikolaevich/claude-code-skills
└─ Spec Kit: github.com/github/spec-kit
```
