---
name: code-quality
description: '코드 품질 관리 - 리뷰, 테스트 자동화, 보안 분석'
category: quality
---

# code-quality Plugin

코드 품질을 체계적으로 관리하고 개선하는 통합 플랫폼입니다.

## Core Philosophy

```
코드 품질 원칙:
├─ 선제적 검증: 문제가 발생하기 전에 미리 발견
├─ 자동화: 반복적인 품질 검사 프로세스 자동화
├─ 측정 가능성: 품질 지표를 데이터로 추적
└─ 지속적 개선: 피드백 루프를 통한 점진적 향상
```

## Components

| Type | Name | Description |
|------|------|-------------|
| Agent | [code-reviewer](agents/code-reviewer.md) | 보안, 성능, 유지보수성, 신뢰성 분석 |
| Agent | [test-automator](agents/test-automator.md) | Suites 3.x 기반 테스트 자동 생성 |
| Command | [/review](commands/review.md) | 실시간 코드 리뷰 실행 |
| Skill | [testing-patterns](skills/testing-patterns/SKILL.md) | 테스트 패턴 및 모킹 전략 |

## Quick Usage

```bash
# 전체 코드 리뷰
/review

# 특정 파일/디렉토리
/review src/auth/

# 보안 전용 스캔
/review --security-only

# CI 모드 (JSON 출력)
/review --format json --output results.json

# 자동 수정
/review --auto-fix low
```

## Analysis Categories

- **Security**: OWASP Top 10, 인증/인가, 입력 검증
- **Performance**: 알고리즘 복잡도, N+1 쿼리, 메모리 누수
- **Maintainability**: SOLID 원칙, 코드 중복, 함수 복잡도
- **Reliability**: 에러 핸들링, 타입 안전성, 경계 조건

## Key Features

- 3단계 스캔 레벨 (quick/standard/thorough)
- CI/CD 파이프라인 통합
- Git Hooks 연동
- 커스텀 규칙 엔진
- 품질 트렌드 추적

## Detailed Documentation

| Document | Contents |
|----------|----------|
| [detailed-guides.md](agent-docs/detailed-guides.md) | 분석 카테고리, 스캔 레벨, 테스트 생성 전략 |
| [examples.md](agent-docs/examples.md) | CI/CD 통합, Git Hooks, 사용 예제 |
| [references.md](agent-docs/references.md) | 베스트 프랙티스, 트러블슈팅, 성능 최적화 |

---

[parent](../CLAUDE.md)
