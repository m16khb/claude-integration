# Full-Stack Orchestration 상세 가이드

## Workflow Engine

오케스트레이션 엔진은 다음 단계로 파이프라인을 실행합니다.

### 1. Request Analysis

```
REQUEST ANALYSIS:
├── 변경된 파일 분석 (Git diff)
├── 영향 범위 추정 (Dependency analysis)
├── 실행 단계 결정 (필요한 단계만 선택)
└── 병렬/순차 전략 수립
```

### 2. Pipeline Execution

```
PIPELINE STAGES:
├── Stage 1: Code Review (필수)
│   ├── 정적 분석 (Linter, Type check)
│   ├── 보안 취약점 스캔
│   ├── 코드 스타일 검사
│   └── 성능 문제 식별
│
├── Stage 2: Testing (선택적 건너뛰기 가능)
│   ├── 단위 테스트 실행
│   ├── 통합 테스트 실행
│   ├── E2E 테스트 실행
│   └── 커버리지 리포트
│
├── Stage 3: Commit (자동화)
│   ├── 커밋 메시지 생성
│   ├── 변경사항 요약
│   ├── PR 생성 (선택)
│   └── CI 트리거
│
└── Stage 4: Report
    ├── 품질 점수 계산
    ├── 개선 제안
    ├── 다음 작업 제안
    └── 히스토리 기록
```

### 3. Quality Gate Rules

```
QUALITY GATE SEVERITY:
├── CRITICAL: 보안 취약점 → 즉시 중단
├── HIGH: 테스트 실패 → 수정 요구
├── MEDIUM: 스타일 위반 → 커밋 가능 but 개선 권장
└── LOW: 미사용 import → 자동 정리
```

---

## /dev-flow Command 상세

### 사용법

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

### 설정 파일 (dev-flow.yml)

```yaml
# .claude/dev-flow.yml
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

---

## CI/CD Patterns

다양한 CI/CD 시나리오를 위한 템플릿 모음입니다.

```
CI/CD PATTERNS:
├── GitHub Actions
│   ├── Node.js App 배포
│   ├── Docker 이미지 빌드
│   ├── Multi-environment 배포
│   └── Scheduled Jobs
│
├── GitLab CI
│   ├── Pipeline Templates
│   ├── Auto DevOps 통합
│   └── Runner 설정
│
├── Jenkins
│   ├── Jenkinsfile 템플릿
│   ├── Pipeline as Code
│   └── 플러그인 설정
│
└── AWS CodePipeline
    ├── Build/Deploy 단계
    ├── CodeBuild 통합
    └── CloudFormation 배포
```

---

## Advanced Features

### 1. Smart Workflow Selection

자동으로 프로젝트 상태를 분석하여 최적의 워크플로우를 선택합니다.

```typescript
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
├── Level 1: Basic (시작)
│   └── Git commit with validation
│
├── Level 2: Quality (중급)
│   ├── Automated code review
│   └── Basic testing
│
├── Level 3: Advanced (상급)
│   ├── Security scanning
│   ├── Performance testing
│   └── Auto-PR creation
│
└── Level 4: Enterprise (기업)
    ├── Compliance checks
    ├── Multi-stage approval
    └── Audit trail
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

---

[CLAUDE.md로 돌아가기](../CLAUDE.md) | [예제](examples.md) | [참고 자료](references.md)
