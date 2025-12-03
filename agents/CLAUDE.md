# agents/ CLAUDE.md

## 모듈 개요

**전문 에이전트 정의 모듈**입니다. Task 도구로 호출되는 특화된 에이전트를 정의합니다.

## 파일 구조

```
agents/
├── CLAUDE.md              # 이 파일
├── backend/               # NestJS 생태계 에이전트
│   ├── CLAUDE.md
│   └── *.md
├── document/              # 문서화 에이전트
│   ├── CLAUDE.md
│   ├── document-builder.md
│   └── agent-docs/
├── frontend/              # (예정)
└── infrastructure/        # (예정)
```

## 하위 모듈

| 모듈 | 전문 분야 | 상태 |
|------|----------|------|
| [backend/](backend/CLAUDE.md) | NestJS + Fastify 생태계 | ✅ 활성 |
| [document/](document/CLAUDE.md) | CLAUDE.md, agent-docs 생성 | ✅ 활성 |
| frontend/ | React, Vue 등 프론트엔드 | 🚧 예정 |
| infrastructure/ | Docker, K8s, CI/CD | 🚧 예정 |

## 에이전트 유형

```
AGENT TYPES:
├─ Orchestrator: 요청 분석 → 전문가 위임 → 결과 통합
├─ Expert: 특정 기술 영역 전문 처리
└─ Utility: 공통 작업 자동화
```

## 에이전트 작성 가이드

### Frontmatter 필수 항목

```yaml
---
name: agent-name
description: '에이전트 설명'
model: claude-opus-4-5-20251101
allowed-tools: [Read, Write, Edit, Glob, Grep, Task]
---
```

### 필수 섹션

1. **ROLE**: 역할 및 전문 분야 (영어)
2. **INPUT FORMAT**: JSON 입력 형식
3. **OUTPUT FORMAT**: JSON 출력 형식
4. **EXECUTION FLOW**: 실행 흐름 (영어)
5. **ERROR HANDLING**: 오류 처리

## 상세 문서

- [agent-docs/agents.md](../agent-docs/agents.md) - 전체 에이전트 목록

## 참조

- [Root CLAUDE.md](../CLAUDE.md)
