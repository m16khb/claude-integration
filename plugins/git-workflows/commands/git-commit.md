---
name: git-workflows:git-commit
description: '스마트 git 커밋 (인자: push - 커밋 후 푸시)'
allowed-tools:
  - Bash(git *)
  - mcp__st__sequentialthinking
model: claude-haiku-4-5-20251001
---

# Smart Git Commit

## MISSION

변경사항을 분석하여 Conventional Commits 형식의 의미 있는 커밋을 생성합니다.

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

## PHASE 3: Analyze & Group Changes

```
GROUPING:
├─ 경로 기반: src/auth/* → "auth" 그룹
├─ 타입 기반: *.test.ts → "test" 그룹
└─ 패턴 기반: A(added)→feat, M(modified)→fix/refactor

COMMIT TYPE 매트릭스:
├─ 새 파일 추가    → feat/test/docs
├─ 기존 파일 수정  → fix/refactor/perf
├─ 파일 삭제      → refactor/chore
└─ 설정 파일      → chore
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

```
MESSAGE FORMAT:
<type>(<scope>): <Korean description>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

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

| 항목 | 내용 |
|------|------|
| 커밋 | `<hash>` <type>: <message> |
| 브랜치 | <branch> |
| 푸시 | ✅/⏭️/❌ |
| 변경 | +<insertions>/-<deletions> |
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

| Error | Response |
|-------|----------|
| Nothing to commit | "변경 사항 없음" |
| Merge conflict | "충돌 파일 확인 후 해결" |
| Push rejected | "git pull --rebase 후 재시도" |
| Pre-commit hook fail | 수정 제안 표시 |

---

## Documentation

상세 내용은 agent-docs/ 참조:
- @../agent-docs/commit-conventions.md - Conventional Commits 표준
- @../agent-docs/branch-strategies.md - Git Flow 브랜치 전략
- @../agent-docs/automation-patterns.md - 다중 커밋, 스마트 그룹화
