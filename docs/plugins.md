# Plugin Reference

## 플러그인 등록 방식

설치 프로세스는 **2단계 구조**로 구성됩니다:

1. **마켓플레이스 추가**: `m16khb/claude-integration` 마켓플레이스를 등록
2. **선택적 설치**: 필요한 플러그인만 설치하여 토큰 효율성 극대화

각 설치된 플러그인은 **오직 자신의 에이전트, 커맨드, 스킬만 컨텍스트에 로드**합니다.

## 플러그인 구조 가이드라인

표준 구조는 세 가지 계층을 포함합니다:

```
plugin-name/
├── agents/      → 도메인별 전문 에이전트
├── commands/    → 해당 플러그인 특화 커맨드
├── skills/      → 선택적 모듈식 지식 패키지
└── agent-docs/  → 상세 문서
```

설계 원칙: **단일 책임 원칙** 준수

## 전체 플러그인 목록 (7개)

### 1. nestjs-backend

**NestJS + Fastify 백엔드 개발을 위한 전문 에이전트 및 도구**

| 항목 | 내용 |
|------|------|
| 카테고리 | development |
| 키워드 | nestjs, fastify, typeorm, redis, bullmq, cqrs, microservices |

**컴포넌트 구성:**
- 에이전트 7개: nestjs-fastify-expert, typeorm-expert, redis-cache-expert, bullmq-queue-expert, cqrs-expert, microservices-expert, suites-testing-expert
- 커맨드 0개
- 스킬 1개: agent-routing

---

### 2. code-quality

**코드 품질 관리 - 리뷰, 테스트 자동화**

| 항목 | 내용 |
|------|------|
| 카테고리 | quality |
| 키워드 | review, security, testing, coverage |

**컴포넌트 구성:**
- 에이전트 2개: code-reviewer, test-automator
- 커맨드 1개: review
- 스킬 1개: testing-patterns

---

### 3. full-stack-orchestration

**워크플로우 오케스트레이션 - 리뷰, 테스트, 커밋 파이프라인**

| 항목 | 내용 |
|------|------|
| 카테고리 | workflows |
| 키워드 | dev-flow, pipeline, workflow, ci-cd |

**컴포넌트 구성:**
- 에이전트 1개: full-stack-orchestrator
- 커맨드 1개: dev-flow
- 스킬 1개: ci-cd-patterns

---

### 4. documentation-generation

**계층적 CLAUDE.md 및 agent-docs 문서 생성**

| 항목 | 내용 |
|------|------|
| 카테고리 | documentation |
| 키워드 | claude.md, agent-docs, documentation, markdown |

**컴포넌트 구성:**
- 에이전트 1개: document-builder
- 커맨드 0개
- 스킬 1개: document-templates

---

### 5. git-workflows

**Git Flow 기반 스마트 커밋 및 브랜치 관리**

| 항목 | 내용 |
|------|------|
| 카테고리 | development |
| 키워드 | git, commit, conventional-commits, git-flow |

**컴포넌트 구성:**
- 에이전트 0개
- 커맨드 1개: git-commit
- 스킬 0개

---

### 6. context-management

**대용량 파일 청킹, 컨텍스트 주입 및 작업 추천**

| 항목 | 내용 |
|------|------|
| 카테고리 | productivity |
| 키워드 | context, chunking, injection, recommendation |

**컴포넌트 구성:**
- 에이전트 0개
- 커맨드 2개: continue-context, inject-context
- 스킬 0개

---

### 7. automation-tools

**Agent, Skill, Command 자동 생성 및 설정 도구**

| 항목 | 내용 |
|------|------|
| 카테고리 | productivity |
| 키워드 | factory, generator, automation, statusline, sync |

**컴포넌트 구성:**
- 에이전트 0개
- 커맨드 5개: factory, optimize, partner, setup-statusline, claude-sync
- 스킬 5개: factory-generator, factory-orchestrator, factory-researcher, factory-validator, ai-partner

---

## 카테고리별 분류

| 카테고리 | 플러그인 수 | 플러그인 목록 |
|---------|-----------|-------------|
| **development** | 2개 | nestjs-backend, git-workflows |
| **quality** | 1개 | code-quality |
| **workflows** | 1개 | full-stack-orchestration |
| **documentation** | 1개 | documentation-generation |
| **productivity** | 2개 | context-management, automation-tools |

## 플러그인 통계

| 항목 | 수량 |
|------|------|
| 전체 플러그인 | 7개 |
| 전체 에이전트 | 11개 |
| 전체 커맨드 | 10개 |
| 전체 스킬 | 9개 |

## 플러그인 조합 예시

### 풀스택 NestJS 개발

```bash
/plugin install nestjs-backend
/plugin install code-quality
/plugin install git-workflows
/plugin install context-management
```

### 문서 자동화 워크플로우

```bash
/plugin install documentation-generation
/plugin install automation-tools
```

### 전체 워크플로우 셋업

```bash
/plugin install full-stack-orchestration
/plugin install code-quality
/plugin install git-workflows
```

## 플러그인 개발 가이드

새 플러그인을 추가하려면:

1. `plugins/` 디렉토리에 플러그인 폴더 생성
2. `agents/`, `commands/`, `skills/`, `agent-docs/` 하위 디렉토리 구성
3. `CLAUDE.md` 작성 (parent 링크 필수)
4. `.claude-plugin/plugin.json` 생성
5. Root `CLAUDE.md`에 플러그인 참조 추가
