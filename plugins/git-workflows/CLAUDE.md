---
name: git-workflows
description: 'Git 워크플로우 자동화 - 스마트 커밋, Git Flow 지원'
category: development
---

# git-workflows Plugin

지능적인 Git 워크플로우 자동화 시스템으로 변경사항을 분석하고 최적의 커밋 메시지를 생성합니다.

## Core Philosophy

```
SMART COMMIT:
Git Changes → Analysis → Grouping → Message → Commit
```

- **의미 있는 커밋**: 변경의 "왜"와 "무엇"을 명확히 전달
- **일관된 형식**: Conventional Commits 표준 준수
- **자동 그룹화**: 논리적 단위로 변경사항 자동 분할

## Commands

| 커맨드 | 설명 | 인자 |
|--------|------|------|
| `/git-workflows:git-commit` | 변경사항 분석 및 스마트 커밋 | `push` - 커밋 후 자동 푸시 |

## Commit Message Structure

```
<type>(<scope>): <subject>     ← 헤더 (50자)

[optional body]                ← 본문 (변경 이유)

Closes #123                    ← 이슈 연결
🤖 Generated with Claude Code  ← 자동 추가
```

## Commit Types

| 타입 | 설명 | 사용 시점 |
|------|------|----------|
| `feat` | 새로운 기능 | 새 파일, 새 API |
| `fix` | 버그 수정 | 오류 해결 |
| `refactor` | 구조 개선 | 동작 변경 없이 개선 |
| `docs` | 문서 수정 | README, 주석 |
| `test` | 테스트 | 테스트 케이스 |
| `chore` | 설정/의존성 | package.json |

## Smart Grouping

```
8 FILES CHANGED → 4 GROUPS:

Group 1: auth (source) - feat
├─ src/auth/auth.service.ts
└─ src/auth/dto/login.dto.ts

Group 2: test - test
└─ tests/auth/auth.service.spec.ts

Group 3: docs - docs
└─ README.md

Group 4: config - chore
└─ package.json
```

## Usage

```bash
# 기본 사용 - 자동 분석 및 커밋
/git-workflows:git-commit

# 커밋 후 자동 푸시
/git-workflows:git-commit push

# 이슈 연결
/git-workflows:git-commit --issue PROJ-123
```

## Security Features

```
├─ 민감 파일 자동 감지 (.env, *.key)
├─ 스테이징 자동 취소 + 경고
├─ main/master 직접 푸시 경고
└─ 대용량 파일 경고 (>100KB)
```

## Branch Context

| 브랜치 패턴 | 예상 커밋 타입 |
|------------|--------------|
| `feature/*` | feat, refactor |
| `hotfix/*` | fix |
| `release/*` | fix, chore, docs |

## Structure

```
plugins/git-workflows/
├─ CLAUDE.md
├─ commands/git-commit.md
└─ agent-docs/
```

## Best Practices

```
DO ✅:
├─ 논리적 단위로 커밋 분할
├─ 이슈 번호 연결 (추적성)
└─ 브랜치 컨텍스트 활용

DON'T ❌:
├─ 모든 변경 하나로 커밋
├─ 민감 파일 커밋 (.env)
└─ main 브랜치 직접 푸시
```

## Documentation

- @agent-docs/commit-conventions.md - Conventional Commits 상세, 타입 감지
- @agent-docs/branch-strategies.md - Git Flow 상세, 브랜치 명명
- @agent-docs/automation-patterns.md - 다중 커밋, 스마트 그룹화

@../CLAUDE.md
