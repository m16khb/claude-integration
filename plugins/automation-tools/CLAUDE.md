---
name: automation-tools
description: '자동화 도구 모음 - 컴포넌트 생성기, 상태 라인 설정, 동기화 도구'
category: productivity
---

# automation-tools Plugin

개발 생산성을 극대화하는 자동화 도구 모음입니다.

## Core Philosophy

```
자동화 원칙:
├─ 반복 작업 제거: 개발자가 집중해야 할 작업에만 집중
├─ 템플릿 기반 생성: 일관된 구조와 품질 보장
├─ 지능적 동기화: 변경 감지 -> 자동 갱신 -> 검증
└─ 확장 가능성: 새로운 컴포넌트 타입 지원
```

## 파일 구조

```
automation-tools/
├─ commands/          # 6개 커맨드
├─ skills/            # 5개 스킬
└─ agent-docs/        # 상세 문서
```

## Commands (6개)

| 커맨드 | 설명 |
|-------|------|
| `/automation-tools:factory` | Agent/Skill/Command 자동 생성 |
| `/automation-tools:prompt-optimizer` | TUI 기반 프롬프트 최적화 |
| `/automation-tools:setup-statusline` | YAML 기반 상태 라인 구성 |
| `/automation-tools:claude-sync` | CLAUDE.md 자동 동기화 |
| `/automation-tools:optimize` | 최적화 실행 |
| `/automation-tools:partner` | AI 파트너 관리 |

## Skills (5개)

| 스킬 | 설명 |
|-----|------|
| factory-generator | 컴포넌트 코드 생성 |
| factory-orchestrator | 생성 워크플로우 조율 |
| factory-researcher | 문서 분석 및 리서치 |
| factory-validator | 생성물 검증 |
| ai-partner | AI 파트너 관리 |

## Quick Start

```bash
# 에이전트 생성
/automation-tools:factory agent "React 전문가"

# 프롬프트 최적화
/automation-tools:prompt-optimizer "코드 리뷰해줘"

# 상태 라인 설정
/automation-tools:setup-statusline --template fullstack

# 문서 동기화
/automation-tools:claude-sync --watch
```

## 상세 문서

- [factory-system.md](agent-docs/factory-system.md) - Agent/Skill/Command 자동 생성 시스템
- [sync-orchestration.md](agent-docs/sync-orchestration.md) - CLAUDE.md 동기화 및 routing-table 관리
- [optimization-guide.md](agent-docs/optimization-guide.md) - 프롬프트/에이전트/커맨드 최적화
- [statusline-config.md](agent-docs/statusline-config.md) - Status Line 설정 및 커스터마이징

[parent](../CLAUDE.md)
