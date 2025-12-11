---
name: context-management:continue-context
description: '현재 컨텍스트를 분석하여 다음 작업을 추천'
argument-hint: '[focus-area]'
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
  - TodoWrite
  - mcp__st__sequentialthinking
model: claude-opus-4-5-20251101
---

# Context-Aware Task Continuation

## MISSION

로드된 컨텍스트를 분석하고 **끊긴 작업을 자동 재개**합니다.

**Focus Area** (optional): $ARGUMENTS

---

## CORE PRINCIPLES

```
├─ 로드된 모든 컨텍스트 완전 파악
├─ 마지막 작업 지점 식별
├─ 중단된 작업 자동 재개
└─ Sequential Thinking으로 논리적 분석
```

---

## PHASE 1: Deep Context Analysis

Sequential Thinking으로 분석:
1. 로드된 파일 목록 파악
2. 각 파일 핵심 내용 이해
3. 파일 간 관계/의존성
4. 수행된 작업 추적
5. 마지막 작업 지점 식별
6. 미완료 작업 탐지

```
SCAN:
├─ LOADED FILES: 경로, 크기, 역할
├─ FILE RELATIONSHIPS: import/export, 호출 관계
├─ WORK HISTORY: 완료/진행중/중단
└─ LAST WORK POINT: 마지막 요청, 마지막 수정
```

---

## PHASE 2: Context Summary

```markdown
## 📊 컨텍스트 분석 결과

### 📁 로드된 파일 ({count}개)
| 파일 | 라인 | 역할 |
|------|------|------|

### ✅ 완료된 작업
- {task1}

### 🔄 중단된 작업
- ⏸️ {interrupted_task}
- 중단 지점: {break_point}
```

---

## PHASE 3: Continuation Strategy

```
DECISION LOGIC:

IF interrupted_task EXISTS:
  → 자동 재개

ELIF explicit_next_step EXISTS:
  → 다음 단계 진행

ELIF $ARGUMENTS (focus-area) PROVIDED:
  → 해당 영역 작업

ELIF logical_next_step INFERRED:
  → 추론된 단계 진행

ELSE:
  → TUI로 선택 제공
```

### Continuation Patterns

| 마지막 작업 | 다음 단계 |
|------------|----------|
| 코드 작성 완료 | 테스트 → 커밋 |
| 분석 완료 | 구현 시작 |
| 테스트 실패 | 버그 수정 |
| 커밋 완료 | 푸시 또는 다음 작업 |

---

## PHASE 4: Execute or Recommend

### 4.1 자동 재개

```
PRINT "🔄 마지막 작업을 이어서 진행합니다..."
EXECUTE interrupted_task from break_point
```

### 4.2 추천 TUI

```
AskUserQuestion:
  question: "어떤 작업을 진행하시겠습니까?"
  options:
    - {recommendation_1}
    - {recommendation_2}
    - 직접 지시
```

### Dynamic Recommendations

```
IF uncommitted_changes → "변경사항 커밋"
IF code_written AND no_tests → "테스트 작성"
IF tests_failed → "테스트 수정"
IF todo_items_pending → "할 일 처리"
```

---

## ERROR HANDLING

| Error | Response |
|-------|----------|
| No context | "/inject-context로 파일 로드" |
| Empty conversation | "무엇을 도와드릴까요?" |
| Ambiguous state | Sequential Thinking 분석 후 TUI |

---

## Documentation

상세 내용은 agent-docs/ 참조:
- @../agent-docs/context-analysis.md - 컨텍스트 분석, 작업 추천
- @../agent-docs/recovery-patterns.md - 세션 복구, MCP Memory 연동
- @../agent-docs/chunking-algorithm.md - 청킹 알고리즘
