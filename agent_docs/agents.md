# 전문 에이전트 목록

## Backend 에이전트

NestJS 생태계 전문 에이전트 모음입니다.

### Orchestrator

| 에이전트 | 설명 |
|---------|------|
| `nestjs-fastify-expert` | NestJS + Fastify 개발 오케스트레이터 - 하위 전문가에게 위임 |

### 전문가 (Experts)

| 에이전트 | 전문 분야 |
|---------|----------|
| `typeorm-expert` | TypeORM - 엔티티, 리포지토리, 마이그레이션, 트랜잭션 |
| `redis-cache-expert` | Redis 캐싱 - @nestjs/cache-manager, ioredis |
| `bullmq-queue-expert` | BullMQ 작업 큐 - 프로듀서, 컨슈머, 모니터링 |
| `cqrs-expert` | CQRS 패턴 - Command, Query, Event, Saga |
| `microservices-expert` | 마이크로서비스 - RabbitMQ, Redis, gRPC, TCP |
| `suites-testing-expert` | 테스팅 - Suites(Automock), Jest, E2E |

## 사용법

### Task 도구로 호출

```typescript
// Orchestrator를 통한 호출 (권장)
Task(subagent_type="nestjs-fastify-expert", prompt="...")

// 직접 전문가 호출
Task(subagent_type="typeorm-expert", prompt="...")
```

### Orchestrator 동작 방식

```
요청 분석 → 적절한 전문가 선택 → 결과 통합
├─ 단일 작업 → 해당 전문가 호출
├─ 복합 작업 → 여러 전문가 순차/병렬 호출
└─ Fastify 관련 → 직접 처리
```

## 폴더 구조

```
agents/
├── backend/
│   ├── nestjs-fastify-expert.md  # Orchestrator
│   ├── typeorm-expert.md
│   ├── redis-cache-expert.md
│   ├── bullmq-queue-expert.md
│   ├── cqrs-expert.md
│   ├── microservices-expert.md
│   └── suites-testing-expert.md
├── frontend/       # (예정)
└── infrastructure/ # (예정)
```

## 모델 설정

모든 에이전트는 `claude-opus-4-5-20251101` 모델 사용
