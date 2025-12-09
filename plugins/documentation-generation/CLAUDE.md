---
name: documentation-generation
description: '문서 생성 자동화 - CLAUDE.md, 에이전트 문서, 템플릿'
category: documentation
---

# documentation-generation Plugin

코드베이스 분석 기반 지능적 문서 생성 시스템. 개발자가 문서 작성이 아닌 개발에 집중할 수 있도록 지원합니다.

## Core Philosophy

- **코드 분석 기반**: 실제 코드 구조를 반영한 문서
- **자동 동기화**: 코드 변경 시 문서 자동 업데이트
- **계층적 구조**: 개요 > 상세 > 참조의 3단계 구성
- **Progressive Disclosure**: 라인 제한 준수 (Root 150, Module 80, Submodule 50)

## 구조

```
documentation-generation/
├── agents/
│   └── document-builder.md    # 문서 생성 전문가 에이전트
├── skills/
│   └── document-templates/    # 재사용 가능한 템플릿 스킬
├── commands/                  # 슬래시 커맨드 (예정)
└── agent-docs/               # 상세 문서
    ├── detailed-guides.md    # 작성 가이드, 패턴
    ├── examples.md           # 실제 사용 예제
    └── references.md         # 참조, 설정, 트러블슈팅
```

## 컴포넌트

| 타입 | 이름 | 설명 |
|------|------|------|
| Agent | [document-builder](agents/document-builder.md) | 코드 분석 기반 문서 생성 전문가 |
| Skill | [document-templates](skills/document-templates/SKILL.md) | CLAUDE.md, README, API 문서 템플릿 |

## 핵심 기능

### document-builder Agent
- AST 파싱, 의존성 분석, 패턴 인식
- 계층적 문서 구조 자동 생성
- Mermaid 다이어그램 자동 생성
- 생성된 문서의 정확성 검증

### document-templates Skill
- 프로젝트 문서: CLAUDE.md, README.md, CONTRIBUTING.md
- API 문서: OpenAPI 3.0, Postman, SDK 템플릿
- 아키텍처 문서: 시스템, 데이터 모델, 배포 가이드

## 빠른 사용

```bash
# document-builder 호출 (키워드 자동 감지)
"이 프로젝트 CLAUDE.md 생성해줘"
"API 문서 업데이트해줘"
"아키텍처 다이어그램 만들어줘"
```

## 라인 제한 규칙

| 레벨 | 최대 라인 | 설명 |
|------|----------|------|
| Root | 150 | 프로젝트 전체 개요 |
| Module | 80 | 플러그인/모듈 개요 |
| Submodule | 50 | 세부 컴포넌트 |

초과 시 agent-docs/로 상세 내용 분리

## 상세 문서

- [상세 가이드](agent-docs/detailed-guides.md) - 커맨드/에이전트/스킬 작성법, 라우팅 시스템
- [예제 모음](agent-docs/examples.md) - 실제 사용 시나리오, 워크플로우
- [참고 자료](agent-docs/references.md) - 설정, 성능, 보안, 트러블슈팅

---

[parent](../../CLAUDE.md)
