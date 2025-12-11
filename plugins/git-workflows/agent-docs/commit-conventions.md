# Commit Conventions

> Conventional Commits 1.0.0 전체 규격 및 커밋 메시지 작성 가이드

## Overview

**Conventional Commits 1.0.0** 규격을 완벽히 준수하여 일관된 커밋 메시지를 생성합니다.
SemVer(유의적 버전)와 연동되어 자동화된 CHANGELOG 생성과 버전 관리가 가능합니다.

**원문**: https://www.conventionalcommits.org/ko/v1.0.0/

```
COMMIT MESSAGE STRUCTURE (Conventional Commits 1.0.0):
┌─────────────────────────────────────────────────────────┐
│ <타입>[적용 범위(선택)][!]: <설명>                        │ ← 헤더 (필수)
│                                                         │
│ [본문(선택)]                                              │ ← 본문
│                                                         │
│ [꼬리말(선택)]                                            │ ← 꼬리말
│ BREAKING CHANGE: <상세 설명>                             │
│ Closes #123                                             │
│                                                         │
│ 🤖 Generated with [Claude Code]                         │ ← 자동 추가
│ Co-Authored-By: Claude <noreply@anthropic.com>         │
└─────────────────────────────────────────────────────────┘
```

---

## Conventional Commits 1.0.0 규격

### 필수 구조 요소 (RFC 2119)

| 규칙 # | 설명 | MUST/SHOULD |
|--------|------|-------------|
| 1 | 타입은 명사 접두어 + 선택적 적용 범위 + 선택적 `!` + `:` + 공백 | MUST |
| 2 | `feat`는 새 기능 추가 시 사용 | MUST |
| 3 | `fix`는 버그 수정 시 사용 | MUST |
| 4 | 적용 범위는 괄호로 감싸진 명사 | SHOULD |
| 5 | 설명은 콜론과 공백 다음에 작성 | MUST |
| 6 | 본문은 설명 다음 빈 행 후 시작 | MAY |
| 7 | 본문은 형식 자유, 여러 단락 가능 | MAY |
| 8 | 꼬리말은 토큰 + `:<space>` 또는 `<space>#` + 값 | MUST |
| 9 | 꼬리말 토큰은 공백 대신 `-` 사용 (예외: BREAKING CHANGE) | MUST |
| 10 | 꼬리말 값은 공백/새 줄 포함 가능 | MAY |
| 11 | BREAKING CHANGE는 타입/범위 접두어 또는 꼬리말에 표시 | MUST |
| 12 | 꼬리말 BREAKING CHANGE는 대문자 + 콜론 + 공백 + 설명 | MUST |
| 13 | 접두어에 포함 시 `:` 바로 앞에 `!` 명시 | MUST |
| 14 | `feat`, `fix` 외 타입도 허용 | MAY |
| 15 | BREAKING CHANGE 외 정보는 대소문자 구분 안 함 | MUST NOT |
| 16 | BREAKING-CHANGE는 BREAKING CHANGE와 동의어 | MUST |

---

## Semantic Versioning 연동

### SemVer 매핑

```
SEMVER MAPPING:
┌──────────────────┬─────────────────┬────────────────────┐
│ 커밋 타입         │ SemVer 영향     │ 버전 예시           │
├──────────────────┼─────────────────┼────────────────────┤
│ fix              │ PATCH           │ 1.0.0 → 1.0.1     │
│ feat             │ MINOR           │ 1.0.0 → 1.1.0     │
│ BREAKING CHANGE  │ MAJOR           │ 1.0.0 → 2.0.0     │
│ docs, style, ... │ 영향 없음        │ 1.0.0 (유지)       │
└──────────────────┴─────────────────┴────────────────────┘

※ BREAKING CHANGE는 어떤 타입이든 MAJOR 버전 증가
예: fix!:, feat!:, refactor!: 모두 MAJOR
```

### 자동화 이점

- **CHANGELOG 자동 생성**: 커밋 타입별 자동 분류
- **버전 자동 결정**: feat→MINOR, fix→PATCH, BREAKING→MAJOR
- **릴리스 노트 생성**: 커밋 메시지 기반 자동 작성

---

## Commit Types

### 타입 정의

