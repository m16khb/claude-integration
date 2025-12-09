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

## PHASE 3: Analyze & Group Changes

### Step 3.1: Collect All Changes

```bash
# 모든 변경 파일 목록 수집
git status --porcelain
```

### Step 3.2: Group by Logical Unit

```
GROUPING ALGORITHM:
┌─────────────────────────────────────────────────────────────┐
│ 1. 경로 기반 그룹화 (Primary)                                │
│    ├─ src/auth/*        → "auth" 그룹                       │
│    ├─ src/user/*        → "user" 그룹                       │
│    ├─ src/common/*      → "common" 그룹                     │
│    ├─ tests/*           → "test" 그룹                       │
│    ├─ docs/*            → "docs" 그룹                       │
│    └─ config/, *.config.* → "config" 그룹                   │
├─────────────────────────────────────────────────────────────┤
│ 2. 파일 타입 기반 그룹화 (Secondary)                         │
│    ├─ *.test.ts, *.spec.ts  → "test" 그룹                   │
│    ├─ *.md                   → "docs" 그룹                   │
│    ├─ *.json, *.yml, *.yaml  → "config" 그룹                │
│    └─ *.ts, *.js, *.py       → "source" 그룹                │
├─────────────────────────────────────────────────────────────┤
│ 3. 변경 패턴 기반 분류 (Tertiary)                            │
│    ├─ A (added)     → 새 기능 가능성 높음 (feat)             │
│    ├─ M (modified)  → 수정/개선 (fix/refactor)               │
│    ├─ D (deleted)   → 정리/리팩토링 (refactor/chore)         │
│    └─ R (renamed)   → 구조 변경 (refactor)                   │
└─────────────────────────────────────────────────────────────┘

MERGE RULES:
├─ 같은 모듈 내 source + test → 하나의 커밋으로 병합
├─ config 파일들 → 별도 커밋 권장
├─ docs 파일들 → 별도 커밋 권장
└─ 5개 이상 파일이 서로 다른 모듈 → 분할 필수
```

### Step 3.3: Determine Commit Type per Group

```
TYPE DETECTION MATRIX:
┌──────────────┬────────────────────────────────────────────┐
│ 변경 패턴     │ 커밋 타입                                   │
├──────────────┼────────────────────────────────────────────┤
│ 새 파일 추가  │ feat (기능) / test (테스트) / docs (문서)   │
│ 기존 파일 수정│ fix (버그) / refactor (구조) / perf (성능)  │
│ 파일 삭제    │ refactor (정리) / chore (설정)              │
│ 파일 이동    │ refactor (구조 변경)                        │
│ 설정 파일    │ chore (빌드/설정)                           │
│ 테스트 파일  │ test (테스트 추가/수정)                      │
│ 문서 파일    │ docs (문서화)                               │
└──────────────┴────────────────────────────────────────────┘

BRANCH CONTEXT OVERRIDE:
├─ feature/* branch → prefer feat/refactor
├─ hotfix/* branch  → prefer fix
├─ release/* branch → prefer fix/chore
├─ develop branch   → mixed (분석 결과 따름)
└─ main/master      → 직접 커밋 경고
```

### Step 3.4: Generate Group Summary

```
OUTPUT FORMAT:
┌─ Group 1: auth ────────────────────────────────────────────┐
│ Type: feat                                                 │
│ Files: src/auth/login.ts, src/auth/jwt.service.ts          │
│ Summary: JWT 기반 로그인 기능 추가                          │
└────────────────────────────────────────────────────────────┘
┌─ Group 2: test ────────────────────────────────────────────┐
│ Type: test                                                 │
│ Files: tests/auth/login.spec.ts                            │
│ Summary: 로그인 테스트 케이스 추가                          │
└────────────────────────────────────────────────────────────┘
```

---

## PHASE 3.5: Multi-Commit Strategy Selection

### Step 3.5.1: Evaluate Grouping Result

```
DECISION TREE:
├─ IF groups.length == 1
│   → SINGLE COMMIT MODE (기존 방식)
│   → Skip to PHASE 4
│
├─ IF groups.length >= 2
│   → MULTI COMMIT MODE
│   → Present TUI for user selection
│
└─ IF groups.length > 5
    → WARN: "변경이 너무 많습니다. 작업 단위를 나누세요"
    → Suggest: git stash로 일부 보류 권장
```

### Step 3.5.2: User Selection TUI (Multi-Commit Mode)

