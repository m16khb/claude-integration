---
name: git-workflows
description: 'Git 워크플로우 자동화 - 스마트 커밋, Git Flow 지원'
category: development
---

# git-workflows Plugin

지능적인 Git 워크플로우 자동화 시스템으로 변경사항을 분석하고 최적의 커밋 메시지를 생성합니다. Git Flow 모범 사례를 따르면서 팀의 커뮤니케이션을 향상시킵니다.

## Core Philosophy

```
Git 워크플로우 원칙:
├─ 의미 있는 커밋: 변경의 "왜"와 "무엇"을 명확히 전달
├─ 일관된 형식: 팀 전체의 커밋 메시지 표준화
├─ 자동화: 반복적인 Git 작업을 자동으로 처리
├─ 컨텍스트 인식: 브랜치와 작업 유형에 따른 적절한 메시지
└─ 히스토리 보존: 나중에 추적하기 쉬운 상세한 변경 기록
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                  Git Workflow Engine                        │
│                                                             │
│  Git Changes ──► Change Analyzer ──► Message Generator       │
│       │               │                   │                │
│       ▼               ▼                   ▼                │
│  ┌─────────┐    ┌─────────────┐    ┌─────────────────┐     │
│  │ File     │    │ Pattern      │    │ Commit          │     │
│  │ Scanner  │    │ Recognition  │    │ Template        │     │
│  └─────────┘    └─────────────┘    └─────────────────┘     │
│         │               │                    │               │
│         └───────────────┼────────────────────┘               │
│                         │                                   │
│                ┌────────▼─────────┐                         │
│                │  Context Store    │                         │
│  ┌─────────────┼──────────────────┼─────────────┐          │
│  │ Branch     │  Issue Tracker  │  Code Review   │          │
│  │ Context    │  Integration    │  Results       │          │
│  └─────────────┴──────────────────┴─────────────┘          │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  Git Operations                            │
│  • Smart Commit    • Auto Push     • PR Draft             │
└─────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. git-commit Command

**용도**: 변경사항을 지능적으로 분석하고 최적의 커밋 메시지 생성

#### 분석 프로세스

```
COMMIT ANALYSIS PIPELINE:
1. 변경 스캔
   ├─ Git diff 분석 (staged & unstaged)
   ├─ 파일 유형 식별
   ├─ 변경 영향도 평가
   └─ 잠재적 버그 패턴 감지

2. 컨텍스트 수집
   ├─ 현재 브랜치 이름과 타입
   ├─ 최근 커밋 히스토리
   ├─ 관련 이슈 (JIRA, GitHub)
   ├─ PR 제목과 설명 (있는 경우)
   └─ 코드 리뷰 피드백

3. 메시지 생성
   ├─ 커밋 타입 결정 (feat, fix, 등)
   ├─ 범위 지정 (module, component)
   ├─ 제목 생성 (50자 이내)
   ├─ 본문 생성 (상세 변경사항)
   └─ 꼬리말 추가 (breaking changes, issues)

4. 포맷팅
   ├─ 한글/영어 선택
   ├─ 팀 규칙 적용
   ├─ 글자 수 제한 준수
   └─ 이모지 선택적 추가
```

#### 사용 예시

```bash
# 기본 커밋
/git-commit

# 커밋 후 자동 푸시
/git-commit push

# 특정 이슈 연결
/git-commit --issue PROJ-123

# 강제 커밋 (스테이징되지 않은 변경 포함)
/git-commit --force

# 상세 모드 (더 많은 분석 정보)
/git-commit --verbose
```

#### 커밋 메시지 예시

```bash
# 기능 추가
feat(auth): JWT 기반 인증 시스템 구현

- Access Token 및 Refresh Token 발급 로직 추가
- 로그인/로그아웃 API 엔드포인트 구현
- 토큰 검증 미들웨어 적용
- Redis를 이용한 토큰 블랙리스트 기능

Closes #123

# 버그 수정
fix(api): 사용자 목록 조회 시 N+1 쿼리 문제 해결

- Eager loading으로 관계 데이터 미리 로드
- Query Builder 최적화
- 응답 시간 3초 → 200ms 개선

