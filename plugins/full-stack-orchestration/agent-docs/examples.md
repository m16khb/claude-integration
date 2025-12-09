# Full-Stack Orchestration 예제

## 1. Feature Development Workflow

새 기능 개발 시나리오입니다.

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

---

## 2. Hotfix Workflow

긴급 수정 시나리오입니다.

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

---

## 3. Documentation Update

문서 업데이트 시나리오입니다.

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

---

## 4. Quality Metrics 예제

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

---

## 5. 워크플로우별 사용 예제

### 일반 개발 (기본)

```bash
# 모든 단계 실행
/dev-flow
```

### 빠른 수정

```bash
# 테스트 없이 빠른 커밋
/dev-flow skip-test
```

### PR 생성

```bash
# Draft PR로 생성
/dev-flow --draft-pr
```

### CI 없이 커밋

```bash
# CI 트리거하지 않고 커밋만
/dev-flow --no-ci commit-only
```

---

[CLAUDE.md로 돌아가기](../CLAUDE.md) | [상세 가이드](detailed-guides.md) | [참고 자료](references.md)
