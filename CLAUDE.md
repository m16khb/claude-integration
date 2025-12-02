# CLAUDE.md

## 프로젝트 개요

**claude-integration**은 Claude Code 생산성 향상을 위한 스마트 커맨드 및 스킬 플러그인입니다.

## 기술 스택

- **언어**: Markdown (커맨드/스킬 정의)
- **플랫폼**: Claude Code CLI
- **스키마**: Anthropic 2025 Skills/Commands Schema
- **패턴**: Orchestrator-Worker, Progressive Disclosure

## 프로젝트 구조

```
claude-integration/
├── commands/           # 슬래시 커맨드 정의
├── agents/             # 전문 에이전트 정의
│   ├── backend/        # NestJS, TypeORM, Redis 등
│   ├── frontend/       # (예정)
│   └── infrastructure/ # (예정)
├── templates/          # 생성 템플릿
└── agent_docs/         # 상세 문서 (Progressive Disclosure)
```

## 주요 커맨드

| 커맨드        | 설명                             |
| ------------- | -------------------------------- |
| `/git-commit` | Conventional Commits 커밋        |
| `/claude-sync`| 코드베이스 변경 감지 및 MD 동기화 |
| `/factory`    | 컴포넌트 생성기                  |

## 설치

```bash
/plugin marketplace add m16khb/claude-integration
/plugin install claude-integration
```

## 상세 문서

- [agent_docs/commands.md](agent_docs/commands.md) - 전체 커맨드 목록
- [agent_docs/agents.md](agent_docs/agents.md) - 전문 에이전트 목록
- [agent_docs/references.md](agent_docs/references.md) - 참고 프레임워크
- [agent_docs/command-writing.md](agent_docs/command-writing.md) - 커맨드 작성 가이드
- [agent_docs/development.md](agent_docs/development.md) - 개발 가이드
