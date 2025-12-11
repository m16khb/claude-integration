---
name: full-stack-orchestration
description: '워크플로우 오케스트레이션 - 리뷰, 테스트, 커밋 파이프라인'
category: workflows
---

# full-stack-orchestration Plugin

개발 워크플로우를 자동화하는 최상위 오케스트레이션 시스템입니다.

## Core Philosophy

```
ORCHESTRATION PIPELINE:
Request → Analysis → Review Gate → Test Gate → Commit Gate → Report
```

- **품질 게이트**: 각 단계의 품질 기준 충족 확인
- **자동화**: 반복적인 수동 작업 제거
- **유연성**: 필요에 따른 단계 건너뛰기 지원

## Components

| 컴포넌트 | 타입 | 설명 |
|---------|------|------|
| @agents/full-stack-orchestrator.md | Agent | 워크플로우 조율자 (Opus) |
| @commands/dev-flow.md | Command | 파이프라인 실행 |
| @skills/ci-cd-patterns/SKILL.md | Skill | CI/CD 템플릿 |

## /dev-flow Command

```bash
# 전체 파이프라인 실행 (권장)
/full-stack-orchestration:dev-flow

# 단계 건너뛰기
/full-stack-orchestration:dev-flow skip-review    # 리뷰 건너뛰기
/full-stack-orchestration:dev-flow skip-test      # 테스트 건너뛰기

# 고급 옵션
/full-stack-orchestration:dev-flow --draft-pr     # Draft PR 생성
/full-stack-orchestration:dev-flow --verbose      # 상세 출력
```

## Pipeline Stages

```
Stage 1: Code Review (필수)
├─ ESLint, TypeCheck, Security Scan
└─ Gate: CRITICAL/HIGH → 중단

Stage 2: Testing (선택적)
├─ Unit, Integration, E2E
└─ Gate: 커버리지 80%+ 필요

Stage 3: Commit (자동화)
├─ Conventional Commits 메시지
└─ PR 생성 + CI 트리거
```

## Quality Gates

| 레벨 | 조건 | 동작 |
|------|------|------|
| CRITICAL | 보안 취약점 | 즉시 중단 |
| HIGH | 테스트 실패 | 수정 요구 |
| MEDIUM | 스타일 위반 | 커밋 가능 |
| LOW | 미사용 import | 자동 정리 |

## Workflow Scenarios

### Feature Development
```bash
git checkout -b feature/new-auth
# ... 개발 작업 ...
/full-stack-orchestration:dev-flow
# 결과: Review ✓ → Test ✓ → Commit ✓ → PR #123
```

### Hotfix
```bash
git checkout -b hotfix/security-patch
/full-stack-orchestration:dev-flow skip-test
# 결과: Security Scan ✓ → Commit + Push
```

## Agent Collaboration

```
full-stack-orchestrator (최상위)
    ├─ code-reviewer (리뷰)
    ├─ test-automator (테스트)
    └─ git-commit (커밋)
```

## Structure

```
plugins/full-stack-orchestration/
├─ CLAUDE.md
├─ agents/full-stack-orchestrator.md
├─ commands/dev-flow.md
├─ skills/ci-cd-patterns/
└─ agent-docs/
```

## Best Practices

```
DO ✅:
├─ 전체 파이프라인 실행 (/dev-flow)
├─ CRITICAL 이슈 즉시 수정
└─ 커버리지 80%+ 유지

DON'T ❌:
├─ CRITICAL/HIGH 무시하고 커밋
└─ --skip-hooks 남용
```

## Documentation

- @agent-docs/pipeline-architecture.md - 파이프라인 아키텍처, Quality Gates 상세
- @agent-docs/workflow-patterns.md - /dev-flow 사용법, 시나리오별 패턴
- @agent-docs/ci-cd-integration.md - GitHub Actions, GitLab CI, Jenkins 템플릿
- @agent-docs/troubleshooting.md - 문제 해결, 디버깅

@../CLAUDE.md
