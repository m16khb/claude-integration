---
name: documentation-generation
description: '문서 생성 자동화 - CLAUDE.md, 에이전트 문서, 템플릿'
category: documentation
---

# documentation-generation Plugin

코드베이스 분석 기반 지능적 문서 생성 시스템. 개발자가 문서 작성이 아닌 개발에 집중할 수 있도록 지원합니다.

## Core Philosophy

```
DOCUMENTATION GENERATION PIPELINE:
┌─────────────────────────────────────────────────────────┐
│  Source Code → AST Parsing → Semantic Analysis →       │
│  Template Selection → Document Generation → Validation  │
└─────────────────────────────────────────────────────────┘
```

- **코드 분석 기반**: 실제 코드 구조를 반영한 문서
- **자동 동기화**: 코드 변경 시 문서 자동 업데이트
- **계층적 구조**: Root > Module > agent-docs/ 3단계 구성
- **Progressive Disclosure**: 라인 제한 준수로 토큰 효율성 극대화

## Progressive Disclosure Hierarchy

```
LEVEL 1: Root CLAUDE.md (300 Soft / 500 Hard)
├─ 프로젝트 전체 개요
├─ 핵심 기능
└─ Links to Level 2 →
         │
         ▼
LEVEL 2: Module CLAUDE.md (200 Soft / 350 Hard)
├─ 플러그인/모듈 개요
├─ 주요 기능
└─ Links to Level 3 →
         │
         ▼
LEVEL 3: agent-docs/ (Unlimited)
├─ template-library.md
├─ code-analysis.md
└─ progressive-disclosure.md
```

## Components

| 타입 | 이름 | 설명 |
|------|------|------|
| Agent | `agents/document-builder.md` | 코드 분석 기반 문서 생성 전문가 |
| Skill | `skills/document-templates/SKILL.md` | CLAUDE.md, README, API 문서 템플릿 |

## document-builder Agent

코드베이스를 분석하여 지능적으로 문서를 생성합니다:

| 기능 | 설명 |
|------|------|
| AST 파싱 | TypeScript, Python, Go 코드 구조 분석 |
| 의존성 분석 | Import 그래프, 순환 의존성 감지 |
| 패턴 인식 | 클래스, 함수, 데코레이터 추출 |
| 다이어그램 생성 | Mermaid 클래스/시퀀스 다이어그램 자동 생성 |
| 문서 검증 | 라인 제한, 링크 유효성 검사 |

### 트리거 키워드

```
Primary: "CLAUDE.md", "documentation", "문서", "readme"
Secondary: "api docs", "아키텍처 다이어그램", "changelog"
```

## document-templates Skill

재사용 가능한 문서 템플릿 카탈로그:

```
TEMPLATE CATEGORIES:
├─ Project → CLAUDE.md, README.md, CONTRIBUTING.md, CHANGELOG.md
├─ API → OpenAPI 3.0, Postman Collection, GraphQL Schema
├─ Architecture → System Design, Data Model, ADR
└─ Technical → Tutorial, How-to Guide, FAQ
```

## Line Limits (헌법 규칙)

| 레벨 | Soft Limit | Hard Limit | 설명 |
|------|-----------|------------|------|
| Root | 300 | 500 | 프로젝트 전체 개요 |
| Module | 200 | 350 | 플러그인/모듈 개요 |
| Submodule | 150 | 250 | 세부 컴포넌트 |

**Soft Limit 초과**: 경고 표시, agent-docs 분할 권장
**Hard Limit 초과**: 강제 분할 필수

## Usage

```bash
# CLAUDE.md 생성
"이 프로젝트 CLAUDE.md 생성해줘"

# API 문서 업데이트
"API 문서 업데이트해줘"

# 다이어그램 생성
"아키텍처 다이어그램 만들어줘"

# 라인 수 검증
"CLAUDE.md 라인 수 체크해줘"
```

## Code Analysis Examples

### TypeScript AST 분석

```typescript
// 입력
@Controller('users')
export class UserController {
  @Get() getUsers(): Promise<User[]> {}
}

// 출력 문서
### GET /users
**Controller**: UserController
**Response**: Promise<User[]>
```

### 다이어그램 자동 생성

```
// 입력: 클래스 코드
class UserService → UserRepository → Database

// 출력: Mermaid
classDiagram
  UserService --> UserRepository
  UserRepository --> Database
```

## Information Compression Techniques

```
압축 기법:
├─ 테이블 활용 → 리스트보다 50% 공간 절약
├─ ASCII 다이어그램 → Mermaid보다 간결
├─ 링크 그룹화 → 개별 링크보다 효율적
└─ 코드 블록 최소화 → 주석 인라인
```

## Structure

```
plugins/documentation-generation/
├─ CLAUDE.md                      # 본 문서
├─ agents/
│   └─ document-builder.md        # 문서 생성 전문가
├─ skills/
│   └─ document-templates/        # 템플릿 스킬
└─ agent-docs/                    # 상세 문서
    ├─ template-library.md        # 템플릿 카탈로그
    ├─ code-analysis.md           # AST 파싱 가이드
    └─ progressive-disclosure.md  # 계층 구조 가이드
```

## Best Practices

```
DO ✅:
├─ 계층 구조 준수 (Root → Module → agent-docs)
├─ 소스코드 참조 시 @ 문법 사용
├─ agent-docs 참조 시 테이블/코드 스팬 사용
├─ 테이블과 압축 기법 활용
└─ 라인 제한 내 필수 내용 우선

DON'T ❌:
├─ CLAUDE.md에서 agent-docs @ 참조 (토큰 낭비)
├─ Hard Limit 초과
├─ 중복 정보 (Root와 Module에 동일 내용)
├─ 깨진 링크
└─ 절대 경로 사용
```

## Documentation (필요 시 Read 도구로 로드)

| 문서 | 설명 |
|------|------|
| `agent-docs/template-library.md` | 문서 템플릿 카탈로그, 변수 시스템, Mermaid 패턴 |
| `agent-docs/code-analysis.md` | AST 파싱 상세, 의존성 분석, 자동 추출 알고리즘 |
| `agent-docs/progressive-disclosure.md` | 계층 구조 상세, 라인 제한, 네비게이션 패턴 |

[parent](../CLAUDE.md)
