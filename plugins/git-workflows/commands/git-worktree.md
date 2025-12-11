---
name: git-workflows:git-worktree
description: 'Git worktree 안전 관리 (인자: <action> [branch] [name])'
allowed-tools:
  - Bash(git *)
  - Bash(ls *)
  - Bash(rm -rf *)
  - AskUserQuestion
model: claude-haiku-4-5-20251001
---

# Git Worktree Manager

## MISSION

Git worktree를 안전하게 생성, 조회, 삭제합니다.
여러 브랜치에서 동시에 작업할 수 있도록 독립된 작업 디렉토리를 관리합니다.

**Args**: $ARGUMENTS

---

## SYNTAX

```
/git-workflows:git-worktree <action> [branch] [name]

Actions:
  add <branch> [name]   - 새 워크트리 생성
  list                  - 워크트리 목록 조회
  remove <name>         - 워크트리 삭제
  prune                 - 삭제된 워크트리 정리

Arguments:
  branch  - 타겟 브랜치 (기존 또는 새 브랜치)
  name    - 워크트리 디렉토리 이름 (기본: 브랜치명)
```

---

## PHASE 1: Parse Arguments

```
ARGUMENT PARSING:
┌─────────────────────────────────────────────────────────┐
│ $ARGUMENTS 파싱                                          │
├─────────────────────────────────────────────────────────┤
│ 예시:                                                    │
│   "add feature/auth"        → branch: feature/auth      │
│   "add feature/auth mywork" → branch: feature/auth      │
│                               name: mywork              │
│   "list"                    → action: list              │
│   "remove mywork"           → name: mywork              │
│   "prune"                   → action: prune             │
└─────────────────────────────────────────────────────────┘

IF no arguments OR invalid action:
  → AskUserQuestion으로 action 선택 요청
```

---

## PHASE 2: Context Gathering

```bash
echo "=== CURRENT REPO ===" && pwd
echo "=== CURRENT BRANCH ===" && git branch --show-current
echo "=== EXISTING WORKTREES ===" && git worktree list
echo "=== AVAILABLE BRANCHES ===" && git branch -a --format='%(refname:short)' | head -20
```

---

## PHASE 3: Safety Checks

```
SAFETY VALIDATION:
┌─────────────────────────────────────────────────────────┐
│ 1. Git 저장소 확인                                       │
│    - .git 디렉토리 존재 여부                             │
│    - bare 저장소 아닌지 확인                             │
│                                                         │
│ 2. 브랜치 검증 (add 시)                                  │
│    - 이미 다른 워크트리에서 체크아웃 중인지              │
│    - 브랜치 존재 여부 (없으면 생성 확인)                 │
│                                                         │
│ 3. 경로 검증                                             │
│    - 디렉토리 이미 존재하는지                            │
│    - 상위 디렉토리 쓰기 권한                             │
│    - 경로 충돌 없는지                                    │
│                                                         │
│ 4. 워크트리 상태 확인 (remove 시)                        │
│    - 커밋되지 않은 변경사항 있는지                       │
│    - 스태시된 변경사항 있는지                            │
└─────────────────────────────────────────────────────────┘
```

---

## PHASE 4: Execute Action

### 4.1 ADD - 워크트리 생성

```
ADD WORKTREE FLOW:
┌─────────────────────────────────────────────────────────┐
│ 1. 브랜치 확인                                           │
│    IF 브랜치 존재:                                       │
│      → git worktree add <path> <branch>                 │
│    ELSE:                                                │
│      → 사용자 확인 후 새 브랜치 생성                     │
│      → git worktree add -b <branch> <path>              │
│                                                         │
│ 2. 경로 결정                                             │
│    - 기본: ../worktrees/<name>                          │
│    - 또는: ../<name>                                    │
│                                                         │
│ 3. 생성 실행                                             │
│    git worktree add <path> <branch>                     │
└─────────────────────────────────────────────────────────┘
```

```bash
# 기존 브랜치로 워크트리 생성
git worktree add "../worktrees/$NAME" "$BRANCH"

# 새 브랜치 생성과 함께 워크트리 생성
git worktree add -b "$BRANCH" "../worktrees/$NAME"

# 원격 브랜치 추적하며 생성
git worktree add --track -b "$LOCAL_BRANCH" "../worktrees/$NAME" "origin/$REMOTE_BRANCH"
```

### 4.2 LIST - 워크트리 목록

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📂 Git Worktrees"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git worktree list --porcelain | while read line; do
  # 포맷팅된 출력
done
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### 4.3 REMOVE - 워크트리 삭제

```
REMOVE WORKTREE FLOW:
┌─────────────────────────────────────────────────────────┐
│ 1. 워크트리 존재 확인                                    │
│                                                         │
│ 2. 변경사항 확인                                         │
│    IF 커밋되지 않은 변경:                                │
│      ⚠️  경고 표시                                       │
│      → 사용자 확인 요청                                  │
│      → 강제 삭제 시 --force 사용                         │
│                                                         │
│ 3. 삭제 실행                                             │
│    git worktree remove <path>                           │
│    OR                                                   │
│    git worktree remove --force <path>                   │
└─────────────────────────────────────────────────────────┘
```

