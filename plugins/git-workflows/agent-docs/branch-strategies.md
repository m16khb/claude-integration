# Branch Strategies

> Git Flow 기반 브랜치 전략 및 워크플로우

## Overview

효율적인 브랜치 관리를 통해 안정적인 릴리스와 협업을 지원합니다.

```
GIT FLOW ARCHITECTURE:
┌─────────────────────────────────────────────────────────┐
│                     main (production)                    │
│  ●───────●───────────────●────────────●──────────►      │
│  v1.0   v1.1           v2.0         v2.1                │
└───┬─────────────────────┬──────────────┬────────────────┘
    │                     │              │
    │ hotfix/            │ release/     │ hotfix/
    │ critical-bug       │ v2.0         │ security-fix
    │                    │              │
┌───┴─────────────────────┴──────────────┴────────────────┐
│                     develop                              │
│  ●─●─●─●─●─●─●─●─●─●─●─●─●─●─●─●─●─●─●─●─●─●─●─►     │
└──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬───────┘
   │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │
   ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼
feature/ feature/ feature/ bugfix/ feature/ ...
user-auth payment  admin   db-fix  notif
```

---

## 브랜치 타입

### Main Branches

```
MAIN BRANCHES:
├─ main (or master)
│   ├─ 프로덕션 릴리스 브랜치
│   ├─ 항상 배포 가능한 상태 유지
│   ├─ 직접 커밋 금지 (PR만 허용)
│   └─ 태그로 버전 관리 (v1.0.0, v1.1.0 ...)
│
└─ develop
    ├─ 개발 통합 브랜치
    ├─ 다음 릴리스 준비
    ├─ feature 브랜치 머지 대상
    └─ 항상 빌드 가능한 상태 유지
```

### Supporting Branches

```
SUPPORTING BRANCHES:
├─ feature/*
│   ├─ 용도: 새 기능 개발
│   ├─ 분기: develop
│   ├─ 머지: develop
│   ├─ 명명: feature/login, feature/payment
│   └─ 생명주기: 짧음 (보통 1-2주)
│
├─ release/*
│   ├─ 용도: 릴리스 준비
│   ├─ 분기: develop
│   ├─ 머지: main + develop
│   ├─ 명명: release/v1.2.0
│   └─ 작업: 버그 수정, 문서 업데이트
│
├─ hotfix/*
│   ├─ 용도: 긴급 프로덕션 수정
│   ├─ 분기: main
│   ├─ 머지: main + develop
│   ├─ 명명: hotfix/critical-bug
│   └─ 우선순위: 최상
│
└─ bugfix/*
    ├─ 용도: 일반 버그 수정
    ├─ 분기: develop
    ├─ 머지: develop
    ├─ 명명: bugfix/api-error
    └─ hotfix와 구분
```

---

## 브랜치별 워크플로우

### Feature Workflow

```
FEATURE WORKFLOW:
1. 브랜치 생성
   git checkout develop
   git checkout -b feature/user-auth

2. 개발 진행
   - 기능 구현
   - 테스트 작성
   - 문서 업데이트

3. 정기 동기화
   git fetch origin
   git rebase origin/develop

4. PR 생성
   - develop으로 PR
   - 코드 리뷰 요청
   - CI 통과 확인

5. 머지 및 정리
   git checkout develop
   git merge feature/user-auth --no-ff
   git branch -d feature/user-auth
   git push origin --delete feature/user-auth
```

### Release Workflow

```
RELEASE WORKFLOW:
1. 릴리스 브랜치 생성
   git checkout develop
   git checkout -b release/v1.2.0

2. 릴리스 준비
   - 버전 번호 업데이트
   - CHANGELOG 작성
   - 문서 업데이트
   - 최종 버그 수정

3. 테스트
   - 통합 테스트
   - 스테이징 배포
   - QA 검증

4. main 머지 및 태그
   git checkout main
   git merge release/v1.2.0 --no-ff
   git tag -a v1.2.0 -m "Release v1.2.0"
   git push origin main --tags

5. develop 백머지
   git checkout develop
   git merge release/v1.2.0 --no-ff
   git branch -d release/v1.2.0
```

### Hotfix Workflow

