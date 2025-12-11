# Project Constitution (프로젝트 헌법)

Claude가 **반드시** 따라야 하는 최우선 규칙 모음입니다.

## 규칙 목록

| # | 규칙명 | 우선순위 | 설명 |
|---|--------|----------|------|
| 1 | [플러그인 버전 관리](#1-플러그인-버전-관리-semantic-versioning) | 2 | Semantic Versioning 준수 |
| 2 | [파일 레퍼런싱 @ 문법](#2-파일-레퍼런싱--문법) | 2 | 모든 파일 참조 시 @ 문법 사용 |
| 3 | [CLAUDE.md 라인 제한](#3-claudemd-라인-제한-progressive-disclosure) | 3 | Root 300라인, Module 200라인 이하 |
| 4 | [agent-docs 동적 로딩](#4-agent-docs-동적-로딩) | 2 | agent-docs는 필요 시에만 로드 |

---

## 1. 플러그인 버전 관리 (Semantic Versioning)

### 개요

플러그인 변경 시 **반드시** 아래 규칙에 따라 `plugin.json`의 버전을 업데이트해야 합니다.

### 버전 규칙

| 변경 유형 | 버전 증가 | 설명 | 예시 |
|----------|----------|------|------|
| **MAJOR** | X.0.0 | 호환성 깨지는 변경 | 1.0.0 → 2.0.0 |
| **MINOR** | 0.X.0 | 하위 호환 새 기능 | 1.0.0 → 1.1.0 |
| **PATCH** | 0.0.X | 버그/문서 수정 | 1.0.0 → 1.0.1 |

### 변경 유형별 상세

```
MAJOR (호환성 파괴):
├─ API 시그니처 변경
├─ 커맨드 삭제 또는 이름 변경
├─ 에이전트 인터페이스 변경
└─ 필수 설정 추가

MINOR (기능 추가):
├─ 새 커맨드 추가
├─ 새 에이전트 추가
├─ 새 스킬 추가
└─ 선택적 기능 추가

PATCH (수정):
├─ 버그 수정
├─ 오타 수정
├─ 문서 업데이트
└─ 성능 개선
```

### 체크리스트

플러그인 변경 전 확인사항:

- [ ] 변경 유형 파악 (MAJOR/MINOR/PATCH)
- [ ] plugin.json 버전 업데이트
- [ ] CHANGELOG 작성 (선택)
- [ ] 테스트 실행

### 예시

```bash
# 새 커맨드 추가 시 (MINOR)
# plugin.json: "version": "1.0.0" → "version": "1.1.0"

# 버그 수정 시 (PATCH)
# plugin.json: "version": "1.1.0" → "version": "1.1.1"

# API 변경 시 (MAJOR)
# plugin.json: "version": "1.1.1" → "version": "2.0.0"
```

---

## 2. 파일 레퍼런싱 @ 문법

### 개요

모든 파일 참조 시 **반드시** `@` 문법을 사용해야 합니다. 이는 Claude Code의 파일 참조 표준이며, 일관성 있는 문서 작성을 보장합니다.

### 문법 규칙

| 문법 | 설명 | 예시 |
|------|------|------|
| `@파일경로` | 파일 전체 참조 | `@src/app.module.ts` |
| `@파일경로:라인` | 특정 라인 참조 | `@src/app.ts:42` |
| `@파일경로:시작-끝` | 라인 범위 참조 | `@src/app.ts:10-20` |
| `@디렉토리/` | 디렉토리 참조 | `@plugins/` |

### 적용 범위

```
@ 문법 필수 사용 위치:
├─ 코드 리뷰 시 파일 위치 표기
├─ 에러 발생 위치 안내
├─ 커맨드/스킬/에이전트 정의 내 소스코드 참조
└─ agent-docs 내부에서 다른 agent-docs 파일 참조

⚠️ 예외 (@ 사용 금지):
├─ CLAUDE.md에서 agent-docs 참조 시 → 일반 링크 사용
└─ 이유: @ 참조는 파일 내용을 자동 로드하여 토큰 낭비
```

### 체크리스트

- [ ] 파일 참조 시 @ 접두사 사용
- [ ] 상대 경로가 아닌 프로젝트 루트 기준 경로 사용
- [ ] 디렉토리는 `/`로 끝나기

### 예시

```markdown
# 좋은 예
@plugins/code-quality/agents/code-reviewer.md 참조
@src/main.ts:15 에서 에러 발생
자세한 내용은 @agent-docs/architecture.md 확인

# 나쁜 예
plugins/code-quality/agents/code-reviewer.md 참조
src/main.ts 15번째 줄에서 에러 발생
자세한 내용은 agent-docs/architecture.md 확인
```

---

## 우선순위 레벨

| 레벨 | 설명 | 예시 |
|------|------|------|
| 1 | 보안 관련 | 인증, 권한, 데이터 보호 |
| 2 | 버전/호환성 | Semantic Versioning |
| 3 | 코드 품질 | 테스트 커버리지, 린트 |
| 4 | 워크플로우 | 커밋 컨벤션, 브랜치 전략 |

---

## 3. CLAUDE.md 라인 제한 (Progressive Disclosure)

### 개요

모든 CLAUDE.md 파일은 **반드시** 라인 제한을 준수해야 합니다. 초과 시 agent-docs/로 분리하여 계층적 문서 구조를 유지합니다.

### 라인 제한 규칙

| 레벨 | Soft Limit | Hard Limit | 설명 |
|------|-----------|------------|------|
| **Root** | 300 | 500 | 프로젝트 루트 CLAUDE.md |
| **Module** | 200 | 350 | 플러그인/모듈 CLAUDE.md |
| **Submodule** | 150 | 250 | 세부 컴포넌트 CLAUDE.md |

- **Soft Limit**: 경고 표시, agent-docs 분할 **권장**
- **Hard Limit**: 강제 분할 **필수**, agent-docs 생성 필수

### 초과 시 처리

```
Soft Limit 초과 시:
├─ 경고 표시
├─ agent-docs 분할 권장
└─ 사용자 선택에 따라 진행

Hard Limit 초과 시:
├─ 상세 내용을 agent-docs/로 분리 필수
├─ CLAUDE.md에는 요약과 링크만 유지
├─ @ 문법으로 상세 문서 참조
└─ 예: @agent-docs/detailed-guide.md
```

### 체크리스트

- [ ] Root CLAUDE.md가 Soft 300라인 이하인가? (권장)
- [ ] Root CLAUDE.md가 Hard 500라인 이하인가? (필수)
- [ ] Module CLAUDE.md가 Soft 200라인 이하인가? (권장)
- [ ] Module CLAUDE.md가 Hard 350라인 이하인가? (필수)
- [ ] 초과 내용이 agent-docs/로 분리되었는가?
- [ ] 분리된 문서가 @ 문법으로 참조되었는가?

### 예시

```markdown
# 좋은 예 (Module CLAUDE.md - 180라인)
# Module Name

간결한 개요

## 핵심 기능
- 기능 1
- 기능 2

## 상세 문서
- @agent-docs/detailed-guide.md - 상세 가이드
- @agent-docs/examples.md - 사용 예시

# 나쁜 예 (Module CLAUDE.md - 450라인)
# Module Name

긴 설명...
상세한 코드 예시...
모든 내용이 한 파일에...
```

---

## 4. agent-docs 동적 로딩

### 개요

agent-docs 파일은 **필요할 때만 로드**해야 합니다. CLAUDE.md에서 `@` 참조를 사용하면 해당 파일 전체가 컨텍스트에 자동 포함되어 토큰을 낭비합니다.

### 핵심 원칙

```
DYNAMIC LOADING PRINCIPLE:
┌─────────────────────────────────────────────────────────┐
│  @ 참조 = 자동 IMPORT (파일 내용이 컨텍스트에 포함)      │
│  일반 링크 = 참조만 (필요 시 Read 도구로 수동 로드)      │
└─────────────────────────────────────────────────────────┘
```

### 참조 방식 비교

| 위치 | @ 참조 | 일반 링크 | 권장 |
|------|--------|----------|------|
| CLAUDE.md → agent-docs | ❌ 자동 로드 | ✅ 참조만 | **일반 링크** |
| agent-docs → agent-docs | ✅ 허용 | ✅ 허용 | 상황에 따라 |
| CLAUDE.md → 소스코드 | ✅ 허용 | - | @ 참조 |

### 올바른 작성법

```markdown
# ❌ 잘못된 예 (agent-docs가 자동 로드됨)
## 상세 문서
- @agent-docs/template-library.md - 문서 템플릿
- @agent-docs/code-analysis.md - AST 파싱

# ✅ 올바른 예 (필요 시 Read 도구로 로드)
## 상세 문서 (필요 시 로드)
| 문서 | 설명 |
|------|------|
| `agent-docs/template-library.md` | 문서 템플릿, Mermaid 패턴 |
| `agent-docs/code-analysis.md` | AST 파싱, 의존성 분석 |

# ✅ 대안: 마크다운 링크 (로드 안됨)
## 상세 문서
- [template-library](agent-docs/template-library.md) - 문서 템플릿
- [code-analysis](agent-docs/code-analysis.md) - AST 파싱
```

### 체크리스트

- [ ] CLAUDE.md에서 agent-docs를 @ 참조하지 않았는가?
- [ ] agent-docs 경로를 코드 스팬(`` ` ``) 또는 일반 링크로 표시했는가?
- [ ] 각 문서의 1-2줄 요약을 함께 작성했는가?

### 예상 효과

```
토큰 절감 효과:
├─ Before: 모든 agent-docs 자동 로드 (~5000+ 토큰)
├─ After: CLAUDE.md만 로드 (~500 토큰)
└─ 절감율: 50-70%
```

---

## 우선순위 레벨

| 레벨 | 설명 | 예시 |
|------|------|------|
| 1 | 보안 관련 | 인증, 권한, 데이터 보호 |
| 2 | 버전/호환성/토큰 효율 | Semantic Versioning, 동적 로딩 |
| 3 | 코드 품질 | 테스트 커버리지, 린트 |
| 4 | 워크플로우 | 커밋 컨벤션, 브랜치 전략 |

---

## 변경 이력

| 날짜 | 변경 내용 |
|------|----------|
| 2024-12-10 | 초기 헌법 문서화 |
| 2024-12-10 | 파일 레퍼런싱 @ 문법 규칙 추가 |
| 2025-12-10 | CLAUDE.md 라인 제한 규칙 추가 |
| 2025-12-11 | agent-docs 동적 로딩 규칙 추가 |

---

[parent](../CLAUDE.md)
