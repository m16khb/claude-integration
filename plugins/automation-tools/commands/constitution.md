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
  # MCP: Sequential Thinking (체계적 분석)
  - mcp__st__sequentialthinking
  # MCP: Context7 (베스트 프랙티스 조회)
  - mcp__c7__resolve-library-id
  - mcp__c7__get-library-docs
  # MCP: Memory (헌법 이력 관리)
  - mcp__mm__store_memory
  - mcp__mm__retrieve_memory
  - mcp__mm__recall_memory
  - mcp__mm__search_by_tag
  - mcp__mm__update_memory_metadata
  - mcp__mm__check_database_health
model: claude-opus-4-5-20251101
---

# Project Constitution Manager

## MISSION

프로젝트 헌법을 `docs/constitution.md`에서 체계적으로 관리합니다.
헌법은 Claude가 **반드시** 따라야 하는 최우선 규칙입니다.

**대상 파일**:
- **상세 관리**: `docs/constitution.md` (규칙 상세, 체크리스트, 예시)
- **요약 참조**: `CLAUDE.md` 헌법 테이블 (규칙명 + 한줄 설명)

**Target**: $ARGUMENTS

---

## MCP INTEGRATION

```
CONSTITUTION WORKFLOW:
├─ Sequential-Thinking MCP (체계적 분석)
│   ├─ 기존 헌법 구조 파악
│   ├─ 새 규칙의 영향도 분석
│   ├─ 충돌/중복 검사
│   └─ 최적 배치 위치 결정
│
├─ Context7 MCP (베스트 프랙티스)
│   ├─ CLAUDE.md 작성 가이드라인 조회
│   ├─ 프로젝트 규칙 패턴 참조
│   └─ 최신 권장사항 반영
│
└─ Memory MCP (이력 관리)
    ├─ 헌법 변경 이력 저장
    ├─ 이전 버전 조회
    └─ 변경 사유 기록
```

---

## PHASE 0: Action Resolution

```
PARSE $ARGUMENTS:

IF $ARGUMENTS is empty OR "help":
  → Show usage TUI

SWITCH first_arg:
  "list"    → PHASE 1: List Rules
  "add"     → PHASE 2: Add Rule
  "edit"    → PHASE 3: Edit Rule
  "remove"  → PHASE 4: Remove Rule
  "check"   → PHASE 5: Integrity Check
  "history" → PHASE 6: View History
  default   → Show usage TUI
```

**Usage TUI:**

```
AskUserQuestion:
  question: "헌법 관리 작업을 선택하세요"
  header: "Action"
  options:
    - label: "list"
      description: "현재 헌법 규칙 목록 표시"
    - label: "add"
      description: "새 규칙 추가 (대화형)"
    - label: "check"
      description: "헌법 무결성 검사"
    - label: "history"
      description: "헌법 변경 이력 조회"
```

---

## PHASE 1: List Rules

```
mcp__st__sequentialthinking:
  thought: "현재 헌법 규칙을 분석합니다.
    1. docs/constitution.md에서 '## 규칙 목록' 테이블 읽기
    2. 각 규칙의 상세 섹션 추출
    3. 규칙별 요약 정보 수집"
  thoughtNumber: 1
  totalThoughts: 3
  nextThoughtNeeded: true
```

```
EXECUTE:
├─ Read("docs/constitution.md")
├─ Extract "## 규칙 목록" table
├─ Parse all ## 번호. 규칙명 sections
└─ Summarize each rule

OUTPUT FORMAT:
┌─────────────────────────────────────────┐
│ 📜 프로젝트 헌법 (Constitution)          │
├─────────────────────────────────────────┤
│ 1. {rule_name_1} (우선순위: {priority})  │
│    └─ {brief_description}               │
│ 2. {rule_name_2} (우선순위: {priority})  │
│    └─ {brief_description}               │
└─────────────────────────────────────────┘
```

---

## PHASE 2: Add Rule

```
mcp__st__sequentialthinking:
  thought: "새 헌법 규칙 추가를 분석합니다.
    1. docs/constitution.md에서 기존 규칙 확인
    2. 규칙명 중복 검사
    3. 다음 규칙 번호 결정
    4. 우선순위 기반 배치 위치 결정"
  thoughtNumber: 1
  totalThoughts: 5
  nextThoughtNeeded: true
```

**Step 1: Gather Rule Info**

```
AskUserQuestion:
  question: "새 규칙의 이름을 입력하세요 (예: '코드 스타일', '테스트 정책')"
  header: "규칙명"
  options:
    - label: "직접 입력"
      description: "규칙 이름을 직접 작성합니다"
```

**Step 2: Context7 Best Practices**

```
mcp__c7__resolve-library-id:
  libraryName: "Claude Code CLAUDE.md best practices"

mcp__c7__get-library-docs:
  context7CompatibleLibraryID: "{resolved_id}"
  topic: "project rules conventions"
  mode: "info"
```

**Step 3: Rule Content**

```
GATHER via conversation:
├─ 규칙 설명 (1-2문장)
├─ 상세 내용 (테이블/코드블록)
├─ 예시 (필수)
└─ 우선순위 (1-4)

PRIORITY LEVELS:
  1: 보안 관련 규칙
  2: 버전/호환성 규칙
  3: 코드 품질 규칙
  4: 워크플로우 규칙
```

