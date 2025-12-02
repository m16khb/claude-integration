# 커맨드 상세

## 커맨드 목록

| 커맨드 | 설명 | 모델 |
|--------|------|------|
| `/git-commit [push]` | Conventional Commits 형식 커밋 | haiku |
| `/claude-sync` | 코드베이스 변경 감지 및 CLAUDE.md 자동 동기화 | opus |
| `/continue-context [focus]` | 현재 컨텍스트 분석 및 다음 작업 추천 | default |
| `/inject-context <file>` | 대용량 파일 청크 로드 | haiku |
| `/setup-statusline [config]` | YAML 설정 기반 status line 환경 구성 | opus |
| `/factory [type] [name]` | Agent, Skill, Command 컴포넌트 생성기 | sonnet |

## 커맨드 작성 3원칙

1. **목적 정확성**: MISSION을 명확히 정의, 모든 분기 케이스 명시
2. **영어 로직**: 내부 로직은 영어로 (토큰 효율성)
3. **한글 TUI**: 사용자 인터페이스는 한글로 (UX)

## 사용 예시

```bash
# Git 커밋 (자동 메시지 생성)
/git-commit

# 커밋 후 즉시 푸시
/git-commit push

# CLAUDE.md 자동 동기화 (스캔 → 비교 → 업데이트)
/claude-sync

# 컴포넌트 생성
/factory agent my-agent
/factory skill my-skill
/factory command my-command
```

## 상세 가이드

자세한 커맨드 작성 방법은 [command-writing.md](command-writing.md) 참조
