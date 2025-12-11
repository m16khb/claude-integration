# Review Workflow

> 코드 리뷰 프로세스 및 자동화 통합 가이드

## Overview

code-reviewer 에이전트의 리뷰 프로세스와 CI/CD 통합 방법을 설명합니다.

```
REVIEW WORKFLOW:
┌─────────────────────────────────────────────────────────┐
│                    Code Changes                          │
└───────────────────────┬─────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
   ┌─────────┐     ┌─────────┐     ┌─────────┐
   │Security │     │ Perf.   │     │ Maint.  │
   │ Check   │     │ Check   │     │ Check   │
   └────┬────┘     └────┬────┘     └────┬────┘
        │               │               │
        └───────────────┼───────────────┘
                        │
                        ▼
              ┌─────────────────┐
              │  Review Report  │
              └─────────────────┘
```

---

## /review 커맨드

### 기본 사용법

```bash
# 전체 프로젝트 리뷰
/code-quality:review

# 특정 파일/디렉토리
/code-quality:review src/auth/
/code-quality:review src/users/user.service.ts

# 변경된 파일만 (Git diff)
/code-quality:review --changed
/code-quality:review --staged
```

### 분석 옵션

```bash
# 분석 카테고리 선택
/code-quality:review --security-only    # 보안 분석만
/code-quality:review --performance-only # 성능 분석만
/code-quality:review --all              # 전체 분석 (기본)

# 스캔 레벨
/code-quality:review --level quick      # 빠른 스캔 (1-2분)
/code-quality:review --level standard   # 표준 스캔 (3-5분)
/code-quality:review --level thorough   # 심층 스캔 (5-10분)

# 출력 형식
/code-quality:review --format markdown  # Markdown (기본)
/code-quality:review --format json      # JSON
/code-quality:review --format sarif     # SARIF (GitHub 호환)
```

### 자동 수정

```bash
# 자동 수정 가능한 이슈 수정
/code-quality:review --auto-fix

# 심각도별 자동 수정
/code-quality:review --auto-fix low     # LOW만 자동 수정
/code-quality:review --auto-fix medium  # MEDIUM 이하 자동 수정

# 드라이런 (변경 없이 미리보기)
/code-quality:review --auto-fix --dry-run
```

---

## 분석 카테고리

### Security (보안)

```
SECURITY ANALYSIS:
├─ OWASP Top 10 검사
├─ 인증/인가 취약점
├─ 입력 검증 부재
├─ 민감 정보 노출
├─ 의존성 취약점
└─ 설정 보안
```

### Performance (성능)

```
PERFORMANCE ANALYSIS:
├─ N+1 쿼리 문제
├─ 메모리 누수 패턴
├─ 불필요한 연산
├─ 캐시 미사용
├─ 비효율적 알고리즘
└─ 큰 페이로드 처리
```

### Maintainability (유지보수성)

```
MAINTAINABILITY ANALYSIS:
├─ SOLID 원칙 위반
├─ 코드 중복 (DRY)
├─ 복잡도 초과 (Cyclomatic)
├─ 긴 메서드/클래스
├─ 매직 넘버/문자열
└─ 불명확한 네이밍
```

### Reliability (신뢰성)

```
RELIABILITY ANALYSIS:
├─ 에러 핸들링 부재
├─ 타입 안전성 문제
├─ 경계 조건 미처리
├─ 리소스 해제 누락
├─ 예외 삼킴
└─ 비동기 처리 결함
```

---

## 스캔 레벨

### Quick (빠른 스캔)

```yaml
quick_scan:
  duration: "1-2분"
  scope:
    - 변경된 파일만
    - 패턴 기반 검사
    - 기본 린트 규칙

  checks:
    - syntax_errors
    - obvious_security_issues
    - import_issues
    - formatting

  use_case: "커밋 전 빠른 확인"
```

### Standard (표준 스캔)

```yaml
standard_scan:
  duration: "3-5분"
  scope:
    - 변경된 파일 + 영향받는 파일
    - AST 기반 분석
    - 의존성 분석

  checks:
    - all_quick_checks
    - security_patterns
    - performance_patterns
    - code_smells
    - complexity_analysis

  use_case: "PR 리뷰, 일일 체크"
```

### Thorough (심층 스캔)

