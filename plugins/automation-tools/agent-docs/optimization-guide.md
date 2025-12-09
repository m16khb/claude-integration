# Optimization Guide

> 프롬프트, 에이전트, 커맨드 최적화 통합 가이드

## Overview

`/optimize` 커맨드는 Claude Code 컴포넌트를 최적화하는 통합 도구입니다.

```
OPTIMIZATION TARGETS:
├─ prompt  - 프롬프트 최적화
├─ agent   - 에이전트 정의 최적화
└─ command - 커맨드 정의 최적화
```

---

## Prompt Optimization

### 최적화 프로세스

```
PROMPT OPTIMIZATION FLOW:
┌─────────────────┐
│  Input Source   │ ─── 텍스트/파일/URL
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Sequential      │ ─── 단계별 분석
│ Thinking        │     (Intent, Task, Structure)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Research        │ ─── Context7, Web 검색
│ Integration     │     Best Practices
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Optimization    │ ─── Task Decomposition
│ Engine          │     Restructuring
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Output          │ ─── 최적화된 프롬프트
└─────────────────┘
```

### 사용법

```bash
# 대화형 최적화
/automation-tools:optimize prompt --interactive

# 직접 텍스트 최적화
/automation-tools:optimize prompt "React 컴포넌트 만들어줘"

# 파일에서 프롬프트 최적화
/automation-tools:optimize prompt my-prompt.txt

# URL 기반 문서를 프롬프트로
/automation-tools:optimize prompt https://docs.example.com/guide
```

### 최적화 유형

```
OPTIMIZATION TYPES:
├─ 작업 자동화
│   ├─ 목적: 반복 작업을 자동화 프롬프트로 변환
│   ├─ 예시: "매일 아침 DB 백업" → 자동화 스크립트 프롬프트
│   └─ 결과: 재사용 가능한 워크플로우 프롬프트
│
├─ 문서 생성
│   ├─ 목적: 구조화된 문서 생성용으로 최적화
│   ├─ 예시: "API 문서 작성" → 상세 문서 생성 프롬프트
│   └─ 결과: 템플릿 기반 문서 생성 프롬프트
│
├─ 코드 생성
│   ├─ 목적: 코드 생성 및 리뷰용으로 최적화
│   ├─ 예시: "로그인 기능" → 구현 상세 프롬프트
│   └─ 결과: 테스트 포함 코드 생성 프롬프트
│
└─ 분석 리서치
    ├─ 목적: 데이터 분석 및 리서치용으로 최적화
    ├─ 예시: "성능 문제 분석" → 체계적 분석 프롬프트
    └─ 결과: 단계별 분석 프롬프트
```

---

## Agent Optimization

### 최적화 영역

```
AGENT OPTIMIZATION AREAS:
├─ Role Clarity (역할 명확성)
│   ├─ PURPOSE 섹션 강화
│   ├─ 전문 분야 명시
│   └─ 경계 조건 정의
│
├─ Trigger Effectiveness (트리거 효과)
│   ├─ 키워드 최적화
│   ├─ 점수 조정
│   └─ 오탐지 방지
│
├─ Tool Utilization (도구 활용)
│   ├─ 필요 도구 식별
│   ├─ 불필요 도구 제거
│   └─ MCP 도구 통합
│
└─ Response Quality (응답 품질)
    ├─ 출력 형식 표준화
    ├─ 예시 품질 향상
    └─ 에러 처리 개선
```

### 사용법

```bash
# 기본 에이전트 최적화
/automation-tools:optimize agent plugins/code-quality/agents/code-reviewer.md

# MCP 통합으로 최신 문서 반영
/automation-tools:optimize agent plugins/nestjs-backend/agents/typeorm-expert.md --mcp

# 변경 없이 분석만
/automation-tools:optimize agent agents/*.md --dry-run
```

### 체크리스트

```
AGENT OPTIMIZATION CHECKLIST:
□ PURPOSE 섹션이 명확한가?
□ 전문 분야가 구체적으로 정의되었나?
□ 트리거 키워드가 적절한가?
□ 필요한 도구만 포함되었나?
□ 예시가 충분하고 명확한가?
□ 에러 처리가 정의되었나?
□ 다른 에이전트와 역할이 겹치지 않는가?
□ 모델 선택이 적절한가?
```

---

