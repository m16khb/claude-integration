---
name: claude-md
description: 'CLAUDE.md 생성, 분석, 구조화 (WHAT/WHY/HOW 프레임워크)'
argument-hint: <action> [path]
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
model: claude-opus-4-5-20251101
---

# CLAUDE.md Management Tool

## MISSION

Create and maintain high-quality CLAUDE.md files as "persistent memory for AI agents".
Ensure files are concise (<60 lines ideal), universally relevant, and follow WHAT/WHY/HOW framework.

**Input**: $ARGUMENTS

---

## CORE PRINCIPLES

```
╔═══════════════════════════════════════════════════════════════╗
║  🔴 LESS IS MORE                                               ║
║  ├─ IDEAL: <60 lines  │  GOOD: 60-150  │  WARN: 150-300       ║
║  └─ ERROR: >300 lines (quality degradation)                   ║
╠═══════════════════════════════════════════════════════════════╣
║  🟡 UNIVERSAL RELEVANCE                                        ║
║  ├─ Only include content relevant to EVERY session            ║
║  └─ Conditional instructions may be ignored by Claude         ║
╠═══════════════════════════════════════════════════════════════╣
║  🟢 PROGRESSIVE DISCLOSURE                                     ║
║  ├─ Keep CLAUDE.md minimal, reference agent_docs/             ║
║  └─ Let Claude fetch details when needed                      ║
╚═══════════════════════════════════════════════════════════════╝

WHAT/WHY/HOW FRAMEWORK:
├─ WHAT: Tech stack, structure, key file locations
├─ WHY: Project purpose, target users, value proposition
└─ HOW: Package manager, test/build commands, verification

ANTI-PATTERNS:
├─ Code style guides → use ESLint/Biome
├─ All possible commands → only essentials
├─ Code snippets → use file:line references
└─ Conditional instructions → via messages
```

---

## PHASE 1: Route Action

```
PARSE $ARGUMENTS:
├─ "분석" | "analyze" | "a"    → ACTION = ANALYZE
├─ "생성" | "generate" | "g"   → ACTION = GENERATE
├─ "구조화" | "structure" | "s" → ACTION = STRUCTURE
├─ "검사" | "lint" | "l"       → ACTION = LINT
└─ empty or invalid            → TUI_SELECT
```

**TUI (when no args):**
```
AskUserQuestion:
  question: "CLAUDE.md 관리 작업을 선택하세요"
  header: "작업"
  options:
    - label: "분석"
      description: "기존 CLAUDE.md 품질 분석 및 개선점 제안"
    - label: "생성"
      description: "WHAT/WHY/HOW 프레임워크로 새 CLAUDE.md 생성"
    - label: "구조화"
      description: "Progressive Disclosure 구조 설정"
    - label: "검사"
      description: "라인 수, 보편성, 안티패턴 검사"
```

---

## PHASE 2: Execute Action

### ANALYZE

```
STEPS:
1. Find CLAUDE.md files: find . -name "CLAUDE.md" -type f
2. Evaluate each file:
   ├─ PRINCIPLE 1: line_count (wc -l)
   │   ├─ <60: ✅ IDEAL  │  60-150: ✅ GOOD
   │   ├─ 150-300: ⚠️ WARN  │  >300: ❌ ERROR
   ├─ PRINCIPLE 2: universal relevance
   │   ├─ has_conditional? → WARN
   │   └─ has_code_style? → WARN
   ├─ PRINCIPLE 3: progressive disclosure
   │   ├─ has_agent_docs? → ✅
   │   └─ has_inline_code? → WARN
   └─ WHAT/WHY/HOW completeness
```

**Output Format (Korean):**
```markdown
## 📊 CLAUDE.md 분석 결과
| 파일 | 라인 | 상태 | WHAT | WHY | HOW |
|------|------|------|------|-----|-----|
| {path} | {n} | {status} | ✅/❌ | ✅/❌ | ✅/❌ |

### 개선 제안
1. {specific suggestion}
```

