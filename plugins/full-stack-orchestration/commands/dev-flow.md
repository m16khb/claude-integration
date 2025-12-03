---
name: dev-flow
description: '개발 워크플로우 오케스트레이션 (리뷰 → 테스트 → 커밋)'
argument-hint: '[skip-review|skip-test]'
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(git:*, npm:*)
  - Task
  - TodoWrite
  - AskUserQuestion
model: claude-opus-4-5-20251101
---

# Development Workflow Command

## MISSION

코드 변경 사항에 대해 리뷰 → 테스트 → 커밋의 완전한 개발 워크플로우를 실행합니다.
각 단계에서 품질 게이트를 적용하여 문제가 있으면 중단합니다.

**Options**: $ARGUMENTS
- `skip-review`: 코드 리뷰 단계 건너뛰기
- `skip-test`: 테스트 단계 건너뛰기

---

## MCP INTEGRATION

```
WORKFLOW ORCHESTRATION:
├─ Sequential-Thinking MCP 호출 (워크플로우 설계)
│   ├─ 변경 사항 분석 → 리뷰 범위 결정
│   ├─ 테스트 전략 수립 (영향받는 테스트 식별)
│   ├─ 품질 게이트 조건 정의
│   └─ 실패 시나리오 대응 계획
│
└─ 적용 시점:
    ├─ 대규모 변경 사항 처리 시
    ├─ 복잡한 워크플로우 실행 시
    └─ 품질 게이트 판단 시
```

---

## PHASE 1: Context Gathering

```bash
# 현재 상태 파악
echo "=== BRANCH ===" && git branch --show-current
echo "=== STATUS ===" && git status --short
echo "=== CHANGED FILES ===" && git diff --name-only
echo "=== STAGED ===" && git diff --cached --name-only
```

```
ANALYZE context:
├─ IF no changes → Report "변경 사항 없음" and EXIT
├─ Extract changed file list
├─ Identify file types (*.ts, *.tsx, etc.)
└─ Count changes (insertions, deletions)
```

---

## PHASE 2: Planning

```
TodoWrite:
  todos:
    - content: "코드 리뷰 실행"
      status: "pending"
      activeForm: "코드 리뷰 실행 중"

    - content: "테스트 생성 및 실행"
      status: "pending"
      activeForm: "테스트 실행 중"

    - content: "커밋 생성"
      status: "pending"
      activeForm: "커밋 생성 중"
```

```markdown
## 📋 개발 워크플로우 시작

### 변경 사항 요약
| 항목 | 값 |
|------|-----|
| 브랜치 | {branch} |
| 변경 파일 | {file_count}개 |
| 추가 | +{insertions} |
| 삭제 | -{deletions} |

### 실행 계획
1. 코드 리뷰 (code-reviewer)
2. 테스트 생성/실행 (test-automator)
3. 커밋 생성 (/git-commit)
```

---

## PHASE 3: Code Review

```
IF "skip-review" NOT in $ARGUMENTS:
  TodoWrite: Mark "코드 리뷰" as in_progress

  Task(
    subagent_type = "code-reviewer",
    prompt = """
    다음 변경된 파일들을 리뷰해주세요:

    {changed_files_list}

    리뷰 범위:
    - 보안 취약점
    - 성능 문제
    - 코드 품질

    CRITICAL/HIGH 이슈가 있으면 즉시 보고해주세요.
    """
  )

  QUALITY GATE:
  ├─ IF critical_issues > 0:
  │   └─ AskUserQuestion: "CRITICAL 이슈가 있습니다. 계속할까요?"
  │       ├─ "수정하고 계속" → Apply fixes, re-review
  │       ├─ "무시하고 계속" → Proceed with warning
  │       └─ "중단" → EXIT
  │
  └─ ELSE: Proceed to next phase

  TodoWrite: Mark "코드 리뷰" as completed
ELSE:
  Report "리뷰 건너뜀 (skip-review)"
```

---

## PHASE 4: Testing

