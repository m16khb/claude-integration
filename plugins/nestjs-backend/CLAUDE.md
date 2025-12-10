---
name: nestjs-backend
description: 'NestJS 백엔드 에코시스템 - 7개 전문가 + 자동 라우팅'
category: development
---

# nestjs-backend Plugin

NestJS 백엔드 개발을 위한 7명의 전문 에이전트와 지능형 라우팅 시스템입니다.

## Core Philosophy

- **단일 책임**: 각 에이전트는 명확한 도메인 전문성
- **자동 라우팅**: 키워드 기반 지능형 전문가 선택
- **협업 능력**: 복합 작업을 위한 에이전트 간 조율

## Expert Agents

| Agent | 전문 분야 | 주요 트리거 |
|-------|----------|------------|
| nestjs-fastify-expert | 오케스트레이터 | "백엔드", "아키텍처" |
| typeorm-expert | DB, ORM, 마이그레이션 | "entity", "typeorm" |
| redis-cache-expert | 캐시, 세션, 분산 락 | "캐시", "redis" |
| bullmq-queue-expert | 작업 큐, 백그라운드 | "큐", "bullmq" |
| cqrs-expert | CQRS, Event Sourcing | "cqrs", "이벤트" |
| microservices-expert | MSA, 서비스 통신 | "마이크로서비스", "gRPC" |
| suites-testing-expert | Suites 3.x, E2E | "테스트", "e2e" |

## Routing System

| 키워드 타입 | 점수 | 예시 |
|------------|------|------|
| Primary | +3 | "redis", "typeorm", "bullmq" |
| Secondary | +2 | "설정", "최적화" |
| Contextual | +1 | 문맥상 관련 |

**실행 전략**: PARALLEL (독립 작업) / SEQUENTIAL (의존성) / HYBRID

## Quick Usage

```bash
"Redis 캐시 TTL 1시간 설정"           # → redis-cache-expert
"캐시와 큐 함께 설정"                  # → [redis + bullmq] 병렬
"인증 시스템 (세션 + 유저 + 이메일)"   # → 오케스트레이터
```

## Structure

```
plugins/nestjs-backend/
├─ CLAUDE.md           # 본 문서
├─ agents/             # 7개 전문가 에이전트
├─ skills/             # 라우팅 스킬
└─ agent-docs/         # 상세 문서
```

## Documentation

- @agent-docs/routing-algorithm.md - 키워드 매칭, 점수 계산, 실행 전략
- @agent-docs/expert-profiles.md - 7명 전문가 상세 프로필과 역할
- @agent-docs/integration-patterns.md - 전문가 간 협업, 오케스트레이션 패턴

@../CLAUDE.md
