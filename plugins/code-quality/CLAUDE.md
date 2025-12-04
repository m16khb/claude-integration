---
name: code-quality
description: '코드 품질 관리 - 리뷰, 테스트 자동화, 보안 분석'
category: quality
---

# code-quality Plugin

코드 품질을 체계적으로 관리하고 개선하는 통합 플랫폼입니다. 정적 분석, 동적 테스트, 보안 검증을 통해 프로덕션 레벨의 코드 품질을 보장합니다.

## Core Philosophy

```
코드 품질 원칙:
├─ 선제적 검증: 문제가 발생하기 전에 미리 발견
├─ 자동화: 반복적인 품질 검사 프로세스 자동화
├─ 측정 가능성: 품질 지표를 데이터로 추적
├─ 지속적 개선: 피드백 루프를 통한 점진적 향상
└─ 팀 교육: 코드 리뷰를 통한 지식 공유
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                Code Quality Platform                         │
│                                                             │
│  Source Code ──► Analysis Pipeline ──► Quality Report        │
│       │               │                  │                │
│       ▼               ▼                  ▼                │
│  ┌─────────┐    ┌─────────────┐    ┌─────────────────┐     │
│  │ Static   │    │ Dynamic      │    │ Security        │     │
│  │ Analysis │    │ Analysis     │    │ Analysis        │     │
│  └─────────┘    └─────────────┘    └─────────────────┘     │
│         │               │                    │               │
│         └───────────────┼────────────────────┘               │
│                         │                                   │
│                ┌────────▼─────────┐                         │
│                │  Quality Store    │                         │
│  ┌─────────────┼──────────────────┼─────────────┐          │
│  │ Metrics     │  Test Coverage  │  Vulnerabilities  │          │
│  │ Tracking    │  Analysis       │  Database         │          │
│  └─────────────┴──────────────────┴─────────────┘          │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│               Improvement Actions                           │
│  • Code Fixes   • Test Generation   • Security Patches     │
└─────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. code-reviewer Agent

**역할**: 코드의 모든 측면을 분석하는 품질 보증 전문가

#### 분석 카테고리

```
ANALYSIS CATEGORIES:
├─ Security (보안)
│   ├─ OWASP Top 10 취약점
│   ├─ 인증/인가 결함
│   ├─ 데이터 노출 리스크
│   ├─ 입력 검증 누락
│   └─ 암호화 구현 오류
│
├─ Performance (성능)
│   ├─ 알고리즘 복잡도
│   ├─ 메모리 누수
│   ├─ N+1 쿼리 문제
│   ├─ 불필요한 연산
│   └─ 리소스 관리
│
├─ Maintainability (유지보수성)
│   ├─ SOLID 원칙 준수
│   ├─ 코드 중복 (DRY)
│   ├─ 함수 복잡도
│   ├─ 네이밍 일관성
│   └─ 주석 및 문서화
│
└─ Reliability (신뢰성)
    ├─ 에러 핸들링
    ├─ 타입 안전성
    ├─ 경계 조건
    ├─ 예외 처리
    └─ 상태 관리
```

#### 스캐 레벨

```yaml
# .claude/code-review-config.yml
scan_levels:
  quick:
    duration: "30s"
    checks:
      - syntax_errors
      - basic_security
      - code_style

  standard:
    duration: "2min"
    checks:
      - all_quick_checks
      - performance_patterns
      - maintainability_issues

  thorough:
    duration: "5min"
    checks:
      - all_standard_checks
      - security_vulnerabilities
      - architecture_violations
      - test_coverage_analysis
```

### 2. test-automator Agent

**역할**: Suites 3.x 기반의 지능적 테스트 생성 자동화

#### 테스트 생성 전략

```
TEST GENERATION STRATEGY:
1. 코드 분석
   ├─ 함수/메서드 시그니처 추출
   ├─ 입력/출력 타입 식별
   ├─ 엣지 케이스 발견
   └─ 비즈니스 로직 파악

2. 테스트 설계
   ├─ Given-When-Then 패턴
   ├─ 경계값 테스트
   ├─ 예외 상황 테스트
   └─ 통합 시나리오

