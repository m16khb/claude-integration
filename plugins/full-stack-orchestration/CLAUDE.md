---
name: full-stack-orchestration
description: '워크플로우 오케스트레이션 - 리뷰, 테스트, 커밋 파이프라인'
category: workflows
---

# full-stack-orchestration Plugin

개발 워크플로우를 자동화하는 최상위 오케스트레이션 시스템입니다. 코드 리뷰, 테스트, 커밋을 하나의 파이프라인으로 통합하여 개발 생산성을 극대화합니다.

## Core Philosophy

```
오케스트레이션 원칙:
├─ 품질 게이트: 각 단계의 품질 기준 충족 확인
├─ 자동화: 반복적인 수동 작업 제거
├─ 피드백 루프: 빠른 피드백과 개선 사이클
├─ 유연성: 필요에 따른 단계 건너뛰기 지원
└─ 가시성: 각 단계의 진행 상황 투명하게 공유
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Full-Stack Orchestrator                   │
└─────────────────────┬───────────────────────────────────────┘
                      │
                /dev-flow Trigger
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                 Workflow Pipeline                            │
│  ┌─────────────┬──────────────┬─────────────────┐         │
│  │   Review    │    Testing   │     Commit      │         │
│  │   Gate      │    Gate      │     Gate        │         │
│  └─────────────┴──────────────┴─────────────────┘         │
│         │              │               │                   │
│         ▼              ▼               ▼                   │
│  ┌─────────────┬──────────────┬─────────────────┐         │
│  │code-reviewer│test-automator│git-workflows    │         │
│  │   Agent     │   Agent      │    Command      │         │
│  └─────────────┴──────────────┴─────────────────┘         │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                   Quality Report                            │
│  • Review Summary    • Test Coverage    • Commit Status   │
└─────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. full-stack-orchestrator Agent

**역할**: 모든 개발 워크플로우의 최상위 조율자

#### 핵심 기능
- **워크플로우 관리**: 정의된 파이프라인 실행 및 모니터링
- **품질 게이트**: 각 단계의 성공 여부 판단 및 다음 단계 진행 여부 결정
- **에러 핸들링**: 실패 시 롤백 또는 수정 제안
- **병렬 실행**: 독립적인 작업은 병렬로 처리하여 시간 단축
- **결과 통합**: 각 단계 결과를 종합하여 최종 보고서 생성

#### 오케스트레이션 로직

```
WORKFLOW ENGINE:
1. Request Analysis
   ├─ 변경된 파일 분석 (Git diff)
   ├─ 영향 범위 추정 (Dependency analysis)
   ├─ 실행 단계 결정 (필요한 단계만 선택)
   └─ 병렬/순차 전략 수립

2. Pipeline Execution
   ├─ Stage 1: Code Review (필수)
   │   ├─ 정적 분석 (Linter, Type check)
   │   ├─ 보안 취약점 스캔
   │   ├─ 코드 스타일 검사
   │   └─ 성능 문제 식별
   │
   ├─ Stage 2: Testing (선택적 건너뛰기 가능)
   │   ├─ 단위 테스트 실행
   │   ├─ 통합 테스트 실행
   │   ├─ E2E 테스트 실행
   │   └─ 커버리지 리포트
   │
   ├─ Stage 3: Commit (자동화)
   │   ├─ 커밋 메시지 생성
   │   ├─ 변경사항 요약
   │   ├─ PR 생성 (선택)
   │   └─ CI 트리거
   │
   └─ Stage 4: Report
       ├─ 품질 점수 계산
       ├─ 개선 제안
       ├─ 다음 작업 제안
       └─ 히스토리 기록

3. Quality Gate Rules
   ├─ CRITICAL: 보안 취약점 → 즉시 중단
   ├─ HIGH: 테스트 실패 → 수정 요구
   ├─ MEDIUM: 스타일 위반 → 커밋 가능 but 개선 권장
   └─ LOW: 미사용 import → 자동 정리
```

### 2. /dev-flow Command

**용도**: 완전한 개발 파이프라인 실행

#### 사용법

```bash
# 기본 실행 (전체 파이프라인)
/dev-flow

# 단계 건너뛰기
/dev-flow skip-review    # 리뷰 건너뛰기 (빠른 수정용)
/dev-flow skip-test     # 테스트 건너뛰기 (문서 변경용)

# 특정 단계만 실행
/dev-flow review-only   # 리뷰만 실행
/dev-flow test-only     # 테스트만 실행
/dev-flow commit-only   # 커밋만 실행