**Step 4: Validation & Apply**

```
VALIDATE:
├─ 중복 규칙명 검사
├─ 형식 일관성 검증
└─ 규칙 번호 순서 확인

IF valid:
  → Edit docs/constitution.md (상세 규칙 추가)
  → Edit CLAUDE.md 헌법 테이블 (요약 1줄 추가)
  → Store change history to Memory
```

**Step 5: Store to Memory**

```
mcp__mm__store_memory:
  content: "헌법 규칙 추가: {rule_name} - {description}"
  metadata:
    tags: "constitution,changelog,{rule_name}"
    type: "constitution_change"
```

---

## PHASE 3: Edit Rule

```
RESOLVE rule_name from $ARGUMENTS[1]

IF rule not found:
  → List available rules
  → AskUserQuestion for selection

DISPLAY current content
GATHER modifications
VALIDATE 150-line limit
APPLY changes
STORE to Memory with diff
```

---

## PHASE 4: Remove Rule

```
mcp__st__sequentialthinking:
  thought: "규칙 삭제의 영향을 분석합니다.
    1. 해당 규칙을 참조하는 다른 문서 검색
    2. 삭제 시 발생할 수 있는 문제 파악
    3. 사용자 확인 필요 여부 결정"
  thoughtNumber: 1
  totalThoughts: 3
  nextThoughtNeeded: true
```

```
AskUserQuestion:
  question: "정말 '{rule_name}' 규칙을 삭제하시겠습니까?"
  header: "확인"
  options:
    - label: "삭제"
      description: "규칙을 영구적으로 삭제합니다"
    - label: "취소"
      description: "삭제를 취소합니다"
```

---

## PHASE 5: Integrity Check

```
mcp__st__sequentialthinking:
  thought: "헌법 무결성을 체계적으로 검사합니다.
    1. docs/constitution.md 파일 존재 여부 확인
    2. 규칙 목록 테이블과 상세 섹션 일치 여부 검증
    3. CLAUDE.md 요약 테이블과 동기화 여부 확인
    4. 각 규칙의 형식 일관성 검증
    5. 앵커 링크 유효성 확인"
  thoughtNumber: 1
  totalThoughts: 5
  nextThoughtNeeded: true
```

```
CHECKS:
├─ [FILE_EXISTS] docs/constitution.md 존재
├─ [TABLE_SYNC] 규칙 목록과 상세 섹션 일치
├─ [CLAUDE_SYNC] CLAUDE.md 요약 테이블 동기화
├─ [FORMAT_CONSISTENT] 규칙 형식 일관성
└─ [LINKS_VALID] 앵커 링크 유효성

OUTPUT:
=== 헌법 무결성 검사 ===

✓ docs/constitution.md 존재
✓ 규칙 목록-상세 동기화
✓ CLAUDE.md 요약 동기화
✓ 규칙 형식 일관성

현재 헌법 규칙:
1. {rule_1} (우선순위: {priority})
2. {rule_2} (우선순위: {priority})

⚠️ 경고:
- {warning_message}
```

---

## PHASE 6: View History

```
mcp__mm__search_by_tag:
  tags: ["constitution", "changelog"]

mcp__mm__recall_memory:
  query: "헌법 변경 이력"
  n_results: 10

OUTPUT:
=== 헌법 변경 이력 ===

{date_1}: {change_description_1}
{date_2}: {change_description_2}
...
```

---

## CONSTITUTION FORMAT

**docs/constitution.md 규칙 상세 형식:**

```markdown
## {번호}. {규칙명}

### 개요

규칙 설명 (1-2문장, **반드시** 키워드 포함 권장)

### 상세 규칙

| 항목 | 설명 |
|------|------|
| ... | ... |

### 체크리스트

- [ ] 체크 항목 1
- [ ] 체크 항목 2

### 예시

```
코드 예시
```
```

**CLAUDE.md 요약 테이블 형식:**

```markdown
| 규칙 | 설명 |
|------|------|
| **규칙명** | 한줄 설명 |
```

---

## ERROR HANDLING

| Error | Response |
|-------|----------|
| constitution.md 없음 | 파일 자동 생성 제안 |
| 중복 규칙명 | 기존 규칙 수정 제안 |
| 테이블-상세 불일치 | 동기화 수정 제안 |
| CLAUDE.md 미동기화 | 요약 테이블 업데이트 |
| 잘못된 형식 | 올바른 형식 안내 및 예시 제공 |
| Memory 연결 실패 | 로컬 백업 후 경고 표시 |

---

## EXECUTE NOW

```
1. Parse $ARGUMENTS → resolve action
2. IF no action → show usage TUI
3. Execute corresponding PHASE
4. Validate changes (if any)
5. Store to Memory (if modified)
6. Display result summary in Korean
```

---

## QUICK REFERENCE

```bash
# 기본 사용법
/automation-tools:constitution list              # 규칙 목록
/automation-tools:constitution add               # 새 규칙 추가
/automation-tools:constitution edit <rule-name>  # 규칙 수정
/automation-tools:constitution remove <rule-name> # 규칙 삭제
/automation-tools:constitution check             # 무결성 검사
/automation-tools:constitution history           # 변경 이력

# 예시
/automation-tools:constitution add "커밋 메시지"
/automation-tools:constitution edit "플러그인 버전 관리"
/automation-tools:constitution check
```