3. 코드 생성
   ├─ Suites 3.x 구조
   ├─ Mock/Stub 자동 생성
   ├─ 테스트 데이터 팩토리
   └─ Assertion 최적화

4. 검증
   ├─ 테스트 실행 가능성
   ├─ 커버리지 측정
   ├─ 성능 벤치마크
   └─ 플레이크 테스트
```

### 3. /review Command

**용도**: 실시간 코드 리뷰 실행 및 개선 제안

#### 실행 모드

```bash
# 전체 스캔 (기본)
/review

# 특정 파일/디렉토리
/review src/auth/
/review src/user.service.ts

# 보안 전용 스캔
/review --security-only

# 성능 전용 스캔
/review --performance-only

# CI 모드 (JSON 출력)
/review --format json --output review-results.json

# 수정 제안 자동 적용
/review --auto-fix low
```

#### 리뷰 결과 포맷

```json
{
  "summary": {
    "files_analyzed": 15,
    "total_issues": 23,
    "critical": 2,
    "high": 5,
    "medium": 12,
    "low": 4,
    "quality_score": 7.2
  },
  "issues": [
    {
      "id": "SEC-001",
      "severity": "critical",
      "type": "security",
      "file": "src/auth/jwt.service.ts",
      "line": 45,
      "message": "Hardcoded JWT secret detected",
      "description": "JWT secret가 코드에 하드코딩되어 보안 위험",
      "suggestion": "환경변수를 사용하거나 secret manager 활용",
      "auto_fixable": false,
      "cwe": "CWE-798"
    }
  ],
  "metrics": {
    "code_smells": 8,
    "complexity": {
      "cyclomatic": 12.5,
      "cognitive": 18.3
    },
    "duplication": "3.2%",
    "test_coverage": "67%"
  },
  "recommendations": [
    "Add unit tests for AuthService (coverage: 45%)",
    "Extract UserValidator class to reduce duplication",
    "Implement rate limiting for auth endpoints"
  ]
}
```

## Advanced Features

### 1. AI 기반 코드 개선

```typescript
// 코드 리팩토링 제안
interface CodeRefactoring {
  before: {
    code: string;
    metrics: CodeMetrics;
  };

  after: {
    code: string;
    metrics: CodeMetrics;
    explanation: string;
    benefits: string[];
  };

  confidence: number; // 0-1
  auto_applicable: boolean;
}
```

### 2. 품질 트렌드 추적

```yaml
# .claude/quality-trends.yml
trends:
  metrics:
    - cyclomatic_complexity
    - test_coverage
    - code_duplication
    - security_vulnerabilities
    - performance_score

  aggregation:
    daily: true
    weekly: true
    monthly: true

  alerts:
    decreasing_coverage:
      threshold: -5%
      action: "notify_team"

    increasing_complexity:
      threshold: +10%
      action: "schedule_refactor"
```

### 3. 팀별 품질 대시보드

```typescript
// 팀별 품질 지표
interface TeamQualityDashboard {
  team: string;
  period: "week" | "month" | "quarter";

  metrics: {
    avg_code_review_time: number;
    bug_fix_rate: number;
    test_coverage: number;
    security_issues: number;
    technical_debt: number;
  };

  top_issues: QualityIssue[];
  improvements: string[];
  goals: QualityGoal[];
}
```

### 4. 커스텀 규칙 엔진

```yaml
# .claude/custom-rules.yml
rules:
  - name: "no-console-log"
    pattern: "console\\.log"
    message: "Console.log은 프로덕션 코드에서 제거해야 합니다"
    severity: "medium"
    auto_fix: "logger.info"

  - name: "require-error-handling"
    pattern: "await\\s+(\\w+)\\("
    context: "try_catch"
    message: "비동기 함수 호출은 에러 핸들링이 필요합니다"
    severity: "high"

  - name: "enforce-naming-convention"
    pattern: "(class|interface)\\s+([a-z])"
    message: "클래스/인터페이스는 파스칼 케이스를 사용해야 합니다"
    severity: "low"
```

## Integration Patterns

### 1. CI/CD 파이프라인 통합

```yaml
# .github/workflows/quality-check.yml
name: Code Quality Check

