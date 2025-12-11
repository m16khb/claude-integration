---
name: automation-tools
description: '자동화 도구 모음 - 컴포넌트 생성기, 상태 라인 설정, 동기화 도구'
category: productivity
---

# automation-tools Plugin

개발 생산성을 극대화하는 자동화 도구 모음입니다.

## Core Philosophy

```
AUTOMATION ARCHITECTURE:
┌─────────────────────────────────────────────────────────┐
│  Factory → Optimize → Sync → Partner → Constitution    │
│     │          │        │        │           │         │
│     └──────────┴────────┴────────┴───────────┘         │
│              Skills Layer + Status Line                 │
└─────────────────────────────────────────────────────────┘
```

- **반복 작업 제거**: 개발자가 집중해야 할 작업에만 집중
- **템플릿 기반 생성**: 일관된 구조와 품질 보장
- **지능적 동기화**: 변경 감지 → 자동 갱신 → 검증

## Commands (6개)

| 커맨드 | 설명 |
|-------|------|
| `/automation-tools:factory` | Agent, Skill, Command 자동 생성 |
| `/automation-tools:optimize` | 프롬프트, 에이전트, 커맨드 최적화 |
| `/automation-tools:partner` | AI 파트너 관리 (선택, 상태, 피드백) |
| `/automation-tools:setup-statusline` | YAML 기반 Status Line 설정 |
| `/automation-tools:claude-sync` | CLAUDE.md, routing-table 동기화 |
| `/automation-tools:constitution` | 프로젝트 헌법(필수 규칙) 관리 |

## Quick Start

```bash
# 에이전트 생성 (URL에서 문서 분석)
/automation-tools:factory agent https://docs.nestjs.com/controllers

# 통합 최적화
/automation-tools:optimize agent agents/code-reviewer.md --mcp

# 문서 동기화
/automation-tools:claude-sync --watch

# 헌법 관리
/automation-tools:constitution list
```

## /factory - 컴포넌트 생성기

WebFetch로 공식 문서 분석 후 Best Practices 적용:

```
Request → Research → Design → Generate → Validate → Install
```

## /claude-sync - 동기화 시스템

```
SYNC WORKFLOW:
1. Component Registry Sync → routing-table.json 갱신
2. Hierarchical Document Sync → Root → Module → agent-docs
3. Gap Analysis → 누락 문서, 라인 수 검사, 링크 유효성
4. Auto Fix → 깨진 링크 수정, 참조 업데이트
```

## Skills (5개)

| 스킬 | 역할 |
|-----|------|
| factory-orchestrator | 생성 워크플로우 조율 |
| factory-researcher | 문서 분석 (WebFetch, Context7) |
| factory-generator | 컴포넌트 코드 생성 |
| factory-validator | 생성물 검증 |
| ai-partner | AI 파트너 관리 |

## Structure

```
plugins/automation-tools/
├─ CLAUDE.md
├─ commands/          # 6개 커맨드
├─ skills/            # 5개 스킬
└─ agent-docs/        # 상세 문서
```

## Best Practices

```
DO ✅:
├─ /factory로 컴포넌트 생성 (일관된 구조)
├─ /claude-sync로 문서 최신 상태 유지
└─ /constitution으로 필수 규칙 관리

DON'T ❌:
├─ 수동으로 routing-table.json 편집
└─ 검증 없이 에이전트 배포
```

## Documentation (필요 시 Read 도구로 로드)

| 문서 | 설명 |
|------|------|
| `agent-docs/factory-system.md` | Agent/Skill/Command 자동 생성, 템플릿 시스템 |
| `agent-docs/sync-orchestration.md` | CLAUDE.md 동기화, routing-table 관리 |
| `agent-docs/optimization-guide.md` | 프롬프트/에이전트/커맨드 최적화 원칙 |
| `agent-docs/statusline-config.md` | Status Line 설정, 커스텀 템플릿 |

[parent](../CLAUDE.md)