# 리팩토링
refactor(user): 중복된 유효성 검사 로직 공통 모듈로 분리

- ValidationService 신규 생성
- 5개 컨트롤러에서 재사용
- 테스트 커버리지 85% → 92% 향상
```

### 2. Git Flow 지원

#### 브랜치 전략

```
GIT FLOW IMPLEMENTATION:
├─ Main Branches
│   ├─ main: 프로덕션 릴리스
│   └─ develop: 개발 통합 브랜치
│
├─ Supporting Branches
│   ├─ feature/: 신규 기능 개발
│   ├─ release/: 릴리스 준비
│   ├─ hotfix/: 긴급 수정
│   └─ bugfix/: 일반 버그 수정
│
└─ Branch Rules
    ├─ main ← release: 머지 시 태그 생성
    ├─ main ← hotfix: 즉시 머지 및 태그
    ├─ develop ← feature: PR 머지
    └─ develop ← release: 릴리즈 후 머지
```

#### 자동 브랜치 관리

```bash
# 기능 브랜치 생성
/git-workflow start feature user-auth
# 결과: git checkout -b feature/user-auth develop

# 기능 완료 및 PR 생성
/git-workflow finish feature user-auth
# 결과:
# 1. develop으로 머지
# 2. PR 자동 생성
# 3. 기능 브랜치 삭제

# 릴리스 시작
/git-workflow start release v1.2.0
# 결과: develop → release/v1.2.0

# 핫픽스 생성
/git-workflow start hotfix auth-bug
# 결과: main → hotfix/auth-bug
```

## Advanced Features

### 1. 스마트 스테이징

```typescript
// 변경 유형에 따른 자동 스테이징
interface SmartStaging {
  // 파일 타입별 규칙
  rules: {
    source: {
      include: ["src/**/*.{ts,js,py,go}"],
      stage: true,
      message: "소스 코드 변경"
    },
    tests: {
      include: ["**/*.{test,spec}.{ts,js,py}"],
      stage: false,
      message: "테스트 코드는 수동 스테이징"
    },
    config: {
      include: ["*.json", "*.yml", "*.yaml"],
      stage: true,
      message: "설정 파일 변경"
    }
  };

  // 변경 크기 기반
  size_threshold: {
    large: "100kb",  // 너무 큰 파일은 분할 권장
    medium: "10kb",   // 확인 필요
    small: "1kb"      // 바로 커밋 가능
  };
}
```

### 2. 이슈 트래커 통합

```yaml
# .claude/git-integrations.yml
issue_tracker:
  type: "jira"  # jira, github, gitlab
  url: "https://company.atlassian.net"
  project_key: "PROJ"

  auto_link:
    enabled: true
    patterns:
      - "PROJ-\\d+"
      - "#\\d+"

  commit_message:
    include_issue: true
    format: "{type}({scope}): {title} (#{issue})"
    close_on_commit: true

  branch_naming:
    feature: "feature/{issue}-{description}"
    bugfix: "bugfix/{issue}-{description}"
```

### 3. 코드 리뷰 연동

```json
{
  "code_review_integration": {
    "pre_commit_hook": {
      "run_linter": true,
      "run_tests": true,
      "check_coverage": true,
      "fail_on_error": true
    },
    "pr_template": {
      "include_commit_details": true,
      "include_test_results": true,
      "include_diff_summary": true,
      "auto_assign_reviewers": true
    }
  }
}
```

### 4. 커밋 서명

```bash
# GPG 서명 설정
/git-workflow config gpg.sign true
/git-workflow config gpg.key "ABCD1234"

# 서명된 커밋
/git-commit --sign
```

## Customization

### 1. 커밋 메시지 템플릿

```yaml
# .claude/commit-templates.yml
templates:
  feature: |
    {type}({scope}): {subject}

    {body}

    - 관련 이슈: {issues}
    - 영향 모듈: {modules}
    - 테스트: {test_status}

  bugfix: |
    fix({scope}): {subject}

    문제 현상:
    - {problem_description}

    해결 방안:
    - {solution}

    테스트 결과:
    - {test_results}

  chore: |
    chore({scope}): {subject}

    변경 사항:
    - {changes}

