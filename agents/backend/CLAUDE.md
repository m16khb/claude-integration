# agents/backend/ CLAUDE.md

## 전문 분야

**NestJS 생태계 전문 에이전트 모음**입니다. NestJS + Fastify 기반 백엔드 개발을 위한 특화된 에이전트를 제공합니다.

## 파일 구조

```
backend/
├── CLAUDE.md                    # 이 파일
├── nestjs-fastify-expert.md     # Orchestrator
├── typeorm-expert.md            # TypeORM 전문가
├── redis-cache-expert.md        # Redis 캐싱 전문가
├── bullmq-queue-expert.md       # BullMQ 큐 전문가
├── cqrs-expert.md               # CQRS 패턴 전문가
├── microservices-expert.md      # 마이크로서비스 전문가
└── suites-testing-expert.md     # 테스팅 전문가
```

## 에이전트 계층

```
ORCHESTRATION:
├─ nestjs-fastify-expert (Orchestrator)
│   ├─ 요청 분석 → 적절한 전문가 선택
│   ├─ 복합 작업 → 여러 전문가 순차/병렬 호출
│   └─ Fastify 관련 → 직접 처리
│
└─ Experts (전문가)
    ├─ typeorm-expert
    ├─ redis-cache-expert
    ├─ bullmq-queue-expert
    ├─ cqrs-expert
    ├─ microservices-expert
    └─ suites-testing-expert
```

## 포함된 에이전트

| 에이전트 | 전문 분야 | 트리거 키워드 |
|---------|----------|--------------|
| `nestjs-fastify-expert` | NestJS + Fastify 오케스트레이터 | fastify, 어댑터, 플러그인 |
| `typeorm-expert` | TypeORM 엔티티, 리포지토리, 마이그레이션 | typeorm, entity, migration |
| `redis-cache-expert` | Redis 캐싱, @nestjs/cache-manager | 캐시, redis, caching |
| `bullmq-queue-expert` | BullMQ 작업 큐, 프로듀서/컨슈머 | 큐, queue, bullmq, job |
| `cqrs-expert` | CQRS 패턴, Command/Query/Event | cqrs, command, query, saga |
| `microservices-expert` | 마이크로서비스, 메시지 브로커 | microservice, rabbitmq, grpc |
| `suites-testing-expert` | Suites(Automock), Jest, E2E | 테스트, test, jest, suites |

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

## 라우팅 예시

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
```

## 참조

- [상위 모듈](../CLAUDE.md)
- [루트](../../CLAUDE.md)
- [agent-docs/agents.md](../../agent-docs/agents.md)
