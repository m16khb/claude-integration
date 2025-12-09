# 상세 가이드

## 커맨드 작성 가이드

### Frontmatter 구조

```yaml
---
name: command-name
description: '커맨드 설명'
argument-hint: <required> [optional]
allowed-tools:
  - Read
  - Write
  - Bash
model: claude-opus-4-5-20251101  # 복잡한 작업은 Opus
---
```

### 주의사항
- `commands/` 디렉토리의 모든 .md 파일은 슬래시 커맨드로 자동 인식
- 민감 정보(API 키, 패스워드) 노출 금지
- Bash 도구 사용시 패턴 명시: `Bash(git:*, npm:*)`
- **복잡한 분석/생성 작업은 Opus 4.5 사용**

## 에이전트 작성 가이드

### 표준 11개 섹션

1. **Frontmatter**: name, description, model, allowed-tools
2. **Purpose**: 에이전트의 핵심 정체성
3. **Core Philosophy**: 설계 원칙
4. **Capabilities**: 도메인별 전문성
5. **Behavioral Traits**: 행동 양식
6. **Workflow Position**: 다른 에이전트와의 관계
7. **Knowledge Base**: 보유 지식 영역
8. **Response Approach**: 문제해결 프로세스
9. **Example Interactions**: 활용 시나리오
10. **Key Distinctions**: 유사 역할과의 경계
11. **Output Examples**: 결과물 기준

### 모델 선택 기준

| 모델 | 용도 | 예시 |
|------|------|------|
| **Opus 4.5** | 복잡한 분석, 아키텍처 설계, 오케스트레이션 | full-stack-orchestrator, typeorm-expert |
| **Sonnet** | 중간 복잡도, 코드 리뷰, 표준 구현 | code-reviewer |
| **Haiku** | 빠른 실행, 간단한 작업, 결정론적 출력 | git-commit |

## 스킬 작성 가이드

### 스킬의 역할
- **지식 재사용**: 여러 에이전트가 공유하는 지식 중앙화
- **자동 활성화**: 키워드 감지으로 관련 스킬 자동 로드
- **전문화된 처리**: 특정 도메인의 패턴과 모범 사례 제공

### 스킬 구조

```
skill-name/
├── SKILL.md          # 스킬 정의
├── patterns/         # 패턴 예시
└── resources/        # 추가 리소스
```

## Document Builder Agent

### 역할
코드베이스 분석을 통한 지능적 문서 생성 전문가

### 핵심 기능
- **코드 분석**: AST 파싱, 의존성 분석, 패턴 인식
- **문서 유추**: 코드에서 자동으로 문서 내용 추출
- **구조화**: 계층적인 문서 구조 자동 생성
- **다이어그램**: Mermaid를 통한 시각화 자동 생성
- **검증**: 생성된 문서의 정확성 검증

### 분석 대상

```
ANALYSIS TARGETS:
├─ 소스 코드
│   ├─ TypeScript/JavaScript 인터페이스
│   ├─ Python 클래스와 메서드
│   ├─ Go 구조체와 인터페이스
│   └─ Java 클래스와 패키지
│
├─ 설정 파일
│   ├─ package.json, requirements.txt
│   ├─ Dockerfile, docker-compose.yml
│   ├─ Kubernetes 매니페스트
│   └─ CI/CD 파이프라인
│
├─ API 정의
│   ├─ OpenAPI/Swagger 스펙
│   ├─ GraphQL 스키마
│   ├─ gRPC 프로토콜
│   └─ REST API 엔드포인트
│
└─ 아키텍처
    ├─ 모듈 의존성 그래프
    ├─ 데이터 흐름 다이어그램
    ├─ 시퀀스 다이어그램
    └─ 배포 아키텍처
```

## 문서 템플릿 라이브러리

```
TEMPLATE LIBRARY:
├─ 프로젝트 문서
│   ├─ CLAUDE.md (Claude Code 설정)
│   ├─ README.md (프로젝트 소개)
│   ├─ CONTRIBUTING.md (기여 가이드)
│   └─ CHANGELOG.md (변경 이력)
│
├─ API 문서
│   ├─ OpenAPI 3.0 스펙
│   ├─ Postman 컬렉션
│   ├─ API 사용 가이드
│   └─ SDK 생성 템플릿
│
├─ 아키텍처 문서
│   ├─ 시스템 아키텍처
│   ├─ 데이터 모델
│   ├─ 배포 가이드
│   └─ 운영 가이드
│
└─ 기술 문서
    ├─ 튜토리얼
    ├─ How-to 가이드
    ├─ 트러블슈팅
    └─ FAQ
```

