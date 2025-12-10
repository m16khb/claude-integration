---
name: nestjs-backend
description: 'NestJS 백엔드 에코시스템 - 7개 전문가 + 자동 라우팅'
category: development
---

# nestjs-backend Plugin

NestJS 백엔드 개발을 위한 7명의 전문 에이전트와 지능형 라우팅 시스템입니다.

## Core Philosophy

```
SINGLE RESPONSIBILITY + AUTO ROUTING:
┌─────────────────────────────────────────────────────────┐
│  User Request → Keyword Detection → Score Calculation   │
│                      ↓                                   │
│  Expert Selection → Execution Strategy → Integration    │
└─────────────────────────────────────────────────────────┘
```

- **단일 책임**: 각 에이전트는 명확한 도메인 전문성
- **자동 라우팅**: 키워드 기반 지능형 전문가 선택 (Primary 3점, Secondary 2점, Context 1점)
- **협업 능력**: 복합 작업을 위한 에이전트 간 조율

## Expert Agents Hierarchy

```
                    ┌─────────────────────────┐
                    │  nestjs-fastify-expert  │ ← Orchestrator
                    │     (백엔드 총괄)         │
                    └───────────┬─────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │           │           │           │           │
        ▼           ▼           ▼           ▼           ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
   │ TypeORM │ │  Redis  │ │ BullMQ  │ │  CQRS   │ │  Micro  │
   │ Expert  │ │ Expert  │ │ Expert  │ │ Expert  │ │ Services│
   └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘
        └───────────┴───────────┼───────────┴───────────┘
                                ▼
                        ┌─────────────┐
                        │   Suites    │ ← Testing Expert
                        │   Testing   │
                        └─────────────┘
```

## Expert Details

| Agent | 전문 분야 | 주요 트리거 | 핵심 기능 |
|-------|----------|------------|----------|
| nestjs-fastify-expert | 오케스트레이터 | "백엔드", "아키텍처" | 복합 요청 분석, 전문가 배정, 결과 통합 |
| typeorm-expert | DB, ORM | "entity", "typeorm", "migration" | 엔티티 모델링, N+1 해결, 마이그레이션 |
| redis-cache-expert | 캐시, 세션 | "캐시", "redis", "session" | Cache-Aside, 분산 락, Rate Limiting |
| bullmq-queue-expert | 작업 큐 | "큐", "bullmq", "worker" | Retry 전략, Dead Letter Queue, Flow |
| cqrs-expert | CQRS 패턴 | "cqrs", "command", "event" | Command/Query 분리, Event Sourcing, Saga |
| microservices-expert | MSA | "마이크로서비스", "gRPC" | 서비스 통신, API Gateway, Circuit Breaker |
| suites-testing-expert | 테스팅 | "테스트", "e2e", "suites" | Suites 3.x, Solitary/Sociable Tests |

## Routing Algorithm

```
SCORE FORMULA:
Total = (Primary × 3) + (Secondary × 2) + (Context × 1) + Bonus

Bonus 조건:
├─ 복합 키워드 (+2): "캐시와 큐"
├─ 오케스트레이터 필요 (+3): 3개+ 도메인
└─ 명시적 전문가 언급 (+5): "typeorm 전문가"
```

| 키워드 타입 | 점수 | 예시 |
|------------|------|------|
| Primary | +3 | "redis", "typeorm", "bullmq", "cqrs" |
| Secondary | +2 | "설정", "최적화", "connection", "ttl" |
| Contextual | +1 | "postgresql", "@Cacheable", "processor" |

## Execution Strategies

| 전략 | 조건 | 예시 |
|------|------|------|
| **SINGLE** | 단일 도메인 | "Redis TTL 설정" → redis-cache-expert |
| **SEQUENTIAL** | 의존성 있음 | "엔티티 생성 후 테스트" → typeorm → suites |
| **PARALLEL** | 독립적 작업 | "캐시와 큐 설정" → [redis, bullmq] 동시 |
| **ORCHESTRATED** | 3개+ 도메인 | "인증 시스템 전체" → nestjs-fastify-expert 조율 |

