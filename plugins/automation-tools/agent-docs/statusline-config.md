# Status Line Configuration

> Claude Code 상태 라인 설정 및 커스터마이징 가이드

## Overview

Status Line은 현재 개발 상태를 실시간으로 표시하는 시스템입니다.

```
STATUS LINE OUTPUT:
[main] DEV 0 errors PASS | 12:34:56
  │     │      │      │       │
  │     │      │      │       └─ 현재 시간
  │     │      │      └─ 테스트 상태
  │     │      └─ 에러 카운트
  │     └─ 환경
  └─ 현재 브랜치
```

---

## 기본 사용법

```bash
# 대화형 설정
/automation-tools:setup-statusline

# 템플릿 적용
/automation-tools:setup-statusline --template fullstack
/automation-tools:setup-statusline --template minimal
/automation-tools:setup-statusline --template backend

# 특정 설정 파일로 설정
/automation-tools:setup-statusline --config .claude/custom-status.yml
```

---

## 설정 파일 구조

### 기본 구조

```yaml
# .claude/status.yml
status:
  # 출력 형식
  format: "[{branch}] {env} {errors} {warnings} {status} | {time}"

  # 업데이트 간격 (초)
  interval: 5

  # 조건부 표시
  show_when:
    - "in_git_repo"
    - "has_package_json"

# 컴포넌트 정의
components:
  branch:
    command: "git branch --show-current"
    style: "blue"
    fallback: "no-git"

  env:
    command: "echo $NODE_ENV"
    style: "green"
    icons:
      development: "DEV"
      staging: "STG"
      production: "PROD"
    default: "DEV"

  errors:
    command: "tsc --noEmit 2>&1 | grep -c 'error' || echo 0"
    style: "red"
    hide_when_zero: true
    format: "{value} errors"

  warnings:
    command: "eslint src --quiet 2>&1 | grep -c 'warning' || echo 0"
    style: "yellow"
    hide_when_zero: true
    format: "{value} warnings"

  status:
    indicators:
      - condition: "npm test --passWithNoTests 2>/dev/null"
        icon: "PASS"
        style: "green"
      - condition: "git diff --quiet"
        icon: "CLEAN"
        style: "green"
      - condition: "git diff --cached --quiet"
        icon: "STAGED"
        style: "yellow"
    default:
      icon: "WORKING"
      style: "yellow"

  time:
    command: "date '+%H:%M:%S'"
    style: "dim"
```

---

## 데이터 소스

### Git Commands

```yaml
git_sources:
  # 현재 브랜치
  branch:
    command: "git branch --show-current"

  # 커밋 해시 (short)
  commit:
    command: "git rev-parse --short HEAD"

  # 상태 (modified, staged, clean)
  status:
    command: "git status --porcelain | wc -l"

  # 원격과의 차이
  ahead_behind:
    command: "git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null"

  # 마지막 커밋 메시지
  last_commit:
    command: "git log -1 --format='%s'"
```

### Build Tools

```yaml
build_sources:
  # npm 스크립트 상태
  npm_test:
    command: "npm test --passWithNoTests 2>&1 | tail -1"

  # 빌드 상태
  npm_build:
    command: "npm run build --dry-run 2>&1 | grep -c 'error' || echo 0"

  # 의존성 상태
  npm_audit:
    command: "npm audit --json 2>/dev/null | jq '.metadata.vulnerabilities.total'"
```

### Linters & Type Checkers

```yaml
lint_sources:
  # TypeScript 에러
  tsc_errors:
    command: "tsc --noEmit 2>&1 | grep -c 'error' || echo 0"

  # ESLint 이슈
  eslint_issues:
    command: "eslint src --format json 2>/dev/null | jq '.[].errorCount + .[].warningCount' | paste -sd+ | bc || echo 0"

  # Prettier 상태
  prettier_status:
    command: "prettier --check 'src/**/*.ts' 2>/dev/null && echo 'OK' || echo 'NEEDS_FORMAT'"
```

### Test Runners

```yaml
test_sources:
  # Jest 상태
  jest_status:
    command: "npm test -- --passWithNoTests --json 2>/dev/null | jq '.success'"

  # 커버리지
  coverage:
    command: "cat coverage/lcov-report/index.html 2>/dev/null | grep -oP '(?<=<span class=\"strong\">)[0-9.]+(?=%</span>)' | head -1 || echo 'N/A'"

  # 테스트 카운트
  test_count:
    command: "npm test -- --listTests 2>/dev/null | wc -l"
```

### Environment Variables

```yaml
env_sources:
  # Node 환경
  node_env:
    command: "echo ${NODE_ENV:-development}"

  # 데이터베이스 연결
  db_status:
    command: "pg_isready -q && echo 'OK' || echo 'DOWN'"

  # Redis 연결
  redis_status:
    command: "redis-cli ping 2>/dev/null || echo 'DOWN'"
```

---

## 템플릿

