# CLAUDE.md

## 프로젝트 개요

**claude-integration**은 Claude Code 생산성 향상을 위한 스마트 커맨드 및 에이전트 마켓플레이스입니다.

## 핵심 가치

> "최소 기능별로 잘 나누어서 저장하고 사용 할 때는 반드시 필요한 도구를 잘 호출해서 사용하자"

- **정확한 호출**: 사용자 의도에 맞는 전문가 에이전트 자동 선택
- **정확한 동작**: 각 에이전트가 자신의 전문 영역에서 완벽한 결과물 생성
- **정확한 의도 파악**: 키워드 기반 라우팅으로 적절한 도구 활성화

## 필수 규칙 (헌법)

> **⚠️ CRITICAL**: 아래 규칙은 Claude가 **반드시** 준수해야 하는 최우선 규칙입니다. 모든 작업 수행 전 헌법 준수 여부를 확인하세요.

| 규칙 | 설명 |
|------|------|
| **플러그인 버전 관리** | Semantic Versioning (MAJOR.MINOR.PATCH) 준수 |
| **파일 레퍼런싱 @ 문법** | 모든 파일 참조 시 `@경로` 형식 필수 |

> 상세 내용: @docs/constitution.md

## 아키텍처

이 마켓플레이스는 **단일 책임 원칙**을 따릅니다:

- **7개 전문화된 플러그인**
- **11개 전문 에이전트** (2개 오케스트레이터 + 9개 전문가)
- **11개 슬래시 커맨드**
- **9개 에이전트 스킬** (라우팅 시스템 포함)

## 기술 스택

- **언어**: Markdown (커맨드/스킬/에이전트 정의)
- **플랫폼**: Claude Code CLI
- **스키마**: Anthropic 2025 Skills/Commands/Agents Schema
- **패턴**: Orchestrator-Worker, Progressive Disclosure, Agent Routing
- **테스트**: Suites 3.x (구 Automock)

## 프로젝트 구조

```
claude-integration/
├── .claude-plugin/          # 플러그인 레지스트리
├── plugins/                  # 7개 전문화된 플러그인
│   └── documentation-generation/
│       └── agent-docs/      # 상세 문서
├── docs/                    # 종합 문서
└── CLAUDE.md               # 본문 (150라인 제한)
```

## 플러그인 목록

| 플러그인 | 카테고리 | 주요 기능 |
|---------|---------|----------|
| @plugins/nestjs-backend/CLAUDE.md | development | NestJS 생태계 전문가 7명 |
| @plugins/code-quality/CLAUDE.md | quality | 코드 리뷰, 테스트 자동화 |
| @plugins/full-stack-orchestration/CLAUDE.md | workflows | 개발 워크플로우 오케스트레이션 |
| @plugins/documentation-generation/CLAUDE.md | documentation | 계층적 문서 자동 생성 |
| @plugins/git-workflows/CLAUDE.md | development | Git Flow 기반 스마트 커밋 |
| @plugins/context-management/CLAUDE.md | productivity | 컨텍스트 분석, 대용량 처리 |
| @plugins/automation-tools/CLAUDE.md | productivity | 컴포넌트 자동 생성, 동기화 |

## 주요 커맨드

| 커맨드 | 플러그인 | 설명 |
|--------|---------|------|
| `/full-stack-orchestration:dev-flow` | full-stack-orchestration | 리뷰 → 테스트 → 커밋 워크플로우 |
| `/code-quality:review` | code-quality | 코드 리뷰 실행 |
| `/git-workflows:git-commit` | git-workflows | Git Flow 기반 스마트 커밋 |
| `/context-management:continue-context` | context-management | 컨텍스트 분석 및 작업 추천 |
| `/context-management:inject-context` | context-management | 대용량 파일 구조 인식 청킹 |
| `/automation-tools:factory` | automation-tools | Agent, Skill, Command 생성기 |
| `/automation-tools:optimize` | automation-tools | 에이전트/커맨드/프롬프트 최적화 |
| `/automation-tools:partner` | automation-tools | AI 파트너 관리 |
| `/automation-tools:setup-statusline` | automation-tools | YAML 기반 status line 구성 |
| `/automation-tools:claude-sync` | automation-tools | CLAUDE.md 자동 동기화 |
| `/automation-tools:constitution` | automation-tools | 프로젝트 헌법 관리 |

## 에이전트 계층

- **full-stack-orchestrator**: 최상위 워크플로우 조율
- **nestjs-fastify-expert**: 백엔드 7명 전문가 조율
- **Experts**: typeorm, redis, bullmq, cqrs, microservices, testing
- **Quality**: code-reviewer, test-automator
- **Docs**: document-builder

## Agent Routing System

자동 키워드 분석으로 전문가 선택:
- "Redis 캐시" → redis-cache-expert
- "엔티티 + 테스트" → typeorm → suites-testing (SEQUENTIAL)
- "캐시 + 큐" → [redis, bullmq] (PARALLEL)

routing-table.json에서 키워드 점수 관리 (primary 3점)

## 설치

```bash
/plugin marketplace add m16khb/claude-integration
/plugin install claude-integration
```

## MCP 서버 (별도 설치 필요)

이 프로젝트는 다음 MCP 서버들과 연동됩니다. 각 사용자가 직접 설치해야 합니다:

| MCP 서버 | 설명 | 설치 명령어 |
|----------|------|-----------|
| `playwright` | 브라우저 자동화 | `npx -y @playwright/mcp@latest` |
| `context7` | 최신 문서 주입 | `npx -y @upstash/context7-mcp@latest` |
| `sequential-thinking` | 단계별 사고 | `npx -y @modelcontextprotocol/server-sequential-thinking` |
| `chrome-devtools` | 크롬 개발자 도구 | `npx -y chrome-devtools-mcp@latest` |

## 상세 문서

### 문서화 가이드
- @plugins/documentation-generation/agent-docs/template-library.md - 문서 템플릿 카탈로그
- @plugins/documentation-generation/agent-docs/code-analysis.md - 코드 분석 및 AST 파싱
- @plugins/documentation-generation/agent-docs/progressive-disclosure.md - 계층적 문서 구조

### 공식 문서
- @docs/architecture.md - 아키텍처 설계 원칙
- @docs/guides/usage.md - 사용 가이드
- @docs/references/agents.md - 에이전트 레퍼런스
- @docs/references/plugins.md - 플러그인 레퍼런스
- @docs/references/agent-skills.md - 에이전트 스킬 레퍼런스

## 빠른 시작

```bash
/code-quality:review          # 코드 리뷰
/full-stack-orchestration:dev-flow        # 전체 워크플로우
/git-workflows:git-commit push # 커밋

"Redis 캐시 설정" # 자동 에이전트 선택
/context-management:inject-context file.ts # 대용량 파일
/automation-tools:claude-sync     # 동기화
```