# Agent Reference

## 에이전트 정의 방식

이 문서는 **11개의 전문화된 AI 에이전트를 체계적으로 정의**합니다. 각 에이전트는 특정 Claude 모델과 연결되어 도메인별 전문성을 제공합니다.

## 카테고리별 분류

### 1. 오케스트레이터 (2개)

| 에이전트 | 모델 | 설명 |
|---------|------|------|
| `full-stack-orchestrator` | Opus | 최상위 워크플로우 조율, 리뷰/테스트/커밋 파이프라인 |
| `nestjs-fastify-expert` | Opus | NestJS + Fastify 오케스트레이터, 백엔드 전문가 위임 및 결과 통합 |

### 2. 백엔드 개발 전문가 (6개)

| 에이전트 | 모델 | 설명 |
|---------|------|------|
| `typeorm-expert` | Opus | TypeORM 엔티티, 리포지토리, 마이그레이션 |
| `redis-cache-expert` | Opus | Redis 캐싱, @nestjs/cache-manager |
| `bullmq-queue-expert` | Opus | BullMQ 작업 큐, 프로듀서/컨슈머 |
| `cqrs-expert` | Opus | CQRS 패턴, Command/Query/Event/Saga |
| `microservices-expert` | Opus | 마이크로서비스, RabbitMQ, gRPC |
| `suites-testing-expert` | Opus | Suites(Automock), Jest, E2E 테스팅 |

### 3. 품질 관리 전문가 (2개)

| 에이전트 | 모델 | 설명 |
|---------|------|------|
| `code-reviewer` | Sonnet | 보안, 성능, 유지보수성, 신뢰성 분석 |
| `test-automator` | Sonnet | Suites 3.x 기반 테스트 자동 생성 |

### 4. 문서화 (1개)

| 에이전트 | 모델 | 설명 |
|---------|------|------|
| `document-builder` | Sonnet | 계층적 CLAUDE.md 및 agent-docs 생성/수정 |

## 모델 할당 전략

| 모델 | 용도 | 에이전트 수 |
|------|------|-----------|
| **Opus** | 오케스트레이션, 복잡한 추론 | 8개 |
| **Sonnet** | 전문 분석, 문서 생성 | 3개 |

## 에이전트 유형

```
AGENT TYPES:
├─ Orchestrator (2개)
│   ├─ full-stack-orchestrator
│   │   └─ 워크플로우 조율 → 리뷰/테스트/커밋 파이프라인
│   └─ nestjs-fastify-expert
│       ├─ 요청 분석 → 전문가 선택
│       ├─ 복합 작업 → 순차/병렬 위임
│       └─ 결과 통합 → 통합 응답
│
├─ Expert (9개)
│   ├─ Backend: typeorm, redis, bullmq, cqrs, microservices, suites-testing
│   ├─ Quality: code-reviewer, test-automator
│   └─ Docs: document-builder
```

## 트리거 키워드

각 에이전트는 특정 키워드로 활성화됩니다:

| 에이전트 | Primary 트리거 |
|---------|-------------|
| `full-stack-orchestrator` | dev-flow, feature-flow, 워크플로우 |
| `nestjs-fastify-expert` | nestjs, fastify, 백엔드 |
| `typeorm-expert` | typeorm, entity, database, repository |
| `redis-cache-expert` | redis, 캐시, cache, 세션 |
| `bullmq-queue-expert` | bullmq, 큐, queue, 백그라운드 |
| `cqrs-expert` | cqrs, command, query, event sourcing |
| `microservices-expert` | microservices, 마이크로서비스, grpc |
| `suites-testing-expert` | suites, automock, 테스트 자동화 |
| `code-reviewer` | 리뷰, review, 보안, security |
| `test-automator` | 테스트, test, e2e, unit test |
| `document-builder` | 문서, documentation, docs, readme |

## 오케스트레이션 패턴

### 라우팅 예시

```
USER REQUEST → ROUTING DECISION

"Redis 캐시 설정해줘"
  → SINGLE_EXPERT: redis-cache-expert

"TypeORM으로 User 엔티티 만들고 테스트도 작성해줘"
  → SEQUENTIAL: typeorm-expert → suites-testing-expert

"BullMQ 큐랑 Redis 캐시 둘 다 설정"
  → PARALLEL: [bullmq-queue-expert, redis-cache-expert]

"코드 리뷰하고 테스트하고 커밋해줘"
  → PIPELINE: full-stack-orchestrator
```

## 플러그인별 에이전트 분포

| 플러그인 | 에이전트 수 | 에이전트 목록 |
|---------|-----------|-------------|
| nestjs-backend | 7개 | nestjs-fastify-expert, typeorm-expert, redis-cache-expert, bullmq-queue-expert, cqrs-expert, microservices-expert, suites-testing-expert |
| code-quality | 2개 | code-reviewer, test-automator |
| full-stack-orchestration | 1개 | full-stack-orchestrator |
| documentation-generation | 1개 | document-builder |
| git-workflows | 0개 | - |
| context-management | 0개 | - |
| automation-tools | 0개 | - |

## 사용법

### Orchestrator를 통한 호출 (권장)

```typescript
Task(
  subagent_type="nestjs-fastify-expert",
  prompt="Redis 캐시 설정하고 BullMQ 큐도 추가해줘"
)

// Orchestrator가 자동으로:
// 1. redis-cache-expert 호출
// 2. bullmq-queue-expert 호출
// 3. 결과 통합
```

### 직접 전문가 호출

```typescript
Task(
  subagent_type="typeorm-expert",
  prompt="User 엔티티 만들어줘"
)
```