```bash
# 안전한 삭제 (변경사항 있으면 실패)
git worktree remove "../worktrees/$NAME"

# 강제 삭제 (변경사항 무시)
git worktree remove --force "../worktrees/$NAME"
```

### 4.4 PRUNE - 정리

```bash
# 삭제된 워크트리 참조 정리
git worktree prune

# Dry-run으로 먼저 확인
git worktree prune --dry-run
```

---

## PHASE 5: Report

### ADD 성공 시

```markdown
## ✅ 워크트리 생성 완료

| 항목 | 내용 |
|------|------|
| 경로 | `../worktrees/<name>` |
| 브랜치 | `<branch>` |
| 상태 | 새 브랜치 생성 / 기존 브랜치 체크아웃 |

### 다음 단계
```bash
# 워크트리로 이동
cd ../worktrees/<name>

# 작업 시작
code .
```
```

### LIST 출력

```markdown
## 📂 Git Worktrees

| # | 경로 | 브랜치 | HEAD |
|---|------|--------|------|
| 1 | /path/to/main | main | abc1234 |
| 2 | /path/to/feature | feature/auth | def5678 |
| 3 | /path/to/hotfix | hotfix/bug | ghi9012 |

총 3개 워크트리
```

### REMOVE 성공 시

```markdown
## ✅ 워크트리 삭제 완료

| 항목 | 내용 |
|------|------|
| 삭제된 경로 | `../worktrees/<name>` |
| 브랜치 | `<branch>` (브랜치는 유지됨) |

ℹ️ 브랜치를 함께 삭제하려면:
```bash
git branch -d <branch>
```
```

---

## ERROR HANDLING

| Error | Response |
|-------|----------|
| Not a git repository | "Git 저장소가 아닙니다" |
| Branch already checked out | "브랜치가 이미 다른 워크트리에서 사용 중입니다" |
| Path already exists | "경로가 이미 존재합니다" |
| Worktree not found | "워크트리를 찾을 수 없습니다" |
| Uncommitted changes | "커밋되지 않은 변경사항이 있습니다. --force로 강제 삭제" |
| Invalid branch name | "유효하지 않은 브랜치 이름입니다" |

---

## INTERACTIVE MODE

```
인자 없이 실행 시:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌲 Git Worktree Manager

작업을 선택하세요:

[1] 새 워크트리 생성 (add)
    브랜치를 별도 디렉토리에서 작업

[2] 워크트리 목록 (list)
    현재 워크트리 상태 확인

[3] 워크트리 삭제 (remove)
    더 이상 필요 없는 워크트리 제거

[4] 정리 (prune)
    삭제된 워크트리 참조 정리

[q] 취소
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
선택:
```

---

## USE CASES

### 1. 기능 개발 중 긴급 버그 수정

```bash
# 현재 feature/payment 작업 중
# hotfix가 필요한 상황

# 새 워크트리 생성
/git-workflows:git-worktree add hotfix/critical-bug hotfix

# 결과:
# ../worktrees/hotfix 디렉토리에서 hotfix 작업
# 기존 feature/payment 작업은 유지
```

### 2. 여러 브랜치 동시 빌드/테스트

```bash
# main, develop, feature 동시에 빌드 확인
/git-workflows:git-worktree add main main-build
/git-workflows:git-worktree add develop dev-build

# 각 워크트리에서 독립적으로 빌드 실행
```

### 3. 코드 리뷰를 위한 PR 브랜치 체크아웃

```bash
# PR 브랜치를 별도 워크트리로
/git-workflows:git-worktree add feature/user-auth review-pr-123

# 현재 작업 중단 없이 PR 코드 리뷰
```

---

## BEST PRACTICES

```
DO ✅:
├─ 워크트리 디렉토리를 일관된 위치에 생성 (../worktrees/)
├─ 작업 완료 후 워크트리 삭제
├─ 정기적으로 prune 실행
└─ 워크트리 이름을 명확하게 지정

DON'T ❌:
├─ 너무 많은 워크트리 생성 (관리 어려움)
├─ 워크트리 내부를 Git 저장소로 착각
├─ 워크트리 디렉토리를 수동으로 삭제 (git worktree remove 사용)
└─ 같은 브랜치로 여러 워크트리 생성 시도
```

---

## WORKTREE DIRECTORY STRUCTURE

```
project/
├── main-repo/           ← 메인 저장소
│   ├── .git/
│   ├── src/
│   └── ...
│
└── worktrees/           ← 워크트리 디렉토리 (권장)
    ├── feature-auth/    ← feature/auth 브랜치
    ├── hotfix-bug/      ← hotfix/bug 브랜치
    └── review-pr-123/   ← PR 리뷰용
```

---

## Documentation

- @../agent-docs/branch-strategies.md - Git Flow 브랜치 전략
- @../agent-docs/automation-patterns.md - 자동화 패턴
