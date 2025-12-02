---
name: claude-md
description: 'CLAUDE.md 생성, 분석, 구조화 도구'
argument-hint: <action> [path]
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---

# CLAUDE.md Management Tool

## MISSION

Create and maintain high-quality CLAUDE.md files following best practices.
CLAUDE.md serves as "persistent memory for AI agents" - loaded into every session.
Ensure files are concise, universally relevant, and properly structured.

**Input**: $ARGUMENTS

---

## CORE PRINCIPLES (MUST FOLLOW)

```
╔════════════════════════════════════════════════════════════════╗
║  🔴 PRINCIPLE 1: LESS IS MORE                                   ║
║  ─────────────────────────────────────────────────────────────  ║
║  LLMs can follow ~150-200 instructions reasonably               ║
║  Claude Code system prompt already uses ~50                     ║
║  CLAUDE.md should stay within remaining capacity                ║
║                                                                ║
║  LIMITS:                                                       ║
║  ├─ IDEAL: <60 lines                                           ║
║  ├─ ACCEPTABLE: 60-150 lines                                   ║
║  ├─ WARNING: 150-300 lines                                     ║
║  └─ ERROR: >300 lines (quality degradation)                    ║
╠════════════════════════════════════════════════════════════════╣
║  🟡 PRINCIPLE 2: UNIVERSAL RELEVANCE                            ║
║  ─────────────────────────────────────────────────────────────  ║
║  Only include content relevant to EVERY session                ║
║  Conditional instructions may be ignored by Claude             ║
║                                                                ║
║  Claude receives system reminder:                              ║
║  "this context may or may not be relevant to your tasks"       ║
╠════════════════════════════════════════════════════════════════╣
║  🟢 PRINCIPLE 3: PROGRESSIVE DISCLOSURE                         ║
║  ─────────────────────────────────────────────────────────────  ║
║  Keep CLAUDE.md minimal, reference detailed docs               ║
║  Let Claude fetch details when needed                          ║
║                                                                ║
║  agent_docs/                                                   ║
║    ├─ building.md                                              ║
║    ├─ testing.md                                               ║
║    └─ architecture.md                                          ║
╚════════════════════════════════════════════════════════════════╝
```

---

## WHAT/WHY/HOW FRAMEWORK

Every CLAUDE.md MUST answer these three questions:

```
WHAT - Technical Stack & Structure
├─ Project structure and codebase map
├─ Monorepo layout (if applicable)
├─ Purpose of each app/package
└─ Key file locations

WHY - Project Goals
├─ Overall project purpose
├─ Target users/problems solved
└─ Core value proposition

HOW - Working Methods
├─ Package manager (bun/npm/pnpm)
├─ Test/typecheck/build commands
├─ Verification process for changes
└─ Deployment workflow (if relevant)
```

---

## ANTI-PATTERNS (NEVER DO)

| Anti-Pattern | Why Bad | Alternative |
|--------------|---------|-------------|
| Include code style guides | LLM = expensive linter; use actual linters | ESLint/Biome config + hooks |
| List all possible commands | Wastes context on conditional info | Only "every session" commands |
| Use /init auto-generation | High-leverage file deserves manual curation | Write manually with care |
| Copy code snippets | Gets stale, wastes tokens | Use `file:line` references |
| Include DB schema details | Not relevant to every task | Separate agent_docs/schema.md |
| Add conditional instructions | May be ignored by Claude | Task-specific via messages |

---

## PHASE 1: Route Action

```
PARSE $ARGUMENTS:
├─ "분석" | "analyze" | "a"    → ACTION = ANALYZE
├─ "생성" | "generate" | "g"   → ACTION = GENERATE
├─ "구조화" | "structure" | "s" → ACTION = STRUCTURE
├─ "검사" | "lint" | "l"       → ACTION = LINT
└─ empty or invalid            → ACTION = TUI_SELECT
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
1. Find all CLAUDE.md files:
   find . -name "CLAUDE.md" -type f 2>/dev/null

2. For each file, evaluate against principles:

   PRINCIPLE 1 - Less is More:
   ├─ line_count: wc -l
   │   ├─ <60: ✅ IDEAL
   │   ├─ 60-150: ✅ GOOD
   │   ├─ 150-300: ⚠️ WARN - consider splitting
   │   └─ >300: ❌ ERROR - instruction quality degrades
   └─ instruction_density: estimate instruction count

   PRINCIPLE 2 - Universal Relevance:
   ├─ has_conditional: grep -q "IF\|만약\|경우에"
   │   → WARN if found (may be ignored)
   ├─ has_code_style: grep -q "코드 스타일\|Code Style\|indent\|spacing"
   │   → WARN (use linter instead)
   └─ has_all_commands: excessive command lists
       → WARN (only include essential commands)

   PRINCIPLE 3 - Progressive Disclosure:
   ├─ has_agent_docs: check for agent_docs/ or similar
   ├─ has_doc_references: links to detailed docs
   └─ has_inline_code: large code blocks
       → WARN (use file:line references)

   WHAT/WHY/HOW Framework:
   ├─ has_what: tech stack, structure sections
   ├─ has_why: project purpose, goals
   └─ has_how: commands, workflows
```

