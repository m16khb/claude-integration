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
├── CLAUDE.md                    # 루트 오케스트레이터 (커맨드 가이드 포함)
├── agent-docs/                  # 루트 공통 문서
├── commands/                    # 슬래시 커맨드 정의 (*.md = 커맨드로 자동 인식)
├── agents/                      # 전문 에이전트 정의
│   ├── CLAUDE.md
│   ├── backend/                 # NestJS, TypeORM, Redis 등
│   │   └── CLAUDE.md
│   └── document/                # 문서화 에이전트
│       └── CLAUDE.md
└── templates/                   # 생성 템플릿
    └── CLAUDE.md
```

## 주요 커맨드

| 커맨드 | 설명 | 사용 예 |
|--------|------|---------|
| `/git-commit` | Conventional Commits 커밋 | `/git-commit push` |
| `/claude-sync` | 계층적 CLAUDE.md 동기화 | `/claude-sync` |
| `/factory` | Agent, Skill, Command 생성기 | `/factory agent user-auth` |
| `/continue-context` | 컨텍스트 분석 후 작업 추천 | `/continue-context` |
| `/inject-context` | 대용량 파일 청킹 및 주입 | `/inject-context ./large-file.ts` |
| `/setup-statusline` | YAML 기반 status line 설정 | `/setup-statusline` |
| `/optimize-command` | 커맨드 최적화 | `/optimize-command <path>` |
| `/optimize-agents` | 에이전트 최적화 | `/optimize-agents <path>` |

### 커맨드 작성 가이드

> **Note**: `commands/` 디렉토리에 CLAUDE.md를 두지 마세요. Claude Code는 해당 디렉토리의 모든 .md 파일을 슬래시 커맨드로 자동 인식합니다.

#### Frontmatter 구조

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

#### 필수 요소

- **$ARGUMENTS**: 사용자 입력 인자 참조
- **TUI 패턴**: `AskUserQuestion`으로 사용자 선택 제공
- **후속 작업**: 완료 후 다음 단계 안내

#### 주의사항

- 민감 정보(API 키, 패스워드) 노출 금지
- Bash 도구 사용시 패턴 명시: `Bash(git:*, npm:*)`
- 컨텍스트 윈도우 고려하여 청크 크기 조절

## 설치

```bash
/plugin marketplace add m16khb/claude-integration
/plugin install claude-integration
```

## MCP 서버 (내장)

플러그인 활성화 시 자동으로 로드되는 MCP 서버:

| MCP 서버 | 설명 | 사용 예 |
|----------|------|---------|
| `playwright` | 브라우저 자동화 | "playwright로 example.com 열어줘" |
| `context7` | 최신 문서 주입 | "use context7 React 19 새 기능 알려줘" |
| `sequential-thinking` | 단계별 사고 | 복잡한 문제 분석 시 자동 활성화 |
| `chrome-devtools` | 크롬 개발자 도구 | "현재 열린 크롬 탭 분석해줘" |

### 요구사항

- **Node.js 18+** (context7, sequential-thinking)
- **Node.js 22+** (chrome-devtools)
- **Chrome 브라우저** (chrome-devtools 사용 시)

### Windows 사용자 참고

Windows에서 MCP 서버가 동작하지 않으면:

```bash
# npx 대신 전역 설치 후 사용
npm install -g @playwright/mcp
npm install -g @upstash/context7-mcp
npm install -g @modelcontextprotocol/server-sequential-thinking
npm install -g chrome-devtools-mcp
```

### MCP 상태 확인

```bash
claude mcp list
```

## 상세 문서

- [agent-docs/commands.md](agent-docs/commands.md) - 전체 커맨드 목록
- [agent-docs/agents.md](agent-docs/agents.md) - 전문 에이전트 목록
- [agent-docs/references.md](agent-docs/references.md) - 참고 프레임워크
- [agent-docs/command-writing.md](agent-docs/command-writing.md) - 커맨드 작성 가이드
- [agent-docs/development.md](agent-docs/development.md) - 개발 가이드

## 모듈별 컨텍스트

| 모듈 | CLAUDE.md | 설명 |
|------|-----------|------|
| [agents/](agents/CLAUDE.md) | 전문 에이전트 | 오케스트레이터 및 전문가 에이전트 |
| [templates/](templates/CLAUDE.md) | 템플릿 | 설정 파일 및 스크립트 템플릿 |

> **Note**: `commands/` 디렉토리에는 CLAUDE.md를 두지 않습니다. Claude Code가 모든 .md 파일을 슬래시 커맨드로 자동 인식하기 때문입니다. 커맨드 작성 가이드는 이 문서의 "커맨드 작성 가이드" 섹션을 참조하세요.
