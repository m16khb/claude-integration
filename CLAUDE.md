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
└── agent-docs/         # 상세 문서 (Progressive Disclosure)
```

## 주요 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/git-commit` | Conventional Commits 커밋 |
| `/claude-sync` | 코드베이스 변경 감지 및 MD 동기화 |
| `/factory` | 컴포넌트 생성기 |
| `/continue-context` | 현재 컨텍스트 분석 후 다음 작업 추천 |
| `/inject-context` | 대용량 파일 구조 인식 청킹 및 컨텍스트 주입 |
| `/setup-statusline` | YAML 설정 기반 status line 환경 구성 |

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
| [commands/](commands/CLAUDE.md) | 슬래시 커맨드 | 커맨드 정의 및 작성 가이드 |
| [agents/](agents/CLAUDE.md) | 전문 에이전트 | 오케스트레이터 및 전문가 에이전트 |
| [templates/](templates/CLAUDE.md) | 템플릿 | 설정 파일 및 스크립트 템플릿 |
