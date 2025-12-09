# NestJS Backend Expert Agents - 상세 가이드

> 7명의 전문 에이전트와 지능형 라우팅 시스템 상세 문서

## Architecture Overview

```
System Architecture:
                         User Request
                    "Redis 캐시 설정해줘"
                              |
                              v
   +----------------------------------------------------------+
   |           nestjs-fastify-expert (Orchestrator)           |
   |  +-------------+---------------+------------------+      |
   |  |   Request   |   Routing     |   Coordination   |      |
   |  |  Analysis   |   System      |     Layer        |      |
   |  +-------------+---------------+------------------+      |
   +----------------------------------------------------------+
                              |
            +-----------------+-----------------+
            v                 v                 v
      +-----------+    +------------+    +-----------+
      |   Redis   |    |  TypeORM   |    |  BullMQ   |
      |  Expert   |    |   Expert   |    |  Expert   |
      +-----------+    +------------+    +-----------+
```

---

## Expert Agents 상세

### 1. nestjs-fastify-expert (Orchestrator)

**역할**: 백엔드 개발 요청 분석 및 전문가 배정

#### 핵심 기능
- 요청 복잡도 분석 (단일 vs 복합)
- 필수 전문가 식별 및 우선순위 결정
- 병렬/순차 실행 전략 수립
- 결과 통합 및 검증

#### 활성화 조건
```
TRIGGERS:
├─ 복합 요청: "캐시와 큐 함께 설정"
├─ 아키텍처: "백엔드 구조 설계"
├─ 마이그레이션: "Express → NestJS 전환"
└─ 최적화: "전체 성능 개선"
```

---

### 2. typeorm-expert

**전문 분야**: 데이터베이스 설계, ORM 최적화, 마이그레이션

#### 상세 기능
```
DATABASE DESIGN:
├─ Entity Modeling
│   ├─ 관계 정의 (1:1, 1:N, M:N)
│   ├─ 인덱스 전략
│   ├─ 파티셔닝 설계
│   └─ 소프트 삭제 패턴
│
├─ Repository Pattern
│   ├─ Custom Repository 구현
│   ├─ Query Builder 최적화
│   ├─ N+1 문제 해결
│   └─ 동적 쿼리 생성
│
├─ Migration Management
│   ├─ 버전 관리 전략
│   ├─ 롤백 시나리오
│   ├─ 데이터 마이그레이션
│   └─ 제로 다운타임 배포
│
└─ Performance
    ├─ Connection Pooling
    ├─ Query Caching
    ├─ Lazy Loading 전략
    └─ Bulk Operations
```

---

### 3. redis-cache-expert

**전문 분야**: 캐시 전략, 세션 관리, 분산 락

#### 캐시 전략
```
CACHE PATTERNS:
├─ Cache-Aside Pattern
│   ├─ Read-through 구현
│   ├─ Write-back 전략
│   └─ TTL 관리
│
├─ Multi-level Caching
│   ├─ L1: In-memory (Node.js)
│   ├─ L2: Redis (shared)
│   └─ L3: Database
│
├─ Cache Invalidation
│   ├─ Tag-based 기반
│   ├─ Event-driven 무효화
│   └─ TTL 자동 만료
│
└─ Advanced Patterns
    ├─ Distributed Lock
    ├─ Rate Limiting
    ├─ Session Store
    └─ Pub/Sub
```

---

### 4. bullmq-queue-expert

**전문 분야**: 작업 큐, 백그라운드 처리, 스케줄링

#### 큐 아키텍처
```
QUEUE ARCHITECTURE:
├─ Queue Types
│   ├─ Default Queue: 일반 작업
│   ├─ Priority Queue: 우선순위 작업
│   ├─ Delayed Queue: 지연 작업
│   └─ Repeat Queue: 반복 작업
│
├─ Worker Patterns
│   ├─ Single Worker: 순차 처리
│   ├─ Multiple Workers: 병렬 처리
│   ├─ Dedicated Workers: 특정 작업 전용
│   └─ Shared Workers: 범용 처리
│
├─ Job Strategies
│   ├─ Retry Logic: 지수 백오프
│   ├─ Dead Letter Queue: 실패 작업 처리
│   ├─ Job Dependencies: 작업 순서
│   └─ Job Chaining: 파이프라인
│
└─ Monitoring
    ├─ Job Metrics: 성능 측정
    ├─ Queue Health: 상태 모니터링
    ├─ Error Tracking: 오류 추적
    └─ Auto-scaling: 동적 확장
```

---

### 5. cqrs-expert

**전문 분야**: CQRS 패턴, Event Sourcing, 도메인 이벤트

#### CQRS 구현
```
CQRS IMPLEMENTATION:
├─ Command Side
│   ├─ Command Handlers
│   ├─ Validation Pipes
│   ├─ Transaction Management
│   └─ Event Publishing
│
├─ Query Side
│   ├─ Query Handlers
│   ├─ Read Models
│   ├─ Materialized Views
│   └─ Query Optimization
│
├─ Event Sourcing
│   ├─ Event Store
│   ├─ Snapshots
│   ├─ Event Replay
│   └─ Version Control
│
└─ Sagas
    ├─ Orchestration
    ├─ Choreography
    ├─ Compensation
    └─ Timeout Handling
```

