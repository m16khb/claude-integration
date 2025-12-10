---
name: context-management
description: '컨텍스트 관리 - 대용량 파일 처리, 작업 추천, 인지 부하 감소'
category: productivity
---

# context-management Plugin

대용량 코드베이스의 복잡성을 관리하고 개발 흐름을 최적화하는 지능형 컨텍스트 관리 시스템입니다.

## Core Philosophy

```
CONTEXT MANAGEMENT PIPELINE:
┌─────────────────────────────────────────────────────────┐
│  Large File → Language Detection → AST Parsing →       │
│  Semantic Chunking → Context Store → Relevance Scoring │
└─────────────────────────────────────────────────────────┘
```

- **정보 압축**: 대용량 파일을 의미 있는 청크로 분할
- **관계 추출**: 파일 간 의존성과 영향도 분석
- **스마트 필터링**: 현재 작업에 관련된 정보만 선택
- **진행 상태 추적**: 작업 컨텍스트와 상태 지속성 보장
- **인지 부하 최소화**: 개발자가 집중해야 할 것에만 집중

## Components

| 컴포넌트 | 타입 | 설명 |
|---------|------|------|
| @commands/continue-context.md | Command | 컨텍스트 분석 및 다음 작업 추천 |
| @commands/inject-context.md | Command | 대용량 파일 구조 인식 청킹 |

## continue-context Command

현재 작업 상태를 분석하고 다음 작업을 추천합니다:

```
CONTEXT ANALYSIS:
├─ Git 상태 분석
│   ├─ 현재 브랜치, 변경 파일
│   ├─ Staged/Unstaged 상태
│   └─ 최근 커밋 히스토리
│
├─ 파일 상태 분석
│   ├─ TODO/FIXME 주석 탐지
│   ├─ 미완료 코드 (빈 함수, 스텁)
│   └─ 타입/린트 에러
│
└─ 작업 추천
    ├─ CRITICAL: 빌드 에러, 실패한 테스트
    ├─ HIGH: 미완료 기능, 리뷰 피드백
    ├─ MEDIUM: TODO 처리, 테스트 작성
    └─ LOW: 코드 정리, 의존성 업데이트
```

### 사용법

```bash
# 전체 컨텍스트 분석
/context-management:continue-context

# 특정 영역 포커스
/context-management:continue-context auth
/context-management:continue-context "결제 모듈"
```

## inject-context Command

대용량 파일을 구조적으로 청킹하여 컨텍스트에 로드합니다:

### 청킹 설정

| 설정 | 기본값 | 설명 |
|------|-------|------|
| max_lines | 800 | 청크당 최대 라인 |
| overlap_lines | 20 | 청크 간 오버랩 |
| respect_boundaries | true | AST 경계 존중 |

### 언어별 AST 파싱

```
LANGUAGE SUPPORT:
├─ TypeScript/JavaScript
│   └─ function, class, interface, type, decorator
│
├─ Python
│   └─ def, class, async def, if __name__
│
├─ Go
│   └─ func, type struct, type interface
│
├─ Rust
│   └─ fn, struct, impl, trait
│
└─ Java
    └─ class, interface, method, annotation
```

### 사용법

```bash
# 기본 청킹으로 파일 로드
/context-management:inject-context src/app.module.ts

# 태스크와 함께 로드
/context-management:inject-context src/auth/ "인증 모듈 분석"
```

### 출력 형식

```
📄 src/app.module.ts (3 chunks)

━━━━━━━━━━ Chunk 1/3 (lines 1-800) ━━━━━━━━━━
[imports and module configuration]

━━━━━━━━━━ Chunk 2/3 (lines 780-1600) ━━━━━━━━━━
[providers and controllers setup]
```

## Recovery Patterns

세션 중단 시 작업 컨텍스트를 복구합니다:

```
RECOVERY WORKFLOW:
Session Interrupted → State Capture → Context Reconstruction → Resume Work
```

### 복구 시나리오

| 시나리오 | 복구 방법 |
|---------|----------|
| 기능 개발 중단 | 미완료 TODO/스텁 탐지 → 구현 재개 |
| 버그 수정 중단 | Stash 복원 → 테스트 실행 → 머지 |
| 리팩토링 중단 | 타입 에러 해결 → 테스트 수정 → 완료 |

### MCP Memory 연동

```bash
# 메모리와 함께 컨텍스트 복구
/context-management:continue-context --use-memory

# Sequential Thinking 연동
/context-management:continue-context --use-sequential-thinking
```

## Daily Workflow

```bash
# 1. 아침: 어제 작업 복구
/context-management:continue-context

# 2. 대용량 파일 작업 시
/context-management:inject-context src/feature.ts

# 3. 점심 전 체크포인트
git commit -m "WIP: feature 50%"

# 4. 오후 작업 재개
/context-management:continue-context

# 5. 퇴근 전 정리
git commit -m "WIP: feature 80% - TODO: 테스트"
```

## Structure

```
plugins/context-management/
├─ CLAUDE.md                    # 본 문서
├─ commands/
│   ├─ continue-context.md      # 컨텍스트 분석 커맨드
│   └─ inject-context.md        # 파일 청킹 커맨드
└─ agent-docs/                  # 상세 문서
    ├─ chunking-algorithm.md    # 청킹 알고리즘 상세
    ├─ context-analysis.md      # 분석 알고리즘 상세
    └─ recovery-patterns.md     # 복구 패턴 상세
```

## Best Practices

```
DO ✅:
├─ 세션 시작 시 /continue-context 실행
├─ 큰 작업은 작은 커밋으로 분할
├─ 중단 전 TODO 주석 추가
└─ 미완료 코드에 명확한 표시

DON'T ❌:
├─ 장시간 커밋 없이 작업
├─ 미완료 코드 주석 없이 방치
├─ Unstaged 변경사항 과다 누적
└─ 세션 종료 전 상태 정리 생략
```

## Documentation

- @agent-docs/chunking-algorithm.md - 구조 인식 청킹, 언어별 AST 파싱, 오버랩 처리
- @agent-docs/context-analysis.md - Git/파일/히스토리 분석, 패턴 인식, 작업 추천
- @agent-docs/recovery-patterns.md - 세션 복구, MCP Memory 연동, 체크포인트

@../CLAUDE.md
