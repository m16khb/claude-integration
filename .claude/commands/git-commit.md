---
allowed-tools: Bash(git *)
description: "스마트 git 커밋 (인자: push - 커밋 후 푸시)"
---

# Git Commit Command

**Args**: $ARGUMENTS

## Context Collection

### Branch Status
- Current branch: !`git branch --show-current`
- Remote sync: !`git status -sb | head -1`

### Changes Summary
```
!`git status --short`
```

### Staged Changes (commit target)
```
!`git diff --cached --stat`
```

### Unstaged Changes (need staging)
```
!`git diff --stat`
```

### Recent Commit Style Reference
```
!`git log --oneline -5`
```

## Commit Rules

### Message Format (Conventional Commits + Korean)
```
<type>: <description>

[optional body]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Type Reference
| type | usage |
|------|-------|
| feat | new feature |
| fix | bug fix |
| refactor | refactoring (no functional change) |
| docs | documentation |
| style | formatting, semicolons |
| test | add/modify tests |
| chore | build, config files |

## Execution Steps

### 1. Security Check
- IF file contains `.env`, `secret`, `credential`, `password` → warn and exclude
- IF current branch is `main`/`master` AND push requested → require confirmation

### 2. Analyze Changes
- Select files from unstaged → `git add`
- Group by logical unit (1 commit = 1 feature/fix)

### 3. Create Commit
- Analyze changes → select appropriate type
- Write clear, concise description in Korean
- Add body if detailed explanation needed

### 4. Push (IF $ARGUMENTS contains `push`)
- Execute `git push origin <current-branch>`
- IF failed → analyze cause and suggest solution

### 5. Report Result
```
## 커밋 결과
- 커밋: <hash> <message>
- 브랜치: <branch>
- 푸시: ✅ 완료 / ⏭️ 스킵
```

## Examples

### Single Feature Commit
```bash
git add src/feature.ts
git commit -m "feat: 사용자 인증 기능 추가

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Multiple Commits (logical separation)
```bash
# Commit 1: bug fix
git add src/api.ts
git commit -m "fix: API 타임아웃 오류 수정"

# Commit 2: docs update
git add README.md
git commit -m "docs: 설치 가이드 업데이트"
```
