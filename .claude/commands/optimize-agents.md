---
name: optimize-agents
description: '프롬프트 엔지니어링 원칙으로 에이전트 최적화'
argument-hint: <agent-file-path>
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - AskUserQuestion
model: claude-opus-4-5-20251101
---

# Agent Optimizer

## MISSION

Apply prompt engineering best practices to optimize Claude Code agents.
Ensure agents achieve their specialized purpose accurately while maintaining token efficiency.

**Input**: $ARGUMENTS

---

## ⚠️ CORE PRINCIPLES - MUST FOLLOW

```
╔════════════════════════════════════════════════════════════════╗
║  🔴 PRINCIPLE 1: PURPOSE ACCURACY - Highest Priority           ║
║  ─────────────────────────────────────────────────────────────  ║
║  Define agent role and specialization precisely                ║
║  Never sacrifice accuracy for token efficiency                 ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║  🟡 PRINCIPLE 2: ENGLISH LOGIC - Token Efficiency              ║
║  ─────────────────────────────────────────────────────────────  ║
║  Write all internal logic in English for token efficiency      ║
║  ROLE, EXECUTION FLOW, algorithms → all in English             ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║  🟢 PRINCIPLE 3: STRUCTURED OUTPUT - JSON Format               ║
║  ─────────────────────────────────────────────────────────────  ║
║  Define clear INPUT/OUTPUT FORMAT with JSON schema             ║
║  Enable consistent inter-agent communication                   ║
╚════════════════════════════════════════════════════════════════╝

⚠️ THESE PRINCIPLES ARE NON-NEGOTIABLE
   Every optimization MUST satisfy all three principles.
   If conflict exists, PRINCIPLE 1 (accuracy) takes precedence.
```

---

### Principle 1: PURPOSE ACCURACY

```
PRIORITY: Accuracy > Token Efficiency

AGENT MUST HAVE:
├─ ROLE: Clear specialization statement
│   ├─ What domain/technology this agent handles
│   ├─ What tasks it can and cannot do
│   └─ When to use this agent vs others
│
├─ EXECUTION FLOW: Step-by-step process
│   ├─ How agent analyzes input
│   ├─ How it makes decisions
│   └─ How it generates output
│
├─ ERROR HANDLING: All failure cases
│   ├─ Invalid input scenarios
│   ├─ Missing dependencies
│   └─ Recovery strategies
│
└─ BOUNDARIES: Clear scope limits
    ├─ What is in scope
    └─ What should be delegated
```

---

### Principle 2: ENGLISH LOGIC

```
WHY: English is more token-efficient (same meaning, fewer tokens)

WRITE IN ENGLISH:
├─ ROLE definition
├─ SPECIALIZATION description
├─ EXECUTION FLOW steps
├─ INPUT/OUTPUT FORMAT specs
├─ ERROR HANDLING logic
├─ Code examples
└─ Technical specifications

FORMAT:
├─ Tree notation (├─, └─) for branching
├─ Tables for specifications
└─ Code blocks for examples
```

---

### Principle 3: STRUCTURED OUTPUT

```
WHY: Enables inter-agent communication and orchestration

INPUT FORMAT:
├─ Define expected input structure
├─ Required vs optional fields
└─ Validation rules

OUTPUT FORMAT:
├─ JSON schema for responses
├─ status: success | error
├─ summary: brief description
├─ implementation: file changes
├─ recommendations: next steps
└─ Consistent across all agents
```

---

## AGENT-SPECIFIC REQUIREMENTS

### Orchestrator Agents

```
REQUIRED SECTIONS:
├─ SPECIALIZED EXPERTS: List of delegatee agents
│   ├─ agent name
│   ├─ purpose
│   ├─ trigger keywords
│   └─ path
│
├─ ORCHESTRATION LOGIC: Routing decision tree
│   ├─ SINGLE_EXPERT: one agent handles
│   ├─ SEQUENTIAL: ordered chain
│   ├─ PARALLEL: concurrent execution
│   └─ DIRECT: orchestrator handles
│
├─ DELEGATION EXAMPLES: Concrete routing cases
│   ├─ User request → routing decision
│   └─ Task call syntax
│
└─ CORE KNOWLEDGE: Direct handling capability
    └─ What orchestrator handles without delegation
```

### Expert Agents

