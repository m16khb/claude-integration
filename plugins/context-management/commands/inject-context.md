---
name: context-management:inject-context
description: '대용량 파일 구조 인식 청킹 및 컨텍스트 주입'
argument-hint: <file_path> [task_instruction]
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - mcp__sequential-thinking__sequentialthinking
  # MCP Memory Service (doobidoo/mcp-memory-service)
  - mcp__memory__store_memory
  - mcp__memory__retrieve_memory
  - mcp__memory__search_memories
model: claude-opus-4-5-20251101
---

# Intelligent File Context Loader

## MISSION

대용량 파일을 컨텍스트로 로드하여 **원문 그대로 복원**합니다.
구조적 경계를 존중하며 청킹하되, 핵심은 **대화 컨텍스트에 파일 내용을 완전히 주입**하는 것입니다.
이후 사용자가 자유롭게 작업을 진행할 수 있도록 컨텍스트만 준비합니다.

**Input**: $ARGUMENTS

---

## CORE PRINCIPLES

```
원문 복원 원칙:
├─ 파일 내용을 가능한 원문 그대로 컨텍스트에 주입
├─ 요약이나 분석이 아닌 실제 코드/텍스트 로딩
├─ 청킹은 토큰 제한을 위한 수단일 뿐
├─ 주입 후 사용자가 자유롭게 활용
├─ 자동 위임/연결 없음 - 사용자 선택 존중
└─ MCP Memory 연동: 관련 메모리 자동 로드 (available 시)
```

---

## PHASE 1: Parse Arguments

```
PARSE $ARGUMENTS:
├─ IF quoted path: FILE_PATH = inside quotes, TASK = after quotes
├─ ELSE: FILE_PATH = first token, TASK = rest
└─ IF TASK empty: TASK = null (작업 지시 없음)

VALIDATE:
├─ FILE_PATH exists? → if not, suggest similar files via Glob
└─ FILE_PATH is text? → if binary, EXIT with error
```

---

## PHASE 2: File Analysis with Sequential Thinking

**Sequential Thinking MCP 호출**로 파일 구조를 분석합니다:

```
mcp__sequential-thinking__sequentialthinking:
  thought: "파일 {FILE_PATH}의 구조를 분석합니다.
    1. 파일 크기와 라인 수 확인
    2. 파일 타입 및 언어 식별
    3. 구조적 경계점 파악 (클래스, 함수, 모듈)
    4. 최적 청킹 전략 결정
    5. 청크 수와 오버랩 계산"
  thoughtNumber: 1
  totalThoughts: 3
  nextThoughtNeeded: true
```

Execute via Bash:

```bash
# Collect metadata
echo "=== FILE INFO ==="
ls -lh "{FILE_PATH}"
wc -l < "{FILE_PATH}"
file "{FILE_PATH}"
```

```
STORE:
├─ TOTAL_LINES = wc -l result
├─ FILE_SIZE = ls -lh result
└─ FILE_TYPE = file command result
```

---

## PHASE 2.5: MCP Memory Integration (Optional)

