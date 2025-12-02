---
name: inject-context
description: "Split-load large files with intelligent chunking and chain to Opus"
argument-hint: <file_path> [task_instruction]
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - SlashCommand
model: haiku
---

# 지능형 파일 컨텍스트 주입 (v2)

대용량 파일을 **구조 인식 청킹**으로 완전하게 로드하고, 사용자 선택에 따라 Opus 모델로 작업을 위임합니다.

**입력**: $ARGUMENTS

---

## 핵심 개선사항 (v2)

| 항목 | v1 | v2 |
|------|-----|-----|
| 청킹 방식 | 고정 800줄 | 구조 인식 (함수/클래스 경계) |
| 오버랩 | 없음 | 20줄 오버랩 (문맥 유지) |
| 컨텍스트 누락 | 가능 | 방지 (경계 보정) |
| 사용자 선택 | 자동 위임 | TUI 선택 메뉴 제공 |

---

## 제약 조건

| 항목 | 값 | 비고 |
|------|-----|------|
| Read 도구 한계 | ~25,000 토큰 | 하드 리밋 |
| 기본 청크 크기 | 600줄 | 안전 마진 확보 |
| 오버랩 크기 | 20줄 | 청크 간 문맥 연결 |
| 최대 청크 수 | 12개 | 컨텍스트 윈도우 고려 |
| 최소 청크 크기 | 50줄 | 과도한 분할 방지 |

---

## 실행 단계

### 1단계: 인자 파싱

```
FULL_ARGS = "$ARGUMENTS"

# 따옴표로 묶인 경로 처리
IF 따옴표 포함:
    FILE_PATH = 따옴표 내부 문자열
    TASK = 따옴표 이후 문자열
ELSE:
    FILE_PATH = 첫 번째 공백 전 토큰
    TASK = 나머지 토큰
END IF

IF TASK가 비어있으면:
    TASK = "파일 구조를 분석하고 핵심 로직을 설명하세요"
END IF
```

### 2단계: 파일 검증 및 메타데이터 수집

Bash 도구로 실행:
```bash
if [ ! -f "{FILE_PATH}" ]; then
    echo "ERROR: File not found: {FILE_PATH}"
    exit 1
fi

# 파일 정보 수집
echo "=== 파일 메타데이터 ==="
echo "경로: {FILE_PATH}"
wc -l < "{FILE_PATH}" | xargs -I{} echo "총 라인: {}줄"
file "{FILE_PATH}" | cut -d: -f2
ls -lh "{FILE_PATH}" | awk '{print "크기: "$5}'

# 파일 확장자
echo "확장자: ${FILE_PATH##*.}"
```

### 3단계: 구조 분석 (Structure Analysis)

파일 타입에 따라 **구조적 경계점** 탐지:

```bash
# 코드 파일의 구조적 경계점 찾기
# 결과: 함수/클래스/모듈 시작 라인 번호

FILE_EXT="${FILE_PATH##*.}"

case "$FILE_EXT" in
    py)
        # Python: class, def, import 블록
        grep -n "^class \|^def \|^from \|^import " "{FILE_PATH}" | head -50
        ;;
    ts|tsx|js|jsx)
        # TypeScript/JavaScript: export, class, function, interface
        grep -n "^export \|^class \|^function \|^interface \|^type \|^const.*= " "{FILE_PATH}" | head -50
        ;;
    go)
        # Go: package, func, type, import
        grep -n "^package \|^func \|^type \|^import " "{FILE_PATH}" | head -50
        ;;
    rs)
        # Rust: mod, fn, struct, impl, use
        grep -n "^pub \|^fn \|^struct \|^impl \|^use \|^mod " "{FILE_PATH}" | head -50
        ;;
    yaml|yml)
        # YAML: 최상위 키 (들여쓰기 없는 키)
        grep -n "^[a-zA-Z_-]*:" "{FILE_PATH}" | head -50
        ;;
    *)
        # 기타: 빈 줄 기준 섹션 분리
        grep -n "^$" "{FILE_PATH}" | head -50
        ;;
esac
```

### 4단계: 스마트 청킹 알고리즘

```
TOTAL_LINES = N (wc -l 결과)
BASE_CHUNK = 600
OVERLAP = 20
MAX_CHUNKS = 12

# 구조적 경계점 배열 (3단계 결과)
BOUNDARIES = [1, ...구조점들..., TOTAL_LINES]

# 청크 계획 생성
CHUNKS = []
current_start = 1

WHILE current_start < TOTAL_LINES:
    # 목표 끝점 계산
    target_end = current_start + BASE_CHUNK - 1

    IF target_end >= TOTAL_LINES:
        # 마지막 청크
        CHUNKS.append({start: current_start, end: TOTAL_LINES})
        BREAK
    END IF

    # 가장 가까운 구조적 경계점 찾기 (target_end 근처)
    best_boundary = find_nearest_boundary(BOUNDARIES, target_end, range=100)

    IF best_boundary exists:
        actual_end = best_boundary - 1  # 경계 직전까지
    ELSE:
        actual_end = target_end
    END IF

    # 청크 추가
    CHUNKS.append({start: current_start, end: actual_end})

    # 다음 청크 시작 (오버랩 적용)
    current_start = actual_end - OVERLAP + 1

    IF len(CHUNKS) >= MAX_CHUNKS:
        WARN "최대 청크 수 도달. 나머지는 요약 모드로 처리"
        BREAK
    END IF
END WHILE
```

