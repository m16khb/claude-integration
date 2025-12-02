---
name: {{NAME}}
description: '{{DESCRIPTION}}'
argument-hint: {{ARGUMENT_HINT}}
allowed-tools:
{{ALLOWED_TOOLS}}
model: {{MODEL}}
---

# {{TITLE}}

## MISSION

{{MISSION_ENGLISH}}

**Input**: $ARGUMENTS

---

## PHASE 1: {{PHASE1_NAME}}

```
{{PHASE1_LOGIC}}
```

---

## PHASE 2: {{PHASE2_NAME}}

```
{{PHASE2_LOGIC}}
```

---

## PHASE 3: {{PHASE3_NAME}}

```
{{PHASE3_LOGIC}}
```

---

## TUI: User Interaction

```
AskUserQuestion:
  question: "{{TUI_QUESTION_KOREAN}}"
  header: "{{TUI_HEADER_KOREAN}}"
  options:
    - label: "{{TUI_OPTION1_KOREAN}}"
      description: "{{TUI_DESC1_KOREAN}}"
    - label: "{{TUI_OPTION2_KOREAN}}"
      description: "{{TUI_DESC2_KOREAN}}"
```

---

## REPORT (Korean)

```markdown
## ✅ {{NAME}} 완료

| 항목 | 결과 |
|------|------|
| {{KEY1}} | {{VALUE1}} |
| {{KEY2}} | {{VALUE2}} |

### 다음 단계

- [ ] {{NEXT_STEP1}}
- [ ] {{NEXT_STEP2}}
```

---

## ERROR HANDLING

| Error | Detection | Response |
|-------|-----------|----------|
| {{ERROR1}} | {{DETECTION1}} | "{{RESPONSE1_KOREAN}}" |
| {{ERROR2}} | {{DETECTION2}} | "{{RESPONSE2_KOREAN}}" |

---

## EXECUTE NOW

```
1. {{STEP1_ENGLISH}}
2. {{STEP2_ENGLISH}}
3. {{STEP3_ENGLISH}}
4. REPORT in Korean
5. SHOW follow-up TUI
```
