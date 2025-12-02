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
├── .claude/commands/        # 슬래시 커맨드 정의 파일
├── agent_docs/              # 상세 개발 문서
└── README.md
```

## 커맨드 목록

| 커맨드 | 설명 | 모델 |
|--------|------|------|
| `/git-commit [push]` | Conventional Commits 형식 커밋 | default |
| `/claude-md [action]` | CLAUDE.md 생성/분석/구조화 | default |
| `/continue-task <task>` | 복잡한 작업을 Opus로 실행 | opus |
| `/inject-context <file>` | 대용량 파일 청크 로드 | haiku |

## 상세 문서

- [agent_docs/command-writing.md](agent_docs/command-writing.md) - 커맨드 작성 가이드
- [agent_docs/development.md](agent_docs/development.md) - 개발 가이드
- [.claude/commands/CLAUDE.md](.claude/commands/CLAUDE.md) - 커맨드 상세 가이드
