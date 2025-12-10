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
┌─────────────────────────────────────────────────────────┐
│  Request → Analysis → Pipeline Execute → Quality Gates │
│                                                         │
│  ├─ Change Detection (Git diff)                        │
│  ├─ Impact Analysis (Dependency graph)                 │
│  ├─ Stage Selection (Context-aware)                    │
│  └─ Progressive Gates (CRITICAL → HIGH → LOW)          │
└─────────────────────────────────────────────────────────┘
```

- **품질 게이트**: 각 단계의 품질 기준 충족 확인
- **자동화**: 반복적인 수동 작업 제거
- **피드백 루프**: 빠른 피드백과 개선 사이클
- **유연성**: 필요에 따른 단계 건너뛰기 지원
- **가시성**: 각 단계의 진행 상황 투명하게 공유

## Architecture

```
                    ┌─────────────────────────────────┐
                    │    Full-Stack Orchestrator      │
                    │    (최상위 워크플로우 조율)      │
                    └────────────────┬────────────────┘
                                     │ /dev-flow
         ┌───────────────────────────┼───────────────────────────┐
         │                           │                           │
         ▼                           ▼                           ▼
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│  Review Gate    │  ───► │  Testing Gate   │  ───► │  Commit Gate    │
│                 │       │                 │       │                 │
│ ├─ ESLint       │       │ ├─ Unit Tests   │       │ ├─ Conventional │
│ ├─ TypeCheck    │       │ ├─ Integration  │       │ ├─ Changelog    │
│ ├─ Security     │       │ ├─ E2E         │       │ ├─ PR Create    │
│ └─ Complexity   │       │ └─ Coverage     │       │ └─ CI Trigger   │
└────────┬────────┘       └────────┬────────┘       └────────┬────────┘
         │                         │                         │
         └─────────► code-reviewer │ test-automator ◄────────┘
                                   │
                            git-workflows
```

## Components

| 컴포넌트 | 타입 | 설명 |
|---------|------|------|
| @agents/full-stack-orchestrator.md | Agent | 최상위 워크플로우 조율자 (Opus) |
| @commands/dev-flow.md | Command | 파이프라인 실행 |
| @skills/ci-cd-patterns/SKILL.md | Skill | CI/CD 템플릿 |

## /dev-flow Command

### 기본 사용법

```bash
# 전체 파이프라인 실행 (권장)
/full-stack-orchestration:dev-flow

# 단계 건너뛰기 (빠른 수정 시)
/full-stack-orchestration:dev-flow skip-review
/full-stack-orchestration:dev-flow skip-test

# 특정 단계만 실행
/full-stack-orchestration:dev-flow review-only
/full-stack-orchestration:dev-flow commit-only
```

### 고급 옵션

```bash
# PR 관련
/full-stack-orchestration:dev-flow --draft-pr    # Draft PR 생성
/full-stack-orchestration:dev-flow --no-pr       # PR 없이 푸시

# 출력 형식
/full-stack-orchestration:dev-flow --verbose     # 상세 출력
/full-stack-orchestration:dev-flow --json        # JSON 형식 (CI용)
```

## Pipeline Stages

```
STAGE 순서:
Stage 1: Code Review (필수)
├─ 정적 분석 (ESLint, TypeCheck)
├─ 보안 스캔 (OWASP)
├─ 코드 복잡도 검사
└─ Gate: CRITICAL/HIGH → 중단

        ↓ success

Stage 2: Testing (선택적)
├─ 단위 테스트 (Jest, Vitest)
├─ 통합 테스트 (Testcontainers)
├─ E2E 테스트 (Playwright)
└─ Gate: 커버리지 80%+ 필요

        ↓ success

Stage 3: Commit (자동화)
├─ Conventional Commits 메시지
├─ Changelog 생성
├─ PR 생성 (선택)
└─ CI 트리거
```

## Quality Gates

| 레벨 | 조건 | 동작 | 자동 수정 |
|------|------|------|----------|
| CRITICAL | 보안 취약점 | 즉시 중단 | 불가 |
| HIGH | 테스트 실패 | 수정 요구 | 부분 가능 |
| MEDIUM | 스타일 위반 | 커밋 가능 | 가능 |
| LOW | 미사용 import | 자동 정리 | 자동 |

## Workflow Scenarios

### Feature Development

```bash
# 새 기능 개발 → 전체 파이프라인
git checkout -b feature/new-auth
# ... 개발 작업 ...
/full-stack-orchestration:dev-flow

