---
name: nestjs-backend
description: 'NestJS 백엔드 에코시스템 - 7개 전문가 + 자동 라우팅'
category: development
---

# nestjs-backend Plugin

NestJS 백엔드 개발을 위한 완전한 전문가 시스템입니다.

## Overview

- **7개 전문 에이전트**: TypeORM, Redis, BullMQ, CQRS, Microservices, Testing
- **nestjs-fastify-expert**: 백엔드 오케스트레이터
- **agent-routing**: 자동 전문가 선택 시스템

## Key Components

### Orchestrator
- `nestjs-fastify-expert` - 요청 분석 → 전문가 선택 → 복합 작업 조율

### Experts (7개)
1. `typeorm-expert` - 데이터베이스 설계 및 ORM
2. `redis-cache-expert` - 캐시 전략 및 세션 관리
3. `bullmq-queue-expert` - 작업 큐 및 백그라운드 처리
4. `cqrs-expert` - CQRS 패턴 및 이벤트 소싱
5. `microservices-expert` - 마이크로서비스 아키텍처
6. `suites-testing-expert` - Suites 3.x 테스트 전략

### Skills
- `agent-routing/` - 키워드 기반 자동 전문가 선택

## Agent Routing System

```json
"Redis 캐시 설정" → redis-cache-expert
"TypeORM 엔티티" → typeorm-expert
"캐시+큐 설정" → [redis, bullmq] 병렬 실행
```

## Quick Start

```bash
# 자동 전문가 선택
"Redis 캐시 TTL 설정해줘"

# 오케스트레이터 직접 호출
# 캐시와 큐를 함께 설정하는 복합 작업 요청
```

## Features

- **Auto-detection**: 키워드로 적절한 전문가 자동 선택
- **Sequential/Parallel**: 작업 유형에 따른 실행 전략
- **NestJS Best Practices**: 프레임워크 표준 준수

[parent](../CLAUDE.md)