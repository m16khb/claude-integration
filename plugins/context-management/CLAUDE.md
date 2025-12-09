---
name: context-management
description: '컨텍스트 관리 - 대용량 파일 처리, 작업 추천, 인지 부하 감소'
category: productivity
---

# context-management Plugin

대용량 코드베이스의 복잡성을 관리하고 개발 흐름을 최적화하는 지능형 컨텍스트 관리 시스템입니다.

## Core Philosophy

```
컨텍스트 관리 원칙:
├─ 정보 압축: 대용량 파일을 의미 있는 청크로 분할
├─ 관계 추출: 파일 간 의존성과 영향도 분석
├─ 스마트 필터링: 현재 작업에 관련된 정보만 선택
├─ 진행 상태 추적: 작업 컨텍스트와 상태 지속성 보장
└─ 인지 부하 최소화: 개발자가 집중해야 할 것에만 집중
```

## Architecture

```
┌───────────────────────────────────────────┐
│        Context Management Engine          │
│                                           │
│  Input ─► Analyzer ─► Context Graph       │
│    │         │             │              │
│    ▼         ▼             ▼              │
│  Scanner  Extractor    Chunking           │
│    └─────────┴─────────────┘              │
│              │                            │
│      Context Store + Relevance Scoring    │
└───────────────────────────────────────────┘
```

## Components

| 컴포넌트 | 타입 | 설명 |
|---------|------|------|
| [continue-context](commands/continue-context.md) | Command | 컨텍스트 분석 및 다음 작업 추천 |
| [inject-context](commands/inject-context.md) | Command | 대용량 파일 구조 인식 청킹 |

## 주요 기능

### continue-context
- 현재 작업 상태 분석 (Git, 파일, 히스토리)
- 패턴 인식 및 다음 단계 추천
- Sequential Thinking MCP 연동

### inject-context
- 구조적 경계 존중 청킹 (800줄, 20줄 오버랩)
- 언어별 AST 파싱 (TS/JS, Python, Go, Rust, Java 등)
- MCP Memory 연동으로 관련 메모리 자동 로드

## Quick Start

```bash
# 컨텍스트 분석 및 작업 추천
/context-management:continue-context

# 대용량 파일 로드
/context-management:inject-context src/app.module.ts

# 태스크와 함께 로드
/context-management:inject-context src/auth/ "인증 모듈 분석"
```

## 상세 문서

- [chunking-algorithm.md](agent-docs/chunking-algorithm.md) - 구조 인식 청킹, 언어별 파싱, AST 경계
- [context-analysis.md](agent-docs/context-analysis.md) - 컨텍스트 분석, 패턴 인식, 작업 추천
- [recovery-patterns.md](agent-docs/recovery-patterns.md) - 세션 복구, 작업 연속성, MCP 연동

[parent](../CLAUDE.md)
