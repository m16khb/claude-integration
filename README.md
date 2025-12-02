# Claude Integration

Claude Code 생산성 향상을 위한 스마트 커맨드 플러그인입니다.

## 설치

```bash
/plugin add m16khb/claude-integration
```

## 커맨드 목록

| 커맨드 | 설명 | 사용법 |
|--------|------|--------|
| `/git-commit` | 스마트 Git 커밋 | `/git-commit` 또는 `/git-commit push` |
| `/claude-md` | CLAUDE.md 관리 | `/claude-md create\|analyze\|structure` |
| `/continue-task` | Opus로 복잡한 작업 실행 | `/continue-task <task>` |
| `/inject-context` | 대용량 파일 컨텍스트 주입 | `/inject-context <file>` |

## 커맨드 상세

### /git-commit

Git 커밋을 스마트하게 생성합니다.

**특징**:
- Staged/Unstaged 변경사항 자동 분석
- Conventional Commits 형식 적용
- 민감 파일 자동 감지 및 경고
- main/master 브랜치 푸시 확인

**사용법**:
```bash
# 커밋만
/git-commit

# 커밋 + 푸시
/git-commit push
```

### /claude-md

프로젝트의 CLAUDE.md 파일을 생성, 분석, 구조화합니다.

**사용법**:
```bash
# 새 CLAUDE.md 생성
/claude-md create

# 기존 CLAUDE.md 분석
/claude-md analyze

# 계층적 구조로 분리
/claude-md structure
```

### /continue-task

Opus 모델을 활용하여 복잡한 멀티스텝 작업을 실행합니다.

**사용법**:
```bash
/continue-task 인증 시스템 구현
```

### /inject-context

대용량 파일을 지능적으로 분할 로드하여 컨텍스트에 주입합니다.

**사용법**:
```bash
/inject-context src/large-file.ts
```

## 라이선스

MIT