```
AskUserQuestion:
  question: "{N}개 그룹으로 변경사항이 분류되었습니다. 커밋 방식을 선택하세요."
  header: "커밋 전략"
  options:
    - label: "그룹별 개별 커밋 (Recommended)"
      description: "각 그룹을 별도 커밋으로 생성합니다. 히스토리가 깔끔해집니다."
    - label: "전체 단일 커밋"
      description: "모든 변경을 하나의 커밋으로 묶습니다."
    - label: "선택적 커밋"
      description: "커밋할 그룹을 직접 선택합니다."
```

### Step 3.5.3: Group Selection TUI (선택적 커밋 모드)

```
IF user selected "선택적 커밋":

AskUserQuestion:
  question: "커밋할 그룹을 선택하세요."
  header: "그룹 선택"
  multiSelect: true
  options:
    # 동적으로 그룹 목록 생성
    - label: "Group 1: {scope}"
      description: "{type}: {files count}개 파일 - {summary}"
    - label: "Group 2: {scope}"
      description: "{type}: {files count}개 파일 - {summary}"
    # ... 추가 그룹들
```

### Step 3.5.4: Execute Multi-Commit Workflow

```
MULTI-COMMIT EXECUTION:
FOR each selected_group IN groups:
    1. Stage files for this group only
       git add {group.files}

    2. Create commit with group-specific message
       git commit -m "{group.type}({group.scope}): {group.summary}"

    3. Report progress
       echo "✅ [{index}/{total}] {group.scope} 커밋 완료"

    4. Continue to next group

END FOR

FINAL REPORT:
├─ 총 {N}개 커밋 생성
├─ 커밋 해시 목록
└─ 각 커밋별 변경 요약
```

### Step 3.5.5: Commit Order Strategy

```
RECOMMENDED ORDER:
1. chore/config  → 설정 변경 먼저 (의존성 기반)
2. refactor      → 구조 변경
3. feat          → 새 기능
4. fix           → 버그 수정
5. test          → 테스트 추가
6. docs          → 문서화 마지막

REASON:
├─ 설정이 먼저 있어야 코드가 동작
├─ 구조 변경 후 기능 추가가 자연스러움
├─ 테스트는 기능 구현 후 추가
└─ 문서는 모든 작업 완료 후 정리
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

### Single Commit Report

```markdown
## ✅ 커밋 완료

| 항목   | 내용                                          |
| ------ | --------------------------------------------- |
| 커밋   | `<hash>` <type>: <message>                    |
| 브랜치 | <branch> (Git Flow: <type>)                   |
| 푸시   | ✅ 완료 / ⏭️ 스킵 / ❌ 실패                   |
| 변경   | +<insertions> / -<deletions> in <files> files |
```

### Multi-Commit Report

```markdown
## ✅ 다중 커밋 완료 ({N}개)

### 커밋 목록
| # | 해시 | 타입 | 스코프 | 메시지 | 파일 수 |
|---|------|------|--------|--------|---------|
| 1 | `abc1234` | feat | auth | JWT 인증 구현 | 3 |
| 2 | `def5678` | test | auth | 인증 테스트 추가 | 2 |
| 3 | `ghi9012` | docs | - | README 업데이트 | 1 |

### 요약
| 항목 | 내용 |
|------|------|
| 브랜치 | <branch> (Git Flow: <type>) |
| 총 커밋 | {N}개 |
| 총 변경 | +<insertions> / -<deletions> in <files> files |
| 푸시 | ✅ 완료 / ⏭️ 스킵 / ❌ 실패 |

### 커밋 순서 (Git Flow 권장)
```
{commit_order_visualization}
chore → refactor → feat → fix → test → docs
```
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
3. Analyze and group changes (PHASE 3)
   - 3.1: Collect all changes
   - 3.2: Group by logical unit (경로/타입/패턴)
   - 3.3: Determine commit type per group
   - 3.4: Generate group summary
4. **Select commit strategy (PHASE 3.5)** ← NEW
   - IF single group → Skip to PHASE 4
   - IF multiple groups → Show TUI for strategy selection
   - Execute multi-commit workflow if selected
5. Create commit(s) with Korean message (PHASE 4)
6. Push if "push" in $ARGUMENTS (PHASE 5)
7. Report results in Korean (PHASE 6)
   - Use Single/Multi report format based on commit count
8. **Show follow-up TUI** (PHASE 7) ← NEVER SKIP
