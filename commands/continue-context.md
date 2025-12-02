---
name: continue-context
description: "현재 컨텍스트를 분석하여 다음 작업을 추천"
argument-hint: [focus-area]
allowed-tools:
  - Read
  - Glob
  - Grep
  - AskUserQuestion
  - TodoWrite
model: claude-sonnet-4-5-20250514
---

# Context-Aware Task Recommender

## MISSION

Analyze current conversation context and recommend logical next actions.
Help user decide what to do next based on loaded files, completed tasks, and pending work.

**Focus Area** (optional): $ARGUMENTS

---

## PHASE 1: Context Scan

```
SCAN conversation history and extract:

1. LOADED FILES:
   ├─ inject-context markers: "📁 파일 컨텍스트"
   ├─ Read tool results
   └─ Recently edited files

2. COMPLETED TASKS:
   ├─ Commits made
   ├─ Files created/modified
   ├─ Tests run
   └─ Commands executed

3. PENDING ITEMS:
   ├─ TodoWrite items with status != completed
   ├─ Mentioned but not done
   ├─ Errors/warnings not resolved
   └─ Follow-up suggestions not acted on

4. PROJECT STATE:
   ├─ Git status (uncommitted changes?)
   ├─ Build/test status (if known)
   └─ Current working directory

BUILD context_summary:
{
  files_loaded: [paths],
  tasks_completed: [summaries],
  tasks_pending: [items],
  recent_changes: [files],
  current_focus: $ARGUMENTS or inferred
}
```

---

## PHASE 2: Context Report (Korean)

```markdown
## 📊 현재 컨텍스트 분석

### 로드된 파일
| 파일 | 라인 | 주요 내용 |
|------|------|----------|
| {path} | {lines} | {key_elements} |

### 완료된 작업
- ✅ {task1}
- ✅ {task2}

### 미완료 항목
- ⏳ {pending1}
- ⏳ {pending2}

### 현재 상태
| 항목 | 상태 |
|------|------|
| Git | {uncommitted changes / clean} |
| 포커스 | {$ARGUMENTS or inferred area} |
```

---

## PHASE 3: Generate Recommendations

```
ANALYZE context and generate recommendations:

CATEGORY 1 - Immediate Actions (based on pending items):
├─ Uncommitted changes → "커밋하기"
├─ Failed tests → "테스트 수정"
├─ TODO items → "할 일 처리"
└─ Errors in output → "오류 해결"

CATEGORY 2 - Logical Next Steps (based on completed work):
├─ Code written → ["테스트 작성", "문서화", "리팩토링"]
├─ Feature added → ["통합 테스트", "PR 생성"]
├─ Bug fixed → ["회귀 테스트", "관련 이슈 확인"]
└─ Analysis done → ["구현 시작", "설계 검토"]

CATEGORY 3 - Context Exploration (based on loaded files):
├─ Related files not loaded → "관련 파일 탐색"
├─ Dependencies → "의존성 분석"
└─ Patterns detected → "패턴 적용 확장"

CATEGORY 4 - Quality Improvements:
├─ No tests → "테스트 커버리지 추가"
├─ No docs → "문서화"
├─ Complex code → "리팩토링"
└─ Security concerns → "보안 검토"

SELECT top 4 recommendations based on:
├─ Urgency (pending items first)
├─ Relevance (to current focus)
├─ Impact (high value actions)
└─ Feasibility (can be done with current context)
```

---

## PHASE 4: Recommendation TUI (Required)

**Always show recommendations:**

```
AskUserQuestion:
  question: "컨텍스트 분석이 완료되었습니다. 다음 작업을 선택하세요."
  header: "추천 작업"
  options:
    - label: "{recommendation_1}"
      description: "{why_recommended_1}"
    - label: "{recommendation_2}"
      description: "{why_recommended_2}"
    - label: "{recommendation_3}"
      description: "{why_recommended_3}"
    - label: "직접 입력"
      description: "다른 작업을 직접 지정합니다"
```

**Dynamic options based on context:**

```
IF uncommitted_changes:
  ADD option: "변경사항 커밋" → /git-commit

IF loaded_files AND no_analysis_done:
  ADD option: "파일 분석" → analyze files

IF tests_exist AND not_recently_run:
  ADD option: "테스트 실행" → run tests

IF todo_items_pending:
  ADD option: "할 일 처리" → work on todo

IF complex_code_detected:
  ADD option: "리팩토링" → refactor suggestions

IF no_documentation:
  ADD option: "문서 작성" → generate docs
```

---

## PHASE 5: Execute Selected Action

```
SWITCH selection:
  "변경사항 커밋":
    → Execute /git-commit flow
    → Return to recommendation TUI

  "파일 분석":
    → Analyze loaded files
    → Report findings
    → Suggest next actions

  "테스트 실행":
    → Run appropriate test command
    → Report results
    → Suggest fixes if failed

  "할 일 처리":
    → Show pending TodoWrite items
    → TUI: select item to work on
    → Execute selected task

  "리팩토링":
    → Identify refactoring targets
    → TUI: select what to refactor
    → Execute with confirmation

  "문서 작성":
    → Identify undocumented code
    → Generate documentation
    → Apply with confirmation

  "직접 입력":
    → TUI: free text input
    → Parse and execute
```

---

## COMMON RECOMMENDATION PATTERNS

| Context | Recommendations |
|---------|-----------------|
| Just finished coding | 테스트 작성, 커밋, 코드 리뷰 |
| Just committed | 푸시, PR 생성, 다음 기능 |
| Just analyzed | 구현 시작, 설계 문서화, 리팩토링 |
| Tests failing | 버그 수정, 디버깅, 관련 코드 확인 |
| Large file loaded | 구조 분석, 핵심 로직 파악, 의존성 확인 |
| Multiple files loaded | 관계 분석, 통합 포인트 확인, 아키텍처 검토 |
| Error occurred | 오류 해결, 로그 확인, 롤백 고려 |
| Nothing pending | 새 작업 시작, 기술 부채 해결, 문서화 |

---

## ERROR HANDLING

| Error | Response (Korean) |
|-------|-------------------|
| No context | "컨텍스트가 없습니다. 파일을 로드하거나 작업을 시작하세요" |
| Empty history | "대화 기록이 없습니다. 무엇을 도와드릴까요?" |
| Ambiguous focus | TUI로 포커스 영역 선택 요청 |

---

## EXECUTE NOW

1. Scan conversation context (PHASE 1)
2. Report context summary in Korean (PHASE 2)
3. Generate smart recommendations (PHASE 3)
4. **Show recommendation TUI** (PHASE 4) ← REQUIRED
5. Execute selected action (PHASE 5)
6. Loop back to PHASE 1 for continuous assistance
