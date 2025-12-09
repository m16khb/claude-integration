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
  - mcp__sequential-thinking__sequentialthinking
model: claude-opus-4-5-20251001
---

# Context-Aware Task Continuation

## MISSION

현재 대화에 로드된 **모든 컨텍스트를 완전히 숙지**하고,
마지막에 **끊긴 작업을 이어서 진행**합니다.

단순 추천이 아닌, **실제 작업 재개**가 목표입니다.

**Focus Area** (optional): $ARGUMENTS

---

## CORE PRINCIPLES

```
컨텍스트 연속성 원칙:
├─ 로드된 모든 컨텍스트를 완전히 파악
├─ 대화 흐름에서 마지막 작업 지점 식별
├─ 끊긴 작업을 자동으로 이어서 진행
├─ 사용자 개입 최소화
└─ Sequential Thinking으로 논리적 분석
```

---

## PHASE 1: Deep Context Analysis with Sequential Thinking

**Sequential Thinking MCP**로 현재 컨텍스트를 심층 분석합니다:

```
mcp__sequential-thinking__sequentialthinking:
  thought: "현재 대화 컨텍스트를 심층 분석합니다.
    1. 로드된 파일 목록 파악
    2. 각 파일의 핵심 내용 이해
    3. 파일 간 관계 및 의존성 파악
    4. 대화에서 수행된 작업 추적
    5. 마지막 작업 지점 식별
    6. 미완료 작업 탐지"
  thoughtNumber: 1
  totalThoughts: 4
  nextThoughtNeeded: true
```

### 1.1 Loaded Context Inventory

```
SCAN conversation and extract:

1. LOADED FILES (inject-context 또는 Read로 로드된 파일):
   FOR each file_marker in conversation:
     EXTRACT:
       ├─ 파일 경로
       ├─ 파일 크기/라인 수
       ├─ 핵심 구조 (클래스, 함수, 모듈)
       ├─ 주요 의존성
       └─ 파일의 역할 (서비스, 컨트롤러, 유틸 등)

2. FILE RELATIONSHIPS:
   ├─ import/export 관계
   ├─ 상속/구현 관계
   ├─ 호출 관계
   └─ 설정 의존성

3. KEY UNDERSTANDING:
   ├─ 코드베이스의 아키텍처
   ├─ 사용된 패턴 (DI, Repository, etc.)
   ├─ 기술 스택
   └─ 프로젝트 구조
```

### 1.2 Work History Tracking

```
TRACK conversation history:

1. COMPLETED TASKS:
   ├─ 파일 생성/수정
   ├─ 커밋 수행
   ├─ 테스트 실행
   ├─ 분석/설명 제공
   └─ 오류 해결

2. IN-PROGRESS TASKS:
   ├─ 시작했으나 완료되지 않은 작업
   ├─ 중단된 구현
   ├─ 대기 중인 확인 사항
   └─ 미해결 질문

3. LAST WORK POINT:
   ├─ 마지막 사용자 요청
   ├─ 마지막 Claude 작업
   ├─ 마지막 파일 수정
   └─ 중단 지점의 상태
```

---

## PHASE 2: Context Summary with Sequential Thinking

```
mcp__sequential-thinking__sequentialthinking:
  thought: "컨텍스트 분석 결과를 정리합니다.
    - 로드된 파일: {file_count}개
    - 완료된 작업: {completed_count}개
    - 진행 중 작업: {in_progress_count}개
    - 마지막 작업: {last_task}
    - 중단 지점: {break_point}
    - 재개 가능 여부: {can_resume}"
  thoughtNumber: 2
  totalThoughts: 4
  nextThoughtNeeded: true
```

### Context Report (Korean)

```markdown
## 📊 컨텍스트 분석 결과

### 📁 로드된 파일 ({count}개)
| 파일 | 라인 | 역할 | 핵심 요소 |
|------|------|------|----------|
| {path} | {lines} | {role} | {key_elements} |

### 🔗 파일 관계
{dependency_graph}

### ✅ 완료된 작업
- {task1}
- {task2}

### 🔄 진행 중/중단된 작업
- ⏸️ {interrupted_task}
- 중단 지점: {break_point}
- 상태: {status}

### 📍 마지막 작업 지점
| 항목 | 내용 |
|------|------|
| 작업 | {last_task} |
| 시점 | {timestamp} |
| 상태 | {state} |
```

---

## PHASE 3: Determine Continuation Strategy

```
mcp__sequential-thinking__sequentialthinking:
  thought: "작업 재개 전략을 결정합니다.
    1. 중단된 작업이 있는가? → 있으면 재개
    2. 명시적 다음 단계가 있는가? → 있으면 진행
    3. 논리적 다음 단계가 있는가? → 추론하여 진행
    4. 추천만 필요한가? → TUI로 선택 제공"
  thoughtNumber: 3
  totalThoughts: 4
  nextThoughtNeeded: true
```

### Decision Tree

