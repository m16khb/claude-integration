# CLAUDE.md

## 프로젝트 개요

**claude-integration**은 Claude Code 생산성 향상을 위한 스마트 커맨드 및 에이전트 마켓플레이스입니다.

## 핵심 가치

> "최소 기능별로 잘 나누어서 저장하고 사용 할 때는 반드시 필요한 도구를 잘 호출해서 사용하자"

- **정확한 호출**: 사용자 의도에 맞는 전문가 에이전트 자동 선택
- **정확한 동작**: 각 에이전트가 자신의 전문 영역에서 완벽한 결과물 생성
- **정확한 의도 파악**: 키워드 기반 라우팅으로 적절한 도구 활성화

## 아키텍처

이 마켓플레이스는 **단일 책임 원칙**을 따릅니다:

- **7개 전문화된 플러그인**
- **12개 전문 에이전트** (2개 오케스트레이터 + 10개 전문가)
- **9개 슬래시 커맨드**
- **4개 에이전트 스킬** (라우팅 시스템 포함)

## 기술 스택

- **언어**: Markdown (커맨드/스킬/에이전트 정의)
- **플랫폼**: Claude Code CLI
- **스키마**: Anthropic 2025 Skills/Commands/Agents Schema
- **패턴**: Orchestrator-Worker, Progressive Disclosure, Agent Routing
- **테스트**: Suites 3.x (구 Automock)

## 프로젝트 구조

```
claude-integration/
├── .claude-plugin/
│   ├── marketplace.json          # 플러그인 레지스트리
│   └── routing-table.json        # 컴포넌트 라우팅 테이블
├── plugins/                      # 7개 전문화된 플러그인
│   ├── nestjs-backend/           # NestJS 생태계 에이전트 + 라우팅
│   │   ├── agents/               # 7개 백엔드 전문가
│   │   └── skills/agent-routing/ # 에이전트 라우팅 시스템
│   ├── code-quality/             # 코드 품질 도구
│   │   ├── agents/               # code-reviewer, test-automator
│   │   ├── commands/             # /review
│   │   └── skills/testing-patterns/  # Suites 3.x 테스트 패턴
│   ├── full-stack-orchestration/ # 워크플로우 오케스트레이션
│   │   ├── agents/               # full-stack-orchestrator
│   │   ├── commands/             # /dev-flow
│   │   └── skills/ci-cd-patterns/
│   ├── documentation-generation/ # 문서 자동화
│   ├── git-workflows/            # Git 워크플로우
│   ├── context-management/       # 컨텍스트 관리
│   └── automation-tools/         # 자동화 도구
├── docs/                         # 종합 문서
└── CLAUDE.md
```

## 플러그인 목록

| 플러그인 | 카테고리 | 컴포넌트 |
|---------|---------|---------|
| `nestjs-backend` | development | 에이전트 7개, 스킬 1개 |
| `code-quality` | quality | 에이전트 2개, 커맨드 1개, 스킬 1개 |
| `full-stack-orchestration` | workflows | 에이전트 1개, 커맨드 1개, 스킬 1개 |
| `documentation-generation` | documentation | 에이전트 1개, 스킬 1개 |
| `git-workflows` | development | 커맨드 1개 |
| `context-management` | productivity | 커맨드 2개 |
| `automation-tools` | productivity | 커맨드 3개 |

## 주요 커맨드

| 커맨드 | 플러그인 | 설명 |
|--------|---------|------|
| `/dev-flow` | full-stack-orchestration | 리뷰 → 테스트 → 커밋 워크플로우 |
| `/review` | code-quality | 코드 리뷰 실행 |
| `/git-commit` | git-workflows | Git Flow 기반 스마트 커밋 |
| `/continue-context` | context-management | 컨텍스트 분석 및 작업 추천 |
| `/inject-context` | context-management | 대용량 파일 구조 인식 청킹 |
| `/factory` | automation-tools | Agent, Skill, Command 생성기 |
| `/setup-statusline` | automation-tools | YAML 기반 status line 구성 |
| `/claude-sync` | automation-tools | CLAUDE.md 자동 동기화 |

## 에이전트 계층

```
ORCHESTRATION HIERARCHY:
│
├─ full-stack-orchestrator (최상위 오케스트레이터)
│   ├─ 워크플로우 조율: dev-flow, feature-flow
│   ├─ 품질 게이트 관리
│   └─ 다중 에이전트 결과 통합
│
├─ nestjs-fastify-expert (백엔드 오케스트레이터)
│   ├─ 요청 분석 → 전문가 선택
│   ├─ 복합 작업 → 순차/병렬 위임
│   └─ Fastify 핵심 설정 직접 처리
│
├─ Backend Experts (7개)
│   ├─ typeorm-expert
│   ├─ redis-cache-expert
│   ├─ bullmq-queue-expert
│   ├─ cqrs-expert
│   ├─ microservices-expert
│   └─ suites-testing-expert
│
├─ Quality Experts (2개)
│   ├─ code-reviewer (보안, 성능, 품질 분석)
│   └─ test-automator (Suites 3.x 기반 테스트 생성)
│
└─ Document Expert
    └─ document-builder
```