```
IF "skip-test" NOT in $ARGUMENTS:
  TodoWrite: Mark "테스트" as in_progress

  # 기존 테스트 실행
  Bash: npm test -- --passWithNoTests

  IF tests_exist AND all_passed:
    Report "기존 테스트 통과"

  ELSE IF tests_failed:
    QUALITY GATE:
    AskUserQuestion: "테스트가 실패했습니다. 어떻게 할까요?"
      ├─ "테스트 수정" → Task(test-automator) to fix
      ├─ "무시하고 계속" → Proceed with warning
      └─ "중단" → EXIT

  # 테스트 커버리지 확인 for changed files
  IF coverage_below_threshold:
    AskUserQuestion: "테스트 커버리지가 낮습니다. 테스트를 추가할까요?"
      ├─ "예" → Task(test-automator) to generate tests
      └─ "아니오" → Proceed

  TodoWrite: Mark "테스트" as completed
ELSE:
  Report "테스트 건너뜀 (skip-test)"
```

---

## PHASE 5: Commit

```
TodoWrite: Mark "커밋" as in_progress

AskUserQuestion:
  question: "커밋을 진행할까요?"
  header: "커밋"
  options:
    - label: "예, 커밋합니다"
      description: "변경 사항을 커밋합니다"
    - label: "메시지 확인 후 커밋"
      description: "커밋 메시지를 먼저 확인합니다"
    - label: "취소"
      description: "커밋하지 않습니다"

SWITCH selection:
  "예, 커밋합니다":
    → Execute /git-commit flow

  "메시지 확인 후 커밋":
    → Generate commit message
    → Show to user
    → AskUserQuestion: "이 메시지로 커밋할까요?"
    → IF approved → git commit

  "취소":
    → Report "커밋 취소됨"
    → EXIT

TodoWrite: Mark "커밋" as completed
```

---

## PHASE 6: Post-Commit Options

```
AskUserQuestion:
  question: "커밋 완료! 다음 작업을 선택하세요"
  header: "후속"
  options:
    - label: "푸시"
      description: "원격 저장소에 푸시합니다"
    - label: "PR 생성"
      description: "Pull Request를 생성합니다"
    - label: "완료"
      description: "워크플로우를 종료합니다"

SWITCH selection:
  "푸시":
    → git push origin {branch}
    → Report push result

  "PR 생성":
    → Generate PR description from commits
    → gh pr create --title "..." --body "..."
    → Return PR URL

  "완료":
    → Print final summary
```

---

## PHASE 7: Final Report

```markdown
## ✅ 개발 워크플로우 완료

### 실행 결과
| 단계 | 상태 | 요약 |
|------|------|------|
| 코드 리뷰 | ✅ 완료 | {review_summary} |
| 테스트 | ✅ 완료 | {test_summary} |
| 커밋 | ✅ 완료 | {commit_hash} |
| 푸시/PR | {status} | {pr_url} |

### 품질 게이트
- 리뷰: {passed/failed} ({issue_count} issues)
- 테스트: {passed/failed} ({test_count} tests)

### 다음 권장 사항
- {recommendation_1}
- {recommendation_2}
```

---

## ERROR HANDLING

| Error | Response |
|-------|----------|
| No changes | "변경 사항이 없습니다" → EXIT |
| Review critical | 사용자에게 선택권 제공 |
| Test failure | 사용자에게 선택권 제공 |
| Commit failure | 에러 메시지 표시, 해결 방법 제안 |
| Push rejected | "git pull --rebase 후 다시 시도하세요" |

---

## EXECUTE NOW

```
1. Gather context (git status, diff)
2. Create TodoWrite plan
3. IF NOT skip-review:
   └─ Task(code-reviewer) → Quality Gate
4. IF NOT skip-test:
   └─ Bash(npm test) → Quality Gate
5. AskUserQuestion: Commit confirmation
6. Execute /git-commit
7. AskUserQuestion: Post-commit options
8. Execute selected action
9. Print final report
```
