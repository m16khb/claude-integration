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
┌─────────────────────────────────────────────────────────┐
│  Code Changes → Analysis → Report → Auto-fix → Commit  │
│                                                         │
│  ├─ Security: OWASP Top 10                             │
│  ├─ Performance: N+1, Memory leaks                     │
│  ├─ Maintainability: SOLID, Complexity                 │
│  └─ Reliability: Error handling, Type safety           │
└─────────────────────────────────────────────────────────┘
```

- **선제적 검증**: 문제가 발생하기 전에 미리 발견
- **자동화**: 반복적인 품질 검사 프로세스 자동화
- **측정 가능성**: 품질 지표를 데이터로 추적
- **지속적 개선**: 피드백 루프를 통한 점진적 향상

## Components

| Type | Name | Description |
|------|------|-------------|
| Agent | @agents/code-reviewer.md | 보안, 성능, 유지보수성, 신뢰성 분석 |
| Agent | @agents/test-automator.md | Suites 3.x 기반 테스트 자동 생성 |
| Command | @commands/review.md | 실시간 코드 리뷰 실행 |
| Skill | @skills/testing-patterns/SKILL.md | 테스트 패턴 및 모킹 전략 |

## code-reviewer Agent

4가지 카테고리로 종합 분석합니다:

| 카테고리 | 분석 대상 | 심각도 |
|---------|----------|--------|
| Security | OWASP Top 10, SQL Injection, XSS | CRITICAL/HIGH |
| Performance | N+1 쿼리, 메모리 누수, 복잡도 | HIGH/MEDIUM |
| Maintainability | SOLID 위반, 코드 중복, 매직 넘버 | MEDIUM/LOW |
| Reliability | 에러 핸들링, 타입 안전성 | HIGH/MEDIUM |

## test-automator Agent

Suites 3.x (구 Automock) 기반 테스트 자동 생성:

```
TESTING PYRAMID:
        ┌─────────┐
        │   E2E   │  10% - Testcontainers
        ├─────────┤
        │ Integra │  20% - Testcontainers
        │  tion   │
┌───────┴─────────┴───────┐
│      Unit Tests         │  70% - Suites 3.x
└─────────────────────────┘
```

### Suites 3.x API

```typescript
import { TestBed, type Mocked } from '@suites/unit';

// Solitary Test: 모든 의존성 자동 모킹
const { unit, unitRef } = await TestBed
  .solitary(ServiceUnderTest)
  .compile();

const repository: Mocked<UserRepository> = unitRef.get(UserRepository);
repository.findOne.mockResolvedValue(mockUser);
```

## /review Command

```bash
# 기본 사용
/code-quality:review                    # 전체 프로젝트
/code-quality:review src/auth/          # 특정 디렉토리
/code-quality:review --changed          # Git 변경 파일만

# 분석 옵션
/code-quality:review --security-only    # 보안 분석만
/code-quality:review --performance-only # 성능 분석만
/code-quality:review --level thorough   # 심층 스캔

# 출력 형식
/code-quality:review --format json      # JSON (CI용)
/code-quality:review --format sarif     # SARIF (GitHub)

# 자동 수정
/code-quality:review --auto-fix low     # LOW 이슈 자동 수정
```

## Scan Levels

| 레벨 | 시간 | 범위 | 사용 시점 |
|------|------|------|----------|
| **quick** | 1-2분 | 변경 파일, 패턴 검사 | 커밋 전 |
| **standard** | 3-5분 | 영향 파일, AST 분석 | PR 리뷰 |
| **thorough** | 5-10분 | 전체, 데이터 흐름 | 릴리스 전 |

## Security Analysis (OWASP Top 10)

| 코드 | 취약점 | 탐지 패턴 |
|------|--------|----------|
| A01 | Broken Access Control | IDOR, 권한 우회 |
| A02 | Cryptographic Failures | 약한 알고리즘, 하드코딩 키 |
| A03 | Injection | SQL, NoSQL, Command Injection |
| A04 | Insecure Design | Race Condition, 입력 검증 부재 |
| A05 | Security Misconfiguration | 기본 자격증명, 디버그 모드 |

### 취약/안전 패턴 비교

```typescript
// ❌ 취약: 인가 없이 리소스 접근
@Get(':id')
async getUser(@Param('id') id: string) {
  return this.userService.findById(id);
}

// ✅ 안전: 권한 검증 추가
@Get(':id')
@UseGuards(AuthGuard, OwnerGuard)
async getUser(@Param('id') id: string, @CurrentUser() user: User) {
  if (user.id !== id && !user.isAdmin) throw new ForbiddenException();
  return this.userService.findById(id);
}
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Code Review
  run: |
    claude-code review --format sarif --changed
- uses: github/codeql-action/upload-sarif@v2
```

### Git Hooks (pre-commit)

```bash
claude-code review --staged --level quick
```

## Coverage Targets

| 레이어 | 목표 | 우선순위 |
|--------|------|----------|
| Service | 90%+ | 높음 |
| Controller | 80%+ | 중간 |
| Repository | 70%+ | 중간 |
| Utils | 95%+ | 높음 |

## Structure

```
plugins/code-quality/
├─ CLAUDE.md                    # 본 문서
├─ agents/
│   ├─ code-reviewer.md         # 코드 리뷰 에이전트
│   └─ test-automator.md        # 테스트 자동화 에이전트
├─ commands/
│   └─ review.md                # /review 커맨드
├─ skills/
│   └─ testing-patterns/        # 테스트 패턴 스킬
└─ agent-docs/                  # 상세 문서
    ├─ security-analysis.md     # OWASP Top 10 상세
    ├─ testing-strategies.md    # Suites 3.x 패턴
    ├─ test-container.md        # Testcontainers 가이드
    └─ review-workflow.md       # CI/CD 통합
```

## Best Practices

```
DO ✅:
├─ 커밋 전 --level quick 실행
├─ PR 전 --level standard 실행
├─ 릴리스 전 --level thorough 실행
└─ CI에서 --format sarif 사용

DON'T ❌:
├─ 보안 경고 무시
├─ 테스트 없이 커밋
├─ 커버리지 임계값 미달
└─ 자동 수정 검증 없이 적용
```

## Documentation

- @agent-docs/security-analysis.md - OWASP Top 10 상세, 취약점 패턴, 탐지 규칙
- @agent-docs/testing-strategies.md - Suites 3.x API, 테스트 패턴, 커버리지 전략
- @agent-docs/test-container.md - Testcontainers 설정, Integration/E2E 테스트
- @agent-docs/review-workflow.md - 리뷰 프로세스, CI/CD 통합, 커스텀 규칙

@../CLAUDE.md
