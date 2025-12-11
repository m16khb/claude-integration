# Routing Algorithm

> 키워드 기반 전문가 자동 선택 알고리즘

## Overview

Agent Routing System은 사용자 요청을 분석하여 가장 적합한 전문가를 자동으로 선택합니다.

```
ROUTING FLOW:
┌─────────────────────────────────────────────────────────┐
│                     User Request                         │
│               "Redis 캐시 설정해줘"                        │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                  Keyword Detection                       │
│           [redis, 캐시] → Primary Keywords               │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                   Score Calculation                      │
│     redis-cache-expert: 6점 (primary×2)                 │
│     bullmq-queue-expert: 0점                            │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                  Expert Selection                        │
│              → redis-cache-expert 선택                   │
└─────────────────────────────────────────────────────────┘
```

---

## 키워드 분류

### Primary Keywords (3점)

핵심 기술 키워드로, 전문가 도메인을 직접 식별합니다.

```
PRIMARY KEYWORDS:
├─ typeorm-expert
│   └─ "typeorm", "entity", "repository", "migration", "데이터베이스", "database"
│
├─ redis-cache-expert
│   └─ "redis", "캐시", "cache", "세션", "session", "ioredis"
│
├─ bullmq-queue-expert
│   └─ "bullmq", "큐", "queue", "작업 큐", "백그라운드", "worker"
│
├─ cqrs-expert
│   └─ "cqrs", "command", "query", "event sourcing", "이벤트"
│
├─ microservices-expert
│   └─ "microservices", "마이크로서비스", "grpc", "message broker"
│
├─ suites-testing-expert
│   └─ "suites", "automock", "테스트", "test", "e2e", "unit test"
│
└─ nestjs-fastify-expert (Orchestrator)
    └─ "nestjs", "fastify", "백엔드", "backend", "아키텍처"
```

### Secondary Keywords (2점)

관련 기능 키워드로, 추가 컨텍스트를 제공합니다.

```
SECONDARY KEYWORDS:
├─ typeorm-expert
│   └─ "orm", "model", "query", "relation", "index"
│
├─ redis-cache-expert
│   └─ "ttl", "expire", "pub/sub", "cluster", "sentinel"
│
├─ bullmq-queue-expert
│   └─ "job", "scheduler", "cron", "delayed", "repeat"
│
├─ cqrs-expert
│   └─ "saga", "handler", "dispatch", "aggregate", "domain"
│
├─ microservices-expert
│   └─ "gateway", "discovery", "circuit breaker", "saga"
│
└─ suites-testing-expert
    └─ "mock", "stub", "fixture", "coverage", "jest"
```

### Contextual Keywords (1점)

문맥 키워드로, 미세 조정에 사용됩니다.

```
CONTEXTUAL KEYWORDS:
├─ typeorm-expert
│   └─ "postgresql", "mysql", "sqlite", "datasource"
│
├─ redis-cache-expert
│   └─ "interceptor", "decorator", "@Cacheable"
│
├─ bullmq-queue-expert
│   └─ "processor", "@Processor", "flow", "board"
│
├─ cqrs-expert
│   └─ "@CommandHandler", "@EventHandler", "eventStore"
│
├─ microservices-expert
│   └─ "@MessagePattern", "@EventPattern", "transport"
│
└─ suites-testing-expert
    └─ "TestBed", "solitary", "sociable", "Mocked"
```

---

## 점수 계산 알고리즘

### 기본 공식

```
SCORE FORMULA:
Total Score = (Primary Count × 3) + (Secondary Count × 2) + (Context Count × 1) + Bonus

Bonus 조건:
├─ 복합 키워드 매칭 (+2): "캐시와 큐", "엔티티 + 테스트"
├─ 오케스트레이터 필요 (+3): 3개 이상 도메인
└─ 명시적 전문가 언급 (+5): "typeorm-expert", "redis 전문가"
```

### 예시 계산

```
INPUT: "Redis 캐시 TTL 설정과 만료 처리"

KEYWORD EXTRACTION:
├─ "redis" → Primary (redis-cache-expert)
├─ "캐시" → Primary (redis-cache-expert)
├─ "TTL" → Secondary (redis-cache-expert)
├─ "만료" → Context (related to TTL/expire)
└─ "처리" → Generic (ignored)

SCORE CALCULATION:
├─ redis-cache-expert: (2 × 3) + (1 × 2) + (1 × 1) = 9점
├─ typeorm-expert: 0점
├─ bullmq-queue-expert: 0점
└─ other experts: 0점

RESULT: redis-cache-expert (9점) 선택
```

---

## 실행 전략

### SINGLE_EXPERT

단일 도메인 요청에 사용됩니다.