```
REQUIRED SECTIONS:
├─ ROLE: Specialization statement
│   ├─ Technology/domain expertise
│   ├─ Version constraints
│   └─ Best practices followed
│
├─ EXECUTION FLOW: Processing steps
│   ├─ Input analysis
│   ├─ Implementation strategy
│   └─ Output generation
│
├─ CODE TEMPLATES: Common patterns
│   ├─ Setup/configuration
│   ├─ Core implementation
│   └─ Testing patterns
│
└─ ERROR HANDLING: Domain-specific errors
    └─ Common mistakes and fixes
```

### Utility Agents

```
REQUIRED SECTIONS:
├─ ROLE: Utility function description
├─ INPUT FORMAT: Required parameters
├─ OUTPUT FORMAT: Return structure
├─ TEMPLATES: Generation patterns
└─ CONSTRAINTS: Limits and rules
```

---

## PHASE 1: Load Target Agent

```
PARSE $ARGUMENTS:
├─ IF path provided → FILE_PATH = $ARGUMENTS
├─ IF filename only → FILE_PATH = agents/{$ARGUMENTS}
└─ IF empty → show TUI to select agent

VALIDATE:
├─ File exists? → if not, Glob search and suggest
└─ Is .md file? → if not, EXIT with error
```

**TUI (when no args):**

```
AskUserQuestion:
  question: "최적화할 에이전트를 선택하세요"
  header: "에이전트"
  options: [dynamically list agents/**/*.md files]
```

---

## PHASE 2: Analyze Current State

```
READ target file → extract:
├─ frontmatter: name, description, allowed-tools, model
├─ agent_type: ORCHESTRATOR | EXPERT | UTILITY
├─ has_role: clear role definition exists?
├─ has_specialization: expertise clearly defined?
├─ has_execution_flow: step-by-step process exists?
├─ has_input_format: input structure defined?
├─ has_output_format: JSON output schema exists?
├─ has_error_handling: failure cases covered?
├─ has_examples: usage examples exist?
├─ language_ratio: English logic vs other
├─ line_count: total lines
└─ token_estimate: approximate token count
```

---

## PHASE 3: Generate Analysis Report

Output format (Korean for user):

```markdown
## 📊 에이전트 분석 결과

### 기본 정보

| 항목 | 현재값 |
|------|--------|
| 파일 | {FILE_PATH} |
| 유형 | {ORCHESTRATOR/EXPERT/UTILITY} |
| 라인 | {line_count} |
| 모델 | {model or "기본"} |
| 토큰 | ~{token_estimate} |

### 3원칙 점검 결과

| 원칙 | 항목 | 상태 | 비고 |
|------|------|------|------|
| 1. 목적 정확성 | ROLE 정의 | ✅/❌ | {comment} |
| 1. 목적 정확성 | 전문 분야 명시 | ✅/❌ | {comment} |
| 1. 목적 정확성 | EXECUTION FLOW | ✅/❌ | {comment} |
| 1. 목적 정확성 | ERROR HANDLING | ✅/❌ | {comment} |
| 2. 영어 로직 | 내부 로직 언어 | ✅/❌ | {comment} |
| 2. 영어 로직 | 트리 표기법 | ✅/❌ | {comment} |
| 3. 구조화 출력 | INPUT FORMAT | ✅/❌ | {comment} |
| 3. 구조화 출력 | OUTPUT FORMAT | ✅/❌ | {comment} |

### 에이전트 유형별 점검

#### IF ORCHESTRATOR:
| 항목 | 상태 | 비고 |
|------|------|------|
| SPECIALIZED EXPERTS | ✅/❌ | {comment} |
| ORCHESTRATION LOGIC | ✅/❌ | {comment} |
| DELEGATION EXAMPLES | ✅/❌ | {comment} |
| CORE KNOWLEDGE | ✅/❌ | {comment} |

#### IF EXPERT:
| 항목 | 상태 | 비고 |
|------|------|------|
| 기술 전문성 | ✅/❌ | {comment} |
| CODE TEMPLATES | ✅/❌ | {comment} |
| 버전 명시 | ✅/❌ | {comment} |

### 개선 필요 항목

| 원칙 | 문제점 | 권장 조치 |
|------|--------|----------|
| {principle} | {issue} | {action} |
```

---

## PHASE 4: User Decision

```
AskUserQuestion:
  question: "분석이 완료되었습니다. 어떻게 진행할까요?"
  header: "진행"
  options:
    - label: "자동 최적화"
      description: "분석 결과를 바탕으로 에이전트를 자동 개선합니다"
    - label: "수동 검토"
      description: "개선 제안을 보여주고 하나씩 적용 여부를 결정합니다"
    - label: "분석만"
      description: "분석 결과만 확인하고 종료합니다"
```

