# CLAUDE.md

## 프로젝트 개요

**claude-integration**은 Claude Code 생산성 향상을 위한 스마트 커맨드 및 에이전트 마켓플레이스입니다.

## 핵심 가치

> "최소 기능별로 잘 나누어서 저장하고 사용 할 때는 반드시 필요한 도구를 잘 호출해서 사용하자"

- **정확한 호출**: 사용자 의도에 맞는 전문가 에이전트 자동 선택
- **정확한 동작**: 각 에이전트가 자신의 전문 영역에서 완벽한 결과물 생성
- **정확한 의도 파악**: 키워드 기반 라우팅으로 적절한 도구 활성화

## 필수 규칙 (헌법)

> **⚠️ CRITICAL**: 아래 규칙은 Claude가 **반드시** 준수해야 하는 최우선 규칙입니다. 모든 작업 수행 전 헌법 준수 여부를 확인하세요.

| 규칙 | 설명 |
|------|------|
| **플러그인 버전 관리** | Semantic Versioning (MAJOR.MINOR.PATCH) 준수 |
| **파일 레퍼런싱 @ 문법** | 소스코드 참조 시 `@경로` 형식 사용 |
| **CLAUDE.md 라인 제한** | Soft: 300/200/150, Hard: 500/350/250 |
| **agent-docs 동적 로딩** | agent-docs는 @ 참조 금지, 필요 시 Read 도구로 로드 |

> 상세 내용: [constitution.md](agent-docs/constitution.md)

## 아키텍처

```
MARKETPLACE ARCHITECTURE:
┌─────────────────────────────────────────────────────────┐
│                   claude-integration                     │
│              (Claude Code 생산성 마켓플레이스)           │
└───────────────────────────┬─────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
  ┌───────────┐      ┌───────────┐      ┌───────────┐
  │Development│      │  Quality  │      │Productivity│
  │ Plugins   │      │  Plugins  │      │  Plugins   │
  └─────┬─────┘      └─────┬─────┘      └─────┬─────┘
        │                  │                   │
        ▼                  ▼                   ▼
   nestjs-backend    code-quality       context-management
   git-workflows     full-stack-orch    automation-tools
                     doc-generation
```

이 마켓플레이스는 **단일 책임 원칙**을 따릅니다:

- **7개 전문화된 플러그인** (카테고리별 분리)
- **11개 전문 에이전트** (2개 오케스트레이터 + 9개 전문가)
- **11개 슬래시 커맨드** (플러그인별 네임스페이스)
- **9개 에이전트 스킬** (라우팅 시스템 포함)

## 기술 스택

- **언어**: Markdown (커맨드/스킬/에이전트 정의)
- **플랫폼**: Claude Code CLI
- **스키마**: Anthropic 2025 Skills/Commands/Agents Schema
- **패턴**: Orchestrator-Worker, Progressive Disclosure, Agent Routing
- **테스트**: Suites 3.x (구 Automock)

## 플러그인 목록

| 플러그인 | 카테고리 | 주요 기능 |
|---------|---------|----------|
| [nestjs-backend](plugins/nestjs-backend/CLAUDE.md) | development | NestJS 생태계 전문가 7명 |
| [code-quality](plugins/code-quality/CLAUDE.md) | quality | 코드 리뷰, 테스트 자동화 |
| [full-stack-orchestration](plugins/full-stack-orchestration/CLAUDE.md) | workflows | 개발 워크플로우 오케스트레이션 |
| [documentation-generation](plugins/documentation-generation/CLAUDE.md) | documentation | 계층적 문서 자동 생성 |
| [git-workflows](plugins/git-workflows/CLAUDE.md) | development | Git Flow 기반 스마트 커밋 |
| [context-management](plugins/context-management/CLAUDE.md) | productivity | 컨텍스트 분석, 대용량 처리 |
| [automation-tools](plugins/automation-tools/CLAUDE.md) | productivity | 컴포넌트 자동 생성, 동기화 |

## 주요 커맨드

