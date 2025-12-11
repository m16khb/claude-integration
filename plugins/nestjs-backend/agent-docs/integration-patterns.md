# Integration Patterns

> 전문가 간 협업 및 오케스트레이션 패턴

## Overview

복잡한 백엔드 작업은 여러 전문가의 협업이 필요합니다. 이 문서는 효과적인 통합 패턴을 설명합니다.

---

## 협업 패턴

### 1. Sequential Pattern (순차 실행)

의존성 있는 작업을 순서대로 실행합니다.

```
SEQUENTIAL FLOW:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Expert A   │───▶│  Expert B   │───▶│  Expert C   │
│  (Step 1)   │    │  (Step 2)   │    │  (Step 3)   │
└─────────────┘    └─────────────┘    └─────────────┘
     Entity           Repository          Test
     생성              구현               작성
```

**예시: 기능 구현 + 테스트**

```
INPUT: "User 엔티티 만들고 CRUD 구현하고 테스트 작성해줘"

SEQUENCE:
1. typeorm-expert
   └─ User Entity 정의
   └─ Relations 설정
   └─ Output: user.entity.ts

2. typeorm-expert (계속)
   └─ UserRepository 구현
   └─ CRUD 메서드
   └─ Output: user.repository.ts

3. suites-testing-expert
   └─ Unit Tests 작성
   └─ Integration Tests
   └─ Output: user.service.spec.ts, user.repository.spec.ts
```

### 2. Parallel Pattern (병렬 실행)

독립적인 작업을 동시에 실행합니다.

```
PARALLEL FLOW:
                    ┌─────────────┐
               ┌───▶│  Expert A   │───┐
               │    │  (Task 1)   │   │
┌─────────┐    │    └─────────────┘   │    ┌─────────┐
│  Start  │───┤                       ├───▶│  End    │
└─────────┘    │    ┌─────────────┐   │    └─────────┘
               └───▶│  Expert B   │───┘
                    │  (Task 2)   │
                    └─────────────┘
```

**예시: 인프라 설정**

```
INPUT: "Redis 캐시랑 BullMQ 큐 설정해줘"

PARALLEL:
├─ redis-cache-expert (동시)
│   └─ Redis 연결 설정
│   └─ 캐시 인터셉터
│   └─ Output: redis.module.ts, cache.interceptor.ts
│
└─ bullmq-queue-expert (동시)
    └─ BullMQ 연결 설정
    └─ 큐 프로세서
    └─ Output: queue.module.ts, email.processor.ts
```

### 3. Hybrid Pattern (혼합 실행)

순차와 병렬을 조합합니다.

```
HYBRID FLOW:
                    ┌─────────────┐
               ┌───▶│  Expert B   │───┐
               │    └─────────────┘   │
┌─────────────┐│                      │┌─────────────┐
│  Expert A   │┤                      ├│  Expert D   │
└──────┬──────┘│                      │└─────────────┘
       │       │    ┌─────────────┐   │
       │       └───▶│  Expert C   │───┘
       │            └─────────────┘
  Phase 1              Phase 2           Phase 3
  (순차)               (병렬)             (순차)
```

**예시: 전체 기능 구현**

```
INPUT: "Order 기능 전체 구현 (DB, 캐시, 알림, 테스트)"

HYBRID:
Phase 1 (순차 - 기반 작업):
└─ typeorm-expert
   └─ Order Entity, OrderItem Entity

Phase 2 (병렬 - 독립 작업):
├─ redis-cache-expert
│   └─ Order 캐싱 전략
│
└─ bullmq-queue-expert
    └─ 주문 알림 큐

Phase 3 (순차 - 통합 테스트):
└─ suites-testing-expert
   └─ 전체 통합 테스트
```

---

## 오케스트레이션 시나리오

### 시나리오 1: 인증 시스템

