# Commands CLAUDE.md

## 디렉토리 개요

Claude Code 플러그인의 슬래시 커맨드 정의 파일들입니다.

## 파일 구조

| 파일 | 커맨드 | 설명 |
|------|--------|------|
| `git-commit.md` | `/git-commit` | 스마트 Git 커밋 |
| `claude-md.md` | `/claude-md` | CLAUDE.md 관리 도구 |
| `continue-task.md` | `/continue-task` | Opus 모델 작업 위임 |
| `inject-context.md` | `/inject-context` | 대용량 파일 청크 로드 |
| `optimize-command.md` | `/optimize-command` | 커맨드 프롬프트 최적화 |

## 커맨드 파일 작성 형식

### 필수 Frontmatter

```yaml
---
name: command-name           # 커맨드 식별자
description: "설명"          # 짧은 설명
argument-hint: <arg>         # 인자 힌트
allowed-tools:               # 허용 도구 목록
  - Read
  - Write
model: opus|haiku           # 선택적, 생략시 기본 모델
---
```

### 본문 구조

1. **제목**: 커맨드 이름 및 버전
2. **입력**: `$ARGUMENTS` 참조
3. **단계별 로직**: 의사코드로 작성
4. **TUI 선택**: AskUserQuestion 활용
5. **후속 작업**: 완료 후 다음 단계 안내

## 허용 도구 패턴

```yaml
# 모든 Bash 허용
allowed-tools:
  - Bash

# 특정 명령만 허용
allowed-tools:
  - Bash(git *)
  - Bash(npm *)

# 복합 도구
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
```

## 모델 선택 가이드

| 모델 | 용도 | 예시 커맨드 |
|------|------|------------|
| haiku | 빠른 파싱, 단순 작업 | inject-context |
| (기본) | 일반 작업 | git-commit, claude-md |
| opus | 복잡한 추론, 코드 생성 | continue-task |

## 주의사항

- `$ARGUMENTS`는 사용자 입력 그대로 전달됨
- 민감 정보 처리 로직 필수 (예: .env 파일 경고)
- 긴 작업은 TodoWrite로 진행 상황 표시
- 작업 완료 후 AskUserQuestion으로 후속 작업 선택 제공
