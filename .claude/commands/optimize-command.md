---
name: optimize-command
description: '프롬프트 엔지니어링 원칙으로 커맨드 최적화'
argument-hint: <command-file-path>
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - AskUserQuestion
model: opus
---

# Command Optimizer

## MISSION

Apply prompt engineering best practices to optimize Claude Code commands.
Ensure commands achieve their purpose accurately while maintaining token efficiency.

**Input**: $ARGUMENTS

---

## ⚠️ CORE PRINCIPLES - MUST FOLLOW

```
╔════════════════════════════════════════════════════════════════╗
║  🔴 PRINCIPLE 1: PURPOSE ACCURACY - Highest Priority           ║
║  ─────────────────────────────────────────────────────────────  ║
║  Define command purpose precisely, execute completely          ║
║  Never sacrifice accuracy for token efficiency                 ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║  🟡 PRINCIPLE 2: ENGLISH LOGIC - Token Efficiency              ║
║  ─────────────────────────────────────────────────────────────  ║
║  Write all internal logic in English for token efficiency      ║
║  MISSION, PHASE, algorithms, conditionals → all in English     ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║  🟢 PRINCIPLE 3: KOREAN TUI - User Interface                   ║
║  ─────────────────────────────────────────────────────────────  ║
║  Write all user-facing content in Korean                       ║
║  AskUserQuestion, reports, error messages → all in Korean      ║
╚════════════════════════════════════════════════════════════════╝

⚠️ THESE PRINCIPLES ARE NON-NEGOTIABLE
   Every optimization MUST satisfy all three principles.
   If conflict exists, PRINCIPLE 1 (accuracy) takes precedence.
```

---

### Principle 1: PURPOSE ACCURACY

```
PRIORITY: Accuracy > Token Efficiency

DO:
├─ Define MISSION with specific, measurable outcome
├─ Specify ALL conditional branches and edge cases
├─ Explain ambiguous parts in detail
├─ Cover ALL error scenarios with responses
└─ Declare DEFAULT values explicitly

DON'T:
├─ Omit important logic to save tokens
├─ Use ambiguous abbreviations or implicit expressions
└─ Leave situations where model must guess

EXAMPLE:
  ❌ "Check file → process"
  ✅ "Check if file exists at FILE_PATH.
      If exists: read content, validate format, proceed to next phase.
      If not exists: use Glob to search similar filenames, suggest alternatives to user."
```

---

### Principle 2: ENGLISH LOGIC

```
WHY: English is more token-efficient (same meaning, fewer tokens)

WRITE IN ENGLISH:
├─ MISSION statement
├─ PHASE definitions
├─ Algorithms and pseudocode
├─ Conditional logic (IF/ELSE/SWITCH)
├─ Data structures
├─ Technical specifications
└─ Error handling logic

FORMAT:
├─ Tree notation (├─, └─) for branching
├─ Tables for specifications
└─ Code blocks for commands
```

---

### Principle 3: KOREAN TUI

```
WHY: Better user experience, intuitive understanding

WRITE IN KOREAN:
├─ AskUserQuestion: question, header, label, description
├─ User-facing reports and results
├─ Error messages (user-facing)
├─ Progress indicators
└─ Completion messages

EXAMPLE:
  AskUserQuestion:
    question: "다음 작업을 선택하세요"
    header: "작업"
    options:
      - label: "자동 최적화"
        description: "분석 결과를 바탕으로 개선"
```

---

## ADDITIONAL GUIDELINES

### Structure

```
PHASE-based execution flow:
├─ MISSION: Clear purpose statement (English)
├─ PHASE 1-N: Sequential execution steps (English logic)
├─ TUI sections: User interaction points (Korean)
├─ ERROR HANDLING: All failure cases (English logic, Korean messages)
└─ EXECUTE NOW: Action summary (English)
```

### Safety

```
NEVER:
├─ Auto-delete user files without confirmation
├─ Execute destructive commands silently
├─ Skip user confirmation for critical actions
└─ Expose sensitive data patterns
```

---

## PHASE 1: Load Target Command

```
PARSE $ARGUMENTS:
├─ IF path provided → FILE_PATH = $ARGUMENTS
├─ IF filename only → FILE_PATH = .claude/commands/{$ARGUMENTS}
└─ IF empty → show TUI to select command

VALIDATE:
├─ File exists? → if not, Glob search and suggest
└─ Is .md file? → if not, EXIT with error
```

**TUI (when no args):**

```
AskUserQuestion:
  question: "최적화할 커맨드를 선택하세요"
  header: "커맨드"
  options: [dynamically list .claude/commands/*.md files]
```

---

## PHASE 2: Analyze Current State

```
READ target file → extract:
├─ frontmatter: name, description, allowed-tools, model
├─ structure: sections, headings, code blocks
├─ line_count: total lines
├─ has_mission: clear purpose statement exists?
├─ has_phases: sequential execution steps exist?
├─ has_tui: AskUserQuestion usage exists?
├─ has_error_handling: failure cases covered?
├─ language_ratio: English logic vs Korean logic
└─ token_estimate: approximate token count
```

---

## PHASE 3: Generate Analysis Report

Output format (Korean for user):