```
DECISION LOGIC:

IF interrupted_task EXISTS:
    # 중단된 작업 자동 재개
    → "마지막 작업을 이어서 진행합니다: {interrupted_task}"
    → EXECUTE interrupted_task from break_point

ELIF explicit_next_step EXISTS:
    # 명시적 다음 단계 진행
    → "다음 단계를 진행합니다: {next_step}"
    → EXECUTE next_step

ELIF $ARGUMENTS (focus-area) PROVIDED:
    # 사용자 지정 영역 작업
    → "'{focus-area}' 영역 작업을 진행합니다"
    → EXECUTE work on focus-area

ELIF logical_next_step INFERRED:
    # 논리적 다음 단계 추론
    → "논리적 다음 단계를 진행합니다: {inferred_step}"
    → EXECUTE inferred_step

ELSE:
    # 명확한 다음 단계 없음 - TUI로 선택
    → Show recommendation TUI (PHASE 4)
```

### Continuation Patterns

| 마지막 작업 | 논리적 다음 단계 |
|------------|-----------------|
| 코드 작성 완료 | 테스트 작성 → 커밋 |
| 분석 완료 | 구현 시작 |
| 테스트 실패 | 버그 수정 |
| 버그 수정 완료 | 테스트 재실행 → 커밋 |
| 리팩토링 완료 | 테스트 확인 → 커밋 |
| 파일 로드 완료 | 요청된 작업 수행 |
| 커밋 완료 | 푸시 또는 다음 작업 |
| PR 생성 완료 | 다음 기능 또는 종료 |

---

## PHASE 4: Execute or Recommend

### 4.1 자동 재개 (중단된 작업이 있을 때)

```
IF can_auto_resume:

  mcp__sequential-thinking__sequentialthinking:
    thought: "중단된 작업을 재개합니다.
      - 작업: {interrupted_task}
      - 중단 지점: {break_point}
      - 재개 방법: {resume_strategy}
      - 예상 결과: {expected_outcome}"
    thoughtNumber: 4
    totalThoughts: 4
    nextThoughtNeeded: false

  PRINT "🔄 마지막 작업을 이어서 진행합니다..."
  PRINT "작업: {interrupted_task}"
  PRINT "중단 지점: {break_point}"
  PRINT "─────────────────────────────────────"

  EXECUTE interrupted_task from break_point

  → 작업 완료 후 PHASE 1로 돌아가 다음 작업 확인
```

### 4.2 추천 TUI (명확한 다음 단계가 없을 때)

```
IF need_user_selection:

  AskUserQuestion:
    question: "컨텍스트 분석이 완료되었습니다. 어떤 작업을 진행하시겠습니까?"
    header: "작업 선택"
    options:
      - label: "{recommendation_1}"
        description: "{why_1} (추천)"
      - label: "{recommendation_2}"
        description: "{why_2}"
      - label: "{recommendation_3}"
        description: "{why_3}"
      - label: "직접 지시"
        description: "다른 작업을 직접 입력합니다"
```

### 4.3 Dynamic Recommendations

```
GENERATE recommendations based on context:

IF uncommitted_changes:
  ADD: "변경사항 커밋" → /git-commit

IF loaded_files AND no_work_done:
  ADD: "파일 분석 및 설명"

IF code_written AND no_tests:
  ADD: "테스트 작성"

IF tests_exist AND not_run:
  ADD: "테스트 실행"

IF tests_failed:
  ADD: "테스트 수정"

IF todo_items_pending:
  ADD: "할 일 처리: {todo}"

IF complex_code:
  ADD: "리팩토링 제안"

IF no_documentation:
  ADD: "문서 작성"
```

---

## PHASE 5: Handle Selection and Execute

```
SWITCH selection:

  "{recommendation}":
    → PRINT "'{recommendation}' 작업을 진행합니다..."
    → EXECUTE selected_task
    → REPORT result
    → LOOP back to PHASE 1

  "직접 지시":
    → PRINT "어떤 작업을 진행하시겠습니까?"
    → WAIT for user input
    → EXECUTE user_task
    → LOOP back to PHASE 1
```

---

## CONTEXT UNDERSTANDING CHECKLIST

작업 재개 전 반드시 확인:

```
□ 모든 로드된 파일 내용 파악
□ 파일 간 의존성/관계 이해
□ 프로젝트 아키텍처 파악
□ 사용된 기술 스택 확인
□ 완료된 작업 목록 정리
□ 중단된 작업 식별
□ 마지막 작업 지점 확인
□ 다음 단계 결정
```

---

## ERROR HANDLING

| Error | Response (Korean) |
|-------|-------------------|
| No context loaded | "로드된 컨텍스트가 없습니다. /inject-context로 파일을 먼저 로드하세요." |
| Empty conversation | "대화 기록이 없습니다. 무엇을 도와드릴까요?" |
| Ambiguous state | Sequential Thinking으로 상태 분석 후 TUI 제공 |
| Multiple interrupted tasks | 우선순위 기반으로 정렬 후 TUI로 선택 |

---

## EXECUTE NOW

1. **Sequential Thinking**: 현재 컨텍스트 심층 분석 (PHASE 1)
2. 로드된 파일 목록 및 내용 완전 파악
3. 작업 히스토리 추적 (완료/진행중/중단)
4. **Sequential Thinking**: 컨텍스트 요약 (PHASE 2)
5. 컨텍스트 리포트 출력
6. **Sequential Thinking**: 재개 전략 결정 (PHASE 3)
7. 중단된 작업 있으면 → **자동 재개** (PHASE 4.1)
8. 없으면 → 추천 TUI 표시 (PHASE 4.2)
9. 선택된 작업 실행 (PHASE 5)
10. 작업 완료 후 → PHASE 1로 돌아가 연속 지원
