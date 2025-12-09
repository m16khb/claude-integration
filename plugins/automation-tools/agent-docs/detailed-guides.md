# automation-tools 상세 가이드

이 문서는 automation-tools 플러그인의 각 컴포넌트에 대한 상세 워크플로우와 설정 가이드를 제공합니다.

---

## 1. Factory Component Generator 워크플로우

### 지원 컴포넌트 타입

```
COMPONENTS:
├─ Agents
│   ├─ 일반 전문가: 특정 도메인 전문 에이전트
│   ├─ 오케스트레이터: 여러 에이전트 조율
│   └─ 통합 전문가: MCP 서버 연동 에이전트
│
├─ Skills
│   ├─ 처리형: 특정 작업 수행 (PDF, 이미지 등)
│   ├─ 생성형: 콘텐츠 생성 (문서, 코드 등)
│   └─ 분석형: 데이터 분석 및 리포팅
│
└─ Commands
    ├─ 유틸리티: 개발 보조 명령어
    ├─ 워크플로우: 복잡한 작업 자동화
    └─ 상호작용: 사용자 인터페이스 명령어
```

### Factory 생성 프로세스

```
생성 프로세스:
Step 1: 문서 분석 (WebFetch)
├─ API 레퍼런스 파싱
├─ 코드 예시 추출
└─ 사용 패턴 분석

Step 2: 컴포넌트 설계
├─ 적절한 타입 결정
├─ 필요한 도구 식별
└─ 인터페이스 정의

Step 3: 코드 생성
├─ 베스트 프랙티스 적용
├─ 에러 핸들링 포함
└─ 테스트 케이스 생성

Step 4: 검증 및 설치
├─ 문법 검증
├─ 기능 테스트
└─ 프로젝트 통합
```

---

## 2. Status Line 설정 가이드

### 설정 파일 구조

```yaml
# .claude/status.yml 예시
status:
  format: "[{branch}] {env} {errors} {warnings} {status}"

components:
  branch:
    command: "git branch --show-current"
    style: "blue"

  environment:
    command: "echo $NODE_ENV"
    style: "green"
    icons:
      development: "DEV"
      staging: "STG"
      production: "PROD"

  errors:
    command: "tsc --noEmit 2>&1 | grep error | wc -l"
    style: "red"
    hide_when_zero: true

  status:
    indicators:
      - condition: "test passing"
        icon: "PASS"
        style: "green"
      - condition: "build success"
        icon: "OK"
        style: "green"
      - condition: "has uncommitted changes"
        icon: "WARN"
        style: "yellow"
```

### 지원 데이터 소스

```
DATA SOURCES:
├─ Git Commands: branch, status, commit hash
├─ Build Tools: npm, yarn, pnpm, make
├─ Linters/Type Checkers: ESLint, TSC, PyLint
├─ Test Runners: Jest, Vitest, PyTest
├─ Environment Variables: NODE_ENV, DATABASE_URL
├─ File System: file counts, directory sizes
├─ Network Status: API connectivity, ping
└─ Custom Commands: any shell command
```

---

## 3. Prompt Optimizer 워크플로우

### 최적화 프로세스

```
최적화 흐름:
1. Input Collection
├─ Direct text/file/URL
├─ Interactive TUI collection
└─ Context extraction

2. Sequential Analysis
├─ Intent clarification
├─ Task identification
└─ Structure planning

3. Research Integration
├─ Context7 최신 문서
├─ Web 검색 및 예시
└─ Best practices 적용

4. Optimization
├─ Task decomposition
├─ Prompt restructuring
└─ Quality validation
```

### 지원 최적화 유형

```
OPTIMIZATION TYPES:
├─ 작업 자동화: 반복 작업을 자동화 프롬프트로
├─ 문서 생성: 구조화된 문서 생성용으로
├─ 코드 생성: 코드 생성 및 리뷰용으로
└─ 분석 리서치: 데이터 분석 및 리서치용으로
```

---

## 4. Claude Sync 동기화 워크플로우

### 동기화 프로세스

```
동기화 프로세스:
1. 변경 감지 (Watch Mode)
├─ 파일 시스템 모니터링
├─ Git 훅 통합 (pre-commit, post-merge)
└─ 수동 트리거 지원

2. 영향 분석
├─ 변경된 파일과 관련된 문서 식별
├─ 종속성 그래프 업데이트
└─ 영향 범위 계산

3. 문서 업데이트
├─ API 변경점 반영
├─ 새로운 기능 추가
├─ 사용 예시 업데이트
└─ 버전 정보 갱신

4. 검증
├─ 링크 유효성 검사
├─ 문법 및 형식 검증
└─ 일관성 확인
```

### 통합 대상

```
INTEGRATION TARGETS:
├─ Plugins
│   ├─ CLAUDE.md 메타데이터
│   ├─ Agent 정의 파일
│   └─ Command 스크립트
│
├─ Documentation
│   ├─ API 레퍼런스
│   ├─ 아키텍처 다이어그램
│   └─ 사용 가이드
│
├─ Configuration
│   ├─ routing-table.json
│   ├─ 환경 설정 파일
│   └─ 의존성 목록
│
└─ Code Artifacts
    ├─ 인터페이스 정의
    ├─ 타입 선언
    └─ 설정 파일
```

---

## 5. 고급 기능

### Template System

```
템플릿 카테고리:
├─ 언어별: TypeScript, Python, Go, Rust
├─ 프레임워크: NestJS, Next.js, FastAPI
├─ 아키텍처: 마이크로서비스, 모놀리스
├─ 도메인: E-commerce, FinTech, 헬스케어
└─ 패턴: CQRS, Event Sourcing, DDD
```

### Custom Component Types

```yaml
# .claude/components.yml
custom_types:
  - name: "api-client"
    template_dir: "templates/api-client"
    required_fields: ["base_url", "auth_type"]

  - name: "middleware"
    template_dir: "templates/middleware"
    required_fields: ["position", "type"]
```

### Integration Hooks

```javascript
// .claude/hooks.js
module.exports = {
  afterComponentCreated: async (component) => {
    // 컴포넌트 생성 후 후크
    await runTests(component.path);
    await updateDocumentation(component);
  },

  beforeSync: async (changes) => {
    // 동기화 전 후크
    return validateChanges(changes);
  }
};
```

---

[parent](../CLAUDE.md) | [examples](examples.md) | [references](references.md)
