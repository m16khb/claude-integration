---
name: {{NAME}}
description: '{{DESCRIPTION_ENGLISH}}'
model: {{MODEL}}
allowed-tools:
{{ALLOWED_TOOLS}}
---

# {{TITLE}}

## ROLE

```
SPECIALIZATION: {{DOMAIN}}

EXPERTISE:
├─ {{EXPERTISE1}}
├─ {{EXPERTISE2}}
└─ {{EXPERTISE3}}
```

---

## CAPABILITIES

```
CAN DO:
├─ {{CAPABILITY1}}
├─ {{CAPABILITY2}}
├─ {{CAPABILITY3}}
└─ {{CAPABILITY4}}
```

---

## CONSTRAINTS

```
LIMITATIONS:
├─ {{CONSTRAINT1}}
├─ {{CONSTRAINT2}}
├─ Single responsibility principle
└─ Must complete independently (no parent context dependency)
```

---

## INPUT FORMAT

```
EXPECTED INPUT:
├─ type: {{INPUT_TYPE}}
├─ required: {{REQUIRED_FIELDS}}
└─ optional: {{OPTIONAL_FIELDS}}

EXAMPLE:
{{INPUT_EXAMPLE}}
```

---

## OUTPUT FORMAT

```json
{
  "status": "success|error",
  "summary": "Brief result description in English",
  "details": {
    "{{DETAIL_KEY1}}": "{{DETAIL_VALUE1}}",
    "{{DETAIL_KEY2}}": "{{DETAIL_VALUE2}}"
  },
  "recommendations": [
    "{{RECOMMENDATION1}}",
    "{{RECOMMENDATION2}}"
  ],
  "metadata": {
    "tokens_used": 0,
    "execution_time_ms": 0
  }
}
```

---

## EXECUTION FLOW

```
SEQUENCE:
├─ Step 1: Input Validation
│   ├─ Check required fields
│   └─ Validate format
├─ Step 2: Core Analysis
│   ├─ {{ANALYSIS_STEP1}}
│   └─ {{ANALYSIS_STEP2}}
├─ Step 3: Result Generation
│   ├─ Structure output
│   └─ Add recommendations
└─ Step 4: Return JSON response
```

---

## ERROR HANDLING

```
ERROR RESPONSES:
├─ Invalid input → {"status": "error", "summary": "Invalid input: {reason}"}
├─ Tool failure → {"status": "error", "summary": "Tool execution failed: {tool}"}
└─ Timeout → {"status": "error", "summary": "Execution timeout"}
```

---

## EXAMPLES

### Example 1: {{EXAMPLE1_NAME}}

**Input**:
```
{{EXAMPLE1_INPUT}}
```

**Output**:
```json
{{EXAMPLE1_OUTPUT}}
```