---

### 6. microservices-expert

**전문 분야**: 마이크로서비스 아키텍처, 서비스 통신

#### 통신 패턴
```
COMMUNICATION PATTERNS:
├─ Synchronous
│   ├─ gRPC: 고성능 RPC
│   ├─ HTTP/REST: 범용 API
│   └─ GraphQL: 유연한 쿼리
│
├─ Asynchronous
│   ├─ Message Broker: RabbitMQ, Kafka
│   ├─ Event Bus: 내부 이벤트
│   └─ Pub/Sub: Redis, NATS
│
├─ Service Discovery
│   ├─ Consul: 서비스 레지스트리
│   ├─ Eureka: Netflix OSS
│   └─ Kubernetes: Native 서비스
│
└─ API Gateway
    ├─ Routing: 요청 분배
    ├─ Authentication: 인증 처리
    ├─ Rate Limiting: 사용량 제한
    └─ Load Balancing: 부하 분산
```

---

### 7. suites-testing-expert

**전문 분야**: Suites 3.x 기반 테스트 전략, E2E 테스트

#### 테스트 전략
```
TESTING PYRAMID:
├─ Unit Tests (70%)
│   ├─ Service Layer
│   ├─ Controller Mocking
│   ├─ Repository Fakes
│   └─ Utility Functions
│
├─ Integration Tests (20%)
│   ├─ API Endpoints
│   ├─ Database Integration
│   ├─ External Services
│   └─ Message Queues
│
└─ E2E Tests (10%)
    ├─ User Workflows
    ├─ Cross-service Scenarios
    ├─ Performance Tests
    └─ Security Tests
```

---

## Agent Routing System

### 라우팅 알고리즘

```
ROUTING ALGORITHM:
1. 키워드 추출
   ├─ 기술 키워드: "Redis", "TypeORM", "BullMQ"
   ├─ 동작 키워드: "설정", "최적화", "마이그레이션"
   ├─ 패턴 키워드: "CQRS", "Microservices", "Testing"
   └─ 복합 키워드: "A와 B 함께", "전체 시스템"

2. 점수 계산
   ├─ Primary 키워드: +3점
   ├─ Secondary 키워드: +2점
   ├─ Contextual 키워드: +1점
   └─ 복합도 보너스: +2점

3. 전문가 선택
   ├─ 최고 점수 전문가: 주 담당
   ├─ 2위 전문가: 보조 또는 병렬
   ├─ 오케스트레이터: 3개 이상 필요 시
   └─ 순차/병렬 결정
```

### 라우팅 테이블

```json
{
  "routing_rules": [
    {
      "keywords": ["redis", "캐시", "cache"],
      "experts": ["redis-cache-expert"],
      "priority": "primary",
      "score": 3
    },
    {
      "keywords": ["typeorm", "entity", "데이터베이스"],
      "experts": ["typeorm-expert"],
      "priority": "primary",
      "score": 3
    },
    {
      "keywords": ["큐", "queue", "bullmq", "백그라운드"],
      "experts": ["bullmq-queue-expert"],
      "priority": "primary",
      "score": 3
    },
    {
      "keywords": ["redis", "bullmq", "캐시", "큐"],
      "experts": ["redis-cache-expert", "bullmq-queue-expert"],
      "execution": "parallel",
      "orchestrator": true
    },
    {
      "keywords": ["cqrs", "event sourcing", "이벤트"],
      "experts": ["cqrs-expert"],
      "priority": "primary",
      "score": 3
    },
    {
      "keywords": ["마이크로서비스", "microservices", "gRPC"],
      "experts": ["microservices-expert"],
      "priority": "primary",
      "score": 3
    },
    {
      "keywords": ["테스트", "test", "e2e", "unit"],
      "experts": ["suites-testing-expert"],
      "priority": "primary",
      "score": 3
    },
    {
      "keywords": ["백엔드", "전체", "아키텍처", "시스템"],
      "experts": ["nestjs-fastify-expert"],
      "priority": "orchestrator",
      "score": 3
    }
  ]
}
```

---

## 오케스트레이션 로직

### 복잡도 분석

```
COMPLEXITY ANALYSIS:
├─ Simple (단일 전문가)
│   ├─ 키워드 1개 도메인
│   ├─ 점수 차이 > 3
│   └─ 직접 라우팅
│
├─ Moderate (2개 전문가)
│   ├─ 키워드 2개 도메인
│   ├─ 의존성 분석
│   └─ 병렬 또는 순차
│
└─ Complex (3개+ 전문가)
    ├─ 다중 도메인
    ├─ 오케스트레이터 필수
    └─ 실행 계획 수립
```

### 실행 전략

```
EXECUTION STRATEGIES:
├─ PARALLEL: 독립적 작업 동시 실행
│   예: Redis 설정 + BullMQ 설정
│
├─ SEQUENTIAL: 의존성 있는 작업 순차 실행
│   예: Entity 설계 → Repository → 테스트
│
└─ HYBRID: 혼합 실행
    예: [Entity + Cache 병렬] → [테스트 순차]
```

---

[parent](../CLAUDE.md)