## Agent Routing System

### 키워드 기반 자동 선택

```
USER REQUEST → KEYWORD DETECTION → EXPERT SELECTION → TASK EXECUTION

예시:
"Redis 캐시 설정" → redis-cache-expert
"TypeORM 엔티티 + 테스트" → typeorm-expert → suites-testing-expert (SEQUENTIAL)
"캐시랑 큐 설정" → [redis-cache-expert, bullmq-queue-expert] (PARALLEL)
```

### 라우팅 테이블

`.claude-plugin/routing-table.json`이 모든 컴포넌트의 트리거 키워드를 중앙 관리:

```json
{
  "components": {
    "agents": {
      "redis-cache-expert": {
        "triggers": {
          "primary": ["redis", "캐시", "cache"],
          "secondary": ["TTL", "ioredis"],
          "context": ["interceptor", "cluster"]
        }
      }
    }
  },
  "routing_rules": {
    "keyword_priority": { "primary_weight": 3, "secondary_weight": 2, "context_weight": 1 },
    "execution_strategies": { "SINGLE_EXPERT", "SEQUENTIAL", "PARALLEL", "DIRECT" }
  }
}
```

### 키워드 점수 계산
- primary(3점) + secondary(2점) + context(1점) → 최고 점수 에이전트 선택

## 워크플로우 패턴

### 1. SEQUENTIAL (순차 실행)
의존성 있는 작업:
```
엔티티 생성 → 테스트 작성
typeorm-expert → suites-testing-expert
```

### 2. PARALLEL (병렬 실행)
독립적 작업:
```
캐시 설정 + 큐 설정
[redis-cache-expert, bullmq-queue-expert]
```

### 3. SINGLE_EXPERT (단일 전문가)
단일 도메인:
```
마이그레이션 최적화
typeorm-expert
```

## Progressive Disclosure 패턴

### 정보 계층 구조
```
Root CLAUDE.md (150라인)
├── 핵심 개요, 빠른 시작
├── @import agent-docs/*
└── 모듈 참조 링크

Module CLAUDE.md (80라인)
├── 모듈 개요, 주요 컴포넌트
├── 빠른 참조 가이드
└── 상세 문서 링크

agent-docs/ (상세)
├── detailed-guides.md
├── examples.md
├── patterns.md
└── references.md
```

## 테스트 작성 가이드 (Suites 3.x)

### 기본 패턴

```typescript
import { TestBed, type Mocked } from '@suites/unit';

describe('UserService', () => {
  let service: UserService;
  let repository: Mocked<UserRepository>;

  beforeAll(async () => {
    const { unit, unitRef } = await TestBed.solitary(UserService).compile();
    service = unit;
    repository = unitRef.get(UserRepository);
  });

  it('should find user', async () => {
    repository.findOne.mockResolvedValue({ id: '1' });
    const result = await service.findById('1');
    expect(result.id).toBe('1');
  });
});
```

### 핵심 포인트
- `TestBed.solitary()`: 모든 의존성 자동 모킹
- `await .compile()`: **비동기 필수**
- `Mocked<T>`: 타입 안전한 모킹

## 오케스트레이션 패턴

### 오케스트레이터의 역할
1. **요청 분석**: 복합 요청을 개별 작업으로 분해
2. **전문가 선택**: 라우팅 시스템을 통한 최적의 전문가 매칭
3. **실행 조율**: 순차/병렬 실행 관리
4. **결과 통합**: 여러 전문가의 결과물 통합

### 예시: full-stack-orchestrator
```
Input: "게임 API 구현 및 테스트"
↓
1. 분해: 백엔드 API + 테스트 자동화
2. 선택: nestjs-fastify-expert + test-automator
3. 실행: SEQUENTIAL 패턴
4. 통합: API 구현 + 테스트 코드
```

## 모범 사례

### 1. 단일 책임 원칙
- 각 컴포넌트는 명확한 하나의 책임만 수행
- 에이전트는 특정 도메인에만 집중

### 2. 자동화 우선
- 반복 작업은 반드시 자동화
- proactive_triggers로 선제적 실행

### 3. 문서 중심 설계
- 모든 컴포넌트는 자체 문서 보유
- 계층적 구조로 정보 과부하 방지

### 4. 테스트 동반 개발
- 모든 구현은 테스트 코드 동반
- suites-testing-expert 자동 활성화
