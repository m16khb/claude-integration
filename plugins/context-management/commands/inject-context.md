---
name: context-management:inject-context
description: '대용량 파일 구조 인식 청킹 및 컨텍스트 주입'
argument-hint: <file_path> [task_instruction]
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - mcp__st__sequentialthinking
  - mcp__mm__retrieve_memory
  - mcp__mm__search_by_tag
model: claude-opus-4-5-20251101
---

# Intelligent File Context Loader

## MISSION

대용량 파일을 **원문 그대로** 컨텍스트에 주입합니다.

**Input**: $ARGUMENTS

---

## CORE PRINCIPLES

```
├─ 원문 그대로 컨텍스트에 주입 (요약 아님)
├─ 구조적 경계 존중 청킹
├─ MCP Memory 연동 (선택적)
└─ 사용자 자유 작업 지원
```

---

## PHASE 1: Parse Arguments

```
PARSE $ARGUMENTS:
├─ FILE_PATH = 파일 경로
├─ TASK = 작업 지시 (선택)
└─ VALIDATE: 파일 존재 + 텍스트 파일 확인
```

---

## PHASE 2: File Analysis

```bash
ls -lh "{FILE_PATH}"
wc -l < "{FILE_PATH}"
file "{FILE_PATH}"
```

---

## PHASE 2.5: MCP Memory (Optional)

MCP memory-service 설치 시 관련 메모리 자동 로드:
- 파일 경로로 검색
- 모듈명으로 검색
- 없으면 조용히 스킵

---

## PHASE 3: Structure Detection

언어별 AST 경계 탐지:

```bash
case "$EXT" in
  py)    grep -n "^class \|^def " "{FILE_PATH}" ;;
  ts|js) grep -n "^export \|^class \|^function " "{FILE_PATH}" ;;
  go)    grep -n "^func \|^type " "{FILE_PATH}" ;;
  md)    grep -n "^# \|^## " "{FILE_PATH}" ;;
  *)     grep -n "^$" "{FILE_PATH}" ;;
esac | head -50
```

---

## PHASE 4: Chunking Strategy

| 설정 | 값 | 설명 |
|-----|---|------|
| Chunk size | 800줄 | 원문 보존 최대화 |
| Overlap | 20줄 | 컨텍스트 연속성 |
| Max chunks | 15 | 대용량 지원 |

```
ALGORITHM:
├─ 800줄 이하: 단일 청크
└─ 800줄 초과: 경계점 기준 분할 + 오버랩
```

---

## PHASE 5: Content Loading

```
FOR each chunk:
  PRINT "===== 📄 청크 {i}/{total} [라인 {start}-{end}] ====="
  Read(file_path, offset=start, limit=end-start+1)
END FOR
```

---

## PHASE 6: Completion Report

```
╔═══════════════════════════════════════════╗
║      📁 파일 컨텍스트 로딩 완료            ║
╠═══════════════════════════════════════════╣
║ 파일: {FILE_PATH}                          ║
║ 크기: {TOTAL_LINES}줄                      ║
║ 청크: {chunk_count}개                      ║
╠═══════════════════════════════════════════╣
║ 📌 원문 그대로 로드 완료                   ║
║ 자유롭게 작업을 진행하세요.                ║
╚═══════════════════════════════════════════╝
```

---

## PHASE 7: Optional Follow-up

```
IF TASK provided:
  AskUserQuestion:
    - 작업 진행
    - 추가 파일 로드
    - 다른 작업
    - 완료
ELSE:
  EXIT (사용자 자유 작업)
```

---

## ERROR HANDLING

| Error | Response |
|-------|----------|
| File not found | Glob으로 유사 파일 제안 |
| Binary file | "바이너리 지원 안 함" |
| Token overflow | 청크 크기 50% 감소 재시도 |
| Empty file | "빈 파일" 알림 |

---

## Documentation

상세 알고리즘은 agent-docs/ 참조:
- @../agent-docs/chunking-algorithm.md - 구조 인식 청킹, 언어별 AST 파싱
- @../agent-docs/context-analysis.md - 컨텍스트 분석, 작업 추천
- @../agent-docs/recovery-patterns.md - MCP Memory 연동, 세션 복구
