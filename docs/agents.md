# Agent Reference

## 에이전트 정의 방식

이 문서는 **9개의 전문화된 AI 에이전트를 체계적으로 정의**합니다. 각 에이전트는 특정 Claude 모델과 연결되어 도메인별 전문성을 제공합니다.

## 카테고리별 분류

### 1. 아키텍처 & 오케스트레이션 (1개)

| 에이전트 | 모델 | 설명 |
|---------|------|------|
| `nestjs-fastify-expert` | Opus | NestJS + Fastify 오케스트레이터, 전문가 위임 및 결과 통합 |

### 2. 백엔드 개발 전문가 (6개)

| 에이전트 | 모델 | 설명 |
|---------|------|------|
| `typeorm-expert` | Sonnet | TypeORM 엔티티, 리포지토리, 마이그레이션 |
| `redis-cache-expert` | Sonnet | Redis 캐싱, @nestjs/cache-manager |
| `bullmq-queue-expert` | Sonnet | BullMQ 작업 큐, 프로듀서/컨슈머 |
| `cqrs-expert` | Sonnet | CQRS 패턴, Command/Query/Event/Saga |
| `microservices-expert` | Sonnet | 마이크로서비스, RabbitMQ, gRPC |
| `suites-testing-expert` | Sonnet | Suites(Automock), Jest, E2E 테스팅 |

### 3. 문서화 (1개)

| 에이전트 | 모델 | 설명 |
|---------|------|------|
| `document-builder` | Sonnet | 계층적 CLAUDE.md 및 agent-docs 생성/수정 |

## 모델 할당 전략

| 모델 | 용도 | 에이전트 수 |
|------|------|-----------|
| **Opus** | 오케스트레이션, 복잡한 위임 결정 | 1개 |
| **Sonnet** | 복잡한 추론, 전문 지식 적용 | 8개 |
| **Haiku** | (예정) 빠른 실행, 결정론적 작업 | 0개 |

## 에이전트 유형

```
AGENT TYPES:
├─ Orchestrator (1개)
│   └─ nestjs-fastify-expert
│       ├─ 요청 분석 → 전문가 선택
│       ├─ 복합 작업 → 순차/병렬 위임
│       └─ 결과 통합 → 통합 응답
│
├─ Expert (7개)
│   ├─ typeorm-expert
│   ├─ redis-cache-expert
│   ├─ bullmq-queue-expert
│   ├─ cqrs-expert
│   ├─ microservices-expert
│   ├─ suites-testing-expert
│   └─ document-builder
│
└─ Utility (예정)
    └─ 공통 작업 자동화
```

## 트리거 키워드

각 에이전트는 특정 키워드로 활성화됩니다:

| 에이전트 | 트리거 키워드 |
|---------|-------------|
| `nestjs-fastify-expert` | fastify, 어댑터, 플러그인, nestjs |
| `typeorm-expert` | typeorm, entity, migration, repository, database |
| `redis-cache-expert` | 캐시, redis, caching, cache-manager |
| `bullmq-queue-expert` | 큐, queue, bullmq, job, worker, background |
| `cqrs-expert` | cqrs, command, query, event, saga |
| `microservices-expert` | microservice, rabbitmq, grpc, tcp, 분산 |
| `suites-testing-expert` | 테스트, test, jest, suites, automock, e2e |
| `document-builder` | claude.md, agent-docs, 문서, documentation |

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

"Fastify 어댑터 설정하고 helmet, cors 플러그인 추가"
  → DIRECT: (Orchestrator 직접 처리)

"마이크로서비스 구조로 CQRS 패턴 적용"
  → SEQUENTIAL: cqrs-expert → microservices-expert
```

## 에이전트 파일 구조

각 에이전트 마크다운 파일은 표준화된 11개 섹션으로 구성됩니다:

1. **Frontmatter**: name, description, model, allowed-tools
2. **Purpose**: 에이전트의 핵심 정체성 정의
3. **Core Philosophy**: 설계 원칙
4. **Capabilities**: 도메인별 전문성 카테고리
5. **Behavioral Traits**: 행동 양식
6. **Workflow Position**: 다른 에이전트와의 관계
7. **Knowledge Base**: 보유 지식 영역
8. **Response Approach**: 문제해결 프로세스
9. **Example Interactions**: 활용 시나리오
10. **Key Distinctions**: 유사 역할과의 경계
11. **Output Examples**: 결과물 기준

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

## 플러그인별 에이전트 분포

| 플러그인 | 에이전트 수 | 에이전트 목록 |
|---------|-----------|-------------|
| backend-development | 7개 | nestjs-fastify-expert, typeorm-expert, redis-cache-expert, bullmq-queue-expert, cqrs-expert, microservices-expert, suites-testing-expert |
| documentation-generation | 1개 | document-builder |
| git-workflows | 0개 | - |
| context-management | 0개 | - |
| automation-tools | 0개 | - |