```
CONDITIONS:
├─ 하나의 전문가만 점수 > 0
├─ 최고 점수와 2위 점수 차이 > 3
└─ 복합 키워드 없음

EXAMPLE:
Input: "TypeORM 마이그레이션 롤백"
Result: typeorm-expert (단독 실행)
```

### SEQUENTIAL

의존성 있는 작업을 순차 실행합니다.

```
CONDITIONS:
├─ 2개 전문가 점수 > 0
├─ 작업 간 의존성 존재
└─ 예: "엔티티 생성 후 테스트"

EXAMPLE:
Input: "User 엔티티 만들고 테스트 작성해줘"
Sequence:
  1. typeorm-expert → Entity 생성
  2. suites-testing-expert → 테스트 작성
```

### PARALLEL

독립적 작업을 병렬 실행합니다.

```
CONDITIONS:
├─ 2개 이상 전문가 점수 > 0
├─ 작업 간 의존성 없음
└─ 예: "캐시와 큐 각각 설정"

EXAMPLE:
Input: "Redis 캐시랑 BullMQ 큐 설정해줘"
Parallel:
  ├─ redis-cache-expert → 캐시 설정
  └─ bullmq-queue-expert → 큐 설정
```

### ORCHESTRATED

복잡한 요청을 오케스트레이터가 조율합니다.

```
CONDITIONS:
├─ 3개 이상 전문가 필요
├─ 복잡한 의존성
└─ 아키텍처 수준 작업

EXAMPLE:
Input: "인증 시스템 전체 구현 (DB, 캐시, 큐, 테스트)"
Orchestration:
  nestjs-fastify-expert 조율:
    1. typeorm-expert → User Entity, Auth Repository
    2. redis-cache-expert → Session Cache
    3. bullmq-queue-expert → Email Queue
    4. suites-testing-expert → All Tests
```

---

## 라우팅 테이블

### 구조

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
      "keywords": ["redis", "bullmq", "캐시", "큐"],
      "experts": ["redis-cache-expert", "bullmq-queue-expert"],
      "execution": "parallel",
      "orchestrator": "nestjs-fastify-expert"
    },
    {
      "keywords": ["typeorm", "테스트", "entity", "test"],
      "experts": ["typeorm-expert", "suites-testing-expert"],
      "execution": "sequential"
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

## 복잡도 분석

### 단순 (Simple)

```
SIMPLE REQUESTS:
├─ 단일 키워드 도메인
├─ 명확한 작업 범위
├─ 직접 라우팅
│
├─ 예시:
│   "Redis TTL 설정" → redis-cache-expert
│   "TypeORM 마이그레이션" → typeorm-expert
│   "BullMQ 워커 생성" → bullmq-queue-expert
│
└─ 처리: SINGLE_EXPERT
```

### 중간 (Moderate)

```
MODERATE REQUESTS:
├─ 2개 도메인 조합
├─ 의존성 분석 필요
├─ 순차 또는 병렬 결정
│
├─ 예시:
│   "캐시랑 큐 설정" → [redis, bullmq] (PARALLEL)
│   "엔티티 만들고 테스트" → typeorm → suites (SEQUENTIAL)
│
└─ 처리: SEQUENTIAL 또는 PARALLEL
```

### 복잡 (Complex)

```
COMPLEX REQUESTS:
├─ 3개 이상 도메인
├─ 오케스트레이터 필수
├─ 실행 계획 수립 필요
│
├─ 예시:
│   "인증 시스템 전체 구현"
│   "마이크로서비스 아키텍처 설계"
│
└─ 처리: ORCHESTRATED
```

---

## 디버깅

### 라우팅 로그

```bash
# 라우팅 결정 과정 확인
DEBUG_ROUTING=true

# 출력 예시:
[ROUTING] Input: "Redis 캐시 TTL 설정"
[ROUTING] Keywords: [redis, 캐시, TTL, 설정]
[ROUTING] Scores:
  - redis-cache-expert: 8 (P:2, S:1, C:0)
  - typeorm-expert: 0
  - bullmq-queue-expert: 0
[ROUTING] Strategy: SINGLE_EXPERT
[ROUTING] Selected: redis-cache-expert
```

### 오탐지 분석

```
FALSE POSITIVE ANALYSIS:
├─ 원인: 키워드 중복
│   예: "캐시 전략" → cache(redis) vs caching(general)
│
├─ 해결: 컨텍스트 고려
│   "Redis 캐시" vs "브라우저 캐시"
│
└─ 조정: routing-table.json 키워드 세분화
```

---

**관련 문서**: [CLAUDE.md](../CLAUDE.md) | [expert-profiles.md](expert-profiles.md) | [integration-patterns.md](integration-patterns.md)
