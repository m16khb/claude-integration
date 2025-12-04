---
name: optimize-command
description: '프롬프트 엔지니어링 원칙으로 커맨드 최적화 (MCP 통합)'
argument-hint: <command-file-path>
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - AskUserQuestion
  - Task
  - mcp__sequential-thinking__sequentialthinking
  - mcp__context7__resolve-library-id
  - mcp__context7__get-library-docs
model: claude-opus-4-5-20251101
---

# Command Optimizer with MCP Integration

## MISSION

Optimize Claude Code commands using prompt engineering best practices and real-time documentation.
Leverage Context7 for latest patterns and Sequential-Thinking for systematic optimization.

**Input**: $ARGUMENTS

---

## CORE OPTIMIZATION PRINCIPLES

```
PRINCIPLE PRIORITY: Accuracy > Efficiency > UX

1. PURPOSE ACCURACY (🔴)
   - Clear mission statement
   - Complete execution flow
   - All edge cases covered
   - Explicit error handling

2. ENGLISH LOGIC (🟡)
   - Token-efficient algorithms
   - Clear technical specs
   - Structured documentation

3. KOREAN TUI (🟢)
   - Intuitive user interface
   - Clear error messages
   - Helpful completion feedback
```

---

## COMMAND OPTIMIZATION PATTERNS

### Structure Template
```yaml
---
frontmatter with tools + model
---

# Command Title

## MISSION
{Clear purpose in English}

## PHASE 1-N
{Sequential steps in English}

## TUI
{AskUserQuestion in Korean}

## ERROR HANDLING
{Table format}

## EXECUTE NOW
{Action summary}
```

---

## OPTIMIZATION WORKFLOW

### Step 1: Load Command
```
PARSE $ARGUMENTS:
├─ Direct path → use
├─ Filename only → search in .claude/commands/
└─ Empty → interactive selection

VALIDATE file exists and .md format
```

### Step 2: Dynamic Analysis with MCP
```
SEQUENTIAL-THINKING:
├─ Parse command structure
├─ Identify violations of 3 principles
├─ Calculate optimization opportunities
└─ Generate improvement strategy

CONTEXT7 INTEGRATION:
├─ Fetch latest command patterns
├─ Compare with current implementation
├─ Identify outdated practices
└─ Suggest modern alternatives
```

### Step 3: Optimization Analysis
```
CHECKLIST:
├─ MISSION clarity and specificity
├─ PHASE structure completeness
├─ Error handling coverage
├─ Token efficiency opportunities
├─ TUI user experience quality
└─ Best practices alignment
```

---

## Step 4: Report Generation

```markdown
## 📊 커맨드 최적화 분석

### 기본 정보
| 파일 | 라인 | 모델 | 토큰 |
|------|------|------|------|
| {path} | {lines} | {model} | {tokens} |

### 3원칙 준수도 평가
| 원칙 | 현재 상태 | 개선안 |
|------|----------|--------|
| 목적 정확성 | {current}% | {target}% |
| 영어 로직 | {current}% | {target}% |
| 한국어 TUI | {current}% | {target}% |

### MCP 기반 최적화 제안
- 최신 패턴 적용: {count}건
- 토큰 절감: {tokens} → {optimized}
- 사용자 경험 개선: {improvements}
```

---

## Step 5: Interactive Optimization

```
AskUserQuestion:
  question: "최적화를 진행할까요?"
  header: "최적화 선택"
  options:
    - label: "전체 자동 최적화"
      description: "MCP 분석 기반으로 전체 개선"
    - label: "단계별 최적화"
      description: "각 섹션별로 확인하며 적용"
    - label: "제안사항만 보기"
      description: "상세 분석 결과만 확인"
```

---

## Step 6: Apply Optimization

```python
# Command optimization template
optimized_command = f"""---
{frontmatter}
---

# {name}

## MISSION

{clear_english_mission}

## PHASE 1-N

{sequential_phases}

## TUI

{korean_ui_elements}

## ERROR HANDLING

{error_table}

## EXECUTE NOW

{execution_summary}
"""
```

---

## QUALITY VALIDATION

| Check | Pass Criteria | Status |
|-------|---------------|--------|
| Mission | Clear, measurable | ✅/❌ |
| Logic | English, efficient | ✅/❌ |
| TUI | Korean, intuitive | ✅/❌ |
| MCP Sync | Latest patterns | ✅/❌ |

---

## EXECUTION FLOW

1. Parse command path from $ARGUMENTS
2. Sequential-Thinking: Structure analysis
3. Context7: Latest patterns fetch
4. Generate optimization report
5. User approval via AskUserQuestion
6. Apply optimizations with Write()
7. Validate against 3 principles
8. Offer follow-up actions

```