```
HOTFIX WORKFLOW:
1. 긴급 브랜치 생성
   git checkout main
   git checkout -b hotfix/security-fix

2. 수정 및 테스트
   - 최소한의 변경
   - 긴급 테스트
   - 영향도 분석

3. main 머지 및 태그
   git checkout main
   git merge hotfix/security-fix --no-ff
   git tag -a v1.2.1 -m "Hotfix v1.2.1"

4. develop 백머지
   git checkout develop
   git merge hotfix/security-fix --no-ff
   git branch -d hotfix/security-fix

5. 즉시 배포
   - 프로덕션 배포
   - 모니터링
```

---

## 브랜치 네이밍 규칙

### 네이밍 패턴

```
NAMING CONVENTIONS:
├─ feature/<issue>-<description>
│   예: feature/PROJ-123-user-login
│       feature/payment-integration
│
├─ release/v<version>
│   예: release/v1.2.0
│       release/v2.0.0-beta
│
├─ hotfix/<issue>-<description>
│   예: hotfix/PROJ-999-critical-bug
│       hotfix/security-patch
│
├─ bugfix/<issue>-<description>
│   예: bugfix/PROJ-456-api-error
│       bugfix/typo-fix
│
└─ chore/<description>
    예: chore/deps-update
        chore/config-cleanup
```

### 네이밍 Best Practices

```
NAMING RULES:
✅ DO:
- 소문자 사용
- 하이픈으로 단어 구분 (kebab-case)
- 간결하고 명확하게 (3-4단어)
- 이슈 번호 포함 (있는 경우)

❌ DON'T:
- 공백 사용
- 언더스코어 (_) 사용
- 너무 긴 이름 (50자 초과)
- 모호한 이름 (fix, update, temp)

예시:
✅ feature/user-authentication
✅ hotfix/PROJ-999-xss-vulnerability
✅ release/v2.1.0
❌ feature/new_feature
❌ fix
❌ feature/this-is-a-very-long-branch-name-that-describes-everything
```

---

## 브랜치 컨텍스트 인식

### 컨텍스트 매핑

```
BRANCH CONTEXT MAPPING:
┌──────────────────┬──────────────────┬─────────────────┐
│ 브랜치 패턴       │ 예상 커밋 타입    │ 권장 스코프      │
├──────────────────┼──────────────────┼─────────────────┤
│ feature/*        │ feat, refactor   │ 기능명          │
│ release/*        │ fix, chore, docs │ -               │
│ hotfix/*         │ fix              │ 긴급            │
│ bugfix/*         │ fix              │ 버그            │
│ chore/*          │ chore, ci        │ deps, config    │
│ develop          │ mixed            │ -               │
│ main/master      │ (직접 커밋 금지)  │ -               │
└──────────────────┴──────────────────┴─────────────────┘
```

### 자동 타입 제안

```typescript
function suggestCommitType(branchName: string): string {
  const patterns = {
    'feature/': 'feat',
    'hotfix/': 'fix',
    'bugfix/': 'fix',
    'release/': 'chore',
    'chore/': 'chore',
  };

  for (const [pattern, type] of Object.entries(patterns)) {
    if (branchName.startsWith(pattern)) {
      return type;
    }
  }

  return 'feat'; // default
}
```

---

## 브랜치 보호 규칙

### 보호 설정

```yaml
# .github/branch-protection.yml
branch_protection:
  main:
    required_reviews: 2
    require_code_owner_review: true
    dismiss_stale_reviews: true
    require_status_checks: true
    required_checks:
      - "ci/test"
      - "ci/lint"
      - "ci/build"
    enforce_admins: true
    restrict_pushes: true

  develop:
    required_reviews: 1
    require_status_checks: true
    required_checks:
      - "ci/test"
      - "ci/lint"

  'release/*':
    required_reviews: 1
    require_status_checks: true
    lock_branch: false

  'hotfix/*':
    required_reviews: 1  # 긴급이므로 1명만
    require_status_checks: true
```

---

## 머지 전략

### 전략 비교

```
MERGE STRATEGIES:
├─ Merge (--no-ff)
│   ├─ 장점: 히스토리 보존, 브랜치 구조 명확
│   ├─ 단점: 히스토리 복잡
│   └─ 사용: feature → develop, release → main
│
├─ Squash Merge
│   ├─ 장점: 깔끔한 히스토리, 하나의 커밋으로 요약
│   ├─ 단점: 상세 히스토리 손실
│   └─ 사용: PR 머지 시 선택적 사용
│
└─ Rebase
    ├─ 장점: 선형 히스토리, 깔끔
    ├─ 단점: 충돌 해결 복잡
    └─ 사용: 브랜치 동기화 (feature ← develop)
```

