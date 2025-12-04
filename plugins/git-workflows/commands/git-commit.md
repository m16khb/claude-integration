---
name: git-workflows:git-commit
description: '스마트 git 커밋 (인자: push - 커밋 후 푸시)'
allowed-tools: Bash(git *)
model: claude-haiku-4-5-20251001
---

# Smart Git Commit

## MISSION

Create semantically meaningful git commits following Conventional Commits format.
Focus on commit and push operations only. Analyze changes → stage → commit → optionally push.

**Args**: $ARGUMENTS

---

## PHASE 1: Gather Context

Execute these commands to understand current state:

```bash
echo "=== BRANCH ===" && git branch --show-current
echo "=== GIT FLOW CONTEXT ===" && git branch --show-current | grep -E "^(feature|release|hotfix|develop|main|master)" || echo "other"
echo "=== REMOTE SYNC ===" && git status -sb | head -1
echo "=== ALL CHANGES ===" && git status --short
echo "=== STAGED (will commit) ===" && git diff --cached --stat
echo "=== UNSTAGED (need staging) ===" && git diff --stat
echo "=== RECENT COMMITS (style reference) ===" && git log --oneline -5
```

```
PARSE branch type for context:
├─ feature/*  → likely feat/refactor commits
├─ release/*  → likely fix/chore commits
├─ hotfix/*   → likely fix commits
├─ develop    → mixed commits
└─ main/master → should rarely commit directly
```

---

## PHASE 2: Security Check

```
CRITICAL RULES:
├─ IF file matches (.env|secret|credential|password|*.pem|*.key)
│   → WARN user, DO NOT stage automatically
│   → AskUserQuestion: "민감 파일이 포함되어 있습니다. 제외하시겠습니까?"
│
├─ IF branch is (main|master) AND "push" in $ARGUMENTS
│   → REQUIRE explicit confirmation via AskUserQuestion
│
├─ IF branch is (main|master) AND no "push" in $ARGUMENTS
│   → WARN: "main/master 브랜치에 직접 커밋 중입니다"
│
└─ IF no changes exist
    → Report "변경 사항 없음" and EXIT
```

**TUI (main/master protection):**

```
AskUserQuestion:
  question: "main/master 브랜치에 직접 작업하려고 합니다. 계속하시겠습니까?"
  header: "경고"
  options:
    - label: "계속 진행"
      description: "main/master에 직접 커밋/푸시합니다 (권장하지 않음)"
    - label: "취소"
      description: "작업을 취소합니다"
```

---

## PHASE 3: Analyze & Stage

```
LOGIC:
1. Group changes by logical unit (1 commit = 1 purpose)
   ├─ IF multiple unrelated changes
   │   → Suggest splitting into multiple commits
   └─ IF all changes related → proceed as single commit

2. Determine commit type from changes:
   │ feat     │ new feature, capability
   │ fix      │ bug fix
   │ refactor │ code restructure (no behavior change)
   │ docs     │ documentation only
   │ style    │ formatting, whitespace
   │ test     │ add/modify tests
   │ chore    │ build, config, dependencies

3. Consider branch context:
   ├─ feature/* branch → prefer feat/refactor
   ├─ hotfix/* branch  → prefer fix
   └─ release/* branch → prefer fix/chore

4. Stage files:
   ├─ IF unstaged changes exist → git add <relevant files>
   └─ IF already staged → use existing staging
```

---

## PHASE 4: Create Commit

```
MESSAGE FORMAT (Conventional Commits):
<type>(<optional scope>): <description in Korean>

[optional body - explain WHY if complex change]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Commit type guidelines:**

```
├─ feat:     새로운 기능 추가
├─ fix:      버그 수정
├─ refactor: 코드 구조 개선 (동작 변경 없음)
├─ docs:     문서만 수정
├─ style:    포맷팅, 세미콜론 등 (코드 변경 없음)
├─ test:     테스트 추가/수정
└─ chore:    빌드, 설정, 의존성 등
```

Execute:

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
    BRANCH = $(git branch --show-current)

    # Check if remote tracking exists
    IF no upstream set:
        git push -u origin $BRANCH
    ELSE:
        git push origin $BRANCH

    IF push failed:
        ├─ rejected (non-fast-forward) → suggest: git pull --rebase
        ├─ auth failed → suggest: check token/SSH key
        └─ no remote → suggest: git remote add origin <url>
```

---

## PHASE 6: Report (Korean)

```markdown
## ✅ 커밋 완료

| 항목   | 내용                                          |
| ------ | --------------------------------------------- |
| 커밋   | `<hash>` <type>: <message>                    |
| 브랜치 | <branch> (Git Flow: <type>)                   |
| 푸시   | ✅ 완료 / ⏭️ 스킵 / ❌ 실패                   |
| 변경   | +<insertions> / -<deletions> in <files> files |
```

---

## PHASE 7: Follow-up TUI (Required)

**Always show after commit completes:**

```
AskUserQuestion:
  question: "커밋이 완료되었습니다. 다음 작업을 선택하세요."
  header: "후속"
  options:
    - label: "푸시"
      description: "원격 저장소에 푸시합니다"
    - label: "추가 커밋"
      description: "다른 변경 사항을 추가로 커밋합니다"
    - label: "완료"
      description: "작업을 종료합니다"
```

### Handle Selection:

```
SWITCH selection:
  "푸시":
    → BRANCH = $(git branch --show-current)
    → git push origin $BRANCH
    → Report push result in Korean

  "추가 커밋":
    → Re-run from PHASE 1

  "완료":
    → Print final summary
    → Exit
```

---

## ERROR HANDLING

| Error                | Response (Korean)                                                      |
| -------------------- | ---------------------------------------------------------------------- |
| Nothing to commit    | "변경 사항 없음" → Exit                                                |
| Merge conflict       | "충돌 파일: {files}" + "`git status`로 확인 후 해결하세요"             |
| Push rejected        | "`git pull --rebase origin {branch}` 후 다시 시도하세요"               |
| Pre-commit hook fail | "훅 실패: {output}" + 수정 제안                                        |
| No remote configured | "원격 저장소 설정 필요: `git remote add origin <url>`"                 |
| Auth failure         | "인증 실패 - GitHub 토큰 또는 SSH 키 확인 필요"                        |
| No upstream branch   | "`git push -u origin {branch}`로 업스트림 설정"                        |
| Detached HEAD        | "브랜치가 아닌 커밋에 있습니다. 브랜치 생성: `git checkout -b <name>`" |

---

## EXECUTE NOW

1. Run PHASE 1 commands (gather context)
2. Check security rules (PHASE 2)
3. Analyze changes and stage (PHASE 3)
4. Create commit with Korean message (PHASE 4)
5. Push if "push" in $ARGUMENTS (PHASE 5)
6. Report results in Korean (PHASE 6)
7. **Show follow-up TUI** (PHASE 7) ← NEVER SKIP