```

### 2. 팀 규칙 설정

```json
{
  "team_rules": {
    "language": "korean",
    "max_subject_length": 50,
    "max_body_line_length": 72,
    "require_body": true,
    "require_issue": true,
    "allowed_types": [
      "feat", "fix", "refactor", "docs",
      "test", "chore", "perf", "ci"
    ],
    "scopes": {
      "required": true,
      "list": [
        "auth", "api", "db", "ui", "util",
        "config", "deploy", "test"
      ]
    },
    "emojis": {
      "enabled": true,
      "mapping": {
        "feat": "✨",
        "fix": "🐛",
        "docs": "📝",
        "test": "✅",
        "chore": "🔧"
      }
    }
  }
}
```

## Performance Optimization

### 1. 대규모 변경 처리

```bash
# 변경이 많을 때 분할 커밋
/git-commit --batch

# 결과:
# 1. 관련 파일별로 그룹화
# 2. 논리적 단위로 분할
# 3. 각 그룹별 커밋 제안
# 4. 전체 실행 또는 선택적 실행
```

### 2. 병렬 처리

```typescript
// 병렬 Git 작업
async function parallelGitOps(operations: GitOperation[]) {
  // 독립적인 작업은 병렬로 실행
  const results = await Promise.allSettled(
    operations.map(op => executeGitOperation(op))
  );

  // 결과 종합
  return aggregateResults(results);
}
```

## Integration Examples

### 1. IDE 단축키 설정

```json
// VS Code keybindings.json
{
  "key": "ctrl+enter",
  "command": "git.commit",
  "args": ["--message", "${input:commitMessage}"],
  "when": "editorTextFocus"
}
```

### 2. Git Hooks

```bash
#!/bin/sh
# .git/hooks/prepare-commit-msg
# 커밋 메시지 검증

# 메시지 형식 확인
if ! grep -qE "^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: " "$1"; then
  echo "커밋 메시지 형식이 올바르지 않습니다."
  echo "예시: feat(auth): 사용자 로그인 기능 추가"
  exit 1
fi

# 이슈 번호 확인
if ! grep -qE "#[0-9]+|PROJ-[0-9]+" "$1"; then
  echo "이슈 번호를 포함해주세요."
  exit 1
fi
```

### 3. CI/CD 파이프라인

```yaml
# .github/workflows/commit-validation.yml
name: Commit Validation

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Check commit messages
        uses: commitizen-tools/commitizen-check@master
        with:
          args: --rev-range HEAD~1
```

## Best Practices

### 1. 커밋 작성
- **원자적 커밋**: 하나의 논리적 변경만 커밋
- **명확한 제목**: 50자 이내로 핵심 내용 전달
- **상세한 본문**: 왜 변경했는지, 어떻게 변경했는지 설명
- **일관된 형식**: 팀 규칙 준수

### 2. 브랜치 관리
- **짧은 생명주기**: 기능 브랜치는 최대 2주 유지
- **정기 동기화**: 주기적으로 upstream 변경 가져오기
- **명확한 이름**: 기능을 예측할 수 있는 브랜치 이름
- **적시 삭제**: 머지 후 브랜치 즉시 삭제

### 3. 협업
- **PR 전 커밋**: PR 전 로컬에서 커밋 완료
- **의미 있는 리뷰**: 코드 리뷰는 커밋 단위로
- **커밋 그룹화**: 관련 커밋은 하나의 PR에
- **히스토리 정리**: 필요시 rebase로 커밋 정리

## Troubleshooting

### 일반적인 문제

#### 커밋 메시지 생성 실패
```
문제: 변경 사항 분석 실패
원인: 스테이징된 변경 없음 또는 너무 많은 변경
해결:
1. git status 확인
2. git add 로 변경 스테이징
3. --batch 옵션으로 대용량 변경 분할
```

#### PR 생성 실패
```
문제: PR 자동 생성 오류
원인: 권한 부족 또는 브랜치 충돌
해결:
1. GitHub 토큰 확인
2. 원격 브랜치 최신화
3. 충돌 해결 후 재시도
```

[parent](../CLAUDE.md)