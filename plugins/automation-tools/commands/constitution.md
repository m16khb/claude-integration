---
name: automation-tools:constitution
description: '프로젝트 헌법 (필수 규칙) 관리'
argument-hint: '<action> [rule-name]'
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
  - mcp__st__sequentialthinking
  - mcp__c7__resolve-library-id
  - mcp__c7__get-library-docs
  - mcp__mm__store_memory
  - mcp__mm__retrieve_memory
  - mcp__mm__search_by_tag
model: claude-opus-4-5-20251101
---

# Project Constitution Manager

## MISSION

프로젝트 헌법을 체계적으로 관리합니다.

**대상 파일:**
- `agent-docs/constitution.md` - 규칙 상세
- `CLAUDE.md` 헌법 테이블 - 요약

**Target**: $ARGUMENTS

---

## ACTIONS

| 액션 | 설명 |
|------|------|
| `list` | 규칙 목록 표시 |
| `add` | 새 규칙 추가 |
| `edit <name>` | 규칙 수정 |
| `remove <name>` | 규칙 삭제 |
| `check` | 무결성 검사 |
| `history` | 변경 이력 조회 |

---

## PHASE 0: Action Resolution

```
IF empty OR "help" → Show usage TUI
ELSE → Execute action
```

---

## PHASE 1: List Rules

```
READ agent-docs/constitution.md
EXTRACT "## 규칙 목록" table
OUTPUT:
┌───────────────────────────────┐
│ 📜 프로젝트 헌법               │
├───────────────────────────────┤
│ 1. {rule} (우선순위: {p})     │
│    └─ {description}          │
└───────────────────────────────┘
```

---

## PHASE 2: Add Rule

1. **규칙 정보 수집**: 규칙명, 설명, 우선순위(1-4)
2. **Context7 조회**: 베스트 프랙티스 참조
3. **검증**: 중복 검사
4. **적용**: constitution.md + CLAUDE.md 업데이트
5. **Memory 저장**: 변경 이력 기록

**우선순위 레벨:**
| 레벨 | 설명 |
|-----|------|
| 1 | 보안 규칙 |
| 2 | 버전/호환성 |
| 3 | 코드 품질 |
| 4 | 워크플로우 |

---

## PHASE 3-4: Edit/Remove

```
RESOLVE rule_name from arguments
DISPLAY current content
GATHER modifications / confirmation
VALIDATE & APPLY
STORE to Memory
```

---

## PHASE 5: Integrity Check

```
CHECKS:
├─ agent-docs/constitution.md 존재
├─ 규칙 목록-상세 동기화
├─ CLAUDE.md 요약 동기화
├─ 규칙 형식 일관성
└─ 앵커 링크 유효성
```

---

## PHASE 6: View History

```
mcp__mm__search_by_tag: ["constitution", "changelog"]

OUTPUT:
=== 헌법 변경 이력 ===
{date}: {change_description}
```

---

## RULE FORMAT

**constitution.md 규칙 형식:**
```markdown
## {번호}. {규칙명}

### 개요
규칙 설명 (1-2문장)

### 상세 규칙
| 항목 | 설명 |

### 체크리스트
- [ ] 체크 항목

### 예시
```

---

## USAGE

```bash
/automation-tools:constitution list
/automation-tools:constitution add
/automation-tools:constitution edit "플러그인 버전 관리"
/automation-tools:constitution check
/automation-tools:constitution history
```

---

## ERROR HANDLING

| Error | Response |
|-------|----------|
| 파일 없음 | 자동 생성 제안 |
| 중복 규칙명 | 기존 규칙 수정 제안 |
| 동기화 불일치 | 자동 수정 제안 |