## Quick Usage

```bash
# 단일 전문가 호출
"Redis 캐시 TTL 1시간 설정"           # → redis-cache-expert
"TypeORM 마이그레이션 롤백"           # → typeorm-expert
"BullMQ 이메일 큐 설정"               # → bullmq-queue-expert

# 복합 호출 (자동 라우팅)
"캐시와 큐 함께 설정"                  # → [redis + bullmq] 병렬
"User 엔티티 만들고 테스트"            # → typeorm → suites 순차
"인증 시스템 (세션 + 유저 + 이메일)"   # → 오케스트레이터
```

## Integration Scenarios

### 인증 시스템 (Orchestrated)

```
Phase 1: typeorm-expert
├─ User Entity, RefreshToken Entity
└─ UserRepository

Phase 2 (병렬):
├─ redis-cache-expert → Session Store, Token Blacklist
└─ bullmq-queue-expert → 이메일 큐

Phase 3: suites-testing-expert
└─ Unit + Integration + E2E Tests
```

### 주문 처리 (CQRS)

```
Phase 1: typeorm-expert → Order, OrderItem Entities
Phase 2: cqrs-expert → Commands, Queries, Events, Saga
Phase 3: redis + bullmq → 캐시 + 알림 큐
Phase 4: suites-testing-expert → 전체 테스트
```

## Structure

```
plugins/nestjs-backend/
├─ CLAUDE.md                    # 본 문서 (개요)
├─ agents/                      # 7개 전문가 에이전트
│   ├─ nestjs-fastify-expert.md # 오케스트레이터
│   ├─ typeorm-expert.md        # DB 전문가
│   ├─ redis-cache-expert.md    # 캐시 전문가
│   ├─ bullmq-queue-expert.md   # 큐 전문가
│   ├─ cqrs-expert.md           # CQRS 전문가
│   ├─ microservices-expert.md  # MSA 전문가
│   └─ suites-testing-expert.md # 테스트 전문가
├─ skills/
│   └─ agent-routing/           # 자동 라우팅 스킬
└─ agent-docs/                  # 상세 문서
    ├─ routing-algorithm.md     # 라우팅 알고리즘 상세
    ├─ expert-profiles.md       # 전문가 프로필 상세
    └─ integration-patterns.md  # 협업 패턴 상세
```

## Technology Stack

| 분야 | 기술 | 전문가 |
|------|------|--------|
| Runtime | Node.js 20+, Fastify 4.x | nestjs-fastify-expert |
| ORM | TypeORM 0.3.x | typeorm-expert |
| Cache | Redis 7.x, ioredis | redis-cache-expert |
| Queue | BullMQ 5.x | bullmq-queue-expert |
| Pattern | @nestjs/cqrs | cqrs-expert |
| MSA | gRPC, RabbitMQ | microservices-expert |
| Testing | Suites 3.x, Jest | suites-testing-expert |

## Best Practices

```
DO ✅:
├─ 키워드로 자연스럽게 요청 ("Redis 캐시 설정")
├─ 복합 작업은 오케스트레이터에게 위임
├─ 테스트는 구현 후 마지막 단계로
└─ agent-docs 상세 문서 참조

DON'T ❌:
├─ 한 전문가에게 모든 작업 할당
├─ 테스트 없이 구현 완료 선언
├─ 순환 의존성 생성
└─ 명확하지 않은 요청
```

## Documentation

- @agent-docs/routing-algorithm.md - 키워드 매칭 상세, 점수 계산, 실행 전략 결정
- @agent-docs/expert-profiles.md - 7명 전문가 상세 프로필, 코드 예시
- @agent-docs/integration-patterns.md - 전문가 간 협업, 오케스트레이션 시나리오

@../CLAUDE.md