# 옵션 설정
/dev-flow --no-verify     # 서명 없이 커밋
/dev-flow --draft-pr      # Draft PR 생성
/dev-flow --no-ci         # CI 트리거하지 않음
```

#### 실행 파라미터

```yaml
# .claude/dev-flow.yml (설정 파일)
pipeline:
  review:
    enabled: true
    tools: ["eslint", "prettier", "security-scan"]
    thresholds:
      security: "critical"  # critical 이상 실패
      style: "error"        # error 이상 실패

  test:
    enabled: true
    coverage:
      threshold: 80        # 80% 미만 실패
      files: ["src/**/*.{ts,js}"]
    types:
      - unit
      - integration
      - e2e

  commit:
    auto_commit: true
    create_pr: true
    pr_template: "docs/pr-template.md"

  report:
    format: "markdown"
    output: ".claude/reports/"
    include_metrics: true
```

### 3. CI/CD Patterns

**용도**: 다양한 CI/CD 시나리오를 위한 템플릿 모음

#### 지원 패턴

```
CI/CD PATTERNS:
├─ GitHub Actions
│   ├─ Node.js App 배포
│   ├─ Docker 이미지 빌드
│   ├─ Multi-environment 배포
│   └─ Scheduled Jobs
│
├─ GitLab CI
│   ├─ Pipeline Templates
│   ├─ Auto DevOps 통합
│   └─ Runner 설정
│
├─ Jenkins
│   ├─ Jenkinsfile 템플릿
│   ├─ Pipeline as Code
│   └─ 플러그인 설정
│
└─ AWS CodePipeline
    ├─ Build/Deploy 단계
    ├─ CodeBuild 통합
    └─ CloudFormation 배포
```

## Advanced Features

### 1. Smart Workflow Selection

자동으로 프로젝트 상태를 분석하여 최적의 워크플로우를 선택합니다.

```typescript
// 워크플로우 선택 로직 예시
interface WorkflowContext {
  changes: ChangeInfo[];
  branchType: 'feature' | 'hotfix' | 'release';
  filesModified: number;
  hasTests: boolean;
  isProduction: boolean;
}

function selectWorkflow(context: WorkflowContext): Workflow {
  if (context.branchType === 'hotfix') {
    return {
      review: 'quick',
      test: 'smoke-only',
      commit: 'auto-push'
    };
  }

  if (context.isProduction) {
    return {
      review: 'thorough',
      test: 'full-suite',
      commit: 'create-pr'
    };
  }

  return defaultWorkflow;
}
```

### 2. Progressive Enhancement

점진적으로 워크플로우를 개선할 수 있습니다.

```
PROGRESSION LEVELS:
├─ Level 1: Basic (시작)
│   └─ Git commit with validation
│
├─ Level 2: Quality (중급)
│   ├─ Automated code review
│   └─ Basic testing
│
├─ Level 3: Advanced (상급)
│   ├─ Security scanning
│   ├─ Performance testing
│   └─ Auto-PR creation
│
└─ Level 4: Enterprise (기업)
    ├─ Compliance checks
    ├─ Multi-stage approval
    └─ Audit trail
```

### 3. Custom Stage Integration

사용자 정의 단계를 추가할 수 있습니다.

```yaml
# .claude/custom-stages.yml
custom_stages:
  - name: "security-scan"
    command: "npm audit"
    required: true
    on_failure: "block"

  - name: "performance-test"
    command: "npm run lighthouse"
    required: false
    on_failure: "warn"

  - name: "deploy-preview"
    command: "vercel --preview"
    required: false
    on_failure: "notify"
```

## Integration Examples

### 1. Feature Development Workflow

```bash
# 새 기능 개발 시나리오
git checkout -b feature/new-auth
# ... 코드 작성 ...

# 전체 파이프라인 실행
/dev-flow

# 결과:
# 1. 코드 리뷰: 2개 제안사항 발견
# 2. 테스트: 95% 커버리지 달성
# 3. 커밋: 자동으로 커밋 메시지 생성
# 4. PR: 자동으로 PR 생성 및 CI 트리거
```

### 2. Hotfix Workflow

```bash
# 긴급 수정 시나리오
git checkout -b hotfix/security-patch
# ... 수정 코드 작성 ...

# 빠른 파이프라인 (리뷰만)
/dev-flow review-only --urgency high

