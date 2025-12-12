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

# EXECUTION

사용자가 `/constitution` 명령을 실행했습니다.

**입력 인자**: $ARGUMENTS

## 실행 지시

### 1단계: 인자 파싱

`$ARGUMENTS`에서 다음을 추출하세요:
- **action**: `list` | `add` | `edit` | `remove` | `check` | `history` (첫 번째 인자)
- **rule-name**: 규칙명 (두 번째 인자, `edit`/`remove` 시 필요)

인자가 없거나 `help`이면 사용법을 표시하세요.

### 2단계: action별 분기 처리

#### action = `list`
1. Read로 `agent-docs/constitution.md` 읽기
2. 규칙 목록을 TUI 형식으로 출력

#### action = `add`
1. AskUserQuestion으로 규칙 정보 수집 (규칙명, 설명, 우선순위 1-4)
2. Context7로 관련 베스트 프랙티스 조회 (선택적)
3. 중복 검사 수행
4. Edit로 `agent-docs/constitution.md` 업데이트
5. Edit로 `CLAUDE.md` 헌법 테이블 업데이트
6. MCP Memory에 변경 이력 저장

#### action = `edit <name>`
1. Read로 기존 규칙 내용 조회
2. AskUserQuestion으로 수정 사항 수집
3. Edit로 양쪽 파일 업데이트
4. MCP Memory에 변경 이력 저장

#### action = `remove <name>`
1. AskUserQuestion으로 삭제 확인
2. Edit로 양쪽 파일에서 규칙 제거
3. MCP Memory에 변경 이력 저장

#### action = `check`
1. 무결성 검사 수행:
   - `agent-docs/constitution.md` 존재 확인
   - CLAUDE.md 요약과 상세 동기화 확인
   - 규칙 형식 일관성 확인
2. 문제 발견 시 자동 수정 제안

#### action = `history`
1. MCP Memory에서 `constitution`, `changelog` 태그로 검색
2. 변경 이력 출력

### 3단계: 결과 출력

수행 결과를 TUI 스타일로 표시하세요.

---

# REFERENCE

## 대상 파일
- `agent-docs/constitution.md` - 규칙 상세
- `CLAUDE.md` 헌법 테이블 - 요약

## ACTIONS 요약

| 액션 | 설명 |
|------|------|
| `list` | 규칙 목록 표시 |
| `add` | 새 규칙 추가 |
| `edit <name>` | 규칙 수정 |
| `remove <name>` | 규칙 삭제 |
| `check` | 무결성 검사 |
| `history` | 변경 이력 조회 |

## 우선순위 레벨

| 레벨 | 설명 |
|-----|------|
| 1 | 보안 규칙 |
| 2 | 버전/호환성 |
| 3 | 코드 품질 |
| 4 | 워크플로우 |

## PHASE 상세: List Rules

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
