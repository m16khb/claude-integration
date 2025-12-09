---
name: full-stack-orchestration
description: '워크플로우 오케스트레이션 - 리뷰, 테스트, 커밋 파이프라인'
category: workflows
---

# full-stack-orchestration Plugin

개발 워크플로우를 자동화하는 최상위 오케스트레이션 시스템입니다.

## Core Philosophy

| 원칙 | 설명 |
|------|------|
| 품질 게이트 | 각 단계의 품질 기준 충족 확인 |
| 자동화 | 반복적인 수동 작업 제거 |
| 피드백 루프 | 빠른 피드백과 개선 사이클 |
| 유연성 | 필요에 따른 단계 건너뛰기 지원 |
| 가시성 | 각 단계의 진행 상황 투명하게 공유 |

## Architecture

```
┌─────────────────────────────────────────────────┐
│           Full-Stack Orchestrator               │
└──────────────────────┬──────────────────────────┘
                       │ /dev-flow
┌──────────────────────▼──────────────────────────┐
│  [Review Gate] → [Testing Gate] → [Commit Gate] │
│       │              │                │         │
│  code-reviewer  test-automator   git-workflows  │
└─────────────────────────────────────────────────┘
```

## Components

| 컴포넌트 | 타입 | 설명 |
|---------|------|------|
| [full-stack-orchestrator](agents/full-stack-orchestrator.md) | Agent | 워크플로우 조율자 |
| [/dev-flow](commands/dev-flow.md) | Command | 파이프라인 실행 |
| [ci-cd-patterns](skills/ci-cd-patterns/SKILL.md) | Skill | CI/CD 템플릿 |

## Quick Start

```bash
# 전체 파이프라인
/dev-flow

# 단계 건너뛰기
/dev-flow skip-review
/dev-flow skip-test

# 특정 단계만
/dev-flow review-only
/dev-flow commit-only

# 옵션
/dev-flow --draft-pr
```

## Quality Gates

| 레벨 | 조건 | 동작 |
|------|------|------|
| CRITICAL | 보안 취약점 | 즉시 중단 |
| HIGH | 테스트 실패 | 수정 요구 |
| MEDIUM | 스타일 위반 | 커밋 가능, 개선 권장 |
| LOW | 미사용 import | 자동 정리 |

## 상세 문서

| 문서 | 내용 |
|------|------|
| [detailed-guides.md](agent-docs/detailed-guides.md) | Workflow Engine, Pipeline, CI/CD Patterns |
| [examples.md](agent-docs/examples.md) | Feature/Hotfix/Docs 워크플로우 예제 |
| [references.md](agent-docs/references.md) | Best Practices, Troubleshooting, Configuration |

---

[parent](../CLAUDE.md)