**Output (Korean):**
```markdown
## 📊 CLAUDE.md 분석 결과

### 기본 정보
| 파일 | 라인 | 상태 | 지시사항 밀도 |
|------|------|------|--------------|
| ./CLAUDE.md | 45 | ✅ 이상적 | ~30개 |
| ./src/CLAUDE.md | 320 | ❌ 초과 | ~200개+ |

### 3원칙 점검

#### 원칙 1: 덜함이 더함 (Less is More)
| 파일 | 라인 | 판정 |
|------|------|------|
| ./CLAUDE.md | 45 | ✅ 이상적 (<60) |

#### 원칙 2: 보편적 관련성 (Universal Relevance)
| 파일 | 조건부 지시 | 코드 스타일 | 판정 |
|------|------------|------------|------|
| ./CLAUDE.md | 없음 | 없음 | ✅ |

#### 원칙 3: 점진적 공개 (Progressive Disclosure)
| 파일 | agent_docs | 문서 참조 | 인라인 코드 |
|------|-----------|----------|------------|
| ./CLAUDE.md | ✅ 있음 | ✅ | ⚠️ 일부 존재 |

### WHAT/WHY/HOW 프레임워크
| 파일 | WHAT | WHY | HOW |
|------|------|-----|-----|
| ./CLAUDE.md | ✅ | ⚠️ 부족 | ✅ |

### 개선 제안
1. [파일]: [구체적 제안]
```

### GENERATE

```
STEPS:
1. Determine target path:
   ├─ IF path in $ARGUMENTS → use it
   └─ ELSE → TUI: select from subdirectories

2. Scan target directory:
   ├─ File types present (*.ts, *.py, etc.)
   ├─ Existing README.md content
   ├─ Package.json / pyproject.toml / go.mod
   └─ Existing agent_docs/ directory

3. TUI: Select project type
   options: ["서비스/앱", "라이브러리", "모노레포", "인프라/설정"]

4. Generate CLAUDE.md using WHAT/WHY/HOW framework:
   ├─ WHAT: tech stack, structure (from scan)
   ├─ WHY: purpose (from README or infer)
   ├─ HOW: essential commands only
   └─ References: agent_docs/ for details

5. Create agent_docs/ structure if complex project:
   ├─ building.md
   ├─ testing.md
   └─ architecture.md

6. Validate output:
   ├─ line_count < 60 (ideal) or < 150 (acceptable)
   ├─ no code style guidelines
   ├─ no conditional instructions
   └─ uses file:line references, not code snippets
```

**Template (Target: <60 lines):**
```markdown
# [Project Name]

## 개요 (WHY)
[1-2 sentences: what this project does and why]

## 기술 스택 (WHAT)
- **언어**: [language]
- **프레임워크**: [framework]
- **패키지 매니저**: [bun/npm/pnpm]

## 구조 (WHAT)
```
project/
├─ src/           # [purpose]
├─ tests/         # [purpose]
└─ [key dirs]
```

## 필수 명령어 (HOW)
| 명령어 | 설명 |
|--------|------|
| `[cmd]` | [desc] |

## 상세 문서
- [agent_docs/building.md](agent_docs/building.md) - 빌드 가이드
- [agent_docs/testing.md](agent_docs/testing.md) - 테스트 방법
```

### STRUCTURE

```
STEPS:
1. Find all CLAUDE.md files
2. Check for agent_docs/ directory
3. Assess Progressive Disclosure status:

   IDEAL STRUCTURE:
   project/
   ├─ CLAUDE.md              # <60 lines, WHAT/WHY/HOW only
   ├─ agent_docs/
   │   ├─ building.md        # Detailed build instructions
   │   ├─ testing.md         # Test strategies, coverage
   │   ├─ architecture.md    # System design details
   │   ├─ database.md        # Schema, migrations
   │   └─ deployment.md      # CI/CD, environments
   └─ [subdirs]/CLAUDE.md    # Optional, for monorepos

4. Report current vs ideal structure
5. TUI: "권장 구조로 재구성할까요?"
   IF yes:
   ├─ Create agent_docs/ directory
   ├─ Extract detailed content from CLAUDE.md
   ├─ Create focused sub-documents
   ├─ Slim down CLAUDE.md to essentials
   └─ Add references to agent_docs/
```

