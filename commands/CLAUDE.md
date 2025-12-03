# commands/ CLAUDE.md

## 모듈 개요

**슬래시 커맨드 정의 모듈**입니다. Claude Code CLI에서 `/` 접두사로 실행되는 커맨드를 정의합니다.

## 파일 구조

```
commands/
├── CLAUDE.md              # 이 파일
├── git-commit.md          # Git 커밋 자동화
├── claude-sync.md         # CLAUDE.md 동기화 (계층적 오케스트레이션)
├── factory.md             # 컴포넌트 생성기
├── continue-context.md    # 컨텍스트 분석 및 작업 추천
├── inject-context.md      # 대용량 파일 청킹 및 주입
└── setup-statusline.md    # Status line 환경 구성
```

## 포함된 커맨드

| 커맨드 | 설명 | 사용 예 |
|--------|------|---------|
| `/git-commit` | Conventional Commits 기반 스마트 커밋 | `/git-commit` |
| `/claude-sync` | 계층적 CLAUDE.md 동기화 | `/claude-sync` |
| `/factory` | Agent, Skill, Command 생성기 | `/factory agent user-auth` |
| `/continue-context` | 현재 컨텍스트 분석 후 다음 작업 추천 | `/continue-context` |
| `/inject-context` | 대용량 파일 구조 인식 청킹 | `/inject-context ./large-file.ts` |
| `/setup-statusline` | YAML 기반 status line 설정 | `/setup-statusline` |

## 커맨드 작성 가이드

### Frontmatter 구조

```yaml
---
name: command-name
description: '커맨드 설명'
argument-hint: <required> [optional]
allowed-tools:
  - Read
  - Write
  - Bash
model: opus|haiku  # 생략시 기본 모델
---
```

### 필수 요소

- **$ARGUMENTS**: 사용자 입력 인자 참조
- **TUI 패턴**: `AskUserQuestion`으로 사용자 선택 제공
- **후속 작업**: 완료 후 다음 단계 안내

### 주의사항

- 민감 정보(API 키, 패스워드) 노출 금지
- Bash 도구 사용시 패턴 명시: `Bash(git:*, npm:*)`
- 컨텍스트 윈도우 고려하여 청크 크기 조절

## 상세 문서

- [agent-docs/command-writing.md](../agent-docs/command-writing.md) - 커맨드 작성 상세 가이드
- [agent-docs/commands.md](../agent-docs/commands.md) - 전체 커맨드 목록

## 참조

- [Root CLAUDE.md](../CLAUDE.md)
