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
└── skills/      → 선택적 모듈식 지식 패키지
```

설계 원칙: **단일 책임 원칙** 준수, 평균 플러그인 크기 3-4개 컴포넌트

## 전체 플러그인 목록 (5개)

### 1. backend-development

**NestJS + Fastify 백엔드 개발을 위한 전문 에이전트 및 도구**

| 항목 | 내용 |
|------|------|
| 카테고리 | development |
| 버전 | 1.0.0 |
| 키워드 | nestjs, fastify, typeorm, redis, bullmq, cqrs, microservices |

**컴포넌트 구성:**
- 에이전트 7개: nestjs-fastify-expert, typeorm-expert, redis-cache-expert, bullmq-queue-expert, cqrs-expert, microservices-expert, suites-testing-expert
- 커맨드 0개
- 스킬 0개

**설치:**
```bash
/plugin install backend-development
```

---

### 2. documentation-generation

**계층적 CLAUDE.md 및 agent-docs 문서 생성 에이전트**

| 항목 | 내용 |
|------|------|
| 카테고리 | documentation |
| 버전 | 1.0.0 |
| 키워드 | claude.md, agent-docs, documentation, markdown |

**컴포넌트 구성:**
- 에이전트 1개: document-builder
- 커맨드 0개
- 스킬 1개: document-builder-templates

**설치:**
```bash
/plugin install documentation-generation
```

---

### 3. git-workflows

**Git Flow 기반 스마트 커밋 및 브랜치 관리**

| 항목 | 내용 |
|------|------|
| 카테고리 | development |
| 버전 | 1.0.0 |
| 키워드 | git, commit, conventional-commits, git-flow |

**컴포넌트 구성:**
- 에이전트 0개
- 커맨드 1개: git-commit
- 스킬 0개

**설치:**
```bash
/plugin install git-workflows
```

---

### 4. context-management

**대용량 파일 청킹, 컨텍스트 주입 및 작업 추천 도구**

| 항목 | 내용 |
|------|------|
| 카테고리 | productivity |
| 버전 | 1.0.0 |
| 키워드 | context, chunking, injection, recommendation |

**컴포넌트 구성:**
- 에이전트 0개
- 커맨드 2개: continue-context, inject-context
- 스킬 0개

**설치:**
```bash
/plugin install context-management
```

---

### 5. automation-tools

**Agent, Skill, Command 자동 생성 및 설정 도구**

| 항목 | 내용 |
|------|------|
| 카테고리 | productivity |
| 버전 | 1.0.0 |
| 키워드 | factory, generator, automation, statusline, sync |

**컴포넌트 구성:**
- 에이전트 0개
- 커맨드 3개: factory, setup-statusline, claude-sync
- 스킬 0개

**설치:**
```bash
/plugin install automation-tools
```

---

## 카테고리별 분류

| 카테고리 | 플러그인 수 | 플러그인 목록 |
|---------|-----------|-------------|
| **development** | 2개 | backend-development, git-workflows |
| **documentation** | 1개 | documentation-generation |
| **productivity** | 2개 | context-management, automation-tools |

## 플러그인 통계

| 항목 | 수량 |
|------|------|
| 전체 플러그인 | 5개 |
| 전체 에이전트 | 8개 |
| 전체 커맨드 | 6개 |
| 전체 스킬 | 1개 |

## 플러그인 조합 예시

### 풀스택 NestJS 개발

```bash
/plugin install backend-development
/plugin install git-workflows
/plugin install context-management
```

### 문서 자동화 워크플로우

```bash
/plugin install documentation-generation
/plugin install automation-tools
```

### 최소 생산성 셋업

```bash
/plugin install git-workflows
/plugin install context-management
```

## 플러그인 개발 가이드

새 플러그인을 추가하려면:

1. `plugins/` 디렉토리에 플러그인 폴더 생성
2. `agents/`, `commands/`, `skills/` 하위 디렉토리 구성
3. `marketplace.json`에 플러그인 메타데이터 추가

```json
{
  "name": "my-plugin",
  "description": "플러그인 설명",
  "version": "1.0.0",
  "author": {
    "name": "작성자",
    "url": "https://github.com/username"
  },
  "source": "./plugins/my-plugin",
  "category": "development",
  "keywords": ["keyword1", "keyword2"],
  "agents": [],
  "commands": [],
  "skills": [],
  "strict": false
}
```
