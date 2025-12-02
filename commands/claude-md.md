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

# CLAUDE.md 관리 도구

**입력**: $ARGUMENTS

---

## 1단계: 작업 선택 (TUI)

**인자가 없으면 TUI로 작업 선택**:

```
IF "$ARGUMENTS"가 비어있거나 공백만 있으면:
    → TUI 메뉴 표시 (AskUserQuestion)
ELSE:
    → 인자 파싱 후 해당 작업 바로 실행
END IF
```

### TUI 메뉴 (인자 없을 때 필수 호출)

```
AskUserQuestion(questions=[
    {
        "question": "CLAUDE.md 관리 작업을 선택하세요",
        "header": "작업",
        "options": [
            {
                "label": "분석",
                "description": "기존 CLAUDE.md 품질 분석 및 개선점 제안"
            },
            {
                "label": "생성",
                "description": "새 디렉토리에 CLAUDE.md 생성"
            },
            {
                "label": "구조화",
                "description": "루트 ↔ 하위 CLAUDE.md 레퍼런스 연결"
            },
            {
                "label": "검사",
                "description": "CLAUDE.md 품질 검사 (라인 수, 구조)"
            }
        ],
        "multiSelect": false
    }
])
```

---

## 2단계: 작업별 실행

### 분석 (analyze)

1. **CLAUDE.md 파일 탐색**

   ```bash
   find . -name "CLAUDE.md" -type f 2>/dev/null | head -20
   ```

2. **각 파일 분석**

   - 라인 수 (60줄 이상적, 300줄 미만)
   - WHAT/WHY/HOW 섹션 존재 여부
   - 코드 스타일 가이드 포함 여부 (경고)

3. **분석 결과 출력**

   ```markdown
   ## CLAUDE.md 분석 결과

   | 파일            | 라인 | 상태 | 비고 |
   | --------------- | ---- | ---- | ---- |
   | ./CLAUDE.md     | 58   | ✅   | 양호 |
   | ./k3s/CLAUDE.md | 90   | ✅   | 양호 |
   ```

---

### 생성 (generate)

1. **대상 경로 TUI**

   ```
   AskUserQuestion: "CLAUDE.md를 생성할 디렉토리 경로를 입력하세요"
   옵션: 탐지된 하위 디렉토리 목록 + Other
   ```

2. **디렉토리 분석**

   ```bash
   find {TARGET} -maxdepth 2 -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.sh" -o -name "*.yaml" \) | head -30
   ls {TARGET}/README.md {TARGET}/CLAUDE.md 2>/dev/null
   ```

3. **목적 선택 TUI**

   ```
   AskUserQuestion: "이 디렉토리의 주요 목적은?"
   옵션: [서비스/앱, 라이브러리, 인프라/설정, 스크립트/도구]
   ```

4. **CLAUDE.md 생성** (목적별 템플릿)

5. **루트 레퍼런스 추가 TUI**
   ```
   AskUserQuestion: "루트 CLAUDE.md에 레퍼런스를 추가할까요?"
   ```

---

### 구조화 (structure)

1. **현재 CLAUDE.md 구조 파악**

   ```bash
   find . -name "CLAUDE.md" -type f 2>/dev/null
   ```

2. **레퍼런스 상태 분석**

   ```markdown
   ## 현재 구조

   | 하위 문서              | 루트에서 참조 |
   | ---------------------- | ------------- |
   | k3s/CLAUDE.md          | ✅            |
   | packages/cli/CLAUDE.md | ❌ 누락       |
   ```

3. **작업 TUI**
   ```
   AskUserQuestion: "누락된 레퍼런스를 추가할까요?"
   ```

---

### 검사 (lint)

**검사 항목**:

| 항목               | 기준    | 심각도     |
| ------------------ | ------- | ---------- |
| 라인 수            | >300줄  | ❌ Error   |
| 라인 수            | >150줄  | ⚠️ Warning |
| 코드 스타일 가이드 | 포함 시 | ⚠️ Warning |
| 기술 스택 섹션     | 없으면  | ❌ Error   |
| 명령어 섹션        | 없으면  | ⚠️ Warning |

**출력**:

```
📋 CLAUDE.md Lint 결과

./CLAUDE.md (58줄)
  ✅ 모든 검사 통과

./k3s/CLAUDE.md (90줄)
  ✅ 모든 검사 통과
```

---

## 3단계: 후속 작업 TUI

모든 작업 완료 후:

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

## CLAUDE.md 작성 원칙

| 원칙            | 설명                         |
| --------------- | ---------------------------- |
| **간결함**      | 60줄 이상적, 300줄 미만      |
| **보편성**      | 모든 작업에 해당하는 내용만  |
| **점진적 공개** | 상세 내용은 하위 문서로 분리 |

### 포함 (WHAT/WHY/HOW)

- 기술 스택, 주요 명령어, 프로젝트 구조, 핵심 규칙

### 제외

- 코드 스타일 → ESLint/Biome
- DB 스키마 → 별도 문서
- API 목록 → OpenAPI

---

## 실행 (지금 수행)

1. "$ARGUMENTS" 확인
2. **비어있으면 → TUI 메뉴 표시** (필수!)
3. 작업 선택에 따라 해당 로직 실행
4. 완료 후 후속 작업 TUI 제공