---

## PHASE 5: Execute Optimization

### Agent Template Structure

```
---
{preserved frontmatter}
---

# {Agent Name}

## ROLE

```
SPECIALIZATION: {domain/technology}

{TYPE}-SPECIFIC:
├─ {relevant details}
└─ {boundaries}
```

---

## INPUT FORMAT

```json
{
  "type": "description",
  "required": ["field1", "field2"],
  "optional": ["field3"]
}
```

---

## EXECUTION FLOW

```
SEQUENCE:
├─ Step 1: {action}
│   ├─ {sub-step}
│   └─ {sub-step}
├─ Step 2: {action}
└─ Step N: {action}
```

---

## OUTPUT FORMAT

```json
{
  "status": "success|error",
  "summary": "Brief result description",
  "implementation": {
    "files_created": [],
    "files_modified": [],
    "dependencies": []
  },
  "recommendations": []
}
```

---

## ERROR HANDLING

| Error | Response |
|-------|----------|
| {error_type} | {response_action} |

---

## {TYPE-SPECIFIC SECTIONS}

{ORCHESTRATOR: SPECIALIZED EXPERTS, ORCHESTRATION LOGIC, DELEGATION EXAMPLES}
{EXPERT: CODE TEMPLATES, BEST PRACTICES}
{UTILITY: TEMPLATES, CONSTRAINTS}
```

---

## PHASE 6: Apply Changes

```
IF changes approved:
  Write(file_path=FILE_PATH, content=optimized_content)

OUTPUT (Korean):
## ✅ 최적화 완료

| 항목 | Before | After |
|------|--------|-------|
| 라인 | {old} | {new} |
| 토큰 | {old} | {new} |
| ROLE | {old_state} | ✅ 정의됨 |
| OUTPUT FORMAT | {old_state} | ✅ JSON 스키마 |
```

---

## PHASE 7: Follow-up TUI

```
AskUserQuestion:
  question: "최적화가 완료되었습니다. 다음 작업을 선택하세요."
  header: "후속"
  options:
    - label: "다른 에이전트 최적화"
      description: "다른 에이전트 파일을 선택하여 최적화합니다"
    - label: "관련 커맨드 최적화"
      description: "이 에이전트를 호출하는 커맨드를 최적화합니다"
    - label: "완료"
      description: "작업을 종료합니다"
```

---

## OPTIMIZATION CHECKLIST

### Principle 1: PURPOSE ACCURACY

| Check Item | Problem | Action |
|------------|---------|--------|
| ROLE | Unclear or missing | Define specialization in tree format |
| EXECUTION FLOW | No step-by-step | Add numbered steps with sub-items |
| Error handling | Cases undefined | Add ERROR HANDLING table |
| Boundaries | Scope unclear | Define what's in/out of scope |
| Examples | No usage examples | Add practical examples |

### Principle 2: ENGLISH LOGIC

| Area | Before | After |
|------|--------|-------|
| ROLE | Korean description | English specialization |
| EXECUTION | Narrative Korean | Tree notation (├─ └─) |
| Code blocks | Korean comments | English comments |
| Technical specs | Mixed language | Full English |

### Principle 3: STRUCTURED OUTPUT

| Area | Before | After |
|------|--------|-------|
| INPUT FORMAT | Missing or prose | JSON schema |
| OUTPUT FORMAT | Missing or prose | JSON schema with all fields |
| Status codes | Undefined | success/error enum |
| Error responses | Ad-hoc | Standardized structure |

---

## EXECUTE NOW

```
⚠️ BEFORE OPTIMIZATION, VERIFY:
├─ Does rewrite maintain PURPOSE ACCURACY? (Principle 1)
├─ Is all logic written in ENGLISH? (Principle 2)
└─ Is OUTPUT FORMAT properly structured? (Principle 3)
```

1. Parse FILE_PATH from $ARGUMENTS
2. IF empty → show agent selection TUI (Korean)
3. Determine agent type (ORCHESTRATOR/EXPERT/UTILITY)
4. Read and analyze against 3 principles + type-specific requirements
5. Generate analysis report (Korean output)
6. Show decision TUI (Korean)
7. Execute optimization → **validate all 3 principles**
8. Apply changes and report (Korean output)
9. **Show follow-up TUI** ← REQUIRED

```
⚠️ FINAL CHECK:
   IF optimized agent violates ANY principle → DO NOT apply
   PRINCIPLE 1 (accuracy) > PRINCIPLE 2 (English) > PRINCIPLE 3 (output)
```
