# Commit Conventions

> Conventional Commits 표준 및 커밋 메시지 작성 가이드

## Overview

일관된 커밋 메시지를 통해 히스토리 추적과 협업을 개선합니다.

```
COMMIT MESSAGE STRUCTURE:
┌─────────────────────────────────────────────────────────┐
│ <type>(<scope>): <subject>                              │ ← 헤더 (50자 이내)
│                                                         │
│ [optional body]                                         │ ← 본문 (72자 단위 줄바꿈)
│ - 변경 이유 설명                                          │
│ - 어떻게 변경했는지                                       │
│                                                         │
│ [optional footer]                                       │ ← 꼬리말 (이슈, Breaking)
│ Closes #123                                             │
│ BREAKING CHANGE: ...                                    │
│                                                         │
│ 🤖 Generated with [Claude Code]                         │ ← 자동 추가
│ Co-Authored-By: Claude <noreply@anthropic.com>         │
└─────────────────────────────────────────────────────────┘
```

---

## Commit Types

### 타입 정의

| 타입 | 설명 | 사용 시점 | 예시 |
|------|------|----------|------|
| `feat` | 새로운 기능 추가 | 새 파일 추가, 새 API 구현 | `feat(auth): JWT 인증 구현` |
| `fix` | 버그 수정 | 오류 해결, 예외 처리 | `fix(api): N+1 쿼리 문제 해결` |
| `refactor` | 코드 구조 개선 | 동작 변경 없이 구조만 개선 | `refactor(user): 검증 로직 공통화` |
| `docs` | 문서만 수정 | README, 주석, API 문서 | `docs(readme): 설치 가이드 추가` |
| `style` | 포맷팅 변경 | 세미콜론, 들여쓰기, 공백 | `style: prettier 포맷 적용` |
| `test` | 테스트 추가/수정 | 테스트 케이스 작성 | `test(auth): 로그인 실패 케이스` |
| `chore` | 빌드/설정/의존성 | package.json, 설정 파일 | `chore(deps): lodash 보안 업데이트` |
| `perf` | 성능 개선 | 최적화 관련 변경 | `perf(db): 인덱스 추가로 조회 개선` |
| `ci` | CI/CD 설정 | GitHub Actions, Jenkins | `ci: 테스트 커버리지 체크 추가` |
| `revert` | 이전 커밋 되돌리기 | 커밋 취소 | `revert: feat(api) 롤백` |

### 타입 감지 매트릭스

```
TYPE DETECTION MATRIX:
┌────────────────────┬──────────────────────────────────┐
│ 변경 패턴           │ 추천 커밋 타입                     │
├────────────────────┼──────────────────────────────────┤
│ 새 파일 추가        │ feat (기능)                       │
│                    │ test (테스트 파일)                │
│                    │ docs (문서 파일)                  │
├────────────────────┼──────────────────────────────────┤
│ 기존 파일 수정      │ fix (버그 수정)                   │
│                    │ refactor (구조 개선)              │
│                    │ perf (성능 최적화)                │
├────────────────────┼──────────────────────────────────┤
│ 파일 삭제          │ refactor (정리)                   │
│                    │ chore (미사용 파일 삭제)           │
├────────────────────┼──────────────────────────────────┤
│ 파일 이동/이름변경  │ refactor (구조 변경)              │
├────────────────────┼──────────────────────────────────┤
│ package.json 수정  │ chore (의존성)                    │
│                    │ feat (새 패키지 추가)             │
├────────────────────┼──────────────────────────────────┤
│ *.test.ts 수정     │ test (테스트)                     │
├────────────────────┼──────────────────────────────────┤
│ *.md 수정          │ docs (문서)                       │
├────────────────────┼──────────────────────────────────┤
│ .yml, .json 수정   │ ci (CI 설정)                      │
│                    │ chore (일반 설정)                 │
└────────────────────┴──────────────────────────────────┘
```

---

## Scope (범위)

### 스코프 정의

```
SCOPE EXAMPLES:
├─ 모듈명: auth, user, payment, admin
├─ 레이어명: api, db, service, controller
├─ 기능명: login, signup, checkout
├─ 컴포넌트명: button, modal, sidebar
└─ 특수: deps, config, security
```

