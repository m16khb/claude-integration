# Pipeline Architecture

> Full-Stack Orchestration 파이프라인의 핵심 아키텍처 문서

## Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Full-Stack Orchestrator                   │
│                                                              │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌────────┐ │
│  │ Request  │ => │ Pipeline │ => │ Quality  │ => │ Report │ │
│  │ Analysis │    │ Execute  │    │  Gates   │    │        │ │
│  └──────────┘    └──────────┘    └──────────┘    └────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Request Analysis

파이프라인 실행 전 변경 사항을 분석하여 최적의 실행 전략을 결정합니다.

### 분석 단계

```
REQUEST ANALYSIS:
├── 1. 변경 파일 분석 (Git diff)
│   ├── 추가된 파일
│   ├── 수정된 파일
│   ├── 삭제된 파일
│   └── 파일 유형 식별
│
├── 2. 영향 범위 추정 (Dependency analysis)
│   ├── 직접 의존성
│   ├── 간접 의존성
│   └── 테스트 범위 결정
│
├── 3. 실행 단계 결정
│   ├── 필수 단계 식별
│   ├── 선택적 단계 판단
│   └── 건너뛸 단계 결정
│
└── 4. 실행 전략 수립
    ├── 병렬 가능 작업
    ├── 순차 실행 작업
    └── 리소스 할당
```

### 변경 유형별 분석

| 변경 유형 | 영향 범위 | 권장 단계 |
|----------|----------|----------|
| 소스 코드 | 전체 | Review → Test → Commit |
| 테스트 파일 | 테스트만 | Test → Commit |
| 문서 파일 | 문서만 | Spell Check → Commit |
| 설정 파일 | 전체 | Full Pipeline |
| 의존성 | 전체 + 보안 | Security Scan → Test → Commit |

---

## Pipeline Stages

### Stage 구조

```
PIPELINE STAGES:
├── Stage 1: Code Review (필수)
│   ├── 정적 분석 (Linter, Type check)
│   ├── 보안 취약점 스캔 (OWASP)
│   ├── 코드 스타일 검사 (Prettier)
│   └── 성능 문제 식별 (complexity analysis)
│
├── Stage 2: Testing (선택적 건너뛰기)
│   ├── 단위 테스트 실행 (Jest, Vitest)
│   ├── 통합 테스트 실행 (Supertest)
│   ├── E2E 테스트 실행 (Playwright)
│   └── 커버리지 리포트 생성
│
├── Stage 3: Commit (자동화)
│   ├── Conventional Commits 메시지 생성
│   ├── 변경사항 요약 작성
│   ├── PR 생성 (선택)
│   └── CI 트리거
│
└── Stage 4: Report
    ├── 품질 점수 계산
    ├── 개선 제안 목록
    ├── 다음 작업 추천
    └── 히스토리 기록
```

### Stage 의존성 그래프

```
┌─────────────┐
│ Code Review │
└──────┬──────┘
       │ success
       ▼
┌─────────────┐
│   Testing   │───────┐
└──────┬──────┘       │ skip-test
       │ success      │
       ▼              ▼
┌─────────────┐    ┌─────────────┐
│   Commit    │◄───│   Commit    │
└──────┬──────┘    └─────────────┘
       │
       ▼
┌─────────────┐
│   Report    │
└─────────────┘
```

---

## Quality Gates

### 심각도 레벨

```
QUALITY GATE SEVERITY:
├── CRITICAL (즉시 중단)
│   ├── 보안 취약점 (SQL Injection, XSS)
│   ├── 인증/인가 결함
│   └── 민감 정보 노출
│
├── HIGH (수정 요구)
│   ├── 테스트 실패
│   ├── 커버리지 미달 (< threshold)
│   └── 타입 오류
│
├── MEDIUM (커밋 가능, 개선 권장)
│   ├── 스타일 위반
│   ├── 코드 복잡도 초과
│   └── 문서 누락
│
└── LOW (자동 정리)
    ├── 미사용 import
    ├── 후행 공백
    └── 파일 끝 빈 줄
```

### Gate 동작 규칙

| 심각도 | 동작 | 자동 수정 | 커밋 가능 |
|--------|------|----------|----------|
| CRITICAL | 즉시 중단 | 불가 | 불가 |
| HIGH | 수정 요구 | 부분 가능 | 불가 |
| MEDIUM | 경고 | 가능 | 가능 |
| LOW | 자동 정리 | 자동 | 가능 |

---

## Smart Workflow Selection

### 컨텍스트 기반 선택

```typescript
interface WorkflowContext {
  changes: ChangeInfo[];
  branchType: 'feature' | 'hotfix' | 'release' | 'docs';
  filesModified: number;
  hasTests: boolean;
  isProduction: boolean;
  urgency: 'normal' | 'high' | 'critical';
}

const workflowRules = {
  hotfix: {
    review: 'quick',       // 보안 스캔만
    test: 'smoke-only',    // 핵심 테스트만
    commit: 'auto-push'    // 즉시 푸시
  },

  production: {
    review: 'thorough',    // 전체 리뷰
    test: 'full-suite',    // 전체 테스트
    commit: 'create-pr'    // PR 생성 필수
  },

  docs: {
    review: 'spell-check', // 맞춤법만
    test: 'skip',          // 테스트 없음
    commit: 'auto'         // 자동 커밋
  }
};
```

### 자동 선택 로직

```
WORKFLOW SELECTION:
1. 브랜치 타입 감지
   └── feature/* → 'feature'
   └── hotfix/* → 'hotfix'
   └── release/* → 'release'
   └── docs/* → 'docs'

2. 변경 내용 분석
   └── *.ts, *.js → 코드 변경
   └── *.md → 문서 변경
   └── package.json → 의존성 변경

3. 컨텍스트 조합
   └── 브랜치 + 변경 내용 → 최적 워크플로우

4. 사용자 오버라이드
   └── CLI 옵션으로 강제 지정 가능
```

---

## 리소스 관리

### 병렬 처리 설정

```yaml
# .claude/orchestration.yml
parallel:
  max_workers: 4
  strategy: "adaptive"  # adaptive | fixed | unlimited

  stages:
    review:
      parallelizable: true
      max_concurrent: 3

    test:
      parallelizable: true
      max_concurrent: 2

    commit:
      parallelizable: false  # 순차 실행 필수
```

### 타임아웃 설정

| Stage | 기본 타임아웃 | 최대 타임아웃 |
|-------|-------------|-------------|
| Review | 2분 | 5분 |
| Test | 5분 | 15분 |
| Commit | 1분 | 3분 |
| Report | 30초 | 1분 |

---

**관련 문서**: [CLAUDE.md](../CLAUDE.md) | [workflow-patterns.md](workflow-patterns.md) | [ci-cd-integration.md](ci-cd-integration.md)