## Command Optimization

### 최적화 영역

```
COMMAND OPTIMIZATION AREAS:
├─ Argument Parsing (인자 처리)
│   ├─ 필수/선택 인자 구분
│   ├─ 기본값 설정
│   └─ 유효성 검증
│
├─ Help Text (도움말)
│   ├─ 명확한 설명
│   ├─ 사용 예시
│   └─ 옵션 설명
│
├─ Error Handling (에러 처리)
│   ├─ 친절한 에러 메시지
│   ├─ 복구 제안
│   └─ 로깅
│
└─ Integration (통합)
    ├─ 다른 커맨드와 연계
    ├─ 파이프라인 지원
    └─ 출력 형식 옵션
```

### 사용법

```bash
# 커맨드 최적화
/automation-tools:optimize command plugins/code-quality/commands/review.md

# 배치 최적화
/automation-tools:optimize command plugins/*/commands/*.md --batch
```

### 체크리스트

```
COMMAND OPTIMIZATION CHECKLIST:
□ description이 명확한가?
□ argument-hint가 적절한가?
□ 필요한 도구만 allowed-tools에 포함되었나?
□ 사용 예시가 충분한가?
□ 에러 메시지가 친절한가?
□ 도움말이 충분한가?
□ 다른 커맨드와 일관된 스타일인가?
□ 출력 형식이 적절한가?
```

---

## 최적화 원칙

### 1. CLARITY (명확성)

```
CLARITY PRINCIPLES:
├─ 명확한 목적
│   └─ 한 문장으로 설명 가능해야 함
├─ 구체적인 제약
│   └─ 모호함 없는 지시사항
├─ 명확한 성공 기준
│   └─ 완료 조건 정의
└─ 예시 포함
    └─ 입력/출력 예시 제공
```

### 2. EFFICIENCY (효율성)

```
EFFICIENCY PRINCIPLES:
├─ 토큰 최소화
│   └─ 불필요한 내용 제거
├─ 컨텍스트 윈도우 최적화
│   └─ 핵심 정보 우선 배치
├─ 중복 제거
│   └─ 반복 내용 통합
└─ 모듈화
    └─ 재사용 가능한 구조
```

### 3. EFFECTIVENESS (효과성)

```
EFFECTIVENESS PRINCIPLES:
├─ 행동 지향적
│   └─ 실행 가능한 지시사항
├─ 측정 가능한 결과
│   └─ 품질 기준 명시
├─ 실용적 적용
│   └─ 즉시 사용 가능
└─ 피드백 루프
    └─ 개선 가능한 구조
```

### 4. MAINTAINABILITY (유지보수성)

```
MAINTAINABILITY PRINCIPLES:
├─ 모듈 구조
│   └─ 섹션별 독립성
├─ 업데이트 용이
│   └─ 변경 영향 최소화
├─ 버전 관리
│   └─ 변경 이력 추적
└─ 문서화
    └─ 자체 설명적
```

---

## 성능 분석

### 최적화 리포트

```json
{
  "optimization_report": {
    "file": "code-reviewer.md",
    "timestamp": "2025-12-09T10:00:00.000Z",
    "improvements": [
      {
        "type": "token_efficiency",
        "before": 2450,
        "after": 1890,
        "improvement": "23%"
      },
      {
        "type": "response_quality",
        "score_before": 7.2,
        "score_after": 8.9,
        "improvement": "24%"
      },
      {
        "type": "trigger_accuracy",
        "false_positives_before": 12,
        "false_positives_after": 3,
        "improvement": "75%"
      }
    ],
    "recommendations": [
      "Consider adding more specific examples",
      "Reduce redundant sections",
      "Add error handling patterns"
    ]
  }
}
```

---

## Migration Guide

### 기존 커맨드에서 마이그레이션

```bash
# From optimize-agents
# Before: /optimize-agents agent.md
# After:
/automation-tools:optimize agent agent.md

# From optimize-command
# Before: /optimize-command command.md
# After:
/automation-tools:optimize command command.md

# From prompt-optimizer
# Before: /prompt-optimizer "my prompt"
# After:
/automation-tools:optimize prompt --interactive "my prompt"
```

---

[CLAUDE.md](../CLAUDE.md) | [factory-system.md](factory-system.md) | [sync-orchestration.md](sync-orchestration.md)
