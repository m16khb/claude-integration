# Troubleshooting

> Full-Stack Orchestration 문제 해결 및 Best Practices

## 일반적인 문제

### 파이프라인 중단

**증상**: 워크플로우가 중간에 멈추고 진행되지 않음

**원인 분석**:
```
PIPELINE HALT:
├── Quality Gate 실패
│   └── 심각도 CRITICAL 또는 HIGH 이슈 감지
├── 타임아웃
│   └── Stage 실행 시간 초과
├── 리소스 부족
│   └── 메모리 또는 CPU 제한
└── 외부 서비스 오류
    └── CI/CD 플랫폼, 테스트 DB 연결 실패
```

**해결 방법**:
```bash
# 1. 현재 상태 확인
/dev-flow --status

# 2. 상세 로그 확인
cat .claude/logs/pipeline-$(date +%Y%m%d).log

# 3. 실패 지점부터 재시작
/dev-flow --resume

# 4. 특정 단계 건너뛰고 재시작
/dev-flow --resume --skip-failed
```

---

### 테스트 실패

**증상**: 테스트가 실패하여 커밋이 차단됨

**원인별 해결**:

```
TEST FAILURES:
├── 단위 테스트 실패
│   ├── 원인: 로직 변경으로 인한 assertion 실패
│   └── 해결: 테스트 코드 수정 또는 구현 수정
│
├── 통합 테스트 실패
│   ├── 원인: 외부 서비스 연결 문제
│   └── 해결: 환경 변수 확인, mock 사용
│
├── E2E 테스트 실패
│   ├── 원인: UI 변경, 타이밍 이슈
│   └── 해결: selector 업데이트, wait 추가
│
└── Flaky 테스트
    ├── 원인: 비결정적 동작
    └── 해결: 재시도 로직, 격리 강화
```

**빠른 해결**:
```bash
# 실패한 테스트만 재실행
npm run test -- --only-failed

# 특정 테스트 파일만 실행
npm run test -- src/auth/auth.service.spec.ts

# 테스트 건너뛰고 커밋 (비권장, 긴급 시만)
/dev-flow skip-test --force
```

---

### 보안 스캔 실패

**증상**: Security audit에서 취약점 발견

**심각도별 대응**:

| 심각도 | 대응 | 시간 제한 |
|--------|------|----------|
| Critical | 즉시 수정 필수 | 즉시 |
| High | 수정 후 커밋 | 24시간 |
| Medium | 이슈 등록 | 1주일 |
| Low | 백로그 | 선택적 |

**해결 방법**:
```bash
# 취약점 상세 확인
npm audit

# 자동 수정 시도
npm audit fix

# 강제 수정 (Breaking changes 포함)
npm audit fix --force

# 특정 취약점 무시 (명시적 예외 처리)
# .npmrc 또는 package.json에 설정
```

---

### 커밋 충돌

**증상**: 커밋 또는 푸시 시 충돌 발생

**해결 흐름**:
```bash
# 1. 원격 변경사항 가져오기
git fetch origin

# 2. rebase 또는 merge
git rebase origin/main
# 또는
git merge origin/main

# 3. 충돌 해결 후 계속
git add .
git rebase --continue

# 4. 파이프라인 재실행
/dev-flow
```

---

## 성능 최적화

### 파이프라인 속도 개선

**병목 지점 분석**:
```
PERFORMANCE BOTTLENECKS:
├── 의존성 설치
│   └── 해결: 캐싱 활성화, npm ci 사용
│
├── 테스트 실행
│   └── 해결: 병렬 실행, 불필요한 테스트 제외
│
├── 빌드 시간
│   └── 해결: 증분 빌드, 캐시 활용
│
└── 코드 분석
    └── 해결: 변경된 파일만 분석
```

**최적화 설정**:
```yaml
# .claude/dev-flow.yml
optimization:
  # 캐싱
  cache:
    enabled: true
    paths:
      - node_modules
      - .eslintcache
      - .tsbuildinfo

  # 병렬 처리
  parallel:
    tests: true
    lint: true
    max_workers: 4

  # 증분 분석
  incremental:
    enabled: true
    only_changed: true
```

### 리소스 사용량 관리

```yaml
# 메모리 제한
resources:
  memory:
    test: "2048M"
    build: "4096M"

  # 타임아웃
  timeout:
    review: 120000   # 2분
    test: 300000     # 5분
    build: 600000    # 10분
```

---

## Best Practices

### 1. 워크플로우 설계

| 원칙 | 설명 | 예시 |
|------|------|------|
| 작게 유지 | 각 단계는 명확한 하나의 책임 | lint, test, build 분리 |
| 빠른 피드백 | 5분 이내 결과 제공 | 빠른 단계 먼저 실행 |
| 롤백 용이 | 실패 시 쉽게 원상복구 | 각 단계 독립적 |
| 점진적 | 복잡도를 점진적으로 증가 | Level 1 → 4 |

### 2. 품질 게이트

| 원칙 | 설명 |
|------|------|
| 명확한 기준 | 각 단계의 성공/실패 기준 명시 |
| 자동화 | 사람의 개입 최소화 |
| 예외 처리 | 긴급 상황을 위한 우회 경로 |
| 학습 | 실패로부터 학습하고 개선 |

### 3. 팀 워크플로우

```
TEAM PRACTICES:
├── 일관성
│   └── 모든 팀원이 동일한 프로세스 사용
│
├── 투명성
│   └── 진행 상황을 모두가 볼 수 있음
│
├── 협업
│   └── PR 리뷰, 코드 오너십 명확
│
└── 지속적 개선
    └── 정기적인 워크플로우 검토
```

---

## 로그 및 디버깅

### 로그 위치

```
LOG LOCATIONS:
├── .claude/logs/
│   ├── pipeline-YYYYMMDD.log    # 일별 파이프라인 로그
│   ├── review-*.log              # 리뷰 상세 로그
│   ├── test-*.log                # 테스트 상세 로그
│   └── error-*.log               # 오류 로그
│
└── .claude/reports/
    ├── quality-report.json       # 품질 보고서
    └── metrics-history.json      # 메트릭 히스토리
```

### 디버그 모드

```bash
# 상세 로그 출력
/dev-flow --verbose

# 디버그 모드 (최대 상세)
/dev-flow --debug

# 특정 단계만 디버그
/dev-flow --debug-stage test
```

---

## 에러 코드

| 코드 | 설명 | 해결 방법 |
|------|------|----------|
| E001 | Quality Gate 실패 | 이슈 수정 후 재시도 |
| E002 | 테스트 실패 | 테스트 수정 또는 건너뛰기 |
| E003 | 빌드 오류 | 빌드 로그 확인 |
| E004 | 타임아웃 | 타임아웃 설정 증가 |
| E005 | 인증 실패 | 자격 증명 확인 |
| E006 | 네트워크 오류 | 연결 상태 확인 |
| E007 | 디스크 부족 | 공간 확보 |
| E008 | 권한 오류 | 파일 권한 확인 |

---

@../CLAUDE.md | @pipeline-architecture.md | @workflow-patterns.md