### 권장 전략

```
RECOMMENDED STRATEGY:
┌──────────────────┬──────────────────────────────────────┐
│ 머지 케이스       │ 전략                                  │
├──────────────────┼──────────────────────────────────────┤
│ feature→develop  │ Merge --no-ff (히스토리 보존)         │
│ release→main     │ Merge --no-ff + Tag                  │
│ hotfix→main      │ Merge --no-ff + Tag                  │
│ develop 동기화   │ Rebase (선형 유지)                    │
│ PR 머지          │ Squash (선택적)                       │
└──────────────────┴──────────────────────────────────────┘
```

---

## 브랜치 생명주기 관리

### 생명주기

```
BRANCH LIFECYCLE:
├─ 생성
│   ├─ 목적 명확화
│   ├─ 네이밍 규칙 준수
│   └─ 이슈 연결
│
├─ 개발
│   ├─ 정기 동기화 (주 2-3회)
│   ├─ 작은 커밋 유지
│   └─ 테스트 통과 유지
│
├─ 리뷰
│   ├─ PR 생성
│   ├─ 코드 리뷰
│   └─ CI 통과
│
└─ 정리
    ├─ 머지 후 로컬 삭제
    ├─ 원격 브랜치 삭제
    └─ 관련 이슈 종료
```

### 오래된 브랜치 정리

```bash
# 머지된 브랜치 확인
git branch --merged develop

# 로컬 브랜치 일괄 삭제
git branch --merged develop | grep -v "develop" | xargs git branch -d

# 원격 브랜치 정리
git remote prune origin

# 30일 이상 오래된 브랜치 찾기
git for-each-ref --sort=-committerdate refs/heads/ \
  --format='%(refname:short) %(committerdate:relative)'
```

---

## 팀 워크플로우 예시

### Small Team (1-5명)

```
SMALL TEAM WORKFLOW:
main ────────────────●────────────●──────────►
                     │            │
                    v1.0         v1.1
                     │            │
develop ──●──●──●────┴────●──●────┴────●──●──►
          │  │  │         │  │         │  │
          feature1        feature2     bugfix

특징:
- 단순한 구조
- PR 리뷰 간소화
- 빠른 릴리스 주기
```

### Medium Team (5-20명)

```
MEDIUM TEAM WORKFLOW:
main ────────────●─────────────●─────────────►
                 │             │
                 │    release/v1.1
                 │    ┌────●────┘
                v1.0  │
                 │    │
develop ──●──●───┴────┴──●──●──●──●──●──●──►
          │  │           │  │  │  │  │  │
          feature1       │  │  │  │  │  bugfix
                         feature2 │  feature3
                                  feature4

특징:
- release 브랜치 활용
- 정기 릴리스 (2-4주)
- 코드 리뷰 필수
```

### Large Team (20+ 명)

```
LARGE TEAM WORKFLOW:
main ────────●───────────●───────────────────►
             │           │
        hotfix/bug  release/v2.0
             │      ┌────●────┐
             │      │         │
develop ─────┴──────┴─────────┴──●──●──●──●──►
                                 │  │  │  │
                            feature-team-A
                                    │  │  │
                               feature-team-B
                                       │  │
                                  feature-team-C

특징:
- 팀별 feature 브랜치
- 엄격한 코드 리뷰
- 자동화된 CI/CD
- 정기 릴리스 트레인
```

---

## Best Practices

### 브랜치 관리 원칙

```
BRANCH MANAGEMENT PRINCIPLES:
✅ 짧은 생명주기
   - feature: 1-2주
   - release: 1주
   - hotfix: 1-2일

✅ 정기 동기화
   - develop 변경사항 주기적으로 rebase
   - 충돌 최소화

✅ 명확한 목적
   - 하나의 기능/수정에 하나의 브랜치
   - 여러 작업 혼재 금지

✅ 적시 삭제
   - 머지 즉시 브랜치 삭제
   - 로컬/원격 모두 정리

✅ 보호 규칙
   - main/develop 직접 푸시 금지
   - PR + 리뷰 필수
   - CI 통과 확인
```

---

[CLAUDE.md](../CLAUDE.md) | [commit-conventions.md](commit-conventions.md) | [automation-patterns.md](automation-patterns.md)
