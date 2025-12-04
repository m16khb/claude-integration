---
name: full-stack-orchestration
description: '워크플로우 오케스트레이션 - 리뷰, 테스트, 커밋 파이프라인'
category: workflows
---

# full-stack-orchestration Plugin

완전한 개발 파이프라인을 오케스트레이션합니다.

## Overview

- **full-stack-orchestrator**: 최상위 워크플로우 오케스트레이터
- **/dev-flow**: 리뷰 → 테스트 → 커밋 완전 파이프라인
- **ci-cd-patterns**: CI/CD 베스트 프랙티스 모음

## Key Components

### Agents
- `full-stack-orchestrator` - 워크플로우 조율, 품질 게이트 관리

### Commands
- `/dev-flow [skip-review|skip-test]` - 완전 개발 워크플로우 실행

### Skills
- `ci-cd-patterns/` - GitHub Actions, 배치 처리 패턴

## Workflow Pipeline

```
/dev-flow 실행
    ↓
1. code-reviewer 호출 (코드 분석)
    ↓
2. test-automator 호출 (테스트 생성)
    ↓
3. git-workflows 호출 (스마트 커밋)
    ↓
4. 결과 통합 및 보고
```

## Quick Start

```bash
# 완전 파이프라인 실행
/dev-flow

# 리뷰 건너뛰기
/dev-flow skip-review

# 테스트 건너뛰기
/dev-flow skip-test
```

## Integration

- 모든 플러그인을 조율하는 최상위 오케스트레이터
- 품질 게이트 통과 시에만 다음 단계 진행

[parent](../CLAUDE.md)