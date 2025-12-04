---
name: code-quality:review
description: '코드 리뷰 실행 커맨드 (보안, 성능, 품질 분석)'
argument-hint: '[file-path]'
allowed-tools:
  - Read
  - Grep
  - Glob
  - Task
  - AskUserQuestion
model: claude-haiku-4-20250414
---

# Code Review Command

## MISSION

지정된 파일 또는 최근 변경된 파일에 대해 포괄적인 코드 리뷰를 수행합니다.
보안, 성능, 코드 품질을 분석하고 개선 방안을 제시합니다.

**Target**: $ARGUMENTS

---

## MCP INTEGRATION

```
REVIEW PROCESS:
├─ Sequential-Thinking MCP 호출 (체계적 리뷰)
│   ├─ 코드 구조 파악 → 위험 영역 식별
│   ├─ 보안/성능/품질 체크리스트 순회
│   ├─ 개선 우선순위 결정
│   └─ 구체적 해결책 도출
│
└─ 적용 시점:
    ├─ 복잡한 비즈니스 로직 리뷰 시
    ├─ 보안 취약점 심층 분석 시
    └─ 아키텍처 수준 검토 시
```

---

## PHASE 1: Target Resolution

```
RESOLVE target files:

IF $ARGUMENTS is empty:
  → Check git status for uncommitted changes
  → AskUserQuestion if multiple files found

IF $ARGUMENTS is file path:
  → Verify file exists
  → Add to review list

IF $ARGUMENTS is directory:
  → Glob("**/*.ts", "**/*.tsx", "**/*.js")
  → Filter by modification time (recent first)
```

**TUI (파일 선택):**

```
AskUserQuestion:
  question: "리뷰할 대상을 선택하세요"
  header: "대상"
  options:
    - label: "최근 변경 파일"
      description: "git diff로 감지된 변경 파일들"
    - label: "특정 디렉토리"
      description: "디렉토리 경로 지정"
    - label: "전체 src/"
      description: "src/ 하위 모든 파일"
```

---

## PHASE 2: Delegate to Expert

```
DELEGATE to code-reviewer agent:

Task(
  subagent_type = "code-reviewer",
  prompt = """
  다음 파일들에 대한 코드 리뷰를 수행해주세요:

  파일 목록:
  {file_list}

  리뷰 범위:
  - 보안 취약점 (OWASP Top 10)
  - 성능 문제 (N+1, 메모리 누수)
  - 코드 품질 (SOLID, DRY)
  - TypeScript 타입 안정성

  각 이슈에 대해:
  - 심각도 (CRITICAL/HIGH/MEDIUM/LOW)
  - 파일 경로와 라인 번호
  - 문제 설명
  - 수정 코드 예시
  """
)
```

---

## PHASE 3: Report Summary

```markdown
## 🔍 코드 리뷰 완료

### 요약
| 항목 | 값 |
|------|-----|
| 검토 파일 | {count}개 |
| 발견 이슈 | {total}개 |
| CRITICAL | {critical}개 |
| HIGH | {high}개 |

### 주요 이슈

#### CRITICAL: {issue_title}
📁 `{file_path}:{line}`

**문제**: {description}

**수정 방안**:
```typescript
// Before
{before_code}

// After
{after_code}
```

### 긍정적 관찰
- {positive_1}
- {positive_2}

### 권장 사항
- [ ] {recommendation_1}
- [ ] {recommendation_2}
```

---

## PHASE 4: Follow-up TUI

```
AskUserQuestion:
  question: "다음 작업을 선택하세요"
  header: "후속"
  options:
    - label: "이슈 자동 수정"
      description: "발견된 이슈를 자동으로 수정합니다"
    - label: "테스트 생성"
      description: "리뷰된 코드에 대한 테스트를 생성합니다"
    - label: "커밋 진행"
      description: "수정 없이 커밋을 진행합니다"
    - label: "완료"
      description: "리뷰만 확인하고 종료합니다"
```

### Handle Selection:

```
SWITCH selection:
  "이슈 자동 수정":
    → FOR EACH critical/high issue:
        Edit file with suggested fix
    → Re-run review to verify

  "테스트 생성":
    → Task(subagent_type="test-automator", prompt="...")

  "커밋 진행":
    → Execute /git-commit

  "완료":
    → Print final summary
    → Exit
```

---

## ERROR HANDLING

| Error | Response |
|-------|----------|
| No files found | "리뷰할 파일이 없습니다" |
| File read error | "파일을 읽을 수 없습니다: {path}" |
| Expert timeout | "분석 시간이 초과되었습니다. 파일 수를 줄여보세요" |

---

## EXECUTE NOW

1. Parse $ARGUMENTS → resolve target files
2. IF no target → show file selection TUI
3. Delegate to code-reviewer agent
4. Display review summary in Korean
5. Show follow-up TUI
6. Execute selected action
