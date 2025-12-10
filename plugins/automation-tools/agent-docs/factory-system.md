# Factory System

> Agent, Skill, Command 자동 생성 시스템 상세 가이드

## Overview

Factory는 Claude Code 컴포넌트를 자동으로 생성하는 시스템입니다.

```
FACTORY ARCHITECTURE:
┌─────────────────────────────────────────────────┐
│                 /factory Command                 │
└───────────────────────┬─────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
  ┌───────────┐   ┌───────────┐   ┌───────────┐
  │ Researcher│   │ Generator │   │ Validator │
  │   Skill   │   │   Skill   │   │   Skill   │
  └─────┬─────┘   └─────┬─────┘   └─────┬─────┘
        │               │               │
        └───────────────┼───────────────┘
                        │
                        ▼
              ┌─────────────────┐
              │   Orchestrator  │
              │      Skill      │
              └─────────────────┘
```

---

## 지원 컴포넌트 타입

### Agents

```
AGENT TYPES:
├─ 일반 전문가 (Expert)
│   ├─ 역할: 특정 도메인 전문 지식 제공
│   ├─ 예시: typeorm-expert, redis-cache-expert
│   └─ 모델: claude-opus-4-5-20251101 (복잡한 분석)
│
├─ 오케스트레이터 (Orchestrator)
│   ├─ 역할: 여러 에이전트 작업 조율
│   ├─ 예시: nestjs-fastify-expert, full-stack-orchestrator
│   └─ 모델: claude-opus-4-5-20251101 (조율 능력 필요)
│
└─ 통합 전문가 (Integration Expert)
    ├─ 역할: MCP 서버 연동 에이전트
    ├─ 예시: playwright-expert, context7-expert
    └─ 모델: 상황에 따라 선택
```

### Skills

```
SKILL TYPES:
├─ 처리형 (Processing)
│   ├─ 역할: 특정 작업 수행
│   ├─ 예시: factory-generator, testing-patterns
│   └─ 특징: 입력 → 처리 → 출력
│
├─ 생성형 (Generation)
│   ├─ 역할: 콘텐츠 생성
│   ├─ 예시: document-templates, code-generator
│   └─ 특징: 템플릿 기반 생성
│
└─ 분석형 (Analysis)
    ├─ 역할: 데이터 분석 및 리포팅
    ├─ 예시: agent-routing, context-analyzer
    └─ 특징: 패턴 인식, 추천
```

### Commands

```
COMMAND TYPES:
├─ 유틸리티 (Utility)
│   ├─ 역할: 개발 보조 명령어
│   ├─ 예시: /review, /optimize
│   └─ 특징: 단일 작업 수행
│
├─ 워크플로우 (Workflow)
│   ├─ 역할: 복잡한 작업 자동화
│   ├─ 예시: /dev-flow, /claude-sync
│   └─ 특징: 다단계 파이프라인
│
└─ 상호작용 (Interactive)
    ├─ 역할: 사용자 인터페이스 명령어
    ├─ 예시: /setup-statusline, /partner
    └─ 특징: TUI, 선택지 제공
```

---

## Factory 생성 프로세스

### Step 1: 문서 분석 (Researcher)

```
DOCUMENT ANALYSIS:
├─ 입력 소스
│   ├─ URL: 공식 문서, API 레퍼런스
│   ├─ 파일: 로컬 문서, 코드 샘플
│   └─ 텍스트: 직접 입력 설명
│
├─ 분석 내용
│   ├─ API 레퍼런스 파싱
│   ├─ 코드 예시 추출
│   ├─ 사용 패턴 분석
│   └─ Best Practices 식별
│
└─ 출력
    ├─ 기술 요약
    ├─ 핵심 기능 목록
    └─ 권장 구현 방식
```

### Step 2: 컴포넌트 설계 (Orchestrator)

```
COMPONENT DESIGN:
├─ 타입 결정
│   ├─ 요구사항 분석
│   ├─ 복잡도 평가
│   └─ 적합한 타입 선택
│
├─ 도구 식별
│   ├─ 필수 도구 (Read, Write, Glob)
│   ├─ 선택 도구 (Bash, WebFetch)
│   └─ MCP 도구 (context7, sequential-thinking)
│
└─ 인터페이스 정의
    ├─ 입력 파라미터
    ├─ 출력 형식
    └─ 에러 처리
```

### Step 3: 코드 생성 (Generator)

