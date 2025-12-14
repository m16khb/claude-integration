---
name: git-workflows:git-commit
description: 'Conventional Commits 1.0.0 규격 스마트 커밋 (인자: push - 커밋 후 푸시)'
argument-hint: [push] [custom-message]
allowed-tools:
  - Bash(git *)
  - mcp__st__sequentialthinking
model: claude-opus-4-5-20251101
---

# Smart Git Commit (Conventional Commits 1.0.0)

## MISSION

변경사항을 분석하여 **Conventional Commits 1.0.0** 규격의 커밋을 생성합니다.
SemVer와 연동: `feat`→MINOR, `fix`→PATCH, `BREAKING CHANGE`→MAJOR

**Args**: $ARGUMENTS

---

## PHASE 1: Gather Context

```bash
echo "=== BRANCH ===" && git branch --show-current
echo "=== CHANGES ===" && git status --short
echo "=== STAGED ===" && git diff --cached --stat
echo "=== UNSTAGED ===" && git diff --stat
echo "=== RECENT COMMITS ===" && git log --oneline -5
```

---

## PHASE 2: Security Check

```
CRITICAL RULES:
├─ 민감 파일 (.env, *.key, *secret*) → 경고 + 확인 필요
├─ main/master + push → 명시적 확인 필수
└─ 변경 없음 → "변경 사항 없음" 출력 후 종료
```

---

## PHASE 2.5: BREAKING CHANGE Detection (NEW)

```
BREAKING CHANGE 감지 기준:
┌─────────────────────────────────────────────────────────┐
│ 1. API 시그니처 변경                                     │
│    - 함수/메서드 파라미터 변경                            │
│    - 반환 타입 변경                                      │
│    - 기존 메서드 삭제                                    │
│                                                         │
│ 2. 설정 파일 변경                                        │
│    - 환경변수 이름 변경                                   │
│    - 설정 키 삭제/이름 변경                               │
│                                                         │
│ 3. 데이터 스키마 변경                                     │
│    - DB 테이블/컬럼 삭제                                  │
│    - API 응답 형식 변경                                   │
│                                                         │
│ 4. 파일 삭제/이동                                        │
│    - public API 파일 삭제                                │
│    - 엔트리 포인트 변경                                   │
└─────────────────────────────────────────────────────────┘

IF BREAKING CHANGE detected:
  → AskUserQuestion: "BREAKING CHANGE로 표시하시겠습니까?"
  → 사용자 확인 시: 타입에 ! 추가 또는 꼬리말에 BREAKING CHANGE 추가
  → SemVer 영향: MAJOR 버전 증가 필요 알림
```

---

## PHASE 3: Analyze & Group Changes

```
GROUPING:
├─ 경로 기반: src/auth/* → "auth" 그룹
├─ 타입 기반: *.test.ts → "test" 그룹
└─ 패턴 기반: A(added)→feat, M(modified)→fix/refactor

COMMIT TYPE 매트릭스:
┌────────────────┬────────────────┬─────────┐
│ 변경 패턴       │ 커밋 타입       │ SemVer  │
├────────────────┼────────────────┼─────────┤
│ 새 파일 추가    │ feat/test/docs │ MINOR   │
│ 기존 파일 수정  │ fix/refactor   │ PATCH   │
│ 파일 삭제      │ refactor/chore │ -       │
│ 설정 파일      │ chore          │ -       │
│ BREAKING 변경  │ type!          │ MAJOR   │
└────────────────┴────────────────┴─────────┘
```

---

## PHASE 3.5: Multi-Commit Strategy (≥2 그룹)

```
IF groups >= 2:
  TUI 선택:
  ├─ 그룹별 개별 커밋 (Recommended)
  ├─ 전체 단일 커밋
  └─ 선택적 커밋

COMMIT ORDER:
chore → refactor → feat → fix → test → docs
```

---

## PHASE 4: Create Commit

### 4.1 일반 커밋

```
MESSAGE FORMAT (Conventional Commits 1.0.0):
<type>(<scope>): <Korean description>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 4.2 BREAKING CHANGE 커밋

```
방법 1: ! 문법
<type>(<scope>)!: <description>

BREAKING CHANGE: <상세 설명>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
Co-Authored-By: Claude <noreply@anthropic.com>

방법 2: 꼬리말만
<type>(<scope>): <description>

BREAKING CHANGE: <상세 설명>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
Co-Authored-By: Claude <noreply@anthropic.com>
```

### 4.3 revert 커밋

```
revert: <되돌리는 커밋의 subject>

This reverts commit <SHA>.

Refs: <SHA>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
Co-Authored-By: Claude <noreply@anthropic.com>
```

### 4.4 커밋 실행

```bash
git commit -m "$(cat <<'EOF'
<type>: <Korean description>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## PHASE 5: Push (Conditional)

```
IF "push" in $ARGUMENTS:
  ├─ upstream 없음 → git push -u origin $BRANCH
  └─ upstream 있음 → git push origin $BRANCH
```

---

## PHASE 6: Report

```markdown
## ✅ 커밋 완료

| 항목        | 내용                       |
| ----------- | -------------------------- |
| 커밋        | `<hash>` <type>: <message> |
| 브랜치      | <branch>                   |
| 푸시        | ✅/⏭️/❌                   |
| 변경        | +<insertions>/-<deletions> |
| SemVer 영향 | MAJOR/MINOR/PATCH/없음     |
| BREAKING    | ⚠️/✅                      |
```

---

## PHASE 7: Follow-up TUI

```
AskUserQuestion:
  question: "다음 작업을 선택하세요"
  options:
    - 푸시 → git push
    - 추가 커밋 → PHASE 1로 재실행
    - 완료 → 종료
```

---

## ERROR HANDLING

| Error                | Response                      |
| -------------------- | ----------------------------- |
| Nothing to commit    | "변경 사항 없음"              |
| Merge conflict       | "충돌 파일 확인 후 해결"      |
| Push rejected        | "git pull --rebase 후 재시도" |
| Pre-commit hook fail | 수정 제안 표시                |

---

## SEMVER QUICK REFERENCE

```
SEMANTIC VERSIONING 연동:
┌──────────────────┬─────────────────────────────┐
│ 커밋             │ SemVer 영향                  │
├──────────────────┼─────────────────────────────┤
│ feat             │ MINOR (1.x.0)               │
│ fix              │ PATCH (1.0.x)               │
│ BREAKING CHANGE  │ MAJOR (x.0.0)               │
│ docs/style/...   │ 영향 없음                    │
└──────────────────┴─────────────────────────────┘
```

---

## Documentation

상세 내용은 agent-docs/ 참조:

- @../agent-docs/commit-conventions.md - Conventional Commits 1.0.0 전체 규격
- @../agent-docs/branch-strategies.md - Git Flow 브랜치 전략
- @../agent-docs/automation-patterns.md - 다중 커밋, 스마트 그룹화
