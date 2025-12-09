# Code Quality - Detailed Guides

code-quality 플러그인의 상세 가이드입니다.

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
└─────────────────────────────────────────────────────────────┘
```

---

## Code Reviewer Agent

### Analysis Categories

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

### Scan Levels

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

---

## Test Automator Agent

### Test Generation Strategy

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

---

## /review Command

### Execution Modes

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

### Review Result Format

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

---

## Advanced Features

### AI-based Code Improvement

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

### Quality Trend Tracking

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

### Team Quality Dashboard

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

### Custom Rule Engine

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

---

[Back to CLAUDE.md](../CLAUDE.md) | [Examples](examples.md) | [References](references.md)
