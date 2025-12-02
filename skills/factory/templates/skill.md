---
name: {{NAME}}
description: {{DESCRIPTION_ENGLISH}}
license: MIT
triggers:
{{TRIGGERS}}
---

# {{TITLE}}

{{SUMMARY_ENGLISH}}

---

## ROLE

```
WHEN {{ACTIVATION_CONDITION}}:
├─ {{ROLE_STEP1}}
├─ {{ROLE_STEP2}}
└─ {{ROLE_STEP3}}
```

---

## GUIDELINES

### Core Principles

```
PRINCIPLES:
├─ {{PRINCIPLE1_ENGLISH}}
├─ {{PRINCIPLE2_ENGLISH}}
└─ {{PRINCIPLE3_ENGLISH}}
```

### Execution Flow

```
FLOW:
├─ Phase 1: {{PHASE1_NAME}}
│   └─ {{PHASE1_DETAIL}}
├─ Phase 2: {{PHASE2_NAME}}
│   └─ {{PHASE2_DETAIL}}
└─ Phase 3: {{PHASE3_NAME}}
    └─ {{PHASE3_DETAIL}}
```

---

## TUI: User Interaction (Korean)

```
AskUserQuestion:
  question: "{{TUI_QUESTION_KOREAN}}"
  header: "{{TUI_HEADER_KOREAN}}"
  options:
    - label: "{{TUI_OPTION1_KOREAN}}"
      description: "{{TUI_DESC1_KOREAN}}"
```

---

## EXAMPLES

### Example 1

**Input**: {{EXAMPLE1_INPUT}}

**Output**: {{EXAMPLE1_OUTPUT}}

---

## CONSTRAINTS

```
LIMITATIONS:
├─ {{CONSTRAINT1}}
├─ {{CONSTRAINT2}}
└─ {{CONSTRAINT3}}
```

---

## ERROR HANDLING

| Error | Detection | Response |
|-------|-----------|----------|
| {{ERROR1}} | {{DETECTION1}} | "{{RESPONSE1_KOREAN}}" |
