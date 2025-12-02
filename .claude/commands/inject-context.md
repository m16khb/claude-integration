---
name: inject-context
description: "Split-load large files with intelligent chunking and chain to Opus"
argument-hint: <file_path> [task_instruction]
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - SlashCommand
model: haiku
---

# Intelligent File Context Injection

Load large files using **structure-aware chunking**, then delegate to Opus based on user selection.

**Input**: $ARGUMENTS

---

## Constraints

| Item | Value | Note |
|------|-------|------|
| Read tool limit | ~25,000 tokens | Hard limit |
| Default chunk size | 600 lines | Safety margin |
| Overlap size | 20 lines | Context connection |
| Max chunks | 12 | Context window consideration |
| Min chunk size | 50 lines | Prevent over-splitting |

---

## Execution Steps

### Step 1: Parse Arguments

```
FULL_ARGS = "$ARGUMENTS"

# Handle quoted paths
IF contains quotes:
    FILE_PATH = string inside quotes
    TASK = string after quotes
ELSE:
    FILE_PATH = first token before space
    TASK = remaining tokens
END IF

IF TASK is empty:
    TASK = "Analyze file structure and explain core logic"
END IF
```

### Step 2: Validate File and Collect Metadata

Execute via Bash:
```bash
if [ ! -f "{FILE_PATH}" ]; then
    echo "ERROR: File not found: {FILE_PATH}"
    exit 1
fi

# Collect file info
echo "=== File Metadata ==="
echo "Path: {FILE_PATH}"
wc -l < "{FILE_PATH}" | xargs -I{} echo "Total lines: {}"
file "{FILE_PATH}" | cut -d: -f2
ls -lh "{FILE_PATH}" | awk '{print "Size: "$5}'

# File extension
echo "Extension: ${FILE_PATH##*.}"
```

### Step 3: Structure Analysis

Detect **structural boundaries** by file type:

```bash
# Find structural boundaries in code files
# Result: line numbers for function/class/module starts

FILE_EXT="${FILE_PATH##*.}"

case "$FILE_EXT" in
    py)
        # Python: class, def, import blocks
        grep -n "^class \|^def \|^from \|^import " "{FILE_PATH}" | head -50
        ;;
    ts|tsx|js|jsx)
        # TypeScript/JavaScript: export, class, function, interface
        grep -n "^export \|^class \|^function \|^interface \|^type \|^const.*= " "{FILE_PATH}" | head -50
        ;;
    go)
        # Go: package, func, type, import
        grep -n "^package \|^func \|^type \|^import " "{FILE_PATH}" | head -50
        ;;
    rs)
        # Rust: mod, fn, struct, impl, use
        grep -n "^pub \|^fn \|^struct \|^impl \|^use \|^mod " "{FILE_PATH}" | head -50
        ;;
    yaml|yml)
        # YAML: top-level keys (no indentation)
        grep -n "^[a-zA-Z_-]*:" "{FILE_PATH}" | head -50
        ;;
    *)
        # Others: section separation by blank lines
        grep -n "^$" "{FILE_PATH}" | head -50
        ;;
esac
```

### Step 4: Smart Chunking Algorithm

```
TOTAL_LINES = N (wc -l result)
BASE_CHUNK = 600
OVERLAP = 20
MAX_CHUNKS = 12

# Structural boundary array (Step 3 result)
BOUNDARIES = [1, ...structure_points..., TOTAL_LINES]

# Generate chunk plan
CHUNKS = []
current_start = 1

WHILE current_start < TOTAL_LINES:
    # Calculate target end
    target_end = current_start + BASE_CHUNK - 1

    IF target_end >= TOTAL_LINES:
        # Last chunk
        CHUNKS.append({start: current_start, end: TOTAL_LINES})
        BREAK
    END IF

    # Find nearest structural boundary (near target_end)
    best_boundary = find_nearest_boundary(BOUNDARIES, target_end, range=100)

    IF best_boundary exists:
        actual_end = best_boundary - 1  # Up to just before boundary
    ELSE:
        actual_end = target_end
    END IF

    # Add chunk
    CHUNKS.append({start: current_start, end: actual_end})

    # Next chunk start (apply overlap)
    current_start = actual_end - OVERLAP + 1

    IF len(CHUNKS) >= MAX_CHUNKS:
        WARN "Max chunks reached. Remaining will be processed in summary mode"
        BREAK
    END IF
END WHILE
```

