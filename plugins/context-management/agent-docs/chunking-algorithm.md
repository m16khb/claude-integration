# Chunking Algorithm

> 구조 인식 청킹 및 대용량 파일 처리 알고리즘

## Overview

inject-context 커맨드의 핵심인 구조 인식 청킹 알고리즘을 설명합니다.

```
CHUNKING PIPELINE:
┌─────────────────────────────────────────────────────────┐
│                    Large File                            │
│                  (1000+ lines)                           │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│               Language Detection                         │
│        (TypeScript, Python, Go, Rust, Java)             │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                  AST Parsing                             │
│            (함수, 클래스, 모듈 경계)                       │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Semantic Chunking                           │
│         (의미 단위 분할, 오버랩 추가)                      │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                Chunk Output                              │
│         [Chunk 1] [Chunk 2] [Chunk 3] ...               │
└─────────────────────────────────────────────────────────┘
```

---

## 청킹 설정

### 기본 설정

```yaml
chunking:
  # 청크 크기
  max_lines: 800         # 청크당 최대 라인 수
  overlap_lines: 20      # 청크 간 오버랩 라인

  # 구조 경계
  respect_boundaries: true
  boundary_types:
    - function
    - class
    - module
    - block

  # 언어별 설정
  language_specific:
    typescript:
      parser: "typescript-estree"
      boundaries: ["function", "class", "interface", "type"]
    python:
      parser: "ast"
      boundaries: ["def", "class", "async def"]
    go:
      parser: "go/ast"
      boundaries: ["func", "type", "interface"]
```

---

## 언어별 파싱

### TypeScript/JavaScript

```
TYPESCRIPT BOUNDARIES:
├─ 함수 정의
│   ├─ function declaration
│   ├─ arrow function (const fn = () => {})
│   └─ method definition
│
├─ 클래스 정의
│   ├─ class declaration
│   ├─ interface declaration
│   └─ type alias
│
├─ 모듈 구조
│   ├─ import statements (그룹화)
│   ├─ export statements
│   └─ namespace/module
│
└─ 데코레이터 블록
    ├─ @Controller, @Injectable 등
    └─ 데코레이터 + 클래스 함께 유지
```

### Python

```
PYTHON BOUNDARIES:
├─ 함수 정의
│   ├─ def function_name():
│   └─ async def function_name():
│
├─ 클래스 정의
│   ├─ class ClassName:
│   └─ dataclass, NamedTuple
│
├─ 모듈 구조
│   ├─ import statements
│   └─ from ... import ...
│
└─ 특수 블록
    ├─ if __name__ == "__main__":
    └─ contextmanager
```

### Go

```
GO BOUNDARIES:
├─ 함수 정의
│   ├─ func name()
│   └─ func (r *Receiver) name()
│
├─ 타입 정의
│   ├─ type Name struct
│   └─ type Name interface
│
└─ 패키지 구조
    ├─ package declaration
    └─ import block
```

---

## 청킹 알고리즘

### 1. 경계 탐지

```python
def detect_boundaries(source: str, language: str) -> List[Boundary]:
    """
    소스 코드에서 의미적 경계를 탐지합니다.
    """
    parser = get_parser(language)
    ast = parser.parse(source)

    boundaries = []
    for node in ast.walk():
        if is_boundary_node(node, language):
            boundaries.append(Boundary(
                start=node.start_line,
                end=node.end_line,
                type=node.type,
                name=node.name
            ))

    return boundaries
```

### 2. 청크 생성

