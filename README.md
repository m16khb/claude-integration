# Claude Integration

Claude Code 생산성 향상을 위한 스마트 커맨드 및 에이전트 마켓플레이스입니다.

## 아키텍처

이 마켓플레이스는 **단일 책임 원칙**을 중심으로 설계되었습니다:

- **5개 전문화된 플러그인**
- **8개 전문 에이전트 + 1개 오케스트레이터**
- **7개 슬래시 커맨드**
- **1개 에이전트 스킬**

각 플러그인은 필요한 컴포넌트만 컨텍스트에 로드하여 **토큰 효율성**을 극대화합니다.

## 설치

### 마켓플레이스 추가 후 설치 (권장)

```bash
# 1. 마켓플레이스 추가
/plugin marketplace add m16khb/claude-integration

# 2. 전체 플러그인 설치
/plugin install claude-integration

# 또는 개별 플러그인 설치
/plugin install backend-development
/plugin install documentation-generation
/plugin install git-workflows
/plugin install context-management
/plugin install automation-tools
```

## 플러그인 목록

| 플러그인 | 카테고리 | 설명 |
|---------|---------|------|
| `backend-development` | development | NestJS + Fastify 백엔드 개발 에이전트 |
| `documentation-generation` | documentation | CLAUDE.md 및 agent-docs 문서 생성 |
| `git-workflows` | development | Git Flow 기반 스마트 커밋 |
| `context-management` | productivity | 대용량 파일 청킹 및 컨텍스트 관리 |
| `automation-tools` | productivity | Agent, Skill, Command 자동 생성 |

## 커맨드 목록

| 커맨드 | 플러그인 | 설명 |
|--------|---------|------|
| `/git-commit` | git-workflows | Git Flow 기반 스마트 커밋 |
| `/continue-context` | context-management | 컨텍스트 분석 및 작업 추천 |
| `/inject-context` | context-management | 대용량 파일 구조 인식 청킹 |
| `/factory` | automation-tools | Agent, Skill, Command 생성기 |
| `/setup-statusline` | automation-tools | YAML 기반 status line 구성 |
| `/claude-sync` | automation-tools | CLAUDE.md 자동 동기화 |

## 에이전트 목록

### Orchestrator (1개)

| 에이전트 | 모델 | 설명 |
|---------|------|------|
| `nestjs-fastify-expert` | Opus | NestJS + Fastify 오케스트레이터 |

### Experts (8개)

| 에이전트 | 모델 | 설명 |
|---------|------|------|
| `typeorm-expert` | Sonnet | TypeORM 엔티티, 마이그레이션, 트랜잭션 |
| `redis-cache-expert` | Sonnet | Redis 캐싱, @nestjs/cache-manager |
| `bullmq-queue-expert` | Sonnet | BullMQ 작업 큐 |
| `cqrs-expert` | Sonnet | CQRS 패턴, Command/Query/Event/Saga |
| `microservices-expert` | Sonnet | 마이크로서비스, RabbitMQ, gRPC |
| `suites-testing-expert` | Sonnet | Suites(Automock), Jest, E2E |
| `document-builder` | Sonnet | 계층적 CLAUDE.md 및 agent-docs 생성 |

## 프로젝트 구조

```
claude-integration/
├── .claude-plugin/
│   └── marketplace.json       # 플러그인 레지스트리
├── plugins/                   # 5개 전문화된 플러그인
│   ├── backend-development/   # NestJS 생태계 에이전트
│   │   ├── agents/
│   │   ├── commands/
│   │   └── skills/
│   ├── documentation-generation/
│   ├── git-workflows/
│   ├── context-management/
│   └── automation-tools/
├── agent-docs/                # 상세 문서
│   ├── constitution.md        # 프로젝트 헌법
│   ├── architecture.md        # 아키텍처 설계 원칙
│   ├── references/            # 레퍼런스
│   │   ├── agents.md
│   │   ├── plugins.md
│   │   └── agent-skills.md
│   └── guides/
│       └── usage.md           # 사용 가이드
├── CLAUDE.md                  # 프로젝트 루트 설정
└── README.md
```

## MCP 서버 (내장)

플러그인 활성화 시 자동 로드:

| MCP 서버 | 설명 | 요구사항 |
|----------|------|---------|
| `playwright` | 브라우저 자동화 | Node.js 18+ |
| `context7` | 최신 문서 주입 | Node.js 18+ |
| `sequential-thinking` | 단계별 사고 | Node.js 18+ |
| `chrome-devtools` | 크롬 개발자 도구 | Node.js 22+, Chrome |

```bash
# MCP 상태 확인
claude mcp list
```

## 상세 문서

- [Constitution](agent-docs/constitution.md) - 프로젝트 헌법 (필수 규칙)
- [Architecture](agent-docs/architecture.md) - 아키텍처 설계 원칙
- [Agents](agent-docs/references/agents.md) - 에이전트 레퍼런스
- [Plugins](agent-docs/references/plugins.md) - 플러그인 레퍼런스
- [Usage](agent-docs/guides/usage.md) - 사용 가이드
- [Agent Skills](agent-docs/references/agent-skills.md) - 스킬 개발 가이드

## 빠른 시작

### NestJS 백엔드 개발

```typescript
// Orchestrator를 통해 자동 위임
Task(
  subagent_type="nestjs-fastify-expert",
  prompt="Redis 캐시 설정하고 BullMQ 큐도 추가해줘"
)
```

### 스마트 Git 커밋

```bash
/git-commit push
```

### 대용량 파일 처리

```bash
/inject-context ./large-file.ts "리팩토링해줘"
```

## 기여

이슈와 PR을 환영합니다!

## 라이선스

MIT License