on: [pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run code review
        run: /review --format json --output results.json

      - name: Generate coverage
        run: npm run test:coverage

      - name: Check thresholds
        run: |
          if [ $(cat results.json | jq '.quality_score') -lt 7 ]; then
            echo "Quality score below threshold"
            exit 1
          fi
```

### 2. IDE 통합

```json
// VS Code settings.json
{
  "codeQuality.enabled": true,
  "codeQuality.realTimeAnalysis": true,
  "codeQuality.autoFix": "low",
  "codeQuality.showHints": true,
  "codeQuality.metrics": [
    "complexity",
    "duplication",
    "coverage"
  ]
}
```

### 3. Git Hooks

```bash
#!/bin/sh
# .git/hooks/pre-commit
echo "Running code quality checks..."

# 코드 리뷰 실행
/review --quiet --format json > .git/review.json

# 품질 스코어 확인
SCORE=$(cat .git/review.json | jq '.summary.quality_score')
if (( $(echo "$SCORE < 7.0" | bc -l) )); then
  echo "Quality score $SCORE is below minimum 7.0"
  cat .git/review.json | jq '.issues[] | select(.severity == "critical")'
  exit 1
fi

echo "Quality checks passed (Score: $SCORE)"
```

## Performance Optimization

### 1. 병렬 분석

```typescript
// 대규모 코드베이스 분석 최적화
class ParallelAnalyzer {
  private readonly workers: number;

  async analyze(files: string[]): Promise<AnalysisResult> {
    // 파일을 그룹으로 분할
    const chunks = this.chunkFiles(files, this.workers);

    // 병렬로 분석 실행
    const promises = chunks.map(chunk =>
      this.analyzeChunk(chunk)
    );

    const results = await Promise.all(promises);

    // 결과 병합
    return this.mergeResults(results);
  }
}
```

### 2. 증분 분석

```bash
# 변경된 파일만 분석
/review --incremental --base HEAD~5

# 결과:
# - 이전 커밋과 비교하여 변경된 파일만 분석
# - 새로운 문제점만 보고
# - 전체 분석 시간 90% 단축
```

### 3. 캐싱 전략

```yaml
# .claude/analysis-cache.yml
cache:
  enabled: true
  strategy: "content-based"  # content-based, time-based
  ttl: "24h"

  cache_keys:
    - file_hash
    - rule_version
    - configuration

  invalidation:
    on_config_change: true
    on_rule_update: true
    manual_flush: "/clear-quality-cache"
```

## Best Practices

### 1. 코드 리뷰
- **사전 분석**: PR 전에 자동 분석 실행
- **우선순위화**: 심각도 기반으로 문제 정렬
- **구체적 제안**: 문제점과 함께 해결책 제공
- **긍정적 피드백**: 잘된 부분도 언급

### 2. 테스트 자동화
- **경계 중심**: 경계값과 예외 케이스 우선
- **유지보수성**: 테스트 코드도 리뷰 대상
- **빠른 피드백**: 테스트 실행 후 즉시 결과 제공
- **커버리지 균형**: 단위/통합/E2E 균형 유지

### 3. 품질 개선
- **측정**: 모든 품질 지표 데이터화
- **추적**: 시간에 따른 품질 변화 모니터링
- **목표 설정**: 구체적인 품질 목표 수립
- **지속적 학습**: 리뷰를 통한 팀 능력 향상

## Troubleshooting

### 일반적인 문제

#### 분석 시간 초과
```
문제: 대규모 코드베이스 분석이 너무 오래 걸림
원인: 모든 파일을 순차적으로 분석
해결:
1. --incremental 옵션 사용
2. --parallel 병렬 처리
3. --exclude로 제외 파일 지정
4. 캐싱 활성화
```

#### 오탐지 많음
```
문제: 실제 문제가 아닌 것을 오류로 보고
원인: 규칙이 너무 엄격하거나 컨텍스트 부족
해결:
1. 규칙 조정 (.claude/custom-rules.yml)
2. 프로젝트별 설정 파일 추가
3. 팀 피드백 수집 후 규칙 개선
4. --confidence 옵션으로 임계값 조절
```

[parent](../CLAUDE.md)