# 결과:
# 1. 보안 스캔만 실행
# 2. 즉시 커밋 및 push
# 3. hotfix 브랜치로 merge 제안
```

### 3. Documentation Update

```bash
# 문서 업데이트 시나리오
# ... 문서 수정 ...

# 최소 워크플로우
/dev-flow skip-review skip-test

# 결과:
# 1. 스펠링 체크만 실행
# 2. 자동으로 커밋
# 3. "docs:" 태그로 커밋
```

## Quality Metrics

각 실행 후 품질 지표를 제공합니다.

```json
{
  "quality_score": 92,
  "metrics": {
    "code_review": {
      "issues_found": 3,
      "critical": 0,
      "high": 1,
      "medium": 2,
      "fixed_automatically": 1
    },
    "testing": {
      "coverage": 87,
      "tests_run": 245,
      "passed": 242,
      "failed": 3,
      "flaky": 0
    },
    "security": {
      "vulnerabilities": 0,
      "dependencies_audited": 1234,
      "outdated_packages": 5
    },
    "performance": {
      "bundle_size_change": "+2.3KB",
      "lighthouse_score": 95,
      "build_time": "2.3s"
    }
  },
  "recommendations": [
    "Update 5 outdated dependencies",
    "Fix 2 failing test cases",
    "Consider lazy loading for large components"
  ]
}
```

## Best Practices

### 1. 워크플로우 설계
- **작게 유지**: 각 단계는 명확한 책임을 가짐
- **빠른 피드백**: 5분 이내에 결과 제공
- **롤백 용이**: 실패 시 쉽게 원상복구 가능
- **점진적**: 복잡도를 점진적으로 증가

### 2. 품질 게이트
- **명확한 기준**: 각 단계의 성공 기준 명시
- **자동화**: 사람의 개입 최소화
- **예외 처리**: 긴급 상황을 위한 예외 경로
- **학습**: 실패로부터 학습하고 개선

### 3. 팀 워크플로우
- **일관성**: 모든 팀원이 동일한 프로세스 사용
- **투명성**: 진행 상황을 모두가 볼 수 있음
- **협업**: PR 리뷰, 코드 오너십 명확
- **지속적 개선**: 정기적인 워크플로우 검토

## Troubleshooting

### 일반적인 문제

#### 워크플로우 중단
```
문제: 파이프라인이 중간에 멈춤
원인: 품질 게이트 실패
해결:
1. 실패한 단계 확인: /dev-flow --status
2. 상세 오류 로그 확인: .claude/logs/
3. 수정 후 재시작: /dev-flow --resume
```

#### 병렬 실행 충돌
```
문제: 병렬 작업 간 충돌 발생
원인: 공유 자원 접근
해결:
1. 의존성 분석: dependency-graph 생성
2. 실행 순서 재정렬
3. Locking 메커니즘 적용
```

#### 성능 저하
```
문제: 워크플로우 실행이 너무 느림
원인: 불필요한 단계 실행
해결:
1. 워크플로우 최적화: --analyze
2. 불필요한 단계 비활성화
3. 캐싱 적용: --cache-results
```

## Performance Optimization

### 1. 병렬 처리
- 독립적인 작업은 병렬로 실행
- 워커 풀 관리로 리소스 효율화
- 결과 캐싱으로 반복 작업 방지

### 2. 증분 실행
- 변경된 파일만 대상으로 실행
- 의존성 그래프 기반 스마트 실행
- 이전 결과 재활용

### 3. 리소스 관리
- Docker 컨테이너 격리
- 메모리 사용량 모니터링
- 타임아웃 설정으로 무한 실행 방지

## Configuration

### 프로젝트 설정 (.claude/orchestration.yml)

```yaml
project:
  name: "my-awesome-app"
  type: "nodejs"  # nodejs, python, go, etc.

pipeline:
  default:
    stages: ["review", "test", "commit"]
    timeout: "10m"

  pull_request:
    stages: ["review", "test", "security", "commit"]
    require_approval: true

  release:
    stages: ["review", "test", "security", "performance", "deploy"]
    require_tests: true

notifications:
  slack:
    webhook: "${SLACK_WEBHOOK_URL}"
    channels: ["#dev", "#qa"]

  email:
    on_failure: true
    recipients: ["team@example.com"]

integrations:
  jira:
    url: "https://company.atlassian.net"
    project_key: "APP"

  sonarqube:
    url: "https://sonar.company.com"
    project_key: "my-app"
```

[parent](../CLAUDE.md)