## Agent Routing System

**agent-routing 스킬**이 사용자 요청을 분석하여 적절한 전문가를 자동 선택합니다:

```
USER REQUEST → KEYWORD DETECTION → EXPERT SELECTION → TASK EXECUTION

예시:
"Redis 캐시 설정" → redis-cache-expert
"TypeORM 엔티티 + 테스트" → typeorm-expert → suites-testing-expert (SEQUENTIAL)
"캐시랑 큐 설정" → [redis-cache-expert, bullmq-queue-expert] (PARALLEL)
```

## Component Registry (routing-table.json)

`.claude-plugin/routing-table.json`이 모든 컴포넌트의 트리거 키워드를 중앙 관리합니다:

```json
{
  "components": {
    "agents": {
      "redis-cache-expert": {
        "triggers": {
          "primary": ["redis", "캐시", "cache"],
          "secondary": ["TTL", "ioredis"],
          "context": ["interceptor", "cluster"]
        }
      }
    }
  },
  "routing_rules": {
    "keyword_priority": { "primary_weight": 3, "secondary_weight": 2, "context_weight": 1 },
    "execution_strategies": { "SINGLE_EXPERT", "SEQUENTIAL", "PARALLEL", "DIRECT" }
  }
}
```

**키워드 점수 계산**: primary(3점) + secondary(2점) + context(1점) → 최고 점수 에이전트 선택

**자동 동기화**: `/claude-sync` 실행 시 routing-table.json 자동 갱신

## 설치

```bash
/plugin marketplace add m16khb/claude-integration
/plugin install claude-integration
```

## MCP 서버 (내장)

| MCP 서버 | 설명 | 요구사항 |
|----------|------|---------|
| `playwright` | 브라우저 자동화 | Node.js 18+ |
| `context7` | 최신 문서 주입 | Node.js 18+ |
| `sequential-thinking` | 단계별 사고 | Node.js 18+ |
| `chrome-devtools` | 크롬 개발자 도구 | Node.js 22+, Chrome |

## 상세 문서

- [docs/architecture.md](docs/architecture.md) - 아키텍처 설계 원칙
- [docs/agents.md](docs/agents.md) - 에이전트 레퍼런스
- [docs/plugins.md](docs/plugins.md) - 플러그인 레퍼런스
- [docs/usage.md](docs/usage.md) - 사용 가이드
- [docs/agent-skills.md](docs/agent-skills.md) - 스킬 개발 가이드

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
model: claude-opus-4-5-20251101  # 복잡한 작업은 Opus
---
```

### 주의사항

- `commands/` 디렉토리의 모든 .md 파일은 슬래시 커맨드로 자동 인식
- 민감 정보(API 키, 패스워드) 노출 금지
- Bash 도구 사용시 패턴 명시: `Bash(git:*, npm:*)`
- **복잡한 분석/생성 작업은 Opus 4.5 사용**

## 에이전트 작성 가이드

### 표준 11개 섹션

1. **Frontmatter**: name, description, model, allowed-tools
2. **Purpose**: 에이전트의 핵심 정체성
3. **Core Philosophy**: 설계 원칙
4. **Capabilities**: 도메인별 전문성
5. **Behavioral Traits**: 행동 양식
6. **Workflow Position**: 다른 에이전트와의 관계
7. **Knowledge Base**: 보유 지식 영역
8. **Response Approach**: 문제해결 프로세스
9. **Example Interactions**: 활용 시나리오
10. **Key Distinctions**: 유사 역할과의 경계
11. **Output Examples**: 결과물 기준

### 모델 선택 기준

| 모델 | 용도 | 예시 |
|------|------|------|
| **Opus 4.5** | 복잡한 분석, 아키텍처 설계, 오케스트레이션 | full-stack-orchestrator, typeorm-expert |
| **Sonnet** | 중간 복잡도, 코드 리뷰, 표준 구현 | code-reviewer |
| **Haiku** | 빠른 실행, 간단한 작업, 결정론적 출력 | git-commit |

## 테스트 작성 가이드 (Suites 3.x)

### 기본 패턴

```typescript
import { TestBed, type Mocked } from '@suites/unit';

describe('UserService', () => {
  let service: UserService;
  let repository: Mocked<UserRepository>;

  beforeAll(async () => {
    const { unit, unitRef } = await TestBed.solitary(UserService).compile();
    service = unit;
    repository = unitRef.get(UserRepository);
  });

  it('should find user', async () => {
    repository.findOne.mockResolvedValue({ id: '1' });
    const result = await service.findById('1');
    expect(result.id).toBe('1');
  });
});
```

### 핵심 포인트

- `TestBed.solitary()`: 모든 의존성 자동 모킹
- `await .compile()`: **비동기 필수**
- `Mocked<T>`: 타입 안전한 모킹
