# Git Workflows 참고 자료

## Best Practices

### 커밋 작성 원칙

| 원칙 | 설명 |
|------|------|
| **원자적 커밋** | 하나의 논리적 변경만 커밋 |
| **명확한 제목** | 50자 이내로 핵심 내용 전달 |
| **상세한 본문** | 왜 변경했는지, 어떻게 변경했는지 설명 |
| **일관된 형식** | 팀 규칙 준수 |

### 브랜치 관리 원칙

| 원칙 | 설명 |
|------|------|
| **짧은 생명주기** | 기능 브랜치는 최대 2주 유지 |
| **정기 동기화** | 주기적으로 upstream 변경 가져오기 |
| **명확한 이름** | 기능을 예측할 수 있는 브랜치 이름 |
| **적시 삭제** | 머지 후 브랜치 즉시 삭제 |

### 협업 원칙

| 원칙 | 설명 |
|------|------|
| **PR 전 커밋** | PR 전 로컬에서 커밋 완료 |
| **의미 있는 리뷰** | 코드 리뷰는 커밋 단위로 |
| **커밋 그룹화** | 관련 커밋은 하나의 PR에 |
| **히스토리 정리** | 필요시 rebase로 커밋 정리 |

---

## Troubleshooting

### 커밋 메시지 생성 실패

```
문제: 변경 사항 분석 실패
원인: 스테이징된 변경 없음 또는 너무 많은 변경

해결 방법:
1. git status 확인
2. git add 로 변경 스테이징
3. --batch 옵션으로 대용량 변경 분할
```

### PR 생성 실패

```
문제: PR 자동 생성 오류
원인: 권한 부족 또는 브랜치 충돌

해결 방법:
1. GitHub 토큰 확인
2. 원격 브랜치 최신화
3. 충돌 해결 후 재시도
```

### Nothing to commit

```
문제: 커밋할 변경 사항 없음

해결 방법:
1. git status로 상태 확인
2. 변경된 파일이 있다면 git add로 스테이징
3. .gitignore 설정 확인
```

### Merge conflict

```
문제: 머지 충돌 발생

해결 방법:
1. git status로 충돌 파일 확인
2. 충돌 파일 수동 해결
3. git add 후 커밋 재시도
```

### Push rejected

```
문제: 푸시 거부됨 (non-fast-forward)

해결 방법:
git pull --rebase origin {branch} 후 다시 시도
```

### Pre-commit hook fail

```
문제: 훅 실패로 커밋 중단

해결 방법:
1. 훅 출력 메시지 확인
2. 린터/테스트 오류 수정
3. 커밋 재시도
```

### No remote configured

```
문제: 원격 저장소 설정 안됨

해결 방법:
git remote add origin <url>
```

### Auth failure

```
문제: 인증 실패

해결 방법:
1. GitHub 토큰 확인 (만료 여부)
2. SSH 키 설정 확인
3. git credential 재설정
```

### No upstream branch

```
문제: 업스트림 브랜치 없음

해결 방법:
git push -u origin {branch}로 업스트림 설정
```

### Detached HEAD

```
문제: 브랜치가 아닌 커밋에 있음

해결 방법:
git checkout -b <new-branch-name>으로 브랜치 생성
```

---

## 에러 코드 참조

| Error | Response (Korean) |
|-------|------------------|
| Nothing to commit | "변경 사항 없음" |
| Merge conflict | "충돌 파일: {files}" + "`git status`로 확인 후 해결하세요" |
| Push rejected | "`git pull --rebase origin {branch}` 후 다시 시도하세요" |
| Pre-commit hook fail | "훅 실패: {output}" + 수정 제안 |
| No remote configured | "원격 저장소 설정 필요: `git remote add origin <url>`" |
| Auth failure | "인증 실패 - GitHub 토큰 또는 SSH 키 확인 필요" |
| No upstream branch | "`git push -u origin {branch}`로 업스트림 설정" |
| Detached HEAD | "브랜치가 아닌 커밋에 있습니다. 브랜치 생성: `git checkout -b <name>`" |

---

## 아키텍처 다이어그램

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

---

## Conventional Commits 규격

### 형식

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### 타입 목록

| Type | Description |
|------|-------------|
| feat | 새로운 기능 |
| fix | 버그 수정 |
| docs | 문서 변경 |
| style | 코드 스타일 변경 (포맷팅 등) |
| refactor | 코드 리팩토링 |
| perf | 성능 개선 |
| test | 테스트 추가/수정 |
| build | 빌드 시스템 변경 |
| ci | CI 설정 변경 |
| chore | 기타 변경사항 |
| revert | 이전 커밋 되돌리기 |

### Breaking Changes

```
feat(api)!: 사용자 API v2 출시

BREAKING CHANGE: /users 엔드포인트 응답 형식 변경
```

---

## 관련 링크

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [Semantic Versioning](https://semver.org/)
- [Commitizen](https://commitizen-tools.github.io/commitizen/)

[parent](../CLAUDE.md)
