# Git Workflows 상세 가이드

## Git Flow 전략

### 브랜치 구조

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

### 브랜치 타입별 컨텍스트

```
BRANCH CONTEXT MAPPING:
├─ feature/*  → likely feat/refactor commits
├─ release/*  → likely fix/chore commits
├─ hotfix/*   → likely fix commits
├─ develop    → mixed commits
└─ main/master → should rarely commit directly
```

---

## 커밋 메시지 규약

### Conventional Commits 형식

```
<type>(<optional scope>): <description in Korean>

[optional body - explain WHY if complex change]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 커밋 타입 가이드라인

| 타입 | 설명 | 사용 시점 |
|------|------|----------|
| `feat` | 새로운 기능 추가 | 새 파일 추가, 새 기능 구현 |
| `fix` | 버그 수정 | 오류 해결, 예외 처리 |
| `refactor` | 코드 구조 개선 | 동작 변경 없이 구조만 개선 |
| `docs` | 문서만 수정 | README, 주석 등 |
| `style` | 포맷팅 변경 | 세미콜론, 들여쓰기 등 |
| `test` | 테스트 추가/수정 | 테스트 케이스 작성 |
| `chore` | 빌드/설정/의존성 | package.json, 설정 파일 |
| `perf` | 성능 개선 | 최적화 관련 변경 |
| `ci` | CI/CD 설정 | GitHub Actions, Jenkins 등 |

### 타입 감지 매트릭스

```
TYPE DETECTION MATRIX:
┌──────────────┬────────────────────────────────────────────┐
│ 변경 패턴     │ 커밋 타입                                   │
├──────────────┼────────────────────────────────────────────┤
│ 새 파일 추가  │ feat (기능) / test (테스트) / docs (문서)   │
│ 기존 파일 수정│ fix (버그) / refactor (구조) / perf (성능)  │
│ 파일 삭제    │ refactor (정리) / chore (설정)              │
│ 파일 이동    │ refactor (구조 변경)                        │
│ 설정 파일    │ chore (빌드/설정)                           │
│ 테스트 파일  │ test (테스트 추가/수정)                      │
│ 문서 파일    │ docs (문서화)                               │
└──────────────┴────────────────────────────────────────────┘
```

---

## 변경사항 분석 프로세스

### 분석 파이프라인

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

### 변경사항 그룹화 알고리즘

```
GROUPING ALGORITHM:
1. 경로 기반 그룹화 (Primary)
   ├─ src/auth/*        → "auth" 그룹
   ├─ src/user/*        → "user" 그룹
   ├─ src/common/*      → "common" 그룹
   ├─ tests/*           → "test" 그룹
   ├─ docs/*            → "docs" 그룹
   └─ config/, *.config.* → "config" 그룹

2. 파일 타입 기반 그룹화 (Secondary)
   ├─ *.test.ts, *.spec.ts  → "test" 그룹
   ├─ *.md                   → "docs" 그룹
   ├─ *.json, *.yml, *.yaml  → "config" 그룹
   └─ *.ts, *.js, *.py       → "source" 그룹

3. 변경 패턴 기반 분류 (Tertiary)
   ├─ A (added)     → 새 기능 가능성 높음 (feat)
   ├─ M (modified)  → 수정/개선 (fix/refactor)
   ├─ D (deleted)   → 정리/리팩토링 (refactor/chore)
   └─ R (renamed)   → 구조 변경 (refactor)
```

### 그룹 병합 규칙

```
MERGE RULES:
├─ 같은 모듈 내 source + test → 하나의 커밋으로 병합
├─ config 파일들 → 별도 커밋 권장
├─ docs 파일들 → 별도 커밋 권장
└─ 5개 이상 파일이 서로 다른 모듈 → 분할 필수
```

---

## 다중 커밋 전략

### 결정 트리

```
DECISION TREE:
├─ IF groups.length == 1
│   → SINGLE COMMIT MODE (기존 방식)
│
├─ IF groups.length >= 2
│   → MULTI COMMIT MODE
│   → Present TUI for user selection
│
└─ IF groups.length > 5
    → WARN: "변경이 너무 많습니다. 작업 단위를 나누세요"
    → Suggest: git stash로 일부 보류 권장
```

### 권장 커밋 순서

```
RECOMMENDED ORDER:
1. chore/config  → 설정 변경 먼저 (의존성 기반)
2. refactor      → 구조 변경
3. feat          → 새 기능
4. fix           → 버그 수정
5. test          → 테스트 추가
6. docs          → 문서화 마지막

REASON:
├─ 설정이 먼저 있어야 코드가 동작
├─ 구조 변경 후 기능 추가가 자연스러움
├─ 테스트는 기능 구현 후 추가
└─ 문서는 모든 작업 완료 후 정리
```

---

## 스마트 스테이징

### 파일 타입별 규칙

```typescript
interface SmartStaging {
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

  size_threshold: {
    large: "100kb",  // 너무 큰 파일은 분할 권장
    medium: "10kb",  // 확인 필요
    small: "1kb"     // 바로 커밋 가능
  };
}
```

---

## 보안 검사

### Critical Rules

```
SECURITY CHECKS:
├─ IF file matches (.env|secret|credential|password|*.pem|*.key)
│   → WARN user, DO NOT stage automatically
│   → AskUserQuestion: "민감 파일이 포함되어 있습니다. 제외하시겠습니까?"
│
├─ IF branch is (main|master) AND "push" in $ARGUMENTS
│   → REQUIRE explicit confirmation via AskUserQuestion
│
├─ IF branch is (main|master) AND no "push" in $ARGUMENTS
│   → WARN: "main/master 브랜치에 직접 커밋 중입니다"
│
└─ IF no changes exist
    → Report "변경 사항 없음" and EXIT
```

---

## 이슈 트래커 통합

### 설정 예시

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

---

## 팀 규칙 설정

### 커스터마이징 옵션

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
      "list": ["auth", "api", "db", "ui", "util", "config", "deploy", "test"]
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

[parent](../CLAUDE.md)
