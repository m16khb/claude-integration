# Architecture & Design Principles

## 핵심 설계 철학

이 마켓플레이스는 **단일 책임 원칙(Single Responsibility Principle)**을 중심으로 설계되었습니다. 각 플러그인은 한 가지를 잘 수행하며, 평균 3-4개의 컴포넌트로 구성됩니다.

## 디렉토리 구조

```
claude-integration/
├── .claude-plugin/
│   └── marketplace.json          # 플러그인 레지스트리
├── plugins/                      # 5개 전문화된 플러그인
│   ├── backend-development/      # NestJS 생태계
│   ├── documentation-generation/ # 문서 자동화
│   ├── git-workflows/            # Git 워크플로우
│   ├── context-management/       # 컨텍스트 관리
│   └── automation-tools/         # 자동화 도구
├── agent-docs/                   # 상세 문서
└── CLAUDE.md                     # 프로젝트 루트 설정
```

## 플러그인 내부 아키텍처

각 플러그인은 **격리된 모듈식 패턴**을 따릅니다:

```
plugin-name/
├── agents/        → 도메인별 전문 에이전트
├── commands/      → 슬래시 커맨드 정의
└── skills/        → Progressive Disclosure 지식 패키지
```

**핵심 원칙**: "각 플러그인은 필요한 에이전트, 커맨드, 스킬만 컨텍스트에 로드" — 토큰 효율성 극대화

## 3-Tier Skill 아키텍처

스킬은 Progressive Disclosure를 통해 효율성을 확보합니다:

1. **메타데이터** — 항상 로드됨 (활성화 기준)
2. **Instructions** — 활성화 시 로드됨
3. **Resources** — 필요 시 로드됨 (예제, 템플릿)

## 에이전트 모델 전략

두 계층 구조로 비용-성능을 최적화합니다:

| 모델 | 용도 | 에이전트 예시 |
|------|------|-------------|
| **Haiku** | 빠른 실행, 결정론적 작업 | 코드 생성, 단순 변환 |
| **Sonnet** | 복잡한 추론, 아키텍처 결정 | 오케스트레이터, 전문가 |
| **Opus** | 고급 분석, 설계 검토 | 아키텍처 리뷰 (제한적) |

## 오케스트레이션 패턴

### Orchestrator-Worker 패턴

```
nestjs-fastify-expert (Orchestrator)
├─ 요청 분석 → 적절한 전문가 선택
├─ 복합 작업 → 여러 전문가 순차/병렬 호출
└─ Fastify 관련 → 직접 처리
```

### 하이브리드 워크플로우 패턴

- **계획 → 실행**: Sonnet이 설계, Haiku가 구현
- **추론 → 행동**: 진단 후 실행
- **복합 → 단순**: 복잡한 설계 후 개별 최적화
- **다중 에이전트**: 풀스택 기능 개발 워크플로우

## 조합 가능성

설계의 핵심은 "번들링보다 조합성"입니다:

- 사용자는 필요한 플러그인만 조합
- 각 플러그인은 독립적으로 동작
- 명확한 경계와 격리된 의존성

## 컴포넌트 구성

| 구성요소 | 수량 | 역할 |
|---------|------|------|
| 전문 에이전트 | 8개 | 도메인 지식 제공 |
| 오케스트레이터 | 1개 | 다중 에이전트 조율 |
| 슬래시 커맨드 | 7개 | 프로젝트 지원 유틸리티 |
| 에이전트 스킬 | 1개 | 모듈식 지식 패키지 |

## 플러그인 카테고리

| 카테고리 | 플러그인 | 설명 |
|---------|---------|------|
| **development** | backend-development, git-workflows | 개발 도구 |
| **documentation** | documentation-generation | 문서 자동화 |
| **productivity** | context-management, automation-tools | 생산성 도구 |

## 설계 효율성

- 평균 플러그인 크기: 3-4개 컴포넌트
- 단일 책임 원칙 준수
- 토큰 효율적인 컨텍스트 로딩
- 명확한 활성화 기준으로 불필요한 호출 방지