### 스코프 감지 알고리즘

```
SCOPE DETECTION:
1. 경로 기반 추출
   src/auth/login.ts → scope: auth
   src/payment/service.ts → scope: payment

2. 파일 패턴 기반
   *.config.* → scope: config
   package.json → scope: deps

3. 다중 모듈 변경 시
   src/auth/ + src/user/ → scope 생략 or "core"
```

### 스코프 사용 예시

```bash
# 단일 모듈
feat(auth): JWT 기반 인증 구현

# 다중 모듈 (스코프 생략)
refactor: 서비스 레이어 구조 개선

# 특수 스코프
chore(deps): 의존성 보안 업데이트
ci(github): 워크플로우 타임아웃 증가
```

---

## Subject (제목)

### 작성 원칙

```
SUBJECT RULES:
✅ DO:
- 50자 이내로 작성
- 명령형으로 작성 ("추가함" ❌ → "추가" ✅)
- 마침표 없이 작성
- 한글로 작성 (팀 규칙)
- 핵심만 간결하게

❌ DON'T:
- "변경함", "수정함" 등 모호한 표현
- 구현 세부사항 나열
- 여러 변경을 하나로 묶기
```

### 좋은 제목 예시

```bash
✅ GOOD:
feat(auth): JWT 기반 인증 시스템 구현
fix(api): 사용자 목록 조회 시 N+1 쿼리 문제 해결
refactor(user): 중복 검증 로직 공통 모듈로 분리
docs(readme): API 사용 가이드 추가
test(auth): 로그인 실패 케이스 테스트 추가

❌ BAD:
fix: 버그 수정
feat: 변경함
update: 코드 업데이트
refactor: 리팩토링
chore: 기타 변경사항
```

---

## Body (본문)

### 작성 가이드

```
BODY GUIDELINES:
1. 왜 변경했는지 설명 (What보다 Why 중시)
2. 72자마다 줄바꿈
3. 변경 사항 나열 (bullet points)
4. 이전 동작과 새 동작 비교
5. 관련 맥락 제공
```

### 본문 템플릿

```markdown
## Feature 추가
feat(payment): 결제 모듈 구현

- PortOne API 연동으로 카드/계좌이체 지원
- 결제 상태 추적 및 웹훅 처리
- 환불 로직 구현
- Redis를 이용한 결제 세션 관리

Related: #145

## Bug 수정
fix(auth): 토큰 갱신 시 레이스 컨디션 해결

문제 현상:
- 동시에 여러 요청 시 토큰이 중복 갱신됨
- 이전 토큰이 무효화되어 인증 실패 발생

해결 방안:
- Redis 분산 락으로 토큰 갱신 직렬화
- 토큰 갱신 윈도우 1분으로 설정
- 기존 토큰 grace period 30초 추가

테스트:
- 동시 요청 100개 테스트 통과
- 토큰 갱신 성공률 100% 달성

Closes #234

## Refactoring
refactor(service): 계층형 아키텍처로 재구성

변경 이유:
- 비즈니스 로직이 컨트롤러에 산재
- 테스트 작성이 어려움
- 중복 코드 다수 존재

변경 사항:
- Domain Service 레이어 추가
- Repository 패턴 도입
- DTO와 Entity 분리
- 의존성 주입 구조 개선

결과:
- 테스트 커버리지 60% → 85%
- 코드 중복 40% 감소
- 평균 응답 시간 15% 개선
```

---

## Footer (꼬리말)

### 이슈 참조

```bash
# 이슈 해결
Closes #123
Closes #456, #789

# 관련 이슈
Related: #123
Refs: #456

# 여러 이슈
Fixes #123
Refs #456
Related: #789
```

### Breaking Changes

```bash
feat(api)!: 사용자 API v2 출시

BREAKING CHANGE: /users 엔드포인트 응답 형식 변경
- 기존: { users: [...] }
- 신규: { data: [...], meta: {...} }

마이그레이션 가이드:
1. 클라이언트 코드에서 response.users → response.data
2. 페이지네이션은 response.meta 사용
3. API v1은 2024-12-31까지 유지
```

### Co-Authors