| 타입 | 설명 | SemVer | 예시 |
|------|------|--------|------|
| `feat` | 새로운 기능 추가 | MINOR | `feat(auth): JWT 인증 구현` |
| `fix` | 버그 수정 | PATCH | `fix(api): N+1 쿼리 해결` |
| `docs` | 문서만 수정 | - | `docs(readme): 설치 가이드` |
| `style` | 포맷팅 변경 | - | `style: prettier 적용` |
| `refactor` | 코드 구조 개선 | - | `refactor(user): 검증 로직 분리` |
| `perf` | 성능 개선 | - | `perf(db): 인덱스 최적화` |
| `test` | 테스트 추가/수정 | - | `test(auth): 로그인 케이스` |
| `chore` | 빌드/설정/의존성 | - | `chore(deps): lodash 업데이트` |
| `ci` | CI/CD 설정 | - | `ci: 테스트 커버리지 추가` |
| `revert` | 커밋 되돌리기 | * | `revert: feat(api) 롤백` |

### 타입 감지 매트릭스

```
TYPE DETECTION MATRIX:
┌────────────────────┬──────────────────────────────────┐
│ 변경 패턴           │ 추천 커밋 타입                     │
├────────────────────┼──────────────────────────────────┤
│ 새 파일 추가        │ feat (기능) / test / docs        │
│ 기존 파일 수정      │ fix / refactor / perf            │
│ 파일 삭제          │ refactor / chore                 │
│ 파일 이동/이름변경  │ refactor                         │
│ package.json 수정  │ chore (deps) / feat (새 패키지)  │
│ *.test.ts 수정     │ test                             │
│ *.md 수정          │ docs                             │
│ .yml, .json 수정   │ ci / chore                       │
└────────────────────┴──────────────────────────────────┘
```

---

## BREAKING CHANGE (단절적 변경)

### 표기 방법

```
방법 1: 타입 뒤 ! (권장)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
feat!: API 응답 형식 변경

또는 범위와 함께:
feat(api)!: 인증 방식 JWT로 변경


방법 2: 꼬리말에 BREAKING CHANGE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
feat(api): 새 인증 시스템

BREAKING CHANGE: 기존 세션 기반 인증이 JWT로 변경됩니다.
기존 세션 쿠키는 더 이상 유효하지 않습니다.


방법 3: ! + BREAKING CHANGE 꼬리말 (둘 다 사용)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
chore!: Node 6 지원 중단

BREAKING CHANGE: Node 6에서 사용 불가능한 JavaScript 기능 사용
```

### BREAKING CHANGE 예시

```bash
# 설명과 BREAKING CHANGE 꼬리말
feat: 설정 객체가 다른 설정을 확장하도록 허용

BREAKING CHANGE: 설정 파일의 `extends` 키가 다른 설정 확장에 사용됩니다

# ! 포함 (간단한 경우)
feat!: 제품 배송 시 고객에게 이메일 발송

# 범위와 ! 포함
feat(api)!: 제품 배송 시 고객에게 이메일 발송

# ! 와 BREAKING CHANGE 꼬리말 함께
chore!: Node 6 지원 중단

BREAKING CHANGE: Node 6에서 사용 불가능한 JavaScript 기능 사용
```

---

## revert (되돌리기)

### revert 커밋 형식

```
revert: <되돌리는 커밋의 subject>

This reverts commit <SHA>.

Refs: 676104e, a215868
```

### revert 예시

```bash
# 단일 커밋 되돌리기
revert: feat(auth): JWT 인증 구현

This reverts commit abc1234.

Refs: abc1234

# 여러 커밋 되돌리기
revert: let us never again speak of the noodle incident

Refs: 676104e, a215868
```

---

## Scope (적용 범위)

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

---

## Subject (설명/제목)

### 작성 원칙

```
SUBJECT RULES (규격 5번):
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
fix(api): 사용자 목록 조회 시 N+1 쿼리 해결
refactor(user): 중복 검증 로직 공통 모듈로 분리
docs(readme): API 사용 가이드 추가
test(auth): 로그인 실패 케이스 테스트 추가

❌ BAD:
fix: 버그 수정
feat: 변경함
update: 코드 업데이트
```

---

## Body (본문)

### 작성 가이드 (규격 6, 7번)

```
BODY GUIDELINES:
1. 설명 다음에 빈 행으로 시작 (규격 6번 필수)
2. 형식 자유, 여러 단락 가능 (규격 7번)
3. 왜 변경했는지 설명 (What보다 Why)
4. 72자마다 줄바꿈 (권장)
```

### 본문 템플릿

```markdown
## Feature 추가
feat(payment): 결제 모듈 구현

- PortOne API 연동으로 카드/계좌이체 지원
- 결제 상태 추적 및 웹훅 처리
- 환불 로직 구현

Related: #145

## Bug 수정
fix(auth): 토큰 갱신 시 레이스 컨디션 해결

문제 현상:
- 동시에 여러 요청 시 토큰이 중복 갱신됨

해결 방안:
- Redis 분산 락으로 토큰 갱신 직렬화

Closes #234
```