```python
def create_chunks(
    source: str,
    boundaries: List[Boundary],
    max_lines: int = 800,
    overlap: int = 20
) -> List[Chunk]:
    """
    경계를 존중하며 청크를 생성합니다.
    """
    chunks = []
    current_chunk = ChunkBuilder()

    for line_num, line in enumerate(source.split('\n')):
        current_chunk.add_line(line)

        # 청크 크기 초과 시 경계에서 분할
        if current_chunk.line_count >= max_lines:
            # 가장 가까운 경계 찾기
            boundary = find_nearest_boundary(boundaries, line_num)

            if boundary:
                # 경계에서 분할
                chunk = current_chunk.split_at(boundary.end)
                chunks.append(chunk)

                # 오버랩 추가
                current_chunk.prepend_overlap(chunk, overlap)
            else:
                # 경계 없으면 강제 분할 (비권장)
                chunks.append(current_chunk.build())
                current_chunk = ChunkBuilder()

    # 마지막 청크 추가
    if current_chunk.line_count > 0:
        chunks.append(current_chunk.build())

    return chunks
```

### 3. 오버랩 처리

```
OVERLAP STRATEGY:
┌────────────────────┐
│     Chunk 1        │
│  ...               │
│  function foo() {  │ ← 경계
│    // 내용         │
│  }                 │
│  [OVERLAP START]   │ ← 오버랩 시작
│  function bar() {  │
│    // 내용 일부    │
└────────────────────┘
           │
           ▼
┌────────────────────┐
│  [OVERLAP]         │ ← 이전 청크에서 복사
│  function bar() {  │
│    // 내용 일부    │
│  [OVERLAP END]     │
│    // 내용 계속    │
│  }                 │
│     Chunk 2        │
│  ...               │
└────────────────────┘
```

---

## 특수 케이스 처리

### 중첩 구조

```typescript
// 중첩된 클래스/함수는 함께 유지
class OuterClass {
  // 전체가 하나의 청크로 유지 (1000줄 미만 시)
  innerMethod() {
    const innerFunction = () => {
      // ...
    };
  }
}
```

### 긴 함수

```
LONG FUNCTION HANDLING:
├─ 함수가 max_lines 초과 시
│   ├─ 내부 블록 (if, for, try) 경계에서 분할
│   ├─ 함수 시그니처는 각 청크에 포함 (컨텍스트 유지)
│   └─ 분할 지점에 주석 추가
│
└─ 예시:
    function veryLongFunction() {
      // === CHUNK 1 START ===
      // Part 1: 초기화
      ...
      // === CHUNK 1 END ===
    }
    // (continued in next chunk)
```

### 데코레이터/어노테이션

```typescript
// 데코레이터와 클래스/메서드는 항상 함께
@Controller('users')
@UseGuards(AuthGuard)
export class UserController {
  @Get()
  @ApiResponse({ status: 200 })
  async getUsers() {
    // 데코레이터 + 메서드 = 하나의 단위
  }
}
```

---

## 사용 예시

### inject-context 커맨드

```bash
# 기본 청킹으로 파일 로드
/context-management:inject-context src/app.module.ts

# 태스크와 함께 로드
/context-management:inject-context src/auth/ "인증 모듈 분석"

# 커스텀 청크 크기
/context-management:inject-context large-file.ts --max-lines 500
```

### 출력 형식

```
📄 src/app.module.ts (3 chunks)

━━━━━━━━━━ Chunk 1/3 (lines 1-800) ━━━━━━━━━━
[imports and module configuration]

━━━━━━━━━━ Chunk 2/3 (lines 780-1600) ━━━━━━━━━━
[providers and controllers setup]

━━━━━━━━━━ Chunk 3/3 (lines 1580-2100) ━━━━━━━━━━
[exports and module metadata]
```

---

## 성능 최적화

### 캐싱

```yaml
caching:
  enabled: true
  strategy: "content-hash"  # 파일 내용 해시 기반
  ttl: 3600                 # 1시간

  # 캐시 무효화 조건
  invalidate_on:
    - file_modified
    - config_changed
```

### 병렬 처리

```yaml
parallel:
  enabled: true
  max_workers: 4
  chunk_batch_size: 10
```

---

**관련 문서**: [CLAUDE.md](../CLAUDE.md) | [context-analysis.md](context-analysis.md) | [recovery-patterns.md](recovery-patterns.md)
