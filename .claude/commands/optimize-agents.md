---
name: optimize-agents
description: '[DEPRECATED] /optimize agent 사용을 권장합니다'
argument-hint: <agent-file-path>
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - AskUserQuestion
  - Task
  - mcp__sequential-thinking__sequentialthinking
  - mcp__context7__resolve-library-id
  - mcp__context7__get-library-docs
model: claude-opus-4-5-20251101
---

# Agent Optimizer with MCP Integration

## MISSION

Apply prompt engineering best practices and latest documentation to optimize Claude Code agents.
Integrate Context7 for up-to-date best practices and Sequential-Thinking for systematic analysis.

**Input**: $ARGUMENTS

---

## CORE OPTIMIZATION PRINCIPLES

```
PRINCIPLE PRIORITY: Accuracy > Efficiency > Structure

1. PURPOSE ACCURACY (🔴)
   - Clear role definition
   - Specialized domain expertise
   - Complete execution flow
   - Comprehensive error handling

2. ENGLISH LOGIC (🟡)
   - Token-efficient language
   - Clear technical specs
   - Structured documentation

3. JSON OUTPUT (🟢)
   - Standardized I/O format
   - Inter-agent compatibility
   - Consistent response schema
```

---

## AGENT TYPE TEMPLATES

### Orchestrator
```
REQUIRED:
├─ ROLE: Workflow coordination purpose
├─ SPECIALIZED EXPERTS: Delegation targets
├─ ORCHESTRATION LOGIC: Routing rules
├─ DELEGATION EXAMPLES: Usage patterns
└─ ERROR HANDLING: Failure recovery
```

### Expert
```
REQUIRED:
├─ ROLE: Domain specialization
├─ EXECUTION FLOW: Task processing steps
├─ CODE TEMPLATES: Common implementations
└─ ERROR HANDLING: Domain-specific issues
```

### Utility
```
REQUIRED:
├─ ROLE: Function description
├─ INPUT FORMAT: Parameter schema
├─ OUTPUT FORMAT: Return structure
└─ TEMPLATES: Generation patterns
```

---

## OPTIMIZATION WORKFLOW

### Step 1: Load and Validate
```
PARSE $ARGUMENTS:
├─ Path provided → use directly
├─ Filename only → search in agents/
└─ Empty → interactive selection

VALIDATE file exists and is .md
```

### Step 2: Dynamic Analysis with MCP
```
SEQUENTIAL-THINKING:
├─ Analyze agent structure
├─ Identify optimization opportunities
├─ Check against 3 principles
└─ Generate improvement plan

CONTEXT7 INTEGRATION:
├─ Fetch latest best practices
├─ Compare with current patterns
├─ Identify outdated approaches
└─ Suggest modern alternatives
```

---

## Step 3: Generate Analysis Report

```markdown
## 📊 에이전트 최적화 분석

### 기본 정보
| 파일 | 유형 | 라인 | 모델 |
|------|------|------|------|
| {path} | {type} | {lines} | {model} |

### 3원칙 준수도
| 원칙 | 점수 | 문제 |
|------|------|------|
| 목적 정확성 | {score}% | {issues} |
| 영어 로직 | {score}% | {issues} |
| 구조화 출력 | {score}% | {issues} |

### 최적화 제안
- Context7 최신 베스트 프랙티스 적용: {count}건
- 토큰 효율화: {tokens} → {optimized}
- 구조 개선: {suggestions}
```

---

## Step 4: Interactive Optimization

```
AskUserQuestion:
  question: "최적화 방식을 선택하세요"
  header: "최적화"
  options:
    - label: "자동 최적화 (MCP 활용)"
      description: "Context7과 Sequential-Thinking으로 자동 개선"
    - label: "단계별 최적화"
      description: "각 항목을 확인하며 개선"
    - label: "분석만 보기"
      description: "제안사항만 확인"
```

---

## Step 5: Apply Optimization

```python
# Agent optimization template
optimized_agent = f"""---
{frontmatter}
---

# {name}

## ROLE

Specialization: {domain}

{execution_flow}

## OUTPUT FORMAT

{json_schema}

## ERROR HANDLING

{error_table}
"""
```

---

## QUALITY GATES

| Gate | Pass Condition | Action |
|------|----------------|---------|
| Accuracy | Role clearly defined | Proceed |
| Efficiency | English logic used | Continue |
| Structure | JSON output format | Complete |
| MCP Sync | Latest practices | Apply |

---

## EXECUTION FLOW

1. Parse $ARGUMENTS for agent path
2. Sequential-Thinking: Analyze structure
3. Context7: Fetch latest best practices
4. Generate optimization report
5. User confirmation via AskUserQuestion
6. Apply changes with Write()
7. Offer follow-up optimization
```