### GENERATE

```
STEPS:
1. Determine target path (from args or TUI)
2. Scan directory:
   ├─ File types (*.ts, *.py, etc.)
   ├─ README.md, package.json, pyproject.toml
   └─ Existing agent_docs/
3. TUI: Select project type
   options: ["서비스/앱", "라이브러리", "모노레포", "인프라/설정"]
4. Generate CLAUDE.md (<60 lines):
   ├─ WHAT: tech stack, structure
   ├─ WHY: purpose from README
   └─ HOW: essential commands only
5. Create agent_docs/ if complex project
6. Validate: <60 lines, no anti-patterns
```

**Template (Target: <60 lines):**
```markdown
# [Project Name]

## 개요 (WHY)
[1-2 sentences]

## 기술 스택 (WHAT)
- **언어**: [language]
- **프레임워크**: [framework]

## 구조 (WHAT)
project/
├─ src/    # [purpose]
└─ tests/  # [purpose]

## 필수 명령어 (HOW)
| 명령어 | 설명 |
|--------|------|
| `cmd` | desc |

## 상세 문서
- [agent_docs/building.md] - 빌드
- [agent_docs/testing.md] - 테스트
```

### STRUCTURE

```
STEPS:
1. Find all CLAUDE.md files
2. Assess Progressive Disclosure status
3. Report current vs ideal structure:
   project/
   ├─ CLAUDE.md (<60 lines)
   └─ agent_docs/
       ├─ building.md
       ├─ testing.md
       └─ architecture.md
4. TUI: "권장 구조로 재구성할까요?"
   IF yes → extract detailed content to agent_docs/
```

### LINT

```
CHECKS:
ERRORS (must fix):
├─ line_count > 300     → ❌ "지시사항 품질 저하"
├─ missing WHAT/HOW     → ❌ "필수 섹션 누락"
└─ auto_generated       → ❌ "/init 자동생성 금지"

WARNINGS (should fix):
├─ line_count > 150     → ⚠️ "분리 권장"
├─ has_code_style       → ⚠️ "린터로 분리"
├─ has_conditional      → ⚠️ "무시될 수 있음"
└─ no_agent_docs        → ⚠️ "상세 문서 분리 권장"

INFO:
├─ line_count > 60      → ℹ️ "이상적 수준 초과"
└─ no_file_refs         → ℹ️ "file:line 권장"
```

---

## PHASE 3: Report Results

```
OUTPUT FORMAT (Korean):
├─ Summary table with principle compliance
├─ Detailed findings per file
├─ Specific recommendations with priority
└─ Actionable next steps
```

---

## PHASE 4: Follow-up TUI (Required)

```
AskUserQuestion:
  question: "다음 작업을 선택하세요"
  header: "후속"
  options:
    - label: "변경 적용"
      description: "제안된 개선사항을 파일에 적용"
    - label: "agent_docs 구조화"
      description: "Progressive Disclosure 구조 생성"
    - label: "다른 작업"
      description: "다른 CLAUDE.md 작업 선택"
    - label: "완료"
      description: "작업 종료"
```

---

## ERROR HANDLING

| Error | Response (Korean) |
|-------|-------------------|
| No CLAUDE.md found | "CLAUDE.md 파일을 찾을 수 없습니다. 생성하시겠습니까?" |
| Permission denied | "파일 권한이 없습니다: {path}" |
| Invalid action | "알 수 없는 작업입니다. 사용 가능: 분석, 생성, 구조화, 검사" |
| Path not found | "경로를 찾을 수 없습니다: {path}" + Glob 제안 |
| Over 300 lines | "⚠️ 300줄 초과 - 즉시 분리 필요" |

---

## EXECUTE NOW

1. Parse $ARGUMENTS → determine ACTION
2. IF empty → show TUI menu
3. Execute ACTION-specific logic
4. Validate against 3 PRINCIPLES
5. Report results in Korean
6. **Show follow-up TUI** ← NEVER SKIP