| 커맨드 | 플러그인 | 설명 |
|--------|---------|------|
| `/full-stack-orchestration:dev-flow` | full-stack-orchestration | 리뷰 → 테스트 → 커밋 워크플로우 |
| `/code-quality:review` | code-quality | 코드 리뷰 실행 |
| `/git-workflows:git-commit` | git-workflows | Git Flow 기반 스마트 커밋 |
| `/context-management:continue-context` | context-management | 컨텍스트 분석 및 작업 추천 |
| `/context-management:inject-context` | context-management | 대용량 파일 구조 인식 청킹 |
| `/automation-tools:factory` | automation-tools | Agent, Skill, Command 생성기 |
| `/automation-tools:optimize` | automation-tools | 에이전트/커맨드/프롬프트 최적화 |
| `/automation-tools:partner` | automation-tools | AI 파트너 관리 |
| `/automation-tools:setup-statusline` | automation-tools | YAML 기반 status line 구성 |
| `/automation-tools:claude-sync` | automation-tools | CLAUDE.md 자동 동기화 |
| `/automation-tools:constitution` | automation-tools | 프로젝트 헌법 관리 |

## 에이전트 계층

```
AGENT HIERARCHY:
┌─────────────────────────────────────────────────────────┐
│            ORCHESTRATORS (2개)                          │
│  full-stack-orchestrator ← 최상위 워크플로우           │
│  nestjs-fastify-expert   ← 백엔드 전문가 조율          │
└───────────────────────────┬─────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
  ┌───────────┐      ┌───────────┐      ┌───────────┐
  │ Backend   │      │  Quality  │      │   Docs    │
  │ Experts   │      │  Experts  │      │  Expert   │
  │  (6개)    │      │   (2개)   │      │   (1개)   │
  └───────────┘      └───────────┘      └───────────┘
       │                  │                   │
       ▼                  ▼                   ▼
  typeorm-expert    code-reviewer      document-builder
  redis-cache       test-automator
  bullmq-queue
  cqrs-expert
  microservices
  suites-testing
```

| 에이전트 | 역할 | 모델 |
|---------|------|------|
| full-stack-orchestrator | 워크플로우 조율 | Opus |
| nestjs-fastify-expert | 백엔드 조율 | Opus |
| typeorm-expert | DB/Entity | Opus |
| redis-cache-expert | 캐싱 | Opus |
| bullmq-queue-expert | Job Queue | Opus |
| cqrs-expert | CQRS 패턴 | Opus |
| microservices-expert | MSA | Opus |
| suites-testing-expert | 테스트 | Opus |
| code-reviewer | 코드 리뷰 | Sonnet |
| test-automator | 테스트 자동화 | Sonnet |
| document-builder | 문서 생성 | Sonnet |

## Agent Routing System

```
ROUTING WORKFLOW:
User Request → Keyword Extraction → Score Calculation → Expert Selection
     │                │                    │                 │
     └─ "Redis 캐시"  └─ [redis, 캐시]    └─ redis=3+2     └─ redis-cache-expert
```

자동 키워드 분석으로 전문가 선택:

| 요청 | 키워드 | 결과 |
|------|--------|------|
| "Redis 캐시" | redis, 캐시 | SINGLE: redis-cache-expert |
| "엔티티 + 테스트" | typeorm, 테스트 | SEQUENTIAL: typeorm → testing |
| "캐시 + 큐" | redis, bullmq | PARALLEL: [redis, bullmq] |

**점수 계산**: Primary(3점) + Secondary(2점) + Context(1점)

routing-table.json에서 키워드-에이전트 매핑 관리

## 설치

```bash
# 마켓플레이스 등록
/plugin marketplace add m16khb/claude-integration

# 전체 플러그인 설치
/plugin install claude-integration

# 또는 개별 플러그인 설치
/plugin install nestjs-backend
/plugin install code-quality
/plugin install automation-tools
```

## MCP 서버 (별도 설치 필요)

이 프로젝트는 다음 MCP 서버들과 연동됩니다:

| MCP 서버 | 설명 | 설치 명령어 |
|----------|------|-----------|
| `playwright` | 브라우저 자동화 | `npx -y @playwright/mcp@latest` |
| `context7` | 최신 문서 주입 | `npx -y @upstash/context7-mcp@latest` |
| `sequential-thinking` | 단계별 사고 | `npx -y @modelcontextprotocol/server-sequential-thinking` |
| `chrome-devtools` | 크롬 개발자 도구 | `npx -y chrome-devtools-mcp@latest` |

### MCP 서버 활용 예시

