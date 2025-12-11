---
name: automation-tools:claude-sync
description: '코드베이스 변경 감지 및 CLAUDE.md 자동 동기화'
argument-hint: [task_instruction]
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Task
  - AskUserQuestion
  - mcp__st__sequentialthinking
  - mcp__c7__resolve-library-id
  - mcp__c7__get-library-docs
model: claude-opus-4-5-20251101
---

# CLAUDE.md Auto-Sync

## MISSION

프로젝트 계층적 문서화 시스템을 스캔, 분석, 동기화합니다.

**핵심 원칙:**
- 모듈마다 CLAUDE.md 작성
- LOC 초과 시 agent-docs로 분할
- 플러그인 CLAUDE.md는 상위에서 일반 링크로 참조
- agent-docs는 @ 참조 금지 (테이블/일반 링크 사용)
- 고아 파일 0개 보장

---

## ARCHITECTURE

```
Root CLAUDE.md
├── [plugins/*/CLAUDE.md](링크) (MODULE)
│   └── `agent-docs/*.md` (테이블로 참조, 동적 로딩)
└── `agent-docs/*.md` (테이블로 참조, 동적 로딩)

⚠️ CRITICAL (헌법 규칙 4):
- CLAUDE.md → agent-docs: @ 참조 금지 (자동 로드되어 토큰 낭비)
- 테이블 또는 일반 링크로 참조, 필요 시 Read 도구로 로드
```

---

## EXECUTION PHASES

### Phase 0: Component Registry Sync

```
SCAN:
├─ Glob("**/agents/*.md") → agent definitions
├─ Glob("**/skills/**/SKILL.md") → skill definitions
└─ Glob("**/commands/*.md") → command definitions

UPDATE: .claude-plugin/routing-table.json
├─ 새 컴포넌트 추가
├─ 삭제된 컴포넌트 제거
└─ last_synced 갱신
```

### Phase 1: Hierarchical Scan

```
COLLECT HIERARCHY:
├─ Root → has_claude_md, has_agent_docs, children
├─ Modules → plugins/*/CLAUDE.md
└─ Submodules → 중첩된 모듈
```

### Phase 2: Gap Analysis

```
LINE LIMITS (헌법 규칙):
├─ ROOT: Soft 300 / Hard 500
├─ MODULE: Soft 200 / Hard 350
└─ SUBMODULE: Soft 150 / Hard 250

CLASSIFY:
├─ CREATE_CLAUDE_MD: 누락
├─ NEEDS_AGENT_DOCS: Hard Limit 초과
├─ RECOMMEND_AGENT_DOCS: Soft Limit 초과
├─ UPDATE_LINKS: 참조 깨짐
└─ OK: 최신 상태
```

### Phase 3: Report & Confirm

TUI로 작업 계획 표시 후 사용자 확인:
- 전체 적용 (병렬 처리)
- 선택 적용 (작업별 확인)
- 미리보기
- 취소

### Phase 4: Parallel Execution

```
Task(subagent_type="document-builder"):
  Action: CREATE/UPDATE/REFACTOR
  Target Path: {path}
  Target Type: MODULE/SUBMODULE
```

### Phase 5: Orphan Detection & Fix

```
ORPHAN TYPES:
├─ CLAUDE.md → 상위에서 참조 안됨 → 일반 링크로 참조 추가
├─ agent-docs → CLAUDE.md에서 링크 안됨 → 테이블에 추가
└─ parent 링크 누락 → [parent](../CLAUDE.md) 추가

⚠️ agent-docs 참조 시 @ 사용 금지 (헌법 규칙 4)
```

### Phase 6: Validation

```
FINAL CHECK:
├─ 모든 링크 경로 유효 (일반 링크 + 테이블)
├─ 라인 수 제한 준수
├─ 고아 파일 0개
├─ 계층 무결성 유지
└─ agent-docs에 @ 참조 없음 (헌법 규칙 4)
```

---

## CLAUDE.md STRUCTURE TEMPLATE

```markdown
# {Module Name}

{1-2문장 개요}

## 핵심 기능
{간결한 기능 설명}

## 주요 구성요소
| 이름 | 역할 | 설명 |
|------|------|------|

## 빠른 시작
{필수 명령어만}

## 상세 문서 (필요 시 Read 도구로 로드)
| 문서 | 설명 |
|------|------|
| `agent-docs/{topic}.md` | {설명} |

## 하위 모듈 (있을 경우)
- [submodule](submodule/CLAUDE.md) - 설명

[parent](../CLAUDE.md)  ← parent 참조 (root 제외)
```

**⚠️ 동적 로딩 원칙:**
- agent-docs는 `코드 스팬` 또는 `[링크](경로)` 형태로 참조
- @ 참조 사용 금지 (토큰 낭비 방지)

---

## USAGE

```bash
# 전체 동기화
/automation-tools:claude-sync

# 특정 플러그인만
/automation-tools:claude-sync --target plugins/nestjs-backend

# routing-table만
/automation-tools:claude-sync --only routing-table

# 검증만 (변경 없음)
/automation-tools:claude-sync --dry-run
```

---

## ERROR HANDLING

| Error | Response |
|-------|----------|
| document-builder 실패 | 경고 후 스킵 |
| Parent CLAUDE.md 없음 | 부모 먼저 생성 |
| 순환 참조 감지 | 에러 리포트, 수동 수정 요청 |
| 병렬 작업 충돌 | 순차 재실행 |

---

## FOLLOW-UP TUI

동기화 완료 후 선택:
- 커밋 → /git-commit
- 문서 검토 → 생성된 파일 열기
- 재동기화 → 다시 실행
- 완료 → 종료
