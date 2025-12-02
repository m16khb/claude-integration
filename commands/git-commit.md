---
allowed-tools: Bash(git *)
description: "스마트 git 커밋 (인자: push - 커밋 후 푸시)"
---

# Git Commit Command

**인자**: $ARGUMENTS

## 컨텍스트 수집

### 브랜치 상태
- 현재 브랜치: !`git branch --show-current`
- 원격 동기화: !`git status -sb | head -1`

### 변경사항 요약
```
!`git status --short`
```

### Staged 변경사항 (커밋 대상)
```
!`git diff --cached --stat`
```

### Unstaged 변경사항 (스테이징 필요)
```
!`git diff --stat`
```

### 최근 커밋 스타일 참조
```
!`git log --oneline -5`
```

## 커밋 규칙

### 메시지 형식 (Conventional Commits + 한글)
```
<type>: <description>

[optional body]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Type 종류
| type | 용도 |
|------|------|
| feat | 새 기능 |
| fix | 버그 수정 |
| refactor | 리팩토링 (기능 변화 없음) |
| docs | 문서 변경 |
| style | 포맷팅, 세미콜론 등 |
| test | 테스트 추가/수정 |
| chore | 빌드, 설정 파일 등 |

## 작업 지시

### 1. 안전 검사
- [ ] `.env`, `secret`, `credential`, `password` 포함 파일 → 커밋 제외 경고
- [ ] 현재 브랜치가 `main`/`master`이고 push 요청 시 → 확인 필요 알림

### 2. 변경사항 분석
- Unstaged 파일 중 커밋 대상을 선별하여 `git add`
- 논리적 단위로 그룹화 (1커밋 = 1기능/1수정)

### 3. 커밋 생성
- 변경 내용을 분석하여 적절한 type 선택
- 한글로 명확하고 간결한 description 작성
- 필요시 body에 상세 설명

### 4. 푸시 (인자에 `push` 포함 시)
- `git push origin <current-branch>`
- 실패 시 원인 분석 및 해결 방안 제시

### 5. 결과 보고
```
## 커밋 결과
- 커밋: <hash> <message>
- 브랜치: <branch>
- 푸시: ✅ 완료 / ⏭️ 스킵
```

## 예시

### 단일 기능 커밋
```bash
git add src/feature.ts
git commit -m "feat: 사용자 인증 기능 추가

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 다중 커밋 (논리적 분리)
```bash
# 커밋 1: 버그 수정
git add src/api.ts
git commit -m "fix: API 타임아웃 오류 수정"

# 커밋 2: 문서 업데이트
git add README.md
git commit -m "docs: 설치 가이드 업데이트"
```