```bash
# Context7로 최신 문서 주입
"use context7 TypeORM migrations 사용법"

# Sequential Thinking으로 복잡한 분석
→ 자동 활성화 (복잡한 요청 감지 시)

# Playwright로 브라우저 자동화
"playwright로 example.com 열고 스크린샷 찍어줘"
```

## 상세 문서 (필요 시 Read 도구로 로드)

### 문서화 가이드
| 문서 | 설명 |
|------|------|
| `plugins/documentation-generation/agent-docs/template-library.md` | 문서 템플릿 카탈로그 |
| `plugins/documentation-generation/agent-docs/code-analysis.md` | 코드 분석 및 AST 파싱 |
| `plugins/documentation-generation/agent-docs/progressive-disclosure.md` | 계층적 문서 구조 |

### 프로젝트 가이드
| 문서 | 설명 |
|------|------|
| `agent-docs/constitution.md` | 프로젝트 헌법 (필수 규칙) |
| `agent-docs/architecture.md` | 아키텍처 설계 원칙 |
| `agent-docs/guides/usage.md` | 사용 가이드 |
| `agent-docs/guides/claude-md-guide.md` | CLAUDE.md 사용 가이드 (공식 블로그 기반) |

### 레퍼런스
| 문서 | 설명 |
|------|------|
| `agent-docs/references/agents.md` | 에이전트 레퍼런스 |
| `agent-docs/references/plugins.md` | 플러그인 레퍼런스 |
| `agent-docs/references/agent-skills.md` | 에이전트 스킬 레퍼런스 |

## 빠른 시작

### 기본 워크플로우

```bash
# 1. 코드 리뷰 → 테스트 → 커밋 (전체 파이프라인)
/full-stack-orchestration:dev-flow

# 2. 개별 단계 실행
/code-quality:review                    # 코드 리뷰만
/git-workflows:git-commit push          # 커밋 + 푸시
```

### 에이전트 자동 선택

```bash
# 자연어로 요청하면 자동으로 적절한 에이전트 선택
"Redis 캐시 설정해줘"                    # → redis-cache-expert
"TypeORM으로 User 엔티티 만들어줘"      # → typeorm-expert
"BullMQ로 이메일 큐 설정하고 테스트"    # → bullmq → suites-testing
```

### 컨텍스트 관리

```bash
# 대용량 파일 로딩
/context-management:inject-context large-file.ts

# 이전 작업 이어서 진행
/context-management:continue-context

# 문서 자동 동기화
/automation-tools:claude-sync
```

### 컴포넌트 생성

```bash
# 새 에이전트 생성
/automation-tools:factory agent "GraphQL 전문가"

# 에이전트 최적화
/automation-tools:optimize agent my-agent.md
```

## 프로젝트 구조 상세

```
claude-integration/
├─ CLAUDE.md                      # 본 문서 (Root)
├─ .claude-plugin/
│   ├─ marketplace.json           # 플러그인 레지스트리
│   └─ routing-table.json         # 에이전트 라우팅
├─ plugins/                       # 7개 플러그인
│   ├─ nestjs-backend/            # NestJS 백엔드 전문가
│   │   ├─ CLAUDE.md
│   │   ├─ agents/                # 7개 에이전트
│   │   └─ agent-docs/
│   ├─ code-quality/              # 코드 품질
│   ├─ full-stack-orchestration/  # 워크플로우
│   ├─ documentation-generation/  # 문서 생성
│   ├─ git-workflows/             # Git 워크플로우
│   ├─ context-management/        # 컨텍스트 관리
│   └─ automation-tools/          # 자동화 도구
└─ agent-docs/                    # 상세 문서
    ├─ constitution.md            # 프로젝트 헌법
    ├─ architecture.md
    ├─ guides/
    └─ references/
```

## Best Practices

```
DO ✅:
├─ 자연어로 에이전트 호출 (자동 라우팅)
├─ /dev-flow로 전체 파이프라인 실행
├─ /claude-sync로 문서 최신 상태 유지
├─ 소스코드 참조 시 @ 문법 사용
├─ agent-docs 참조 시 일반 링크/코드 스팬 사용
└─ 헌법 규칙 준수

DON'T ❌:
├─ CLAUDE.md에서 agent-docs @ 참조 (토큰 낭비)
├─ 수동으로 routing-table.json 편집
├─ Hard Limit 초과 문서 작성
├─ 검증 없이 main 직접 푸시
└─ 테스트 없이 배포
```