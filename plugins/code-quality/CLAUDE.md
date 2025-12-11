---
name: code-quality
description: '코드 품질 관리 - 리뷰, 테스트 자동화, 보안 분석'
category: quality
---

# code-quality Plugin

코드 품질을 체계적으로 관리하고 개선하는 통합 플랫폼입니다.

## Core Philosophy

```
CODE QUALITY PIPELINE:
Code Changes → Analysis → Report → Auto-fix → Commit
    │
    ├─ Security: OWASP Top 10
    ├─ Performance: N+1, Memory leaks
    ├─ Maintainability: SOLID, Complexity
    └─ Reliability: Error handling, Type safety
```

- **선제적 검증**: 문제가 발생하기 전에 미리 발견
- **자동화**: 반복적인 품질 검사 프로세스 자동화
- **측정 가능성**: 품질 지표를 데이터로 추적

## Components

| Type | Name | Description |
|------|------|-------------|
| Agent | `agents/code-reviewer.md` | 보안, 성능, 유지보수성 분석 |
| Agent | `agents/test-automator.md` | Suites 3.x 기반 테스트 자동 생성 |
| Command | `commands/review.md` | 실시간 코드 리뷰 실행 |
| Skill | `skills/testing-patterns/SKILL.md` | 테스트 패턴 및 모킹 전략 |

## /review Command

```bash
# 기본 사용
/code-quality:review                    # 전체 프로젝트
/code-quality:review src/auth/          # 특정 디렉토리
/code-quality:review --changed          # Git 변경 파일만

# 분석 옵션
/code-quality:review --security-only    # 보안 분석만
/code-quality:review --level thorough   # 심층 스캔

# 자동 수정
/code-quality:review --auto-fix low     # LOW 이슈 자동 수정
```

## Scan Levels

| 레벨 | 시간 | 사용 시점 |
|------|------|----------|
| quick | 1-2분 | 커밋 전 |
| standard | 3-5분 | PR 리뷰 |
| thorough | 5-10분 | 릴리스 전 |

## test-automator Agent

Suites 3.x (구 Automock) 기반 테스트 자동 생성:

```typescript
import { TestBed, type Mocked } from '@suites/unit';

const { unit, unitRef } = await TestBed
  .solitary(ServiceUnderTest)
  .compile();

const repository: Mocked<UserRepository> = unitRef.get(UserRepository);
```

## Coverage Targets

| 레이어 | 목표 |
|--------|------|
| Service | 90%+ |
| Controller | 80%+ |
| Utils | 95%+ |

## Structure

```
plugins/code-quality/
├─ CLAUDE.md
├─ agents/
│   ├─ code-reviewer.md
│   └─ test-automator.md
├─ commands/review.md
├─ skills/testing-patterns/
└─ agent-docs/
```

## Best Practices

```
DO ✅:
├─ 커밋 전 --level quick 실행
├─ PR 전 --level standard 실행
└─ CI에서 --format sarif 사용

DON'T ❌:
├─ 보안 경고 무시
├─ 테스트 없이 커밋
└─ 자동 수정 검증 없이 적용
```

## Documentation (필요 시 Read 도구로 로드)

| 문서 | 설명 |
|------|------|
| `agent-docs/security-analysis.md` | OWASP Top 10 상세, 취약점 패턴 |
| `agent-docs/testing-strategies.md` | Suites 3.x API, 테스트 패턴 |
| `agent-docs/test-container.md` | Testcontainers Integration/E2E 테스트 |
| `agent-docs/review-workflow.md` | CI/CD 통합, 커스텀 규칙 |

[parent](../CLAUDE.md)
