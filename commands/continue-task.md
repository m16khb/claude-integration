---
name: continue-task
description: "Execute advanced tasks with Opus using all available context"
argument-hint: <task_instruction>
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - WebSearch
  - WebFetch
  - Task
  - TodoWrite
  - AskUserQuestion
  - NotebookEdit
model: opus
---

# Opus Advanced Task Executor

## MISSION

Execute complex tasks leveraging Opus's deep reasoning capabilities.
Reuse existing context from conversation history. Provide actionable results.

**Task**: $ARGUMENTS

---

## PHASE 1: Context Inventory

```
SCAN conversation history for:
├─ inject-context markers: "📁 파일 컨텍스트 주입 완료"
├─ Read tool results: files already loaded
├─ Previous task outputs: prior analysis/code
└─ User clarifications: requirements mentioned

BUILD context_map:
{
  loaded_files: [{path, lines, key_elements}],
  read_files: [paths],
  prior_tasks: [summaries],
  constraints: [user requirements]
}

RULE: NEVER re-read files already in context
```

---

## PHASE 2: Task Classification

```
CLASSIFY $ARGUMENTS into:
├─ ANALYSIS       → understand code, find patterns, explain logic
├─ GENERATION     → create new code, features, components
├─ REFACTORING    → improve existing code without behavior change
├─ DEBUGGING      → identify and fix bugs, issues
├─ DOCUMENTATION  → write docs, comments, guides
├─ TESTING        → create tests, verify behavior
├─ SECURITY       → audit for vulnerabilities
└─ OPTIMIZATION   → improve performance

DEFAULT (if empty): "Analyze loaded files and explain core logic"
```

---

## PHASE 3: Execute by Type

### ANALYSIS
```
1. Map overall structure (modules, dependencies)
2. Identify entry points (main, exports, handlers)
3. Trace critical paths
4. Detect patterns/anti-patterns
5. Document findings with file:line references
```

### GENERATION
```
1. Analyze existing code style (naming, patterns)
2. Design new component matching conventions
3. Write code with inline documentation
4. Include error handling
5. Suggest test cases
```

### REFACTORING
```
1. Document current problems clearly
2. Define target state
3. Assess impact scope (what breaks?)
4. Create incremental change plan
5. Include rollback strategy
```

### DEBUGGING
```
1. Reproduce: understand symptoms
2. Hypothesize: form likely causes
3. Investigate: trace code path
4. Fix: minimal invasive change
5. Verify: suggest regression test
```

### DOCUMENTATION
```
1. Identify audience (dev, user, ops)
2. Match existing doc style
3. Include code examples
4. Cover edge cases
5. Add troubleshooting section
```

---

## PHASE 4: Report (Korean Output)

```markdown
## 📋 작업 완료

| 항목 | 내용 |
|------|------|
| 작업 | {task summary} |
| 유형 | {ANALYSIS/GENERATION/etc.} |
| 상태 | ✅ 완료 / ⚠️ 부분 완료 |

### 수행 내용
[Detailed description of what was done]

### 코드 변경 (해당 시)
```[lang]
// code here
```

### 참조 파일
| 파일 | 위치 | 역할 |
|------|------|------|
| `file.ts` | 42-56 | 핵심 로직 |

### 액션 아이템
- [ ] 구체적 다음 단계 1
- [ ] 구체적 다음 단계 2

### 권장 사항
1. 우선순위 높은 제안
2. 추가 고려 사항
```

---

## PHASE 5: Follow-up TUI (Required)

**Always present after task completion:**

```
AskUserQuestion:
  question: "작업이 완료되었습니다. 다음으로 무엇을 하시겠습니까?"
  header: "후속 작업"
  options:
    - label: "관련 파일 추가 분석"
      description: "연관된 다른 파일을 추가로 분석합니다"
    - label: "코드 변경 적용"
      description: "제안된 변경사항을 실제 파일에 적용합니다"
    - label: "테스트 작성/실행"
      description: "변경된 코드에 대한 테스트를 작성합니다"
    - label: "작업 완료"
      description: "현재 작업을 완료하고 종료합니다"
```

### Handle Selection:
```
SWITCH selection:
  "관련 파일 추가 분석":
    → Suggest related files based on imports/dependencies
    → TUI: select file → Read or /inject-context

  "코드 변경 적용":
    → Apply changes via Edit tool
    → Report changes made

  "테스트 작성/실행":
    → TUI: ["단위 테스트 작성", "기존 테스트 실행", "커버리지 분석"]
    → Execute selected option

  "작업 완료":
    → Print final summary
    → Exit
```

---

## TASK-SPECIFIC FOLLOW-UPS

Customize options based on task type:

| Task Type | Custom Options |
|-----------|---------------|
| ANALYSIS | ["심층 분석", "아키텍처 다이어그램", "개선점 구현"] |
| GENERATION | ["코드 리뷰", "테스트 추가", "문서화"] |
| DEBUGGING | ["수정 적용", "회귀 테스트", "관련 버그 탐색"] |
| REFACTORING | ["변경 적용", "영향 분석", "롤백 준비"] |

---

## ERROR HANDLING

| Error | Response (Korean) |
|-------|-------------------|
| Empty task | "작업 지시가 없습니다. 분석할 내용을 입력하세요" |
| No context | "로드된 파일이 없습니다. /inject-context로 파일을 먼저 로드하세요" |
| Ambiguous task | TUI로 구체화 요청: ["코드 분석", "버그 수정", "리팩토링", "문서화"] |
| Timeout/large | "작업이 너무 큽니다. 범위를 좁혀주세요" + 분할 제안 |
| Permission error | "파일 접근 권한이 없습니다: {path}" |

---

## OPUS STRENGTHS (Leverage These)

| Capability | Application |
|------------|-------------|
| Deep reasoning | Multi-step analysis, architecture decisions |
| Code understanding | Pattern recognition, bug root cause |
| Long context | Cross-file relationships |
| Accurate generation | Production-ready code |
| Nuanced judgment | Trade-off analysis |

---

## CRITICAL RULES

1. **Context reuse**: Never re-read loaded files
2. **Explicit references**: Use `file:line` format for all code citations
3. **Assumption clarity**: State any assumptions made
4. **Executable code**: All suggested code must be runnable
5. **Follow-up required**: MUST show TUI after every task completion

---

## EXECUTE NOW

1. Inventory available context (PHASE 1)
2. Classify task type (PHASE 2)
3. Execute with type-appropriate strategy (PHASE 3)
4. Report results in Korean (PHASE 4)
5. **Show follow-up TUI** (PHASE 5) ← NEVER SKIP
