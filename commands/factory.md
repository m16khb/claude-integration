---
name: factory
description: 'Agent, Skill, Command 컴포넌트 생성기'
argument-hint: '[type] [name]'
allowed-tools:
  - Read
  - Write
  - Glob
  - AskUserQuestion
  - Bash(mkdir *)
model: claude-opus-4-5-20251101
---

# Component Factory

## MISSION

Generate Claude Code components (agent, skill, command) following Anthropic 2025 schema and best practices.

**Input**: $ARGUMENTS

---

## PHASE 1: Parse Arguments

```
PARSE $ARGUMENTS:
├─ IF empty → show type selection TUI
├─ IF "command [name]" → type=command, extract name
├─ IF "skill [name]" → type=skill, extract name
├─ IF "agent [name]" → type=agent, extract name
└─ ELSE → show error, suggest valid formats

DEFAULTS:
├─ type: null (require selection)
├─ name: null (require input)
├─ location: "project" (.claude/)
└─ model: "default" (inherit user setting)
```

**TUI (when no args):**

```
AskUserQuestion:
  question: "어떤 유형의 컴포넌트를 만드시겠습니까?"
  header: "유형"
  options:
    - label: "Command"
      description: "/name으로 명시적 호출하는 슬래시 커맨드"
    - label: "Skill"
      description: "관련 작업 시 자동으로 활성화되는 스킬"
    - label: "Agent"
      description: "독립 컨텍스트에서 전문 작업 수행하는 에이전트"
```

---

## PHASE 2: Collect Basic Info

### 2.1 Name Collection

```
IF name not provided:
  AskUserQuestion:
    question: "컴포넌트 이름을 입력하세요 (예: code-review, tdd-guide)"
    header: "이름"
    options:
      - label: "직접 입력"
        description: "kebab-case 형식 권장"

VALIDATE name:
├─ Must be kebab-case (lowercase, hyphens)
├─ No spaces or special characters
├─ 3-30 characters length
└─ IF invalid → show error, ask again
```

### 2.2 Purpose Collection

```
AskUserQuestion:
  question: "이 컴포넌트의 주요 목적은 무엇인가요?"
  header: "목적"
  options:
    - label: "직접 입력"
      description: "예: 코드 리뷰 자동화, TDD 사이클 안내"
```

---

## PHASE 3: Advanced Settings

### 3.1 Installation Location

```
AskUserQuestion:
  question: "설치 위치를 선택하세요"
  header: "위치"
  options:
    - label: "프로젝트"
      description: ".claude/ 디렉토리 (팀과 공유)"
    - label: "사용자"
      description: "~/.claude/ 디렉토리 (개인용)"
    - label: "플러그인"
      description: "현재 플러그인 디렉토리 (배포용)"

LOCATION_MAP:
├─ "프로젝트" → base_path = ".claude"
├─ "사용자" → base_path = "~/.claude"
└─ "플러그인" → base_path = "."
```

### 3.2 Model Selection (Command/Agent only)

```
IF type IN ["command", "agent"]:
  AskUserQuestion:
    question: "사용할 모델을 선택하세요"
    header: "모델"
    options:
      - label: "기본값"
        description: "사용자 설정 모델 사용"
      - label: "Opus"
        description: "복잡한 분석/생성 작업"
      - label: "Sonnet"
        description: "균형잡힌 성능"
      - label: "Haiku"
        description: "빠른 응답, 간단한 작업"

MODEL_MAP:
├─ "기본값" → omit model field
├─ "Opus" → model: claude-opus-4-5-20251101
├─ "Sonnet" → model: claude-sonnet-4-20250514
└─ "Haiku" → model: claude-haiku-4-20250414
```

### 3.3 Tool Selection (Command/Agent only)

```
IF type IN ["command", "agent"]:
  AskUserQuestion:
    question: "필요한 도구를 선택하세요"
    header: "도구"
    multiSelect: true
    options:
      - label: "Read"
        description: "파일 읽기"
      - label: "Write"
        description: "파일 쓰기"
      - label: "Grep/Glob"
        description: "코드 검색"
      - label: "Bash"
        description: "명령어 실행"

TOOL_MAP:
├─ "Read" → "Read"
├─ "Write" → "Write"
├─ "Grep/Glob" → "Grep", "Glob"
└─ "Bash" → "Bash(*)"
```

---

## PHASE 4: Find Templates

