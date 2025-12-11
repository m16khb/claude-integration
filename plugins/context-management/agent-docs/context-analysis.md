# Context Analysis

> 컨텍스트 분석 및 작업 추천 알고리즘

## Overview

continue-context 커맨드의 컨텍스트 분석 프로세스를 설명합니다.

```
CONTEXT ANALYSIS PIPELINE:
┌─────────────────────────────────────────────────────────┐
│                  Current State                           │
│      (Git, Files, History, Environment)                  │
└───────────────────────┬─────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
   ┌─────────┐     ┌─────────┐     ┌─────────┐
   │   Git   │     │  File   │     │ History │
   │ Analysis│     │ Analysis│     │ Analysis│
   └────┬────┘     └────┬────┘     └────┬────┘
        │               │               │
        └───────────────┼───────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Pattern Recognition                         │
│           (작업 패턴, 미완료 작업 감지)                    │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│            Next Action Recommendation                    │
│              (우선순위별 작업 추천)                        │
└─────────────────────────────────────────────────────────┘
```

---

## 분석 영역

### Git 상태 분석

```
GIT ANALYSIS:
├─ 현재 브랜치
│   ├─ 브랜치 타입 감지 (feature/hotfix/release)
│   ├─ 원격과의 동기화 상태
│   └─ 마지막 커밋 정보
│
├─ 변경 사항
│   ├─ Staged 파일 목록
│   ├─ Unstaged 변경 파일
│   └─ Untracked 파일
│
├─ 최근 커밋 히스토리
│   ├─ 최근 10개 커밋
│   ├─ 커밋 메시지 패턴
│   └─ 작업 흐름 추론
│
└─ 충돌/병합 상태
    ├─ Merge conflict 여부
    ├─ Rebase 진행 상태
    └─ Cherry-pick 상태
```

### 파일 상태 분석

```
FILE ANALYSIS:
├─ 최근 수정 파일
│   ├─ 수정 시간순 정렬
│   ├─ 파일 유형 분류
│   └─ 변경 크기 분석
│
├─ 파일 관계
│   ├─ 의존성 그래프
│   ├─ Import/Export 관계
│   └─ 테스트 파일 매핑
│
├─ 미완료 표시 감지
│   ├─ TODO, FIXME 주석
│   ├─ @ts-ignore, @ts-expect-error
│   └─ 빈 함수/스텁
│
└─ 코드 품질 지표
    ├─ 린트 에러 카운트
    ├─ 타입 에러 카운트
    └─ 테스트 실패 여부
```

### 히스토리 분석

```
HISTORY ANALYSIS:
├─ 세션 히스토리
│   ├─ 최근 실행한 커맨드
│   ├─ 열었던 파일 목록
│   └─ 검색/수정 패턴
│
├─ 작업 패턴 인식
│   ├─ 반복적인 작업 감지
│   ├─ 작업 순서 패턴
│   └─ 시간대별 작업 유형
│
└─ 중단된 작업 감지
    ├─ 미완료 작업 추적
    ├─ 중단 지점 기록
    └─ 복구 제안
```

---

## 패턴 인식

### 작업 유형 패턴

```
WORK PATTERNS:
├─ 기능 개발 패턴
│   ├─ 새 파일 생성 → 구현 → 테스트 → 커밋
│   └─ 감지: 새 파일 + entity/service/controller
│
├─ 버그 수정 패턴
│   ├─ 파일 조회 → 수정 → 테스트 확인 → 커밋
│   └─ 감지: 기존 파일 수정 + fix 관련 브랜치
│
├─ 리팩토링 패턴
│   ├─ 여러 파일 동시 수정 → 테스트 → 커밋
│   └─ 감지: 다수 파일 수정 + 기능 변경 없음
│
└─ 문서 작업 패턴
    ├─ .md 파일 수정 → 커밋
    └─ 감지: docs/, README 관련 변경
```

### 미완료 작업 감지

```
INCOMPLETE WORK DETECTION:
├─ 코드 내 표시
│   ├─ TODO: 구현 필요
│   ├─ FIXME: 수정 필요
│   ├─ HACK: 임시 코드
│   └─ XXX: 주의 필요
│
├─ 구조적 표시
│   ├─ throw new Error('Not implemented')
│   ├─ console.log('TODO:')
│   ├─ 빈 함수 본문
│   └─ 주석 처리된 코드
│
└─ 상태 표시
    ├─ Unstaged 변경
    ├─ Stash 항목
    └─ 실패한 테스트
```

---

## 작업 추천

### 추천 우선순위

```
RECOMMENDATION PRIORITY:
1. CRITICAL (즉시 필요)
   ├─ Merge conflict 해결
   ├─ 빌드 에러 수정
   └─ 실패한 테스트 수정

2. HIGH (높은 우선순위)
   ├─ 미완료 기능 완성
   ├─ 커밋 전 작업 완료
   └─ 리뷰 피드백 반영

3. MEDIUM (중간 우선순위)
   ├─ TODO 항목 처리
   ├─ 테스트 커버리지 향상
   └─ 문서 업데이트

4. LOW (낮은 우선순위)
   ├─ 코드 정리
   ├─ 의존성 업데이트
   └─ 성능 최적화
```

### 추천 형식

```markdown
## 🔄 컨텍스트 분석 결과

### 현재 상태
- **브랜치**: feature/user-auth
- **변경 파일**: 5개 (3 staged, 2 unstaged)
- **마지막 커밋**: 2시간 전

### 추천 작업

#### 1. 🔴 [CRITICAL] 타입 에러 수정
`src/auth/auth.service.ts:45`에서 타입 에러 발생
```typescript
// Type 'undefined' is not assignable to type 'User'
```

#### 2. 🟡 [HIGH] 미완료 기능 완성
`src/auth/guards/jwt.guard.ts`의 TODO 항목:
```typescript
// TODO: Refresh token 검증 로직 구현
```

#### 3. 🟢 [MEDIUM] 테스트 작성
`src/auth/auth.service.ts`에 대한 테스트 파일 없음

### 다음 단계 제안
1. 타입 에러 수정 후 `npm run type-check`
2. TODO 항목 구현
3. `/code-quality:review` 실행 후 커밋
```

---

## 사용법

### 기본 사용

```bash
# 전체 컨텍스트 분석
/context-management:continue-context

# 특정 영역에 포커스
/context-management:continue-context auth
/context-management:continue-context "인증 모듈"

# 상세 분석
/context-management:continue-context --detailed
```

### Sequential Thinking 연동

```bash
# MCP 연동으로 단계별 분석
/context-management:continue-context --use-sequential-thinking
```

---

## 설정

### 분석 설정

```yaml
# .claude/context-config.yml
analysis:
  git:
    enabled: true
    history_depth: 10

  files:
    enabled: true
    max_recent: 20
    ignore_patterns:
      - "node_modules/**"
      - "dist/**"
      - "*.lock"

  history:
    enabled: true
    session_memory: true

recommendations:
  max_items: 5
  priority_order:
    - critical
    - high
    - medium
  include_low: false
```

---

**관련 문서**: [CLAUDE.md](../CLAUDE.md) | [chunking-algorithm.md](chunking-algorithm.md) | [recovery-patterns.md](recovery-patterns.md)
