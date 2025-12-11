---
name: git-workflows
description: 'Git 워크플로우 자동화 - Conventional Commits 1.0.0, Worktree 관리'
category: development
---

# git-workflows Plugin

Conventional Commits 1.0.0 규격을 완벽히 준수하는 지능적인 Git 워크플로우 자동화 시스템입니다.

## Core Philosophy

```
SMART GIT WORKFLOW:
├─ Commit: Changes → Analysis → Grouping → BREAKING CHECK → Message
└─ Worktree: Branch → Safety Check → Create/Remove → Report
```

- **Conventional Commits 1.0.0**: 규격 완전 준수
- **Semantic Versioning 연동**: 커밋 타입과 SemVer 자동 매핑
- **Worktree 관리**: 다중 브랜치 동시 작업 지원

## Semantic Versioning 연동

| 커밋 타입 | SemVer | 설명 |
|----------|--------|------|
| `feat` | MINOR | 새 기능 추가 (하위 호환) |
| `fix` | PATCH | 버그 수정 |
| `BREAKING CHANGE` | MAJOR | 단절적 변경 (호환성 파괴) |
| 기타 (docs, chore...) | - | 버전 영향 없음 |

## Commands

| 커맨드 | 설명 | 인자 |
|--------|------|------|
| `/git-workflows:git-commit` | 스마트 커밋 생성 | `push` - 커밋 후 푸시 |
| `/git-workflows:git-worktree` | Worktree 관리 | `<action> [branch] [name]` |

## git-worktree 사용법

```bash
# 워크트리 생성 (기존 브랜치)
/git-workflows:git-worktree add feature/auth

# 워크트리 생성 (이름 지정)
/git-workflows:git-worktree add feature/auth my-feature

# 워크트리 목록
/git-workflows:git-worktree list

# 워크트리 삭제
/git-workflows:git-worktree remove my-feature

# 정리 (삭제된 참조 제거)
/git-workflows:git-worktree prune
```

### Worktree 활용 시나리오

```
USE CASES:
├─ 긴급 버그 수정: 현재 작업 유지하며 hotfix 브랜치 작업
├─ 동시 빌드: main, develop 동시에 빌드 확인
├─ PR 리뷰: 작업 중단 없이 PR 코드 체크아웃
└─ A/B 비교: 두 브랜치 코드 나란히 비교
```

## Commit Types

| 타입 | 설명 | SemVer |
|------|------|--------|
| `feat` | 새로운 기능 | MINOR |
| `fix` | 버그 수정 | PATCH |
| `docs` | 문서만 수정 | - |
| `style` | 포맷팅 | - |
| `refactor` | 구조 개선 | - |
| `perf` | 성능 개선 | - |
| `test` | 테스트 | - |
| `chore` | 빌드/설정 | - |
| `ci` | CI/CD | - |
| `revert` | 되돌리기 | * |

## BREAKING CHANGE 문법

```
방법 1: 타입 뒤에 ! 추가
feat!: API 응답 형식 변경
feat(api)!: 인증 방식 변경

방법 2: 꼬리말에 BREAKING CHANGE
feat(api): 새 인증 시스템

BREAKING CHANGE: 기존 Bearer 토큰 무효화
```

## Commit Message Structure

```
<type>[scope][!]: <subject>     ← 헤더 (50자)

[optional body]                 ← 본문 (변경 이유)

[optional footer]               ← 꼬리말
BREAKING CHANGE: <description>  ← 단절적 변경 시
Closes #123                     ← 이슈 연결
🤖 Generated with Claude Code   ← 자동 추가
```

## Smart Grouping

```
8 FILES → 4 GROUPS:
├─ Group 1: auth (source) → feat
├─ Group 2: test → test  
├─ Group 3: docs → docs
└─ Group 4: config → chore
```

## Security Features

```
├─ 민감 파일 자동 감지 (.env, *.key)
├─ main/master 직접 푸시 경고
├─ 대용량 파일 경고 (>100KB)
└─ Worktree 변경사항 확인 후 삭제
```

## Branch Context

| 브랜치 패턴 | 예상 타입 | SemVer |
|------------|----------|--------|
| `feature/*` | feat, refactor | MINOR |
| `hotfix/*` | fix | PATCH |
| `release/*` | fix, chore, docs | PATCH |

## Structure

```
plugins/git-workflows/
├─ CLAUDE.md
├─ commands/
│   ├─ git-commit.md      ← 스마트 커밋
│   └─ git-worktree.md    ← Worktree 관리
└─ agent-docs/
    ├─ commit-conventions.md
    ├─ branch-strategies.md
    └─ automation-patterns.md
```

## Best Practices

```
DO ✅:
├─ 논리적 단위로 커밋 분할
├─ BREAKING CHANGE 명시적 표기
├─ Worktree로 다중 브랜치 동시 작업
├─ 작업 완료 후 Worktree 정리
└─ feat/fix로 SemVer 활용

DON'T ❌:
├─ 모든 변경 하나로 커밋
├─ BREAKING CHANGE 누락
├─ Worktree 디렉토리 수동 삭제
├─ 민감 파일 커밋 (.env)
└─ main 브랜치 직접 푸시
```

## Documentation (필요 시 Read 도구로 로드)

| 문서 | 설명 |
|------|------|
| `agent-docs/commit-conventions.md` | Conventional Commits 1.0.0 전체 규격 |
| `agent-docs/branch-strategies.md` | Git Flow 상세, 브랜치 명명 |
| `agent-docs/automation-patterns.md` | 다중 커밋, 스마트 그룹화 |

[parent](../CLAUDE.md)
