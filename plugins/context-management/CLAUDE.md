---
name: context-management
description: '컨텍스트 관리 - 대용량 파일 처리, 작업 추천, 인지 부하 감소'
category: productivity
---

# context-management Plugin

대용량 코드베이스의 복잡성을 관리하고 개발 흐름을 최적화하는 지능형 컨텍스트 관리 시스템입니다.

## Core Philosophy

```
CONTEXT PIPELINE:
Large File → Language Detection → AST Parsing → Semantic Chunking → Context Store
```

- **정보 압축**: 대용량 파일을 의미 있는 청크로 분할
- **관계 추출**: 파일 간 의존성과 영향도 분석
- **스마트 필터링**: 현재 작업에 관련된 정보만 선택
- **인지 부하 최소화**: 개발자가 집중해야 할 것에만 집중

## Commands

| 커맨드 | 설명 |
|--------|------|
| `/context-management:continue-context` | 컨텍스트 분석 및 다음 작업 추천 |
| `/context-management:inject-context` | 대용량 파일 구조 인식 청킹 |

## continue-context Command

현재 작업 상태를 분석하고 다음 작업을 추천합니다:

```
CONTEXT ANALYSIS:
├─ Git: 브랜치, 변경 파일, Staged/Unstaged
├─ Files: TODO/FIXME, 미완료 코드, 에러
└─ Recommendations: CRITICAL → HIGH → MEDIUM → LOW
```

```bash
/context-management:continue-context
/context-management:continue-context auth    # 특정 영역 포커스
```

## inject-context Command

대용량 파일을 구조적으로 청킹하여 로드합니다:

| 설정 | 기본값 | 설명 |
|------|-------|------|
| max_lines | 800 | 청크당 최대 라인 |
| overlap_lines | 20 | 청크 간 오버랩 |
| respect_boundaries | true | AST 경계 존중 |

### 언어별 AST 파싱

```
├─ TypeScript: function, class, interface, decorator
├─ Python: def, class, async def
├─ Go: func, type struct, interface
└─ Rust/Java: 유사 패턴
```

```bash
/context-management:inject-context src/app.module.ts
/context-management:inject-context src/auth/ "인증 모듈 분석"
```

## Recovery Patterns

세션 중단 시 작업 컨텍스트를 복구합니다:

| 시나리오 | 복구 방법 |
|---------|----------|
| 기능 개발 중단 | 미완료 TODO/스텁 탐지 → 구현 재개 |
| 버그 수정 중단 | Stash 복원 → 테스트 → 머지 |
| 리팩토링 중단 | 타입 에러 해결 → 테스트 수정 |

## Daily Workflow

```bash
# 1. 아침: 어제 작업 복구
/context-management:continue-context

# 2. 대용량 파일 작업 시
/context-management:inject-context src/feature.ts

# 3. 점심 전 체크포인트
git commit -m "WIP: feature 50%"

# 4. 퇴근 전 정리
git commit -m "WIP: feature 80% - TODO: 테스트"
```

## Structure

```
plugins/context-management/
├─ CLAUDE.md
├─ commands/
│   ├─ continue-context.md
│   └─ inject-context.md
└─ agent-docs/
```

## Best Practices

```
DO ✅:
├─ 세션 시작 시 /continue-context 실행
├─ 큰 작업은 작은 커밋으로 분할
└─ 미완료 코드에 명확한 TODO 표시

DON'T ❌:
├─ 장시간 커밋 없이 작업
├─ 미완료 코드 주석 없이 방치
└─ Unstaged 변경사항 과다 누적
```

## Documentation (필요 시 Read 도구로 로드)

| 문서 | 설명 |
|------|------|
| `agent-docs/chunking-algorithm.md` | 구조 인식 청킹, 언어별 AST 파싱 |
| `agent-docs/context-analysis.md` | Git/파일/히스토리 분석, 작업 추천 |
| `agent-docs/recovery-patterns.md` | 세션 복구, MCP Memory 연동 |

[parent](../CLAUDE.md)