**MCP memory-service**가 설치되어 있다면 해당 파일 관련 메모리를 자동으로 로드합니다.
(참조: [doobidoo/mcp-memory-service](https://github.com/doobidoo/mcp-memory-service))

### Memory Search Strategy

```
EXTRACT search keywords from FILE_PATH:
├─ 전체 경로: "src/auth/auth.service.ts"
├─ 모듈명: "auth" (디렉토리에서 추출)
├─ 파일명: "auth.service" (확장자 제외)
└─ 프로젝트명: 현재 작업 디렉토리명
```

### Execution

```
TRY:
  # 1. 파일 경로로 관련 메모리 검색
  mcp__memory__retrieve_memory:
    query: "{FILE_PATH}"

  # 2. 모듈명으로 추가 검색
  mcp__memory__search_memories:
    query: "{module_name}"
    tags: ["{module_name}", "{project_name}"]

  IF memories found:
    PRINT "┌─────────────────────────────────────────────┐"
    PRINT "│ 📝 관련 메모리 발견 ({count}개)              │"
    PRINT "├─────────────────────────────────────────────┤"
    FOR each memory in memories:
      PRINT "│ • {memory.content}"
      PRINT "│   [{memory.tags}] - {memory.created_at}"
    PRINT "└─────────────────────────────────────────────┘"

CATCH (MCP memory not available OR connection error):
  # 조용히 스킵 - 에러 메시지 없이 진행
  # MCP memory는 선택적 기능임
  SKIP to PHASE 3
```

### Memory Context Benefits

```
MCP Memory 연동 시 이점:
├─ 이전 분석 결과 자동 로드
├─ 해당 파일 관련 작업 히스토리
├─ 팀원이 남긴 노트/메모
├─ 관련 버그 수정 기록
└─ 세션 간 컨텍스트 연속성 보장
```

---

## PHASE 3: Structure Detection

Detect code boundaries based on file extension:

```bash
EXT="${FILE_PATH##*.}"
case "$EXT" in
  py)     grep -n "^class \|^def \|^async def " "{FILE_PATH}" ;;
  ts|js)  grep -n "^export \|^class \|^function \|^const.*= " "{FILE_PATH}" ;;
  go)     grep -n "^func \|^type \|^package " "{FILE_PATH}" ;;
  rs)     grep -n "^pub \|^fn \|^struct \|^impl " "{FILE_PATH}" ;;
  java)   grep -n "^public \|^private \|^class \|^interface " "{FILE_PATH}" ;;
  md)     grep -n "^# \|^## \|^### " "{FILE_PATH}" ;;
  json)   grep -n '^\s*"[a-zA-Z]' "{FILE_PATH}" ;;  # JSON keys
  yaml|yml) grep -n "^[a-zA-Z_-]\+:" "{FILE_PATH}" ;;  # YAML top-level keys
  toml)   grep -n "^\[" "{FILE_PATH}" ;;  # TOML sections
  xml|html) grep -n "^<[a-zA-Z]" "{FILE_PATH}" ;;  # XML/HTML tags
  sql)    grep -n "^CREATE \|^ALTER \|^INSERT \|^SELECT " "{FILE_PATH}" ;;  # SQL statements
  sh|bash) grep -n "^function \|^[a-zA-Z_]\+() " "{FILE_PATH}" ;;  # Shell functions
  *)      grep -n "^$" "{FILE_PATH}" ;;  # Fallback: blank lines
esac | head -50
```

```
STORE: BOUNDARIES = [line numbers where structure starts]
```

---

## PHASE 4: Chunking Strategy with Sequential Thinking

```
mcp__sequential-thinking__sequentialthinking:
  thought: "청킹 전략을 결정합니다.
    - 파일 크기: {TOTAL_LINES}줄
    - 구조점: {BOUNDARIES.length}개
    - 최적 청크 크기: 원문 보존을 위해 가능한 크게
    - 오버랩: 컨텍스트 연속성을 위해 20줄
    - 목표: 파일 전체를 컨텍스트에 로드"
  thoughtNumber: 2
  totalThoughts: 3
  nextThoughtNeeded: true
```

### Chunking Parameters

| Parameter  | Value     | Rationale              |
| ---------- | --------- | ---------------------- |
| Chunk size | 800 lines | 원문 보존을 위해 최대화 |
| Overlap    | 20 lines  | 컨텍스트 연속성 유지   |
| Max chunks | 15        | 대용량 파일 지원       |
| Min chunk  | 50 lines  | 과도한 분할 방지       |

### Algorithm

```
ALGORITHM:
├─ IF TOTAL_LINES <= 800: single chunk (no split)
├─ ELSE: create chunks respecting BOUNDARIES
│
│   chunks = []
│   start = 1
│   WHILE start < TOTAL_LINES AND len(chunks) < MAX_CHUNKS:
│     target_end = start + CHUNK_SIZE - 1
│
│     # Find nearest boundary near target_end
│     boundary = nearest(BOUNDARIES, target_end, tolerance=50)
│     actual_end = boundary - 1 if boundary else target_end
│
│     chunks.append({start, actual_end})
│     start = actual_end - OVERLAP + 1
│   END WHILE
│
└─ IF remaining lines: add final chunk
```

---

## PHASE 5: Full Content Loading (원문 복원)

**핵심: 파일 내용을 원문 그대로 컨텍스트에 주입**

```
FOR each chunk in chunks:
  PRINT "===== 📄 청크 {i}/{total} [라인 {start}-{end}] ====="
  PRINT "파일: {FILE_PATH}"
  PRINT "─────────────────────────────────────────────"

  TRY:
    Read(file_path=FILE_PATH, offset=start, limit=end-start+1)
  CATCH overflow:
    # Split chunk in half and retry
    mid = (start + end) / 2
    Read(file_path=FILE_PATH, offset=start, limit=mid-start+1)
    PRINT "───── (continued) ─────"
    Read(file_path=FILE_PATH, offset=mid+1, limit=end-mid)
  END TRY

  PRINT "─────────────────────────────────────────────"
  PRINT ""  # separator
END FOR
```

### Output Format (원문 보존)

각 청크는 다음 형식으로 출력됩니다:

```
===== 📄 청크 1/3 [라인 1-800] =====
파일: src/auth/auth.service.ts
─────────────────────────────────────────────
[실제 파일 내용 원문 그대로]
─────────────────────────────────────────────
```

---

## PHASE 6: Context Summary with Sequential Thinking

```
mcp__sequential-thinking__sequentialthinking:
  thought: "컨텍스트 주입을 완료합니다.
    - 로드된 파일: {FILE_PATH}
    - 총 라인: {TOTAL_LINES}줄
    - 청크 수: {chunk_count}개
    - 구조점: {boundary_count}개
    - 상태: 원문 컨텍스트 주입 완료
    - 다음: 사용자가 자유롭게 작업 진행 가능"
  thoughtNumber: 3
  totalThoughts: 3
  nextThoughtNeeded: false
```

### Completion Report (Korean)

```markdown
╔════════════════════════════════════════════════════════════╗
║              📁 파일 컨텍스트 로딩 완료                       ║
╠════════════════════════════════════════════════════════════╣
║ 파일: {FILE_PATH}                                           ║
║ 크기: {TOTAL_LINES}줄 ({FILE_SIZE})                         ║
║ 청크: {chunk_count}개 (오버랩 {OVERLAP}줄)                   ║
║ 구조점: {boundary_count}개 탐지                             ║
╠════════════════════════════════════════════════════════════╣
║ 📌 파일 내용이 컨텍스트에 원문 그대로 로드되었습니다.         ║
║ 이제 자유롭게 질문하거나 작업을 진행하세요.                  ║
╚════════════════════════════════════════════════════════════╝
```

---

## PHASE 7: Optional Follow-up

**자동 위임 없음** - 사용자가 원할 경우에만 TUI 제공:

```
IF TASK is provided:
  PRINT "작업 지시: {TASK}"
  PRINT "위 작업을 진행하시겠습니까? 아니면 다른 작업을 하시겠습니까?"

  AskUserQuestion:
    question: "컨텍스트가 준비되었습니다. 어떻게 진행하시겠습니까?"
    header: "다음 작업"
    options:
      - label: "작업 진행"
        description: "'{TASK}' 작업을 진행합니다"
      - label: "추가 파일 로드"
        description: "관련 파일을 추가로 로드합니다"
      - label: "다른 작업"
        description: "다른 작업을 직접 지시합니다"
      - label: "완료"
        description: "컨텍스트만 유지하고 종료합니다"

ELSE:
  # TASK 없으면 TUI 없이 바로 종료
  PRINT "컨텍스트가 준비되었습니다. 자유롭게 질문하거나 작업을 지시하세요."
  EXIT
```

### Handle Selection:

```
SWITCH selection:
  "작업 진행":
    → 사용자가 지정한 TASK 작업 수행
    → (continue-context 자동 호출 없음)

  "추가 파일 로드":
    → TUI: input file path
    → Recursive: inject-context on new file

  "다른 작업":
    → 사용자 입력 대기
    → 입력된 작업 수행

  "완료":
    → Print "컨텍스트가 준비되었습니다."
    → Exit
```

---

## ERROR HANDLING

| Error                    | Response (Korean)                               |
| ------------------------ | ----------------------------------------------- |
| File not found           | "파일을 찾을 수 없습니다" + Glob 유사 파일 제안 |
| Permission denied        | "파일 읽기 권한이 없습니다"                     |
| Binary file              | "바이너리 파일은 지원하지 않습니다"             |
| Token overflow           | 청크 크기 50% 감소 후 재시도                    |
| Structure detection fail | 고정 청킹으로 폴백                              |
| Empty file               | "빈 파일입니다. 다른 파일을 선택하세요"         |

---

## CONSTRAINTS REMOVED

```
❌ 제거된 제약:
├─ continue-context 자동 연결 제거
├─ Opus 자동 위임 제거
├─ 강제 TUI 제거 (TASK 없으면 TUI 스킵)
└─ 요약/분석 우선 제거 → 원문 보존 우선

✅ 유지/강화:
├─ Sequential Thinking으로 구조 분석
├─ 구조적 경계 존중 청킹
├─ 원문 그대로 컨텍스트 주입
└─ 사용자 선택 존중
```

---

## EXECUTE NOW

1. Parse FILE_PATH and TASK from $ARGUMENTS
2. **Sequential Thinking**: 파일 구조 분석
3. Validate file exists and is readable
4. Collect metadata (size, type)
5. **MCP Memory**: 관련 메모리 검색 및 로드 (PHASE 2.5) ← NEW
   - MCP memory-service available → 파일/모듈 관련 메모리 검색
   - Not available → 조용히 스킵
6. Detect structural boundaries
7. **Sequential Thinking**: 청킹 전략 결정
8. Calculate optimal chunks
9. **Load chunks sequentially - 원문 그대로 출력**
10. **Sequential Thinking**: 완료 요약
11. Report completion in Korean
12. IF TASK provided → Show optional TUI
13. ELSE → Exit (사용자 자유 작업)