**Output (Korean):**
```markdown
## 📁 Progressive Disclosure 구조 분석

### 현재 상태
| 항목 | 상태 | 비고 |
|------|------|------|
| CLAUDE.md | 150줄 | ⚠️ 상세 내용 분리 필요 |
| agent_docs/ | ❌ 없음 | 생성 권장 |

### 권장 구조
```
project/
├─ CLAUDE.md (목표: <60줄)
└─ agent_docs/
    ├─ building.md
    ├─ testing.md
    └─ architecture.md
```

### 분리 대상 내용
| 현재 위치 | 이동 대상 | 예상 라인 |
|----------|----------|----------|
| ## 빌드 가이드 | agent_docs/building.md | 30줄 |
| ## 테스트 | agent_docs/testing.md | 25줄 |
```

### LINT

```
CHECKS (ordered by severity):

ERRORS (must fix):
├─ line_count > 300        → ❌ "지시사항 품질 저하 발생"
├─ missing WHAT section    → ❌ "기술 스택/구조 필수"
├─ missing HOW section     → ❌ "작업 방법 필수"
└─ auto_generated          → ❌ "/init 자동생성 금지"

WARNINGS (should fix):
├─ line_count > 150        → ⚠️ "분리 권장"
├─ has_code_style          → ⚠️ "린터/포매터로 분리"
├─ has_conditional         → ⚠️ "조건부 지시는 무시될 수 있음"
├─ has_inline_code > 10    → ⚠️ "file:line 참조 사용"
├─ missing WHY section     → ⚠️ "프로젝트 목적 추가"
└─ no_agent_docs           → ⚠️ "상세 문서 분리 권장"

INFO (consider):
├─ line_count > 60         → ℹ️ "이상적 수준 초과"
├─ missing_doc_refs        → ℹ️ "문서 참조 추가 고려"
└─ no_file_refs            → ℹ️ "file:line 형식 권장"
```

**Output (Korean):**
```markdown
## 📋 CLAUDE.md 품질 검사 결과

### ./CLAUDE.md (45줄)
✅ 모든 필수 검사 통과

### ./src/CLAUDE.md (320줄)
❌ **ERROR**: 라인 수 초과 (300줄 제한)
   → 지시사항 품질이 균등하게 저하됩니다
   → agent_docs/로 상세 내용 분리 필요

⚠️ **WARN**: 코드 스타일 섹션 포함
   → ESLint/Biome 설정 또는 hooks로 분리

⚠️ **WARN**: 조건부 지시사항 발견
   → Claude가 무시할 수 있음
   → 작업별 메시지로 전달 권장

### 요약
| 수준 | 개수 | 항목 |
|------|------|------|
| ❌ ERROR | 1 | 라인 초과 |
| ⚠️ WARN | 2 | 코드 스타일, 조건부 지시 |
| ℹ️ INFO | 0 | - |
```

---

## PHASE 3: Report Results

```
OUTPUT FORMAT (Korean):
├─ Summary table with principle compliance
├─ Detailed findings per file
├─ Specific recommendations with priority
├─ Actionable next steps
└─ Reference to best practices applied
```

---

## PHASE 4: Follow-up TUI (Required)

**Always show after action completes:**

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
| No CLAUDE.md found | "CLAUDE.md 파일을 찾을 수 없습니다. WHAT/WHY/HOW 프레임워크로 생성하시겠습니까?" |
| Permission denied | "파일 읽기/쓰기 권한이 없습니다: {path}" |
| Invalid action | "알 수 없는 작업입니다. 사용 가능: 분석, 생성, 구조화, 검사" |
| Path not found | "경로를 찾을 수 없습니다: {path}" + Glob으로 유사 경로 제안 |
| Over 300 lines | "⚠️ 300줄 초과 파일 발견 - 즉시 분리가 필요합니다" |
| Auto-generated detected | "⚠️ 자동 생성 파일 감지 - 수동 작성 권장" |

---

## BEST PRACTICES REFERENCE

```
CONTEXT WINDOW OPTIMIZATION:
├─ LLM performs best with focused, relevant context
├─ CLAUDE.md is at START of context (less impactful position)
├─ User messages are at END (more impactful position)
└─ Task-specific instructions → deliver via messages, not CLAUDE.md

WHAT TO INCLUDE:
├─ Project structure (always relevant)
├─ Tech stack (always relevant)
├─ Essential commands (always relevant)
├─ Package manager (always relevant)
└─ Verification process (always relevant)

WHAT TO EXCLUDE:
├─ Code style guidelines (use linter)
├─ All possible commands (only essentials)
├─ Database schemas (agent_docs/)
├─ Detailed architecture (agent_docs/)
├─ Conditional instructions (via messages)
└─ Code snippets (use file:line)
```

---

## EXECUTE NOW

1. Parse $ARGUMENTS → determine ACTION
2. IF empty → show TUI menu
3. Execute ACTION-specific logic (PHASE 2)
4. Validate output against 3 PRINCIPLES
5. Report results in Korean (PHASE 3)
6. **Show follow-up TUI** (PHASE 4) ← NEVER SKIP
