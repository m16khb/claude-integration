# CLAUDE.md

## 프로젝트 개요

**claude-integration**은 Claude Code 생산성 향상을 위한 스마트 커맨드 플러그인입니다.

## 기술 스택

- **언어**: Markdown (커맨드 정의)
- **플랫폼**: Claude Code CLI
- **구성**: plugin.json + .claude/commands/*.md

## 프로젝트 구조

```
claude-integration/
├── plugin.json              # 플러그인 메타데이터 및 커맨드 등록
├── .claude/
│   └── commands/            # 슬래시 커맨드 정의 파일
│       ├── git-commit.md    # /git-commit - 스마트 커밋
│       ├── claude-md.md     # /claude-md - CLAUDE.md 관리
│       ├── continue-task.md # /continue-task - Opus 작업 위임
│       └── inject-context.md # /inject-context - 대용량 파일 로드
└── README.md
```

## 커맨드 목록

| 커맨드 | 설명 | 모델 |
|--------|------|------|
| `/git-commit [push]` | Conventional Commits 형식 커밋 | default |
| `/claude-md [action]` | CLAUDE.md 생성/분석/구조화 | default |
| `/continue-task <task>` | 복잡한 작업을 Opus로 실행 | opus |
| `/inject-context <file>` | 대용량 파일 청크 로드 | haiku |

## 커맨드 작성 규칙

### Frontmatter 구조
```yaml
---
name: command-name
description: "커맨드 설명"
argument-hint: <required> [optional]
allowed-tools:
  - Read
  - Write
  - Bash
model: opus|haiku  # 생략시 기본 모델
---
```

### 커맨드 본문 작성
- **$ARGUMENTS**: 사용자 입력 인자 참조
- **TUI 패턴**: AskUserQuestion으로 사용자 선택 제공
- **후속 작업**: 작업 완료 후 다음 단계 선택 TUI 필수

## 개발 가이드

### 새 커맨드 추가
1. `.claude/commands/` 디렉토리에 `.md` 파일 생성
2. Frontmatter에 메타데이터 정의
3. `plugin.json`의 commands 섹션에 등록
4. 테스트: `/plugin reload` → `/새커맨드`

### 모델 선택 기준
- **haiku**: 빠른 파싱, 단순 작업 (inject-context)
- **default**: 일반 작업 (git-commit, claude-md)
- **opus**: 복잡한 추론, 코드 생성 (continue-task)

## 주의사항

- 커맨드에서 민감 정보(API 키, 패스워드) 노출 금지
- Bash 도구 사용시 allowed-tools에 패턴 명시 (예: `Bash(git *)`)
- 사용자 컨텍스트 윈도우 고려하여 청크 크기 조절

## 관련 문서

- [.claude/commands/CLAUDE.md](.claude/commands/CLAUDE.md) - 커맨드 작성 상세 가이드
