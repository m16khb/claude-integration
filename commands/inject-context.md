---
name: inject-context
description: "대용량 파일 구조 인식 청킹 및 컨텍스트 주입"
argument-hint: <file_path> [task_instruction]
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - SlashCommand
model: claude-3-5-haiku-20241022
---

# Intelligent File Context Loader

## MISSION

Load large files into context using structure-aware chunking.
Preserve code boundaries (functions, classes). Hand off to Opus for analysis.

**Input**: $ARGUMENTS

---

## CONSTRAINTS

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Chunk size | 500 lines | Stay within Read tool limits |
| Overlap | 20 lines | Maintain context continuity |
| Max chunks | 10 | Prevent context overflow |
| Min chunk | 50 lines | Avoid over-fragmentation |

---

## PHASE 1: Parse Arguments

```
PARSE $ARGUMENTS:
├─ IF quoted path: FILE_PATH = inside quotes, TASK = after quotes
├─ ELSE: FILE_PATH = first token, TASK = rest
└─ IF TASK empty: TASK = "파일 구조 분석 및 핵심 로직 설명"

VALIDATE:
├─ FILE_PATH exists? → if not, suggest similar files via Glob
└─ FILE_PATH is text? → if binary, EXIT with error
```

---

## PHASE 2: File Analysis

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
  *)      grep -n "^$" "{FILE_PATH}" ;;  # Fallback: blank lines
esac | head -50
```

```
STORE: BOUNDARIES = [line numbers where structure starts]
```

---

## PHASE 4: Chunking Algorithm

```
ALGORITHM:
├─ IF TOTAL_LINES <= 500: single chunk (no split)
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

## PHASE 5: Sequential Loading

```
FOR each chunk in chunks:
  PRINT "===== 청크 {i}/{total} [라인 {start}-{end}] ====="

  TRY:
    Read(file_path=FILE_PATH, offset=start, limit=end-start+1)
  CATCH overflow:
    # Split chunk in half and retry
    mid = (start + end) / 2
    Read(file_path=FILE_PATH, offset=start, limit=mid-start+1)
    Read(file_path=FILE_PATH, offset=mid+1, limit=end-mid)
  END TRY

  PRINT ""  # separator
END FOR
```

---

## PHASE 6: Completion Report (Korean)

```markdown
╔════════════════════════════════════════════════════════════╗
║              📁 파일 컨텍스트 로딩 완료                       ║
╠════════════════════════════════════════════════════════════╣
║ 파일: {FILE_PATH}                                           ║
║ 크기: {TOTAL_LINES}줄 ({FILE_SIZE})                         ║
║ 청크: {chunk_count}개 (오버랩 {OVERLAP}줄)                   ║
║ 구조점: {boundary_count}개 탐지                             ║
╠════════════════════════════════════════════════════════════╣
║ 작업 지시: {TASK}                                           ║
╚════════════════════════════════════════════════════════════╝
```

---

## PHASE 7: Follow-up TUI (Required)

```
AskUserQuestion:
  question: "컨텍스트 로딩이 완료되었습니다. 다음 작업을 선택하세요."
  header: "다음 작업"
  options:
    - label: "Opus로 작업 위임"
      description: "로드된 컨텍스트로 '{TASK}' 작업을 Opus에서 실행"
    - label: "추가 파일 로드"
      description: "관련 파일을 추가로 로드합니다"
    - label: "작업 지시 변경"
      description: "다른 작업 지시로 변경합니다"
    - label: "컨텍스트만 유지"
      description: "자동 위임 없이 현재 상태 유지"
```

### Handle Selection:
```
SWITCH selection:
  "Opus로 작업 위임":
    → SlashCommand("/continue-task {TASK}")

  "추가 파일 로드":
    → TUI: input file path
    → Recursive: inject-context on new file

  "작업 지시 변경":
    → TUI: input new TASK
    → SlashCommand("/continue-task {new_TASK}")

  "컨텍스트만 유지":
    → Print "컨텍스트가 준비되었습니다. 직접 질문하세요."
    → Exit
```

---

## ERROR HANDLING

| Error | Response (Korean) |
|-------|-------------------|
| File not found | "파일을 찾을 수 없습니다" + Glob 유사 파일 제안 |
| Permission denied | "파일 읽기 권한이 없습니다" |
| Binary file | "바이너리 파일은 지원하지 않습니다" |
| Token overflow | 청크 크기 50% 감소 후 재시도 |
| Structure detection fail | 고정 청킹으로 폴백 |
| Empty file | "빈 파일입니다. 다른 파일을 선택하세요" |

---

## EXECUTE NOW

1. Parse FILE_PATH and TASK from $ARGUMENTS
2. Validate file exists and is readable
3. Collect metadata (size, type)
4. Detect structural boundaries
5. Calculate optimal chunks
6. Load chunks sequentially with overlap
7. Report completion in Korean
8. **Show TUI for next action** ← REQUIRED
