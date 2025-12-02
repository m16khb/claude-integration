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
  - Task
model: opus
---

# CLAUDE.md Management Tool

**Input**: $ARGUMENTS

---

## Step 1: Action Selection (TUI)

**Show TUI if no arguments provided**:

```
IF "$ARGUMENTS" is empty or whitespace only:
    → Show TUI menu (AskUserQuestion)
ELSE:
    → Parse args and execute action directly
END IF
```

### TUI Menu (required when no args)

```
AskUserQuestion(questions=[
    {
        "question": "CLAUDE.md 관리 작업을 선택하세요",
        "header": "작업",
        "options": [
            {"label": "분석", "description": "기존 CLAUDE.md 품질 분석 및 개선점 제안"},
            {"label": "생성", "description": "새 디렉토리에 CLAUDE.md 생성"},
            {"label": "구조화", "description": "루트 ↔ 하위 CLAUDE.md 레퍼런스 연결"},
            {"label": "검사", "description": "CLAUDE.md 품질 검사 (라인 수, 구조)"}
        ],
        "multiSelect": false
    }
])
```

---

## Step 2: Execute by Action Type

### Analyze

1. **Find CLAUDE.md files**
   ```bash
   find . -name "CLAUDE.md" -type f 2>/dev/null | head -20
   ```

2. **Analyze each file**
   - Line count (ideal: 60+, max: <300)
   - Check WHAT/WHY/HOW sections
   - Check code style guide inclusion (warn if exists)

3. **Output result**
   ```markdown
   ## CLAUDE.md 분석 결과

   | 파일            | 라인 | 상태 | 비고 |
   | --------------- | ---- | ---- | ---- |
   | ./CLAUDE.md     | 58   | ✅   | 양호 |
   | ./k3s/CLAUDE.md | 90   | ✅   | 양호 |
   ```

---

### Generate

1. **Target path TUI**
   ```
   AskUserQuestion: "CLAUDE.md를 생성할 디렉토리 경로를 입력하세요"
   Options: detected subdirectories + Other
   ```

2. **Analyze directory**
   ```bash
   find {TARGET} -maxdepth 2 -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.sh" -o -name "*.yaml" \) | head -30
   ls {TARGET}/README.md {TARGET}/CLAUDE.md 2>/dev/null
   ```

3. **Purpose selection TUI**
   ```
   AskUserQuestion: "이 디렉토리의 주요 목적은?"
   Options: [서비스/앱, 라이브러리, 인프라/설정, 스크립트/도구]
   ```

4. **Generate CLAUDE.md** (use purpose-specific template)

5. **Add root reference TUI**
   ```
   AskUserQuestion: "루트 CLAUDE.md에 레퍼런스를 추가할까요?"
   ```

---

### Structure

1. **Scan current CLAUDE.md structure**
   ```bash
   find . -name "CLAUDE.md" -type f 2>/dev/null
   ```

2. **Analyze reference status**
   ```markdown
   ## 현재 구조

   | 하위 문서              | 루트에서 참조 |
   | ---------------------- | ------------- |
   | k3s/CLAUDE.md          | ✅            |
   | packages/cli/CLAUDE.md | ❌ 누락       |
   ```

3. **Action TUI**
   ```
   AskUserQuestion: "누락된 레퍼런스를 추가할까요?"
   ```

---

### Lint

**Check items**:

| Item | Criteria | Severity |
|------|----------|----------|
| Line count | >300 | ❌ Error |
| Line count | >150 | ⚠️ Warning |
| Code style guide | included | ⚠️ Warning |
| Tech stack section | missing | ❌ Error |
| Commands section | missing | ⚠️ Warning |

**Output**:
```
📋 CLAUDE.md Lint 결과

./CLAUDE.md (58줄)
  ✅ 모든 검사 통과

./k3s/CLAUDE.md (90줄)
  ✅ 모든 검사 통과
```

---

## Step 3: Follow-up TUI

After all tasks complete:

```
AskUserQuestion(questions=[
    {
        "question": "다음 작업을 선택하세요",
        "header": "후속",
        "options": [
            {"label": "변경 적용", "description": "제안된 내용을 파일에 적용"},
            {"label": "다른 작업", "description": "다른 CLAUDE.md 작업 선택"},
            {"label": "완료", "description": "작업 종료"}
        ],
        "multiSelect": false
    }
])
```

---

## CLAUDE.md Writing Principles

| Principle | Description |
|-----------|-------------|
| **Concise** | Ideal 60+ lines, max <300 |
| **Universal** | Only content applicable to all tasks |
| **Progressive** | Detailed content in sub-documents |

### Include (WHAT/WHY/HOW)
- Tech stack, key commands, project structure, core rules

### Exclude
- Code style → ESLint/Biome
- DB schema → separate docs
- API list → OpenAPI

---

## Execute (now)

1. Check "$ARGUMENTS"
2. **IF empty → show TUI menu** (required!)
3. Execute logic based on action selection
4. Provide follow-up TUI after completion
