# Agent Skills Guide

## 핵심 구조

Agent Skills는 Claude의 기능을 확장하는 모듈식 패키지입니다. **점진적 공개(Progressive Disclosure)** 패턴을 통해 토큰 효율적인 지식 로딩을 구현합니다.

## Progressive Disclosure 아키텍처

스킬은 3단계 아키텍처로 구성됩니다:

```
SKILL LOADING HIERARCHY:
├─ Level 1: 메타데이터 (항상 로드)
│   ├─ name: 스킬 식별자
│   ├─ description: 활성화 기준 포함
│   └─ triggers: 키워드 매칭
│
├─ Level 2: Instructions (활성화 시 로드)
│   ├─ 핵심 지도 원칙
│   ├─ 수행 절차
│   └─ 제약 조건
│
└─ Level 3: Resources (필요 시 로드)
    ├─ 예제 코드
    ├─ 템플릿
    └─ 참조 문서
```

## 스킬 파일 형식

### 메타데이터 (Frontmatter)

```yaml
---
name: skill-name-in-kebab-case
description: |
  스킬 설명. 1024자 미만.
  **사용 시기**: 이 스킬이 활성화되어야 하는 조건을 명시합니다.
triggers:
  - keyword1
  - keyword2
  - 한글키워드
---
```

### 본문 구조

```markdown
# Skill Name

## Purpose
스킬의 핵심 목적과 해결하는 문제

## Instructions
활성화 시 따라야 할 핵심 지침

## Resources
필요 시 참조할 예제, 템플릿, 코드 스니펫

## Examples
실제 사용 시나리오

## Constraints
스킬 적용 시 제약 사항
```

## 활성화 메커니즘

스킬은 **패턴 매칭**으로 자동 활성화됩니다:

```
USER INPUT → KEYWORD EXTRACTION → TRIGGER MATCHING → SKILL ACTIVATION

예시:
"Redis 캐싱 설정해줘"
  → 키워드: ["redis", "캐싱", "설정"]
  → 매칭: redis-cache-expert 트리거와 일치
  → 결과: redis-cache-expert 스킬 활성화
```

## 현재 스킬 목록

### document-builder-templates

**계층적 문서 생성을 위한 템플릿 모음**

| 항목 | 내용 |
|------|------|
| 플러그인 | documentation-generation |
| 트리거 | claude.md, agent-docs, 문서 템플릿, documentation |

**포함 템플릿:**
- 루트 CLAUDE.md 템플릿
- 모듈 CLAUDE.md 템플릿
- agent-docs 문서 템플릿

---

## 스킬 개발 가이드

### 1. 스킬 파일 생성

`plugins/{plugin-name}/skills/` 디렉토리에 마크다운 파일 생성:

```
plugins/
└── my-plugin/
    └── skills/
        └── my-skill.md
```

### 2. 메타데이터 정의

```yaml
---
name: my-skill
description: |
  스킬 설명. **사용 시기**: 조건 명시.
triggers:
  - trigger1
  - trigger2
---
```

### 3. 본문 작성

Progressive Disclosure 원칙에 따라:
- **즉시 필요한 정보**: Instructions 섹션에
- **필요 시 참조 정보**: Resources 섹션에
- **예제 코드**: Examples 섹션에

### 4. marketplace.json 등록

```json
{
  "skills": [
    "skills/my-skill.md"
  ]
}
```

## 스킬 vs 에이전트

| 구분 | 스킬 | 에이전트 |
|------|------|---------|
| 목적 | 지식 패키지 | 행동 주체 |
| 활성화 | 자동 (패턴 매칭) | 명시적 호출 |
| 컨텍스트 | 점진적 로딩 | 전체 로딩 |
| 독립성 | 에이전트에 종속 | 독립적 실행 |

## 토큰 효율성

스킬의 Progressive Disclosure는 토큰 사용을 최적화합니다:

```
WITHOUT SKILLS:
├─ 모든 지식 항상 로드
└─ 컨텍스트 낭비 발생

WITH SKILLS:
├─ 메타데이터만 항상 로드 (~100 토큰)
├─ Instructions 활성화 시 로드 (~500 토큰)
└─ Resources 필요 시 로드 (~1000+ 토큰)
```

## 다중 스킬 활성화

하나의 요청에서 여러 스킬이 활성화될 수 있습니다:

```
"Kubernetes와 Helm 차트 배포 설정"
  → 활성화: kubernetes-deployment, helm-charts
  → 두 스킬의 Instructions 결합
  → 필요한 Resources만 선택적 로드
```

## 모범 사례

1. **명확한 트리거**: 중복 없는 고유 키워드 사용
2. **계층적 정보**: 중요도에 따라 섹션 분리
3. **간결한 Instructions**: 핵심만 포함
4. **풍부한 Resources**: 다양한 예제 제공
5. **버전 관리**: 변경 시 버전 업데이트