```bash
# 페어 프로그래밍
Co-authored-by: Jane Doe <jane@example.com>

# 여러 기여자
Co-authored-by: John Smith <john@example.com>
Co-authored-by: Jane Doe <jane@example.com>
```

---

## 자동 생성 프로세스

### 분석 파이프라인

```
COMMIT MESSAGE GENERATION:
┌─────────────────────────────────────────────────────────┐
│ 1. 변경 스캔                                             │
│    ├─ git diff (staged & unstaged)                     │
│    ├─ 파일 목록 추출                                     │
│    └─ 변경 유형 분류 (A/M/D/R)                          │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│ 2. 컨텍스트 수집                                         │
│    ├─ 현재 브랜치 (feature/hotfix/...)                  │
│    ├─ 최근 커밋 히스토리                                 │
│    ├─ 파일 경로 패턴                                     │
│    └─ 코드 diff 분석                                    │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│ 3. 타입/스코프 결정                                       │
│    ├─ 타입 매트릭스 적용                                 │
│    ├─ 스코프 추출 (경로 기반)                            │
│    └─ 신뢰도 점수 계산                                   │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│ 4. 메시지 생성                                           │
│    ├─ 제목 생성 (50자 제한)                             │
│    ├─ 본문 생성 (변경 요약)                             │
│    ├─ 이슈 연결 (Closes #)                              │
│    └─ 포맷팅 (Conventional Commits)                     │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│ 5. 사용자 확인                                           │
│    ├─ 생성된 메시지 표시                                 │
│    ├─ 편집 기회 제공                                     │
│    └─ 승인 후 커밋 실행                                  │
└─────────────────────────────────────────────────────────┘
```

---

## 팀 규칙 설정

### 설정 파일

```json
// .claude/commit-conventions.json
{
  "team_rules": {
    "language": "korean",
    "max_subject_length": 50,
    "max_body_line_length": 72,
    "require_body": true,
    "require_scope": true,
    "require_issue": false,

    "allowed_types": [
      "feat", "fix", "refactor", "docs",
      "test", "chore", "perf", "ci"
    ],

    "scopes": {
      "required": true,
      "list": [
        "auth", "user", "payment", "admin",
        "api", "db", "config", "test"
      ],
      "allow_custom": true
    },

    "issue_tracker": {
      "enabled": true,
      "pattern": "(PROJ-\\d+|#\\d+)",
      "auto_link": true
    },

    "footer": {
      "include_claude_signature": true,
      "include_co_author": true
    }
  }
}
```

### 검증 규칙

```typescript
interface ValidationRules {
  // 제목 검증
  subject: {
    maxLength: 50;
    pattern: /^(feat|fix|docs|style|refactor|test|chore|perf|ci|revert)(\(.+\))?: .+/;
    noTrailingPeriod: true;
  };

  // 본문 검증
  body?: {
    maxLineLength: 72;
    minLines: 3;
    requireBulletPoints: true;
  };

  // 꼬리말 검증
  footer?: {
    requireIssue: boolean;
    issuePattern: RegExp;
  };
}
```

---

## 사용 예시

### 기본 사용

```bash
# 자동 분석 및 커밋
/git-workflows:git-commit

# 출력:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 변경 분석 결과

📁 변경 파일:
  M  src/auth/auth.service.ts
  M  src/auth/jwt.guard.ts
  A  src/auth/dto/login.dto.ts

📊 타입/스코프 분석:
  타입: feat (신뢰도: 95%)
  스코프: auth
  제목: JWT 기반 인증 시스템 구현

💬 생성된 커밋 메시지:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
feat(auth): JWT 기반 인증 시스템 구현

- Access Token 및 Refresh Token 발급
- JWT Guard를 이용한 라우트 보호
- 로그인 DTO 추가 및 검증

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ 커밋하시겠습니까? (y/n)
```

### 이슈 연결

```bash
# 이슈와 함께 커밋
/git-workflows:git-commit --issue PROJ-123

# 결과:
fix(api): 사용자 목록 조회 최적화

Closes PROJ-123
```

---

[CLAUDE.md](../CLAUDE.md) | [branch-strategies.md](branch-strategies.md) | [automation-patterns.md](automation-patterns.md)