```
INPUT: "JWT 인증 시스템 전체 구현"

ORCHESTRATION (nestjs-fastify-expert):
┌──────────────────────────────────────────────────────────┐
│  Phase 1: 데이터 계층                                      │
│  ├─ typeorm-expert                                        │
│  │   └─ User Entity (email, password, roles)              │
│  │   └─ RefreshToken Entity                               │
│  │   └─ UserRepository                                    │
│  └─ 출력: user.entity.ts, refresh-token.entity.ts         │
├──────────────────────────────────────────────────────────┤
│  Phase 2: 인프라 계층 (병렬)                               │
│  ├─ redis-cache-expert                                    │
│  │   └─ Session Store                                     │
│  │   └─ Token Blacklist                                   │
│  │                                                        │
│  └─ bullmq-queue-expert                                   │
│      └─ 비밀번호 재설정 이메일 큐                           │
│      └─ 환영 이메일 큐                                     │
├──────────────────────────────────────────────────────────┤
│  Phase 3: 테스트 계층                                      │
│  └─ suites-testing-expert                                 │
│      └─ Auth Service Unit Tests                           │
│      └─ Auth Controller Integration Tests                 │
│      └─ E2E Login Flow Tests                              │
└──────────────────────────────────────────────────────────┘
```

### 시나리오 2: 주문 처리 시스템

```
INPUT: "이커머스 주문 처리 시스템"

ORCHESTRATION:
┌──────────────────────────────────────────────────────────┐
│  Phase 1: 도메인 모델                                      │
│  └─ typeorm-expert                                        │
│      └─ Order, OrderItem, OrderStatus Entities            │
│      └─ Product, Inventory Entities                       │
│      └─ Payment Entity                                    │
├──────────────────────────────────────────────────────────┤
│  Phase 2: CQRS 패턴                                       │
│  └─ cqrs-expert                                           │
│      └─ CreateOrderCommand, CancelOrderCommand            │
│      └─ GetOrderQuery, ListOrdersQuery                    │
│      └─ OrderCreatedEvent, OrderCancelledEvent            │
│      └─ OrderSaga (결제 → 재고 → 배송)                     │
├──────────────────────────────────────────────────────────┤
│  Phase 3: 인프라 (병렬)                                    │
│  ├─ redis-cache-expert                                    │
│  │   └─ 상품 정보 캐시                                     │
│  │   └─ 재고 Lock (분산 락)                               │
│  │                                                        │
│  └─ bullmq-queue-expert                                   │
│      └─ 주문 확인 이메일                                   │
│      └─ 재고 업데이트 큐                                   │
│      └─ 결제 처리 큐                                       │
├──────────────────────────────────────────────────────────┤
│  Phase 4: 테스트                                          │
│  └─ suites-testing-expert                                 │
│      └─ Command/Query Handler Tests                       │
│      └─ Saga Tests                                        │
│      └─ E2E Order Flow Tests                              │
└──────────────────────────────────────────────────────────┘
```

### 시나리오 3: 마이크로서비스 마이그레이션

```
INPUT: "모놀리스에서 마이크로서비스로 마이그레이션"

ORCHESTRATION:
┌──────────────────────────────────────────────────────────┐
│  Phase 1: 아키텍처 설계                                    │
│  └─ nestjs-fastify-expert                                 │
│      └─ 서비스 경계 정의                                   │
│      └─ 통신 패턴 결정                                     │
│      └─ 데이터 분리 전략                                   │
├──────────────────────────────────────────────────────────┤
│  Phase 2: 서비스 구현 (병렬)                               │
│  ├─ microservices-expert                                  │
│  │   └─ API Gateway 설정                                  │
│  │   └─ gRPC 서비스 정의                                  │
│  │   └─ Event Bus 설정                                    │
│  │                                                        │
│  └─ typeorm-expert                                        │
│      └─ 서비스별 DB 스키마                                 │
│      └─ 데이터 마이그레이션 스크립트                       │
├──────────────────────────────────────────────────────────┤
│  Phase 3: 인프라 설정 (병렬)                               │
│  ├─ redis-cache-expert                                    │
│  │   └─ 분산 세션                                         │
│  │   └─ 서비스 간 캐시 공유                               │
│  │                                                        │
│  └─ bullmq-queue-expert                                   │
│      └─ 서비스 간 비동기 통신                             │
│      └─ Saga 오케스트레이션                               │
├──────────────────────────────────────────────────────────┤
│  Phase 4: 테스트 & 검증                                    │
│  └─ suites-testing-expert                                 │
│      └─ Contract Tests                                    │
│      └─ Integration Tests                                 │
│      └─ Chaos Engineering Tests                           │
└──────────────────────────────────────────────────────────┘
```

