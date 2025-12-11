# Sync Orchestration

> CLAUDE.md 자동 동기화 및 routing-table.json 관리 가이드

## Overview

Claude Sync는 코드베이스 변경을 감지하여 문서를 자동으로 동기화하는 시스템입니다.

```
SYNC ARCHITECTURE:
┌──────────────────────────────────────────────────────────┐
│                    /claude-sync Command                   │
└───────────────────────────┬──────────────────────────────┘
                            │
            ┌───────────────┼───────────────┐
            │               │               │
            ▼               ▼               ▼
     ┌───────────┐   ┌───────────┐   ┌───────────┐
     │  Change   │   │  Impact   │   │  Document │
     │ Detection │   │ Analysis  │   │  Update   │
     └─────┬─────┘   └─────┬─────┘   └─────┬─────┘
            │               │               │
            └───────────────┼───────────────┘
                            │
                            ▼
                  ┌─────────────────┐
                  │   Validation    │
                  │     Layer       │
                  └─────────────────┘
```

---

## 동기화 프로세스

### Phase 0: Component Registry Sync

```
REGISTRY SYNC (routing-table.json):
├─ 스캔
│   ├─ Glob("**/agents/*.md") → 에이전트 정의
│   ├─ Glob("**/skills/**/SKILL.md") → 스킬 정의
│   └─ Glob("**/commands/*.md") → 커맨드 정의
│
├─ 추출
│   ├─ name (frontmatter)
│   ├─ model (frontmatter)
│   ├─ triggers (## TRIGGERS 또는 frontmatter)
│   └─ path (프로젝트 루트 기준)
│
├─ 업데이트
│   ├─ 새 컴포넌트 추가
│   ├─ last_synced 갱신
│   ├─ 삭제된 컴포넌트 제거
│   └─ 경로 유효성 검증
│
└─ 결과
    └─ .claude-plugin/routing-table.json 최신화
```

### Phase 1: Hierarchical Scan

```
HIERARCHY SCAN:
├─ 루트 레벨
│   ├─ CLAUDE.md 존재 확인
│   ├─ agent-docs/ 존재 확인
│   └─ 하위 모듈 식별
│
├─ 모듈 레벨 (plugins/*)
│   ├─ 각 플러그인 CLAUDE.md
│   ├─ 각 플러그인 agent-docs/
│   └─ 에이전트/스킬/커맨드 파일
│
└─ 서브모듈 레벨
    ├─ 중첩된 모듈 (있는 경우)
    └─ 부모 참조 확인
```

### Phase 2: Gap Analysis

```
GAP ANALYSIS:
├─ 문서 존재 확인
│   ├─ CLAUDE.md 있음/없음
│   ├─ agent-docs/ 있음/없음
│   └─ 상세 문서 있음/없음
│
├─ 라인 수 검사
│   ├─ Root CLAUDE.md: max 200줄 (확장됨)
│   ├─ Module CLAUDE.md: max 120줄 (확장됨)
│   └─ Submodule CLAUDE.md: max 80줄 (확장됨)
│
├─ 링크 유효성
│   ├─ 부모 CLAUDE.md 참조
│   ├─ 자식 모듈 링크
│   └─ agent-docs/ 링크
│
└─ 분류 결과
    ├─ OK: 최신 상태
    ├─ CREATE_CLAUDE_MD: CLAUDE.md 누락
    ├─ CREATE_AGENT_DOCS: agent-docs 필요
    ├─ UPDATE_CLAUDE_MD: 내용 업데이트 필요
    ├─ UPDATE_LINKS: 링크 수정 필요
    └─ REFACTOR_TO_AGENT_DOCS: 분할 필요
```

---

## routing-table.json 관리

### 구조

```json
{
  "last_synced": "2025-12-09T00:00:00.000Z",
  "version": "1.0.0",

  "agents": {
    "agent-name": {
      "path": "plugins/plugin-name/agents/agent-name.md",
      "model": "claude-opus-4-5-20251101",
      "role": "expert | orchestrator",
      "triggers": {
        "primary": ["키워드1", "키워드2"],
        "secondary": ["키워드3", "키워드4"],
        "context": ["키워드5"]
      },
      "plugin": "plugin-name"
    }
  },

  "skills": {
    "skill-name": {
      "path": "plugins/plugin-name/skills/skill-name/SKILL.md",
      "triggers": ["키워드1", "키워드2"],
      "plugin": "plugin-name"
    }
  },

  "commands": {
    "command-name": {
      "path": "plugins/plugin-name/commands/command-name.md",
      "triggers": ["/command-name", "/plugin:command-name"],
      "plugin": "plugin-name"
    }
  },

  "routing_rules": [
    {
      "keywords": ["keyword1", "keyword2"],
      "experts": ["expert-name"],
      "priority": "primary",
      "score": 3
    }
  ]
}
```

### 키워드 점수 계산