```
CODE GENERATION:
├─ 구조 생성
│   ├─ Frontmatter (name, description, model)
│   ├─ 섹션 구조 (## 헤딩)
│   └─ 코드 블록
│
├─ Best Practices 적용
│   ├─ 일관된 스타일
│   ├─ 명확한 지시사항
│   └─ 재사용 가능한 패턴
│
└─ 테스트 케이스
    ├─ 기본 사용 시나리오
    ├─ 엣지 케이스
    └─ 에러 케이스
```

### Step 4: 검증 및 설치 (Validator)

```
VALIDATION:
├─ 문법 검증
│   ├─ Markdown 구문
│   ├─ YAML frontmatter
│   └─ 코드 블록 유효성
│
├─ 기능 테스트
│   ├─ 기본 동작 확인
│   ├─ 도구 호출 테스트
│   └─ 출력 형식 검증
│
└─ 프로젝트 통합
    ├─ 파일 생성
    ├─ routing-table.json 업데이트
    └─ CLAUDE.md 링크 추가
```

---

## 사용법

### 기본 사용

```bash
# 에이전트 생성
/automation-tools:factory agent "React 컴포넌트 전문가"

# 스킬 생성
/automation-tools:factory skill react-component-generator

# 커맨드 생성
/automation-tools:factory command microservice-init
```

### 문서 기반 생성

```bash
# URL에서 문서 분석 후 생성
/automation-tools:factory agent https://docs.nestjs.com/controllers

# 복합 전문가 생성
/automation-tools:factory agent "PostgreSQL + Redis 전문가"
```

### 고급 옵션

```bash
# 특정 모델 지정
/automation-tools:factory agent "분석 전문가" --model opus

# 특정 플러그인에 생성
/automation-tools:factory skill cache-strategy --plugin nestjs-backend

# 템플릿 지정
/automation-tools:factory command db-migrate --template workflow
```

---

## Template System

### 템플릿 카테고리

```
TEMPLATE CATEGORIES:
├─ 언어별
│   ├─ TypeScript: 타입 안전성 강조
│   ├─ Python: FastAPI, Django 패턴
│   ├─ Go: 간결하고 효율적인 패턴
│   └─ Rust: 안전성 우선 패턴
│
├─ 프레임워크별
│   ├─ NestJS: 데코레이터, DI 패턴
│   ├─ Next.js: App Router, Server Components
│   ├─ FastAPI: 비동기, Pydantic 패턴
│   └─ Express: 미들웨어 패턴
│
├─ 아키텍처별
│   ├─ 마이크로서비스: 서비스 분리, 통신
│   ├─ 모놀리스: 모듈화, 레이어
│   └─ Serverless: 함수 단위 설계
│
└─ 도메인별
    ├─ E-commerce: 결제, 재고, 주문
    ├─ FinTech: 보안, 규제 준수
    └─ 헬스케어: 개인정보, HIPAA
```

### 커스텀 템플릿

```yaml
# .claude/templates/custom-agent.yml
template:
  name: "custom-agent"
  type: "agent"

  structure:
    frontmatter:
      model: "claude-opus-4-5-20251101"
      allowed-tools:
        - Read
        - Write
        - Glob
        - Bash

    sections:
      - name: "## PURPOSE"
        required: true
      - name: "## CAPABILITIES"
        required: true
      - name: "## WORKFLOW"
        required: true
      - name: "## EXAMPLES"
        required: false

  validation:
    min_lines: 50
    max_lines: 500
    required_keywords:
      - "PURPOSE"
      - "CAPABILITIES"
```

---

## 생성 결과물

### Agent 결과물 구조

```
plugins/my-expert/
├─ CLAUDE.md           # 플러그인 메타데이터
├─ agents/
│   └─ my-expert.md    # 에이전트 정의
├─ skills/
│   └─ routing.md      # 라우팅 스킬
├─ commands/
│   └─ init.md         # 초기화 커맨드
└─ agent-docs/
    └─ guide.md        # 상세 가이드
```

### Skill 결과물 구조

```
plugins/my-plugin/skills/
├─ my-skill/
│   ├─ SKILL.md        # 스킬 정의
│   ├─ patterns/       # 패턴 예시
│   └─ resources/      # 추가 리소스
```

### Command 결과물 구조

```
plugins/my-plugin/commands/
├─ my-command.md       # 커맨드 정의
└─ templates/          # 커맨드 템플릿
```

---

@../CLAUDE.md | @sync-orchestration.md | @optimization-guide.md
