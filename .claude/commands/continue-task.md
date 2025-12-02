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

Works with inject-context for advanced tasks. **Provides next step hints after completion**.

**Task instruction**: $ARGUMENTS

---

## Step 1: Build Context Map

Scan conversation history → create **structured context map**:

```
CONTEXT_MAP = {
    # Files loaded via inject-context
    loaded_files: [
        {
            path: "file path",
            lines: "N lines",
            chunks: "M chunks",
            type: "file type",
            key_structures: ["class names", "function names", ...]
        },
        ...
    ],

    # Session continuity info
    session_context: {
        previous_session: "summary (if exists)",
        handoff_notes: "handoff notes (if exists)"
    },

    # Directly read files
    read_files: ["path1", "path2", ...],

    # User request history
    user_requests: ["request1", "request2", ...],

    # Current task context
    current_task: "$ARGUMENTS"
}
```

### Context Detection Patterns

```
Find in conversation history:
- "📁 파일 컨텍스트 주입 완료" → v2 inject-context
- "파일 컨텍스트 주입 완료" → v1 inject-context
- "이전 세션 컨텍스트 복원 완료" → session continuity
- "===== 청크 N/M" → chunk load boundary
- Read tool results → directly read files
```

**Important**: IF context already exists → do NOT re-read. Maximize history usage.

---

## Step 2: Parse Task Instruction

```
TASK = "$ARGUMENTS"

IF TASK is empty OR "default":
    TASK = "Analyze file structure and explain core logic"
END IF

# Classify task type
TASK_TYPE = classify(TASK)
# Possible types:
#   - analysis: code analysis, structure understanding
#   - generation: new code generation
#   - refactoring: code improvement
#   - debugging: bug fix, problem solving
#   - documentation: docs, comments
#   - testing: test writing, verification
#   - security: security review
#   - optimization: performance optimization
```

---

## Step 3: Execute Task

### Strategy by Task Type

#### Analysis
```
1. Understand overall structure (directory, module layout)
2. Identify entry points (main, export, index)
3. Trace dependency graph
4. Identify core business logic
5. Detect patterns and anti-patterns
6. Suggest architecture diagram
```

#### Generation
```
1. Analyze existing code style
2. Understand naming conventions
3. Reference similar code
4. Write new code (maintain style consistency)
5. Generate test code together
6. Include documentation comments
```

#### Refactoring
```
1. Clarify current problems
2. Define target state
3. Analyze impact scope
4. Create incremental change plan
5. Suggest verification for each step
6. Include rollback strategy
```

#### Debugging
```
1. Understand symptoms exactly
2. Identify reproduction conditions
3. Form cause hypothesis
4. Verify hypothesis (logs, tests)
5. Suggest minimal invasive fix
6. Suggest regression tests
```

#### Documentation
```
1. Identify target audience
2. Analyze existing doc style
3. Include code examples
4. Explain edge cases
5. Add FAQ section
6. Reflect change history
```

---

## Step 4: Report Result

```markdown
╔═══════════════════════════════════════════════════════════════╗
║                    📋 작업 완료 보고서                           ║
╠═══════════════════════════════════════════════════════════════╣
║ 작업: {TASK summary}                                           ║
║ 유형: {TASK_TYPE}                                              ║
║ 상태: ✅ 완료 / ⚠️ 부분 완료 / ❌ 실패                          ║
╚═══════════════════════════════════════════════════════════════╝

### 📝 수행 내용
[Specific task content description]

### 💻 코드 변경 (해당시)
```[language]
// Changed code
```

### 📁 참조된 파일
| 파일 | 라인 | 설명 |
|------|------|------|
| `file1.ts` | 42-56 | Related function |
| `file2.py` | 100-120 | Call site |

### ⚡ 액션 아이템
- [ ] Item1: description
- [ ] Item2: description

### 💡 권장 사항
1. First recommendation
2. Second recommendation
```

---

## Step 5: Next Step Selection (TUI) - Required!

After task completion, use **AskUserQuestion** for follow-up:

```
AskUserQuestion(questions=[
    {
        "question": "작업이 완료되었습니다. 다음으로 무엇을 하시겠습니까?",
        "header": "후속 작업",
        "options": [
            {"label": "관련 파일 추가 분석", "description": "현재 분석과 관련된 다른 파일을 추가로 분석합니다"},
            {"label": "코드 변경 적용", "description": "제안된 변경사항을 실제 파일에 적용합니다"},
            {"label": "테스트 작성/실행", "description": "변경된 코드에 대한 테스트를 작성하거나 실행합니다"},
            {"label": "작업 완료", "description": "현재 작업을 완료하고 종료합니다"}
        ],
        "multiSelect": false
    }
])
```

### Handle Selection

```
SWITCH user_selection:
    CASE "관련 파일 추가 분석":
        suggestions = analyze_related_files(CONTEXT_MAP)
        AskUserQuestion → select file
        → /inject-context {selected file} OR direct Read

    CASE "코드 변경 적용":
        apply_suggested_changes() via Edit tool
        Report application result

    CASE "테스트 작성/실행":
        AskUserQuestion(questions=[
            {
                "question": "어떤 테스트 작업을 수행할까요?",
                "header": "테스트",
                "options": [
                    {"label": "단위 테스트 작성", "description": "새로운 단위 테스트를 작성합니다"},
                    {"label": "기존 테스트 실행", "description": "기존 테스트를 실행합니다"},
                    {"label": "테스트 커버리지 분석", "description": "테스트 커버리지를 분석합니다"}
                ],
                "multiSelect": false
            }
        ])

    CASE "작업 완료":
        print_final_summary()
        Suggest session context save (if needed)
END SWITCH
```

---

## Custom Follow-up Options by Task Type

### After Analysis
```
Options: ["심층 분석 (특정 모듈)", "아키텍처 다이어그램 생성", "개선점 구현", "작업 완료"]
```

### After Generation
```
Options: ["코드 리뷰 요청", "테스트 추가", "문서화 추가", "작업 완료"]
```

### After Debugging
```
Options: ["수정 적용", "회귀 테스트 작성", "관련 버그 탐색", "작업 완료"]
```

---

## Opus Model Usage Guide

| Strength | How to Use |
|----------|------------|
| Complex reasoning | Multi-step analysis, architecture design |
| Code understanding | Pattern recognition, bug detection |
| Long context | Relationship between multiple files |
| Accurate generation | Production quality code |
| Careful judgment | Trade-off analysis |

---

## Execute (now)

1. **Build context map**: Parse loaded files/session info from history
2. **Parse task**: Analyze "$ARGUMENTS" → classify task type
3. **Execute task**: Thoroughly execute with type-appropriate strategy
4. **Report result**: Structured format report
5. **Follow-up selection**: **AskUserQuestion for next step** (required!)
6. **Handle selection**: Execute additional work based on user choice

---

## Important Notes

1. **Reuse context**: Do NOT re-read already loaded files
2. **Explicit reference**: Use `filename:line` format when quoting code
3. **State assumptions**: Clarify uncertain parts
4. **Executable**: Suggested code must be actually runnable
5. **Follow-up required**: MUST call AskUserQuestion after task completion

---

## Never Skip

- **Step 5 (follow-up selection)** - Core of TUI experience
- MUST provide next step selection after task completion
- Maintain workflow continuity with context-appropriate options