```
KEYWORD SCORING:
├─ Primary (3점)
│   └─ 핵심 기술 키워드: "redis", "typeorm", "bullmq"
│
├─ Secondary (2점)
│   └─ 관련 기능 키워드: "캐시", "설정", "최적화"
│
├─ Context (1점)
│   └─ 문맥 키워드: "interceptor", "cluster"
│
└─ 계산
    └─ 총점 = (Primary × 3) + (Secondary × 2) + (Context × 1)
    └─ 최고 점수 에이전트 선택
```

---

## 사용법

### 기본 동기화

```bash
# 전체 프로젝트 동기화
/automation-tools:claude-sync

# 특정 플러그인만 동기화
/automation-tools:claude-sync --target plugins/nestjs-backend

# 특정 작업만 수행
/automation-tools:claude-sync --only routing-table
/automation-tools:claude-sync --only agent-docs
```

### Watch Mode

```bash
# 파일 변경 감시 모드 시작
/automation-tools:claude-sync --watch

# 특정 디렉토리만 감시
/automation-tools:claude-sync --watch --target plugins/

# 간격 설정 (초)
/automation-tools:claude-sync --watch --interval 30
```

### 검증 모드

```bash
# 변경 없이 검증만
/automation-tools:claude-sync --dry-run

# 상세 리포트 생성
/automation-tools:claude-sync --report

# JSON 출력
/automation-tools:claude-sync --format json
```

---

## 통합 대상

### Plugins

```
PLUGIN SYNC:
├─ CLAUDE.md 메타데이터
│   ├─ name, description 동기화
│   ├─ 컴포넌트 목록 업데이트
│   └─ 상세 문서 링크 확인
│
├─ Agent 정의 파일
│   ├─ frontmatter 추출
│   ├─ triggers 동기화
│   └─ routing-table 업데이트
│
└─ Command 스크립트
    ├─ 사용법 추출
    ├─ 인자 정보 동기화
    └─ 도움말 생성
```

### Documentation

```
DOCUMENTATION SYNC:
├─ API 레퍼런스
│   ├─ 인터페이스 변경 감지
│   ├─ 타입 정의 업데이트
│   └─ 예제 코드 갱신
│
├─ 아키텍처 다이어그램
│   ├─ Mermaid 다이어그램
│   ├─ 의존성 그래프
│   └─ 시퀀스 다이어그램
│
└─ 사용 가이드
    ├─ 설치 방법
    ├─ 빠른 시작
    └─ 트러블슈팅
```

### Configuration

```
CONFIGURATION SYNC:
├─ routing-table.json
│   ├─ 컴포넌트 레지스트리
│   ├─ 라우팅 규칙
│   └─ 키워드 매핑
│
├─ 환경 설정 파일
│   ├─ .claude/ 디렉토리
│   ├─ 플러그인 설정
│   └─ 커스텀 설정
│
└─ 의존성 목록
    ├─ MCP 서버 요구사항
    ├─ 도구 의존성
    └─ 버전 정보
```

---

## 고급 설정

### 동기화 설정 파일

```yaml
# .claude/sync-config.yml
sync:
  # 동기화 대상
  targets:
    - plugins/
    - docs/
    - .claude-plugin/

  # 제외 패턴
  exclude:
    - "**/*.test.md"
    - "**/node_modules/**"
    - "**/.git/**"

  # 라인 제한 (확장된 설정)
  line_limits:
    root: 200
    module: 120
    submodule: 80

  # 자동 수정
  auto_fix:
    broken_links: true
    outdated_refs: true
    missing_sections: false

  # 알림
  notifications:
    on_change: true
    on_error: true
```

### Integration Hooks

```javascript
// .claude/sync-hooks.js
module.exports = {
  beforeSync: async (changes) => {
    // 동기화 전 검증
    console.log(`Syncing ${changes.length} files...`);
    return validateChanges(changes);
  },

  afterSync: async (result) => {
    // 동기화 후 작업
    if (result.updated.length > 0) {
      await notifyTeam(result);
    }
  },

  onError: async (error) => {
    // 오류 처리
    console.error('Sync error:', error);
    await logError(error);
  }
};
```

---

## 트러블슈팅

### 동기화 충돌

```
문제: 동시 수정으로 인한 충돌
원인: 여러 프로세스가 같은 파일 수정

해결:
1. Git 상태 확인: git status
2. 변경사항 스태시: git stash
3. 동기화 재실행: /claude-sync
4. 스태시 적용: git stash pop
```

### 링크 오류

```
문제: 깨진 링크 발견
원인: 파일 이동 또는 삭제

해결:
1. 검증 모드 실행: /claude-sync --dry-run
2. 오류 리포트 확인
3. 수동 링크 수정 또는 --auto-fix 사용
```

---

**관련 문서**: [CLAUDE.md](../CLAUDE.md) | [factory-system.md](factory-system.md) | [optimization-guide.md](optimization-guide.md)
