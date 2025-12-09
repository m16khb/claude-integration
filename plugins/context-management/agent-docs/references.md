# Context Management 참고 자료

이 문서는 context-management 플러그인의 베스트 프랙티스, 문제 해결 가이드, 성능 고려사항을 제공합니다.

## 목차

- [베스트 프랙티스](#베스트-프랙티스)
- [문제 해결 가이드](#문제-해결-가이드)
- [성능 최적화](#성능-최적화)
- [설정 레퍼런스](#설정-레퍼런스)

---

## 베스트 프랙티스

### 컨텍스트 관리

- **작게 유지**: 한 번에 처리하는 컨텍스트는 3-5개 파일로 제한
- **관련성 우선**: 현재 작업과 직접 관련된 것만 로드
- **정기 정리**: 사용하지 않는 컨텍스트는 정기적으로 삭제
- **버전 관리**: 중요한 컨텍스트 상태는 저장

### 청킹 전략

- **의미론적 경계**: 클래스, 함수, 모듈 단위로 분할
- **독립성**: 각 청크는 독립적으로 이해 가능해야 함
- **일관된 크기**: 각 청크는 비슷한 토큰 크기 유지
- **오버랩**: 중요한 경계는 약간의 오버랩 포함

### 워크플로우 최적화

- **빠른 피드백**: 5초 이내에 분석 결과 제공
- **점진적 로딩**: 필요한 만큼만 점진적으로 로드
- **백그라운드 처리**: 대용량 분석은 백그라운드에서 실행
- **인터럽트 지원**: 긴 분석은 중간에 중단 가능

---

## 문제 해결 가이드

### 일반적인 문제

#### 컨텍스트가 너무 클 때

```
문제: 토큰 초과 또는 응답 지연
원인: 너무 많은 파일을 한 번에 처리
해결:
1. 필터링 강화: /inject-context --filter "high-relevance"
2. 청크 크기 줄임: /inject-context --chunk-size 5000
3. 배치 처리: --batch 3
```

#### 관련성이 낮은 추천

```
문제: 다음 단계 추천의 정확도 낮음
원인: 작업 패턴 학습 부족
해결:
1. 피드백 제공: /continue-context --feedback "not-relevant"
2. 수동 힌트: /continue-context --hint "testing"
3. 히스토리 정리: /clear-context-history
```

### 오류 처리 테이블

| Error | Response (Korean) |
|-------|-------------------|
| No context loaded | "로드된 컨텍스트가 없습니다. /inject-context로 파일을 먼저 로드하세요." |
| Empty conversation | "대화 기록이 없습니다. 무엇을 도와드릴까요?" |
| Ambiguous state | Sequential Thinking으로 상태 분석 후 TUI 제공 |
| Multiple interrupted tasks | 우선순위 기반으로 정렬 후 TUI로 선택 |
| File not found | "파일을 찾을 수 없습니다" + Glob 유사 파일 제안 |
| Permission denied | "파일 읽기 권한이 없습니다" |
| Binary file | "바이너리 파일은 지원하지 않습니다" |
| Token overflow | 청크 크기 50% 감소 후 재시도 |
| Structure detection fail | 고정 청킹으로 폴백 |
| Empty file | "빈 파일입니다. 다른 파일을 선택하세요" |

### 컨텍스트 이해 체크리스트

작업 재개 전 반드시 확인:

```
[ ] 모든 로드된 파일 내용 파악
[ ] 파일 간 의존성/관계 이해
[ ] 프로젝트 아키텍처 파악
[ ] 사용된 기술 스택 확인
[ ] 완료된 작업 목록 정리
[ ] 중단된 작업 식별
[ ] 마지막 작업 지점 확인
[ ] 다음 단계 결정
```

---

## 성능 최적화

### 컨텍스트 캐싱

```yaml
# .claude/context-cache.yml
cache:
  strategy: "lru"  # lru, lfu, fifo
  max_size: "100mb"
  ttl: "1h"

compression:
  enabled: true
  level: 6  # 1-9

invalidation:
  on_file_change: true
  on_dependency_update: true
  manual_purge: "/clear-context-cache"
```

### Lazy Loading 전략

필요할 때만 컨텍스트를 로드하여 성능 최적화:

1. **메타데이터만 먼저 로드**: 파일 크기, 타입, 구조점
2. **관련성 점수 계산**: 현재 작업과의 연관도
3. **높은 관련성일 경우에만 전체 로드**: 임계값 초과 시

### 병렬 처리 최적화

- 파일 목록을 워커 수로 분할
- 병렬로 분석 실행
- 결과 병합

---

## 설정 레퍼런스

### 컨텍스트 지속성 설정

```yaml
# .claude/context-persistence.yml
storage:
  type: "file"  # file, redis, database
  path: ".claude/context/"
  ttl: "24h"

sessions:
  auto_save: true
  max_sessions: 10
  restore_on_startup: true

compression:
  enabled: true
  algorithm: "gzip"
  min_size: "1mb"
```

### 필터링 규칙 설정

```typescript
interface ContextFilter {
  // 파일 타입 기반
  fileTypes: {
    include: ["ts", "js", "py", "go"];
    exclude: ["test.ts", "spec.ts", ".d.ts"];
  };

  // 경로 기반
  paths: {
    include: ["src/**", "lib/**"];
    exclude: ["node_modules/**", "dist/**"];
  };

  // 크기 기반
  size: {
    max_file_size: "50kb";
    max_total_size: "1mb";
  };

  // 시간 기반
  time: {
    modified_within: "7d";
    accessed_within: "1d";
  };
}
```

### 제거된 제약 사항

```
제거됨:
├─ continue-context 자동 연결 제거
├─ Opus 자동 위임 제거
├─ 강제 TUI 제거 (TASK 없으면 TUI 스킵)
└─ 요약/분석 우선 제거 → 원문 보존 우선

유지/강화:
├─ Sequential Thinking으로 구조 분석
├─ 구조적 경계 존중 청킹
├─ 원문 그대로 컨텍스트 주입
└─ 사용자 선택 존중
```

---

[메인 문서](../CLAUDE.md) | [상세 가이드](detailed-guides.md) | [예제](examples.md)