# 결과:
# ✓ Review: 2개 경고 (자동 수정)
# ✓ Test: 95% 커버리지
# ✓ Commit: "feat: 인증 시스템 구현"
# ✓ PR: #123 생성됨
```

### Hotfix

```bash
# 긴급 수정 → 빠른 파이프라인
git checkout -b hotfix/security-patch
# ... 패치 적용 ...
/full-stack-orchestration:dev-flow skip-test

# 결과:
# ✓ Security Scan: 취약점 해결
# ✓ Commit + Push: 즉시 반영
```

### Documentation

```bash
# 문서 변경 → 최소 파이프라인
git checkout -b docs/update-readme
# ... 문서 수정 ...
/full-stack-orchestration:dev-flow skip-review skip-test

# 결과:
# ✓ Spell Check: 통과
# ✓ Commit: "docs: README 업데이트"
```

## Agent Collaboration

```
ORCHESTRATOR 워크플로우:
┌─────────────────────────────────────────────────────────┐
│              full-stack-orchestrator                    │
│                  (워크플로우 조율)                       │
└───────────────────────┬─────────────────────────────────┘
                        │
    ┌───────────────────┼───────────────────┐
    ▼                   ▼                   ▼
┌─────────┐      ┌──────────────┐      ┌─────────────┐
│ code-   │      │ test-        │      │ git-commit  │
│reviewer │      │ automator    │      │ (command)   │
│ (Agent) │      │ (Agent)      │      │             │
└─────────┘      └──────────────┘      └─────────────┘
    │                   │                    │
    ▼                   ▼                    ▼
  Review             Testing              Commit
  Report             Report              Message
```

## CI/CD Integration

| 플랫폼 | 템플릿 | 설명 |
|--------|--------|------|
| GitHub Actions | @agent-docs/ci-cd-integration.md | Node.js, Docker, Matrix |
| GitLab CI | @agent-docs/ci-cd-integration.md | 병렬 Stage, 캐싱 |
| Jenkins | @agent-docs/ci-cd-integration.md | Declarative Pipeline |
| AWS CodePipeline | @agent-docs/ci-cd-integration.md | CloudFormation |

## Structure

```
plugins/full-stack-orchestration/
├─ CLAUDE.md                      # 본 문서
├─ agents/
│   └─ full-stack-orchestrator.md # 워크플로우 조율자
├─ commands/
│   └─ dev-flow.md                # /dev-flow 커맨드
├─ skills/
│   └─ ci-cd-patterns/            # CI/CD 패턴 스킬
└─ agent-docs/                    # 상세 문서
    ├─ pipeline-architecture.md   # 파이프라인 아키텍처
    ├─ workflow-patterns.md       # 워크플로우 패턴
    ├─ ci-cd-integration.md       # CI/CD 통합
    └─ troubleshooting.md         # 문제 해결
```

## Best Practices

```
DO ✅:
├─ 전체 파이프라인 실행 (/dev-flow)
├─ CRITICAL 이슈 즉시 수정
├─ 커버리지 80%+ 유지
└─ Conventional Commits 준수

DON'T ❌:
├─ CRITICAL/HIGH 무시하고 커밋
├─ 테스트 없이 프로덕션 배포
├─ --skip-hooks 남용
└─ 리뷰 없이 main 직접 푸시
```

## Documentation

- @agent-docs/pipeline-architecture.md - 파이프라인 아키텍처, Quality Gates 상세
- @agent-docs/workflow-patterns.md - /dev-flow 사용법, 시나리오별 패턴, 커스텀 Stage
- @agent-docs/ci-cd-integration.md - GitHub Actions, GitLab CI, Jenkins 템플릿
- @agent-docs/troubleshooting.md - 문제 해결, 디버깅, Best Practices

@../CLAUDE.md
