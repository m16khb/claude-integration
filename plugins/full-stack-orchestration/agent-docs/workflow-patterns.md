# Workflow Patterns

> 개발 시나리오별 워크플로우 패턴 및 /dev-flow 상세 가이드

## /dev-flow Command

### 기본 사용법

```bash
# 전체 파이프라인 실행
/dev-flow

# 단계 건너뛰기
/dev-flow skip-review    # 리뷰 건너뛰기 (빠른 수정용)
/dev-flow skip-test      # 테스트 건너뛰기 (문서 변경용)

# 특정 단계만 실행
/dev-flow review-only    # 리뷰만 실행
/dev-flow test-only      # 테스트만 실행
/dev-flow commit-only    # 커밋만 실행
```

### 고급 옵션

```bash
# Git 관련
/dev-flow --no-verify      # 서명 없이 커밋
/dev-flow --amend          # 마지막 커밋 수정

# PR 관련
/dev-flow --draft-pr       # Draft PR 생성
/dev-flow --no-pr          # PR 생성 안 함

# CI 관련
/dev-flow --no-ci          # CI 트리거하지 않음
/dev-flow --skip-hooks     # Git hooks 건너뛰기

# 보고서 관련
/dev-flow --verbose        # 상세 출력
/dev-flow --json           # JSON 형식 출력
/dev-flow --output report.md  # 파일로 저장
```

---

## 설정 파일

### dev-flow.yml

```yaml
# .claude/dev-flow.yml
pipeline:
  # 코드 리뷰 설정
  review:
    enabled: true
    tools:
      - eslint
      - prettier
      - security-scan
      - complexity-check
    thresholds:
      security: "critical"   # critical 이상만 실패
      style: "error"         # error 이상만 실패
      complexity: 15         # 순환 복잡도 최대값

  # 테스트 설정
  test:
    enabled: true
    coverage:
      threshold: 80          # 최소 커버리지
      files:
        - "src/**/*.{ts,js}"
        - "!src/**/*.spec.ts"
    types:
      - unit
      - integration
      # - e2e  # 선택적
    parallel: true
    timeout: 300000          # 5분

  # 커밋 설정
  commit:
    auto_commit: true
    create_pr: true
    pr_template: "docs/pr-template.md"
    conventional:
      enabled: true
      types:
        - feat
        - fix
        - refactor
        - docs
        - test
        - chore

  # 보고서 설정
  report:
    format: "markdown"
    output: ".claude/reports/"
    include_metrics: true
    history: 10              # 최근 10개 기록 유지
```

---

## 시나리오별 워크플로우

### 1. Feature Development

새 기능 개발 시 권장 워크플로우:

```bash
# 1. 브랜치 생성
git checkout -b feature/new-auth

# 2. 개발 작업 수행
# ... 코드 작성 ...

# 3. 전체 파이프라인 실행
/dev-flow

# 결과:
# ✓ Code Review: 2개 경고 (자동 수정됨)
# ✓ Testing: 95% 커버리지
# ✓ Commit: "feat: 새로운 인증 시스템 구현"
# ✓ PR: #123 생성됨
```

### 2. Hotfix

긴급 수정 시 빠른 워크플로우:

```bash
# 1. 핫픽스 브랜치 생성
git checkout -b hotfix/security-patch

# 2. 수정 작업
# ... 패치 적용 ...

# 3. 빠른 파이프라인
/dev-flow --urgency high

# 결과:
# ✓ Security Scan: 취약점 해결 확인
# ✓ Smoke Test: 핵심 기능 정상
# ✓ Commit + Push: 즉시 반영
```

### 3. Documentation Update

문서만 변경 시 최소 워크플로우:

```bash
# 1. 문서 브랜치
git checkout -b docs/update-readme

# 2. 문서 수정
# ... README.md 수정 ...

# 3. 문서용 파이프라인
/dev-flow skip-review skip-test

# 결과:
# ✓ Spell Check: 통과
# ✓ Commit: "docs: README 업데이트"
```

### 4. Release Preparation

릴리스 준비 시 전체 검증 워크플로우:

```bash
# 1. 릴리스 브랜치
git checkout -b release/v1.2.0

# 2. 전체 검증 파이프라인
/dev-flow --thorough

# 결과:
# ✓ Full Code Review
# ✓ Complete Test Suite
# ✓ Security Audit
# ✓ Performance Test
# ✓ Changelog Generation
# ✓ Version Bump
```

---

## Progressive Enhancement

### 단계별 워크플로우 도입

```
PROGRESSION LEVELS:
├── Level 1: Basic (시작 단계)
│   └── Git commit with basic validation
│   └── 적합: 개인 프로젝트, 초기 설정
│
├── Level 2: Quality (품질 관리)
│   ├── Automated code review
│   ├── Basic testing (unit)
│   └── 적합: 소규모 팀 프로젝트
│
├── Level 3: Advanced (고급 자동화)
│   ├── Security scanning
│   ├── Full test coverage
│   ├── Auto-PR creation
│   └── 적합: 중규모 팀, 프로덕션
│
└── Level 4: Enterprise (기업 수준)
    ├── Compliance checks
    ├── Multi-stage approval
    ├── Audit trail
    ├── Integration with JIRA/Slack
    └── 적합: 대규모 조직, 규제 환경
```

---

## Custom Stages

### 사용자 정의 단계 추가

```yaml
# .claude/custom-stages.yml
custom_stages:
  - name: "security-scan"
    position: "after:review"
    command: "npm audit --audit-level=high"
    required: true
    on_failure: "block"
    timeout: 60000

  - name: "performance-test"
    position: "after:test"
    command: "npm run lighthouse"
    required: false
    on_failure: "warn"
    timeout: 120000

  - name: "deploy-preview"
    position: "after:commit"
    command: "vercel --preview"
    required: false
    on_failure: "notify"
    env:
      VERCEL_TOKEN: "${VERCEL_TOKEN}"

  - name: "notify-slack"
    position: "final"
    command: "node scripts/notify.js"
    required: false
    on_failure: "ignore"
```

### 조건부 실행

```yaml
custom_stages:
  - name: "e2e-test"
    condition:
      branch: "release/*"
      files: "src/**/*.ts"
    command: "npm run test:e2e"

  - name: "deploy-staging"
    condition:
      branch: "develop"
      day: ["Mon", "Tue", "Wed", "Thu", "Fri"]
    command: "npm run deploy:staging"
```

---

## Quality Metrics

### 실행 후 품질 지표

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
      "flaky": 0,
      "duration_ms": 45230
    },
    "security": {
      "vulnerabilities": 0,
      "dependencies_audited": 1234,
      "outdated_packages": 5
    },
    "performance": {
      "bundle_size_change": "+2.3KB",
      "lighthouse_score": 95,
      "build_time_ms": 2300
    }
  },
  "recommendations": [
    "Update 5 outdated dependencies",
    "Fix 3 failing test cases",
    "Consider lazy loading for large components"
  ]
}
```

---

@../CLAUDE.md | @pipeline-architecture.md | @ci-cd-integration.md