---

## 결과 통합

### 통합 원칙

```
INTEGRATION PRINCIPLES:
├─ 일관성
│   ├─ 네이밍 컨벤션 통일
│   ├─ 디렉토리 구조 일관성
│   └─ 코드 스타일 통일
│
├─ 의존성 관리
│   ├─ 순환 의존성 방지
│   ├─ 모듈 경계 명확화
│   └─ DI 컨테이너 활용
│
├─ 테스트 연계
│   ├─ 개별 컴포넌트 단위 테스트
│   ├─ 통합 지점 통합 테스트
│   └─ 전체 플로우 E2E 테스트
│
└─ 문서화
    ├─ API 문서 자동 생성
    ├─ 아키텍처 다이어그램
    └─ 의존성 그래프
```

### 출력 구조

```
OUTPUT STRUCTURE:
src/
├── modules/
│   └── order/
│       ├── entities/           # typeorm-expert
│       │   ├── order.entity.ts
│       │   └── order-item.entity.ts
│       │
│       ├── repositories/       # typeorm-expert
│       │   └── order.repository.ts
│       │
│       ├── commands/           # cqrs-expert
│       │   ├── create-order.command.ts
│       │   └── create-order.handler.ts
│       │
│       ├── queries/            # cqrs-expert
│       │   └── get-order.query.ts
│       │
│       ├── events/             # cqrs-expert
│       │   └── order-created.event.ts
│       │
│       ├── sagas/              # cqrs-expert
│       │   └── order.saga.ts
│       │
│       ├── cache/              # redis-cache-expert
│       │   └── order-cache.interceptor.ts
│       │
│       ├── queues/             # bullmq-queue-expert
│       │   ├── order-notification.processor.ts
│       │   └── order-notification.producer.ts
│       │
│       └── __tests__/          # suites-testing-expert
│           ├── order.service.spec.ts
│           ├── order.repository.spec.ts
│           ├── create-order.handler.spec.ts
│           └── order.e2e-spec.ts
│
└── config/
    ├── redis.config.ts         # redis-cache-expert
    ├── queue.config.ts         # bullmq-queue-expert
    └── database.config.ts      # typeorm-expert
```

---

## Best Practices

### 1. 작업 분리

```
DO:
├─ 명확한 경계로 작업 분리
├─ 각 전문가의 전문 분야 존중
└─ 인터페이스를 통한 통신

DON'T:
├─ 한 전문가에게 모든 작업 할당
├─ 전문가 간 직접 의존성
└─ 통합 없이 개별 결과물 사용
```

### 2. 의존성 관리

```
DEPENDENCY RULES:
├─ Entity → Repository → Service 순서
├─ 캐시/큐는 Service 레이어에서 사용
├─ CQRS는 Application 레이어에서 구현
└─ 테스트는 모든 레이어 완료 후
```

### 3. 에러 처리

```
ERROR HANDLING:
├─ 각 Phase별 검증 단계
├─ 실패 시 롤백 전략
├─ 부분 성공 처리
└─ 사용자 피드백
```

---

**관련 문서**: [CLAUDE.md](../CLAUDE.md) | [routing-algorithm.md](routing-algorithm.md) | [expert-profiles.md](expert-profiles.md)