### Step 5: Sequential Chunk Loading

```
context_loaded = []

FOR i, chunk IN enumerate(CHUNKS):
    # Chunk header output
    PRINT "===== 청크 {i+1}/{len(CHUNKS)} [라인 {chunk.start}-{chunk.end}] ====="

    TRY:
        Read(file_path=FILE_PATH, offset=chunk.start, limit=chunk.end - chunk.start + 1)
        context_loaded.append(chunk)
    CATCH overflow:
        # Split in half on overflow
        mid = (chunk.start + chunk.end) // 2
        PRINT "⚠️ Chunk size exceeded. Split loading..."
        Read(file_path=FILE_PATH, offset=chunk.start, limit=mid - chunk.start + 1)
        Read(file_path=FILE_PATH, offset=mid + 1, limit=chunk.end - mid)
        context_loaded.append(chunk)
    END TRY

    PRINT ""  # Chunk separator
END FOR
```

### Step 6: Verify Context Completeness

```
# Calculate loaded lines
total_loaded = sum(chunk.end - chunk.start + 1 for chunk in context_loaded)
# Actual coverage excluding overlap
unique_coverage = actual covered lines based on TOTAL_LINES

IF unique_coverage < TOTAL_LINES * 0.95:
    WARN "⚠️ {100 - unique_coverage/TOTAL_LINES*100:.1f}% of file not loaded"
    # Load missing sections additionally
END IF
```

### Step 7: Load Complete Report and User Selection

```markdown
╔═══════════════════════════════════════════════════════════════╗
║           📁 파일 컨텍스트 주입 완료                              ║
╠═══════════════════════════════════════════════════════════════╣
║ 파일: {FILE_PATH}                                              ║
║ 크기: {TOTAL_LINES}줄                                          ║
║ 청크: {len(CHUNKS)}개 (오버랩 {OVERLAP}줄)                      ║
║ 커버리지: {coverage}%                                          ║
║ 구조점: {len(BOUNDARIES)}개 탐지                               ║
╠═══════════════════════════════════════════════════════════════╣
║ 작업 지시: {TASK}                                              ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## Step 8: User Selection (TUI) - Required!

Use **AskUserQuestion** for next action:

```
AskUserQuestion(questions=[
    {
        "question": "컨텍스트 로딩이 완료되었습니다. 다음 작업을 선택하세요.",
        "header": "다음 작업",
        "options": [
            {"label": "Opus로 작업 위임", "description": "로드된 컨텍스트를 기반으로 '{TASK}' 작업을 Opus 모델에서 실행합니다"},
            {"label": "추가 파일 로드", "description": "관련 파일을 추가로 로드합니다 (inject-context 재실행)"},
            {"label": "작업 지시 변경", "description": "다른 작업 지시로 변경합니다"},
            {"label": "컨텍스트만 유지", "description": "자동 위임 없이 현재 컨텍스트를 유지합니다"}
        ],
        "multiSelect": false
    }
])
```

### Handle Selection

```
SWITCH user_selection:
    CASE "Opus로 작업 위임":
        SlashCommand(command="/continue-task {TASK}")

    CASE "추가 파일 로드":
        AskUserQuestion → get additional file path
        → inject-context for that file too

    CASE "작업 지시 변경":
        AskUserQuestion → get new task instruction
        → /continue-task with new TASK

    CASE "컨텍스트만 유지":
        Print completion message and exit
        → User enters follow-up command directly
END SWITCH
```

---

## Error Handling

| Error | Response |
|-------|----------|
| File not found | Search similar filenames and suggest |
| Permission denied | Inform permission issue |
| Token overflow | Reduce chunk size by 50% and retry |
| Binary file | Print error message and exit |
| Structure detection failed | Fallback to fixed chunking |

---

## Execute (now)

1. Parse FILE_PATH and TASK from $ARGUMENTS
2. Analyze file existence/size/structure via Bash
3. Create smart chunking plan (structure-based)
4. Sequential Read calls with overlap
5. Verify context completeness
6. Output completion report
7. **AskUserQuestion for next action**
8. Execute SlashCommand or additional work based on selection

---

## Never Skip

- Structure analysis (Step 3) - Core of chunking quality
- Apply overlap (Step 4) - Ensures context continuity
- User selection (Step 8) - Provides TUI experience

Complete context without loss, user must be able to select next steps.