```
SEARCH template files:
├─ Glob: ~/.claude/plugins/**/templates/*.template
├─ Glob: ./templates/*.template
└─ IF not found → use inline default templates

TEMPLATE_MAP:
├─ command → command.md.template
├─ skill → skill.md.template
└─ agent → agent.md.template
```

---

## PHASE 5: Generate Content

### 5.1 Build Output Path

```
PATH_RULES:
├─ command → {base_path}/commands/{name}.md
├─ skill → {base_path}/skills/{name}/SKILL.md
└─ agent → {base_path}/agents/{name}.md

CHECK path exists:
├─ IF exists → show overwrite confirmation TUI
└─ IF not exists → proceed
```

### 5.2 Generate File Content

```
FOR type = "command":
  GENERATE with:
  ├─ frontmatter: name, description, allowed-tools, model
  ├─ MISSION: purpose in English
  ├─ PHASES: English logic with tree notation
  ├─ TUI sections: Korean labels
  ├─ ERROR HANDLING: table format
  └─ EXECUTE NOW: action summary

FOR type = "skill":
  GENERATE with:
  ├─ frontmatter: name, description, license, triggers
  ├─ triggers: extract keywords from purpose
  │   └─ Split Korean/English, add variations
  ├─ ROLE: English description
  ├─ GUIDELINES: English instructions
  └─ EXAMPLES: input/output samples

FOR type = "agent":
  GENERATE with:
  ├─ frontmatter: name, description, model, allowed-tools
  ├─ ROLE: specialization area
  ├─ CAPABILITIES: task list
  ├─ CONSTRAINTS: limitations
  └─ OUTPUT FORMAT: JSON schema
```

---

## PHASE 6: Write Files

```
ACTIONS:
1. Bash: mkdir -p {directory_path}
2. Write: {output_path} with generated content
3. IF location = "플러그인":
   └─ Update plugin.json (add to commands/skills)

VERIFY:
├─ File created successfully
└─ Content matches expected structure
```

---

## PHASE 7: Report (Korean)

```markdown
## ✅ 컴포넌트 생성 완료

| 항목 | 값      |
| ---- | ------- |
| 유형 | {type}  |
| 이름 | {name}  |
| 경로 | {path}  |
| 모델 | {model} |

### 생성된 파일

`{path}`

### 사용 방법

**Command인 경우:**
```

/{name} [args]

```

**Skill인 경우:**
관련 작업 요청 시 자동 활성화됩니다.
트리거 키워드: {triggers}

**Agent인 경우:**
Task tool에서 subagent_type으로 호출됩니다.

### 다음 단계

- [ ] 생성된 파일 내용 검토 및 수정
- [ ] 테스트 실행
- [ ] (플러그인인 경우) plugin.json에 등록
```

---

## PHASE 8: Follow-up TUI

```
AskUserQuestion:
  question: "다음 작업을 선택하세요"
  header: "다음"
  options:
    - label: "파일 열기"
      description: "생성된 파일 내용 확인"
    - label: "다른 컴포넌트 생성"
      description: "factory 재실행"
    - label: "plugin.json 업데이트"
      description: "플러그인 설정에 등록"
    - label: "완료"
      description: "작업 종료"
```

---

## ERROR HANDLING

| Error                    | Detection                           | Response                                                      |
| ------------------------ | ----------------------------------- | ------------------------------------------------------------- |
| Invalid type             | type NOT IN [command, skill, agent] | "유효한 유형: command, skill, agent"                          |
| Invalid name             | regex test fails                    | "이름은 kebab-case 형식이어야 합니다 (예: my-command)"        |
| Template not found       | Glob returns empty                  | Use inline default template                                   |
| Path exists              | file already exists                 | Show overwrite confirmation TUI                               |
| Permission denied        | Write fails                         | "권한 오류: {path}에 쓸 수 없습니다. 다른 위치를 선택하세요." |
| Directory creation fails | mkdir fails                         | "디렉토리 생성 실패: {error}"                                 |
| plugin.json parse error  | JSON.parse fails                    | "plugin.json 파싱 오류. 수동으로 수정하세요."                 |

---

## EXECUTE NOW

```
1. PARSE $ARGUMENTS → extract type, name
2. IF missing info → AskUserQuestion (Korean)
3. COLLECT location, model, tools via TUI
4. GLOB find template files
5. READ template OR use inline default
6. GENERATE content following type-specific rules
7. BASH mkdir -p {directory}
8. WRITE component file
9. REPORT completion (Korean)
10. SHOW follow-up TUI (Korean)
```
