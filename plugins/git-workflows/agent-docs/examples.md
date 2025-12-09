# Git Workflows 사용 예제

## 기본 사용법

### 단순 커밋

```bash
# 기본 커밋 (분석 후 메시지 자동 생성)
/git-workflows:git-commit

# 커밋 후 자동 푸시
/git-workflows:git-commit push
```

### 옵션 사용

```bash
# 특정 이슈 연결
/git-workflows:git-commit --issue PROJ-123

# 강제 커밋 (스테이징되지 않은 변경 포함)
/git-workflows:git-commit --force

# 상세 모드 (더 많은 분석 정보)
/git-workflows:git-commit --verbose
```

---

## 커밋 메시지 예시

### 기능 추가 (feat)

```bash
feat(auth): JWT 기반 인증 시스템 구현

- Access Token 및 Refresh Token 발급 로직 추가
- 로그인/로그아웃 API 엔드포인트 구현
- 토큰 검증 미들웨어 적용
- Redis를 이용한 토큰 블랙리스트 기능

Closes #123
```

### 버그 수정 (fix)

```bash
fix(api): 사용자 목록 조회 시 N+1 쿼리 문제 해결

- Eager loading으로 관계 데이터 미리 로드
- Query Builder 최적화
- 응답 시간 3초 → 200ms 개선
```

### 리팩토링 (refactor)

```bash
refactor(user): 중복된 유효성 검사 로직 공통 모듈로 분리

- ValidationService 신규 생성
- 5개 컨트롤러에서 재사용
- 테스트 커버리지 85% → 92% 향상
```

### 문서 (docs)

```bash
docs(readme): API 사용 가이드 추가

- 인증 플로우 다이어그램 추가
- 에러 코드 레퍼런스 작성
- curl 예제 포함
```

### 테스트 (test)

```bash
test(auth): 로그인 실패 케이스 테스트 추가

- 잘못된 비밀번호 테스트
- 만료된 토큰 테스트
- 블랙리스트 토큰 테스트
```

### 설정 (chore)

```bash
chore(deps): 의존성 보안 업데이트

- lodash 4.17.19 → 4.17.21
- axios 0.21.0 → 0.21.4
- npm audit 취약점 0건
```

---

## 다중 커밋 예시

### 그룹 분석 결과

```
┌─ Group 1: auth ────────────────────────────────────────────┐
│ Type: feat                                                 │
│ Files: src/auth/login.ts, src/auth/jwt.service.ts          │
│ Summary: JWT 기반 로그인 기능 추가                          │
└────────────────────────────────────────────────────────────┘
┌─ Group 2: test ────────────────────────────────────────────┐
│ Type: test                                                 │
│ Files: tests/auth/login.spec.ts                            │
│ Summary: 로그인 테스트 케이스 추가                          │
└────────────────────────────────────────────────────────────┘
┌─ Group 3: docs ────────────────────────────────────────────┐
│ Type: docs                                                 │
│ Files: docs/auth.md                                        │
│ Summary: 인증 문서 업데이트                                 │
└────────────────────────────────────────────────────────────┘
```

### TUI 선택 화면

```
커밋 전략 선택:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

3개 그룹으로 변경사항이 분류되었습니다. 커밋 방식을 선택하세요.

[1] 그룹별 개별 커밋 (Recommended)
    각 그룹을 별도 커밋으로 생성합니다. 히스토리가 깔끔해집니다.

[2] 전체 단일 커밋
    모든 변경을 하나의 커밋으로 묶습니다.

[3] 선택적 커밋
    커밋할 그룹을 직접 선택합니다.
```

### 다중 커밋 실행 결과

```markdown
## 다중 커밋 완료 (3개)

### 커밋 목록
| # | 해시 | 타입 | 스코프 | 메시지 | 파일 수 |
|---|------|------|--------|--------|---------|
| 1 | `abc1234` | feat | auth | JWT 인증 구현 | 3 |
| 2 | `def5678` | test | auth | 인증 테스트 추가 | 2 |
| 3 | `ghi9012` | docs | - | README 업데이트 | 1 |

### 요약
| 항목 | 내용 |
|------|------|
| 브랜치 | feature/user-auth (Git Flow: feature) |
| 총 커밋 | 3개 |
| 총 변경 | +245 / -12 in 6 files |
| 푸시 | 완료 |
```

---

## Git Flow 워크플로우 예시

### 기능 브랜치 생성

```bash
# 기능 브랜치 생성
/git-workflow start feature user-auth
# 결과: git checkout -b feature/user-auth develop
```

### 기능 완료 및 PR 생성

```bash
# 기능 완료 및 PR 생성
/git-workflow finish feature user-auth
# 결과:
# 1. develop으로 머지
# 2. PR 자동 생성
# 3. 기능 브랜치 삭제
```

### 릴리스 시작

```bash
# 릴리스 시작
/git-workflow start release v1.2.0
# 결과: develop → release/v1.2.0
```

### 핫픽스 생성

```bash
# 핫픽스 생성
/git-workflow start hotfix auth-bug
# 결과: main → hotfix/auth-bug
```

---

## 커밋 메시지 템플릿

### Feature 템플릿

```yaml
feature: |
  {type}({scope}): {subject}

  {body}

  - 관련 이슈: {issues}
  - 영향 모듈: {modules}
  - 테스트: {test_status}
```

### Bugfix 템플릿

```yaml
bugfix: |
  fix({scope}): {subject}

  문제 현상:
  - {problem_description}

  해결 방안:
  - {solution}

  테스트 결과:
  - {test_results}
```

### Chore 템플릿

```yaml
chore: |
  chore({scope}): {subject}

  변경 사항:
  - {changes}
```

---

## 후속 작업 TUI

### 커밋 완료 후 선택 화면

```
커밋이 완료되었습니다. 다음 작업을 선택하세요.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1] 푸시
    원격 저장소에 푸시합니다

[2] 추가 커밋
    다른 변경 사항을 추가로 커밋합니다

[3] 완료
    작업을 종료합니다
```

---

## 통합 예시

### IDE 단축키 설정

```json
// VS Code keybindings.json
{
  "key": "ctrl+enter",
  "command": "git.commit",
  "args": ["--message", "${input:commitMessage}"],
  "when": "editorTextFocus"
}
```

### Git Hooks

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

### CI/CD 파이프라인

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

---

## 코드 리뷰 연동

### 설정

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

### GPG 서명 커밋

```bash
# GPG 서명 설정
/git-workflow config gpg.sign true
/git-workflow config gpg.key "ABCD1234"

# 서명된 커밋
/git-commit --sign
```

---

## 대규모 변경 처리

### 분할 커밋

```bash
# 변경이 많을 때 분할 커밋
/git-commit --batch

# 결과:
# 1. 관련 파일별로 그룹화
# 2. 논리적 단위로 분할
# 3. 각 그룹별 커밋 제안
# 4. 전체 실행 또는 선택적 실행
```

[parent](../CLAUDE.md)