---

## Footer (꼬리말)

### git trailer format (규격 8-10번)

```
꼬리말 형식:
<토큰>: <값>        ← :<space> 구분자
<토큰> #<값>        ← <space># 구분자

규칙:
- 토큰은 공백 대신 - 사용 (예: Acked-by)
- 예외: BREAKING CHANGE는 공백 허용
- 값은 공백/새 줄 포함 가능
```

### 이슈 참조

```bash
# 이슈 해결 (자동 종료)
Closes #123
Closes #456, #789
Fixes #123

# 관련 이슈 (참조만)
Related: #123
Refs: #456
See-also: #789

# 여러 이슈
Fixes #123
Refs #456
Related: #789
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
│    └─ git diff, 파일 목록, 변경 유형 (A/M/D/R)          │
├─────────────────────────────────────────────────────────┤
│ 2. 컨텍스트 수집                                         │
│    └─ 브랜치, 히스토리, 경로 패턴, diff 분석            │
├─────────────────────────────────────────────────────────┤
│ 3. BREAKING CHANGE 감지 (NEW)                           │
│    └─ API 변경, 스키마 변경, 삭제 감지                  │
├─────────────────────────────────────────────────────────┤
│ 4. 타입/스코프 결정                                       │
│    └─ 매트릭스 적용, 스코프 추출, 신뢰도 계산           │
├─────────────────────────────────────────────────────────┤
│ 5. 메시지 생성                                           │
│    └─ 제목 (50자), 본문, 이슈 연결, 포맷팅              │
├─────────────────────────────────────────────────────────┤
│ 6. SemVer 영향 표시                                      │
│    └─ MAJOR/MINOR/PATCH 안내                            │
└─────────────────────────────────────────────────────────┘
```

---

## FAQ (규격 원문)

### Q: 초기 개발 단계에서 커밋 메시지를 어떻게 다루어야 하나요?

이미 제품을 출시한 것처럼 진행하세요. 동료 개발자가 무엇이 고쳐졌고 무엇이 문제인지 알고 싶어 합니다.

### Q: 커밋이 여러 타입에 해당하면?

가능하면 돌아가서 여러 개의 커밋으로 쪼개세요. Conventional Commits는 조직화된 커밋과 PR을 만들도록 유도합니다.

### Q: 잘못된 타입을 사용하면?

- **스펙에 맞는 타입이지만 틀린 경우** (예: feat 대신 fix): `git rebase -i`로 히스토리 편집
- **스펙에 맞지 않는 타입** (예: feet): 도구에 의해 누락될 뿐, 치명적이지 않음

### Q: 모든 기여자가 규격을 사용해야 하나요?

아니요. 스쿼시 머지를 사용하면 리드 유지관리자가 머지 시 메시지를 정리할 수 있습니다.

---

## 사용 예시

```bash
# 자동 분석 및 커밋
/git-workflows:git-commit

# 출력:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 변경 분석 결과

📁 변경 파일:
  M  src/auth/auth.service.ts (API 시그니처 변경 감지)
  M  src/auth/jwt.guard.ts
  A  src/auth/dto/login.dto.ts

⚠️  BREAKING CHANGE 후보 감지:
  - src/auth/auth.service.ts: 메서드 파라미터 변경

📊 타입/스코프 분석:
  타입: feat! (BREAKING CHANGE)
  스코프: auth
  제목: JWT 기반 인증 시스템 구현
  SemVer 영향: MAJOR

💬 생성된 커밋 메시지:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
feat(auth)!: JWT 기반 인증 시스템 구현

- Access Token 및 Refresh Token 발급
- JWT Guard를 이용한 라우트 보호
- 로그인 DTO 추가 및 검증

BREAKING CHANGE: 기존 세션 기반 인증이 JWT로 변경됩니다.
기존 API 클라이언트는 Bearer 토큰 방식으로 수정 필요합니다.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ 커밋하시겠습니까? (y/n)
```

---

## 참고 자료

- [Conventional Commits 1.0.0 규격](https://www.conventionalcommits.org/ko/v1.0.0/)
- [Semantic Versioning 2.0.0](https://semver.org/lang/ko/)
- [Angular Commit Guidelines](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)
- [@commitlint/config-conventional](https://github.com/conventional-changelog/commitlint)

---

**관련 문서**: [CLAUDE.md](../CLAUDE.md) | [branch-strategies.md](branch-strategies.md) | [automation-patterns.md](automation-patterns.md)
