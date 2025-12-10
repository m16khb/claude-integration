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

## Architecture

```
문서 생성 프로세스:
코드 분석 → AST 파싱 → 의존성 추출 → 문서 생성
```

## 컴포넌트

| 타입 | 이름 | 설명 |
|------|------|------|
| Agent | @agents/document-builder.md | 코드 분석 기반 문서 생성 전문가 |
| Skill | @skills/document-templates/SKILL.md | CLAUDE.md, README, API 문서 템플릿 |

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

- @agent-docs/template-library.md - 문서 템플릿 카탈로그, 재사용 패턴
- @agent-docs/code-analysis.md - AST 파싱, 의존성 분석, 자동 추출
- @agent-docs/progressive-disclosure.md - 계층적 구조, 라인 제한, 네비게이션

@../CLAUDE.md