### 5단계: 순차적 청크 로드

```
context_loaded = []

FOR i, chunk IN enumerate(CHUNKS):
    # 청크 헤더 출력
    PRINT "===== 청크 {i+1}/{len(CHUNKS)} [라인 {chunk.start}-{chunk.end}] ====="

    TRY:
        Read(file_path=FILE_PATH, offset=chunk.start, limit=chunk.end - chunk.start + 1)
        context_loaded.append(chunk)
    CATCH overflow:
        # 오버플로우 시 절반으로 분할
        mid = (chunk.start + chunk.end) // 2
        PRINT "⚠️ 청크 크기 초과. 분할 로드 중..."
        Read(file_path=FILE_PATH, offset=chunk.start, limit=mid - chunk.start + 1)
        Read(file_path=FILE_PATH, offset=mid + 1, limit=chunk.end - mid)
        context_loaded.append(chunk)
    END TRY

    PRINT ""  # 청크 간 구분
END FOR
```

### 6단계: 컨텍스트 완전성 검증

```
# 로드된 라인 수 계산
total_loaded = sum(chunk.end - chunk.start + 1 for chunk in context_loaded)
# 오버랩 제외한 실제 커버리지
unique_coverage = TOTAL_LINES 기준 실제 커버된 라인 수

IF unique_coverage < TOTAL_LINES * 0.95:
    WARN "⚠️ 파일의 {100 - unique_coverage/TOTAL_LINES*100:.1f}%가 로드되지 않았습니다"
    # 누락된 구간 추가 로드
END IF
```

### 7단계: 로드 완료 보고 및 사용자 선택

```markdown
╔═══════════════════════════════════════════════════════════════╗
║           📁 파일 컨텍스트 주입 완료                              ║
╠═══════════════════════════════════════════════════════════════╣
║ 파일: {FILE_PATH}                                              ║
║ 크기: {TOTAL_LINES}줄                                          ║
║ 청크: {len(CHUNKS)}개 (오버랩 {OVERLAP}줄)                      ║
║ 커버리지: {coverage}%                                          ║
║ 구조점: {len(BOUNDARIES)}개 탐지                               ║
╠═══════════════════════════════════════════════════════════════╣
║ 작업 지시: {TASK}                                              ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## 8단계: 사용자 선택 (TUI-like) - 필수!

**AskUserQuestion 도구**를 사용하여 다음 작업 선택:

```
AskUserQuestion(questions=[
    {
        "question": "컨텍스트 로딩이 완료되었습니다. 다음 작업을 선택하세요.",
        "header": "다음 작업",
        "options": [
            {
                "label": "Opus로 작업 위임",
                "description": "로드된 컨텍스트를 기반으로 '{TASK}' 작업을 Opus 모델에서 실행합니다"
            },
            {
                "label": "추가 파일 로드",
                "description": "관련 파일을 추가로 로드합니다 (inject-context 재실행)"
            },
            {
                "label": "작업 지시 변경",
                "description": "다른 작업 지시로 변경합니다"
            },
            {
                "label": "컨텍스트만 유지",
                "description": "자동 위임 없이 현재 컨텍스트를 유지합니다"
            }
        ],
        "multiSelect": false
    }
])
```

### 선택에 따른 후속 처리

```
SWITCH user_selection:
    CASE "Opus로 작업 위임":
        SlashCommand(command="/continue-task {TASK}")

    CASE "추가 파일 로드":
        AskUserQuestion으로 추가 파일 경로 입력받기
        → 해당 파일도 inject-context로 로드

    CASE "작업 지시 변경":
        AskUserQuestion으로 새 작업 지시 입력받기
        → 새 TASK로 /continue-task 호출

    CASE "컨텍스트만 유지":
        완료 메시지 출력 후 종료
        → 사용자가 직접 후속 명령 입력
END SWITCH
```

---

## 오류 처리

| 오류 | 대응 |
|------|------|
| 파일 없음 | 유사 파일명 검색 후 제안 |
| 권한 없음 | 권한 문제 안내 |
| 토큰 오버플로우 | 청크 크기 50% 감소 후 재시도 |
| 바이너리 파일 | 오류 메시지 출력 후 종료 |
| 구조점 탐지 실패 | 기본 고정 청킹으로 폴백 |

---

## 실행 (지금 수행)

1. $ARGUMENTS에서 FILE_PATH와 TASK 파싱
2. Bash로 파일 존재/크기/구조 분석
3. 스마트 청킹 계획 수립 (구조적 경계 기반)
4. 오버랩 적용하여 순차적 Read 호출
5. 컨텍스트 완전성 검증
6. 완료 보고서 출력
7. **AskUserQuestion으로 다음 작업 선택 받기**
8. 선택에 따라 SlashCommand 또는 추가 작업 수행

---

## 중요: 절대 생략 금지

- 구조 분석 (3단계) - 청킹 품질의 핵심
- 오버랩 적용 (4단계) - 문맥 연결 보장
- 사용자 선택 (8단계) - TUI 경험 제공

컨텍스트 누락 없이, 사용자가 다음 단계를 선택할 수 있어야 합니다.