```markdown
## 📊 커맨드 분석 결과

### 기본 정보

| 항목 | 현재값            |
| ---- | ----------------- |
| 파일 | {FILE_PATH}       |
| 라인 | {line_count}      |
| 모델 | {model or "기본"} |
| 토큰 | ~{token_estimate} |

### 3원칙 점검 결과

| 원칙           | 항목             | 상태  | 비고      |
| -------------- | ---------------- | ----- | --------- |
| 1. 목적 정확성 | MISSION 명확성   | ✅/❌ | {comment} |
| 1. 목적 정확성 | 조건 분기 완전성 | ✅/❌ | {comment} |
| 1. 목적 정확성 | 에러 처리        | ✅/❌ | {comment} |
| 2. 영어 로직   | 내부 로직 언어   | ✅/❌ | {comment} |
| 2. 영어 로직   | PHASE 구조       | ✅/❌ | {comment} |
| 3. 한국어 TUI  | AskUserQuestion  | ✅/❌ | {comment} |
| 3. 한국어 TUI  | 리포트/출력      | ✅/❌ | {comment} |

### 개선 필요 항목

| 원칙        | 문제점  | 권장 조치 |
| ----------- | ------- | --------- |
| {principle} | {issue} | {action}  |
```

---

## PHASE 4: User Decision

```
AskUserQuestion:
  question: "분석이 완료되었습니다. 어떻게 진행할까요?"
  header: "진행"
  options:
    - label: "자동 최적화"
      description: "분석 결과를 바탕으로 커맨드를 자동 개선합니다"
    - label: "수동 검토"
      description: "개선 제안을 보여주고 하나씩 적용 여부를 결정합니다"
    - label: "분석만"
      description: "분석 결과만 확인하고 종료합니다"
```

---

## PHASE 5: Execute Optimization

### Case: Auto Optimization

```
REWRITE command following template:

---
{preserved frontmatter}
---

# {Command Title}

## MISSION
{1-2 sentence clear purpose in English}

**Input**: $ARGUMENTS

---

## PHASE 1: {First Step}
{Logic in English with tree notation}

---

## PHASE N: {Nth Step}
{Continue pattern}

---

## TUI: {User Interaction}
{AskUserQuestion blocks with Korean labels}

---

## ERROR HANDLING
| Error | Response |
{Table format - English logic, Korean user messages}

---

## EXECUTE NOW
{Numbered action summary in English}
```

### Case: Manual Review

```
FOR each improvement:
  SHOW: current vs proposed diff
  AskUserQuestion:
    question: "이 변경을 적용할까요?"
    options: ["적용", "건너뛰기"]
  IF "적용" selected → apply change
END FOR
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
| 구조 | {old_structure} | PHASE 기반 |
```

---

## PHASE 7: Follow-up TUI

```
AskUserQuestion:
  question: "최적화가 완료되었습니다. 다음 작업을 선택하세요."
  header: "후속"
  options:
    - label: "다른 커맨드 최적화"
      description: "다른 커맨드 파일을 선택하여 최적화합니다"
    - label: "최적화 결과 테스트"
      description: "개선된 커맨드를 실행하여 테스트합니다"
    - label: "완료"
      description: "작업을 종료합니다"
```

---

## OPTIMIZATION CHECKLIST

### Principle 1: PURPOSE ACCURACY

| Check Item     | Problem                   | Action                                   |
| -------------- | ------------------------- | ---------------------------------------- |
| MISSION        | Unclear or missing        | Define specific purpose in 1-2 sentences |
| Branches       | Some cases missing        | Specify ALL IF/ELSE branches explicitly  |
| Error handling | Failure cases undefined   | Add ERROR HANDLING table                 |
| Defaults       | DEFAULT not specified     | Declare default values for all variables |
| Edge cases     | Exceptions not considered | Handle boundary conditions explicitly    |

### Principle 2: ENGLISH LOGIC

| Area         | Before             | After                   |
| ------------ | ------------------ | ----------------------- |
| MISSION      | Korean description | English statement       |
| PHASE logic  | Korean explanation | English pseudocode      |
| Conditionals | Korean if-then     | `IF condition → action` |
| Algorithms   | Narrative Korean   | Tree notation (├─ └─)   |

### Principle 3: KOREAN TUI

| Area            | Before           | After                        |
| --------------- | ---------------- | ---------------------------- |
| AskUserQuestion | English labels   | Korean question/header/label |
| Reports         | English output   | Korean result template       |
| Error messages  | English messages | Korean user guidance         |
| Completion      | English or none  | Korean completion message    |

---

## EXECUTE NOW

```
⚠️ BEFORE OPTIMIZATION, VERIFY:
├─ Does rewrite maintain PURPOSE ACCURACY? (Principle 1)
├─ Is all logic written in ENGLISH? (Principle 2)
└─ Is all user-facing content in KOREAN? (Principle 3)
```

1. Parse FILE_PATH from $ARGUMENTS
2. IF empty → show command selection TUI (Korean)
3. Read and analyze target command against 3 principles
4. Generate analysis report (Korean output)
5. Show decision TUI (Korean)
6. Execute optimization → **validate all 3 principles**
7. Apply changes and report (Korean output)
8. **Show follow-up TUI** ← REQUIRED

```
⚠️ FINAL CHECK:
   IF optimized command violates ANY principle → DO NOT apply
   PRINCIPLE 1 (accuracy) > PRINCIPLE 2 (English) > PRINCIPLE 3 (Korean)
```