```yaml
thorough_scan:
  duration: "5-10분"
  scope:
    - 전체 코드베이스
    - 데이터 흐름 분석
    - 크로스파일 분석

  checks:
    - all_standard_checks
    - deep_security_audit
    - architectural_analysis
    - dead_code_detection
    - dependency_audit

  use_case: "릴리스 전, 보안 감사"
```

---

## CI/CD 통합

### GitHub Actions

```yaml
# .github/workflows/code-review.yml
name: Code Review

on:
  pull_request:
    branches: [main, develop]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Code Review
        run: |
          claude-code review \
            --format sarif \
            --output results.sarif \
            --changed

      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: results.sarif

      - name: Comment on PR
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('review-report.md', 'utf8');
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: report
            });
```

### GitLab CI

```yaml
# .gitlab-ci.yml
code-review:
  stage: review
  script:
    - claude-code review --format json --output review.json
    - |
      if [ $(jq '.summary.critical' review.json) -gt 0 ]; then
        echo "Critical issues found!"
        exit 1
      fi
  artifacts:
    reports:
      codequality: review.json
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
```

### Git Hooks

```bash
# .husky/pre-commit
#!/bin/sh
claude-code review --staged --level quick

if [ $? -ne 0 ]; then
  echo "Code review found issues. Please fix before committing."
  exit 1
fi
```

```bash
# .husky/pre-push
#!/bin/sh
claude-code review --changed --level standard

if [ $? -ne 0 ]; then
  echo "Code review found issues. Please fix before pushing."
  exit 1
fi
```

---

## 리포트 형식

### Markdown 리포트

```markdown
# Code Review Report

## Summary
- **Total Issues**: 12
- **Critical**: 2
- **High**: 3
- **Medium**: 5
- **Low**: 2

## Critical Issues

### 🔴 SQL Injection in UserService
**File**: `src/users/user.service.ts:45`
**Category**: Security (A03:Injection)

```typescript
// 문제 코드
const query = `SELECT * FROM users WHERE id = '${id}'`;
```

**권장 수정**:
```typescript
const user = await this.userRepository.findOne({ where: { id } });
```

---

## High Issues
...
```

### JSON 리포트

```json
{
  "timestamp": "2025-12-09T10:00:00Z",
  "summary": {
    "total": 12,
    "critical": 2,
    "high": 3,
    "medium": 5,
    "low": 2
  },
  "issues": [
    {
      "id": "SEC-001",
      "severity": "critical",
      "category": "security",
      "rule": "no-sql-injection",
      "file": "src/users/user.service.ts",
      "line": 45,
      "column": 10,
      "message": "Potential SQL injection vulnerability",
      "suggestion": "Use parameterized queries",
      "fixable": false
    }
  ]
}
```

---

## 커스텀 규칙

### 규칙 설정

```yaml
# .claude/review-rules.yml
rules:
  security:
    enabled: true
    severity_override:
      no-eval: critical  # 기본값 high → critical

  performance:
    enabled: true
    thresholds:
      max_query_count: 5  # N+1 감지 임계값
      max_payload_size: 1mb

  maintainability:
    enabled: true
    thresholds:
      max_complexity: 10
      max_method_lines: 50
      max_class_lines: 300

  # 커스텀 규칙
  custom:
    - name: no-console-log
      pattern: "console\\.log"
      severity: low
      message: "Remove console.log before production"
      autofix: true

ignore:
  paths:
    - "**/*.spec.ts"
    - "**/migrations/**"
  rules:
    - no-any  # 마이그레이션 파일에서 any 허용
```

---

## 트러블슈팅

### 느린 스캔

```
문제: 리뷰가 너무 오래 걸림
원인: 대규모 코드베이스

해결:
1. --level quick 사용
2. --changed 옵션으로 변경 파일만 분석
3. ignore 패턴 추가 (node_modules, dist 등)
```

### 오탐지 (False Positive)

```
문제: 정상 코드가 이슈로 감지됨
원인: 컨텍스트 부족

해결:
1. 인라인 주석으로 규칙 비활성화
   // claude-review-disable-next-line no-any
2. .claude/review-rules.yml에서 규칙 조정
3. 피드백 제출 (학습용)
```

---

**관련 문서**: [CLAUDE.md](../CLAUDE.md) | [security-analysis.md](security-analysis.md) | [testing-strategies.md](testing-strategies.md)