### Fullstack Template

```yaml
# fullstack 템플릿
status:
  format: "[{branch}] {env} | {tsc} {eslint} {test} | {time}"

components:
  branch:
    command: "git branch --show-current"
    style: "blue"

  env:
    command: "echo ${NODE_ENV:-dev}"
    icons:
      development: "DEV"
      dev: "DEV"
      staging: "STG"
      production: "PROD"
    style: "cyan"

  tsc:
    command: "tsc --noEmit 2>&1 | grep -c 'error' || echo 0"
    format: "TSC:{value}"
    style:
      zero: "green"
      nonzero: "red"

  eslint:
    command: "eslint src --quiet 2>&1 | grep -c ':' || echo 0"
    format: "LINT:{value}"
    style:
      zero: "green"
      nonzero: "yellow"

  test:
    command: "npm test --passWithNoTests 2>&1 | grep -q 'passed' && echo 'PASS' || echo 'FAIL'"
    style:
      PASS: "green"
      FAIL: "red"

  time:
    command: "date '+%H:%M'"
    style: "dim"
```

### Minimal Template

```yaml
# minimal 템플릿
status:
  format: "{branch} {status}"

components:
  branch:
    command: "git branch --show-current 2>/dev/null || echo 'no-git'"
    style: "blue"

  status:
    indicators:
      - condition: "git diff --quiet && git diff --cached --quiet"
        icon: "✓"
        style: "green"
      - condition: "git diff --cached --quiet"
        icon: "M"
        style: "yellow"
      - condition: "true"
        icon: "+"
        style: "yellow"
```

### Backend Template

```yaml
# backend 템플릿 (NestJS)
status:
  format: "[{branch}] {db} {redis} {queue} | {errors} | {time}"

components:
  branch:
    command: "git branch --show-current"
    style: "blue"

  db:
    command: "pg_isready -q 2>/dev/null && echo 'DB:OK' || echo 'DB:DOWN'"
    style:
      OK: "green"
      DOWN: "red"

  redis:
    command: "redis-cli ping 2>/dev/null >/dev/null && echo 'REDIS:OK' || echo 'REDIS:DOWN'"
    style:
      OK: "green"
      DOWN: "red"

  queue:
    command: "curl -s localhost:3000/health/queue | jq -r '.status' 2>/dev/null || echo 'N/A'"
    style:
      healthy: "green"
      unhealthy: "red"

  errors:
    command: "tsc --noEmit 2>&1 | grep -c 'error' || echo 0"
    hide_when_zero: true
    format: "{value} errors"
    style: "red"

  time:
    command: "date '+%H:%M:%S'"
    style: "dim"
```

---

## 스타일 옵션

### 색상

```yaml
styles:
  # 기본 색상
  colors:
    - red
    - green
    - yellow
    - blue
    - magenta
    - cyan
    - white
    - black

  # 밝은 색상
  bright_colors:
    - bright_red
    - bright_green
    - bright_yellow
    - bright_blue

  # 특수 스타일
  special:
    - dim
    - bold
    - italic
    - underline
```

### 조건부 스타일

```yaml
# 값에 따른 스타일 변경
errors:
  command: "..."
  style:
    "0": "green"       # 0일 때 녹색
    "1-5": "yellow"    # 1-5일 때 노란색
    "6+": "red"        # 6 이상일 때 빨간색
```

---

## 고급 설정

### 커스텀 명령어

```yaml
custom_commands:
  # 복합 명령어
  full_status:
    command: |
      ERRORS=$(tsc --noEmit 2>&1 | grep -c 'error' || echo 0)
      TESTS=$(npm test --passWithNoTests 2>&1 | grep -q 'passed' && echo 'PASS' || echo 'FAIL')
      echo "$ERRORS errors, $TESTS"

  # 외부 스크립트
  project_health:
    command: "node scripts/health-check.js"
```

### 성능 최적화

```yaml
performance:
  # 캐싱
  cache:
    enabled: true
    ttl: 10  # 초

  # 무거운 명령어 비활성화
  heavy_commands:
    - "npm audit"
    - "eslint"
  heavy_interval: 60  # 60초마다만 실행

  # 타임아웃
  command_timeout: 5  # 초
```

---

## 트러블슈팅

### 표시 안 됨

```
문제: Status line이 표시되지 않음
원인: 설정 파일 오류 또는 권한 문제

해결:
1. 설정 파일 문법 확인
2. 명령어 수동 실행 테스트
3. PATH 환경변수 확인
4. 실행 권한 부여 (chmod +x)
```

### 느린 업데이트

```
문제: 업데이트가 느림
원인: 무거운 명령어

해결:
1. interval 값 증가
2. 캐싱 활성화
3. 무거운 명령어 분리
4. heavy_interval 설정
```

---

[CLAUDE.md](../CLAUDE.md) | [factory-system.md](factory-system.md) | [sync-orchestration.md](sync-orchestration.md)
