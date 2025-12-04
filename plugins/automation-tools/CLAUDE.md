---
name: automation-tools
description: '자동화 도구 모음 - 컴포넌트 생성기, 상태 라인 설정, 동기화 도구'
category: productivity
---

# automation-tools Plugin

개발 생산성을 극대화하는 자동화 도구 모음입니다. Agent, Skill, Command 컴포넌트를 자동 생성하고 프로젝트 문서를 실시간 동기화합니다.

## Core Philosophy

```
자동화 원칙:
├─ 반복 작업 제거: 개발자가 집중해야 할 작업에만 집중
├─ 템플릿 기반 생성: 일관된 구조와 품질 보장
├─ 지능적 동기화: 변경 감지 → 자동 갱신 → 검증
└─ 확장 가능성: 새로운 컴포넌트 타입 지원
```

## Key Components

### 1. Factory Component Generator

**용도**: WebFetch 기반 문서 분석으로 Agent/Skill/Command 자동 생성

#### Supported Component Types

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

#### Factory Workflow

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

### 2. Status Line Configuration

**용도**: YAML 설정 기반으로 개발 환경 상태 표시줄 자동 구성

#### Configuration Structure

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
      development: "🔧"
      staging: "⚡"
      production: "🚀"

  errors:
    command: "tsc --noEmit 2>&1 | grep error | wc -l"
    style: "red"
    hide_when_zero: true

  status:
    indicators:
      - condition: "test passing"
        icon: "✅"
        style: "green"
      - condition: "build success"
        icon: "🟢"
        style: "green"
      - condition: "has uncommitted changes"
        icon: "⚠️"
        style: "yellow"
```

#### Supported Data Sources

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

### 3. Claude Code Synchronization

**용도**: 코드베이스 변경 감지 및 CLAUDE.md 자동 동기화

#### Sync Workflow

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

#### Integration Points

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

## Quick Start Guide

### 1. 새로운 에이전트 생성

```bash
# 기본 문서 기반 생성
/factory agent "React 컴포넌트 전문가"

# 특정 문서 기반 생성
/factory agent https://docs.nestjs.com/controllers

# 복합 전문가 생성
/factory agent "PostgreSQL + Redis 전문가"
```

**결과물 예시**:
- `plugins/database-experts/CLAUDE.md`
- `plugins/database-experts/agents/postgresql-expert.md`
- `plugins/database-experts/agents/redis-expert.md`
- `plugins/database-experts/skills/database-routing.md`

### 2. Status Line 설정

```bash
# 대화형 설정
/setup-statusline

# 특정 설정 파일로 설정
/setup-statusline --config .claude/custom-status.yml

# 템플릿 적용
/setup-statusline --template fullstack
```

### 3. 자동 동기화 활성화

```bash
# 전체 프로젝트 동기화
/claude-sync

# 특정 플러그인만 동기화
/claude-sync --target plugins/nestjs-backend

# 워치 모드 시작
/claude-sync --watch
```

## Advanced Features

### 1. Template System

```
템플릿 카테고리:
├─ 언어별: TypeScript, Python, Go, Rust
├─ 프레임워크: NestJS, Next.js, FastAPI
├─ 아키텍처: 마이크로서비스, 모놀리스
├─ 도메인: E-commerce, FinTech, 헬스케어
└─ 패턴: CQRS, Event Sourcing, DDD
```

### 2. Custom Component Types

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

### 3. Integration Hooks

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

## Best Practices

### Component Generation

1. **명확한 목적 정의**: 단일 책임 원칙 준수
2. **재사용 가능한 디자인**: 다른 프로젝트에서도 사용 가능
3. **완전한 문서화**: 사용법과 예시 포함
4. **에러 핸들링**: 예외 상황 대비
5. **테스트 포함**: 자동화된 테스트 케이스

### Status Line

1. **필요한 정보만**: 과도한 정보는 생산성 저하
2. **일관된 스타일**: 시각적 혼란 방지
3. **성능 고려**: 무거운 명령어 피하기
4. **조건부 표시**: 불필요할 때는 숨기기

### Synchronization

1. **자주 but 신중하게**: 변경 감지는 자주, 업데이트는 신중
2. **백업 전략**: 중요한 변경 전 백업
3. **검증 필수**: 자동 업데이트 후 반드시 검증
4.롤백 준비: 문제 발생 시 빠른 롤백

## Troubleshooting

### Common Issues

#### Factory 생성 실패
```
원인: 문서 접근 불가 또는 파싱 오류
해결:
1. URL 확인 또는 로컬 파일 사용
2. 문서 형식 확인 (Markdown, HTML 지원)
3. 인증 필요시 API 키 설정
```

#### Status Line 표시 오류
```
원인: 명령어 실행 실패 또는 권한 문제
해결:
1. 명령어 수동 실행 테스트
2. PATH 환경변수 확인
3. 실행 권한 부여 (chmod +x)
```

#### Sync 충돌
```
원인: 동시 수정 또는 권한 문제
해결:
1. Git 상태 확인 및 stash
2. 파일 잠금 해제
3. 수동 병합 후 재시도
```

## Integration Examples

### 1. NestJS 프로젝트 자동화

```bash
# 전체 NestJS 스택 설정
/factory agent "NestJS 전문가"
/setup-statusline --template nestjs
/claude-sync --watch
```

### 2. React 개발 환경

```bash
# React 관련 컴포넌트 생성
/factory skill react-component-generator
/factory command react-component-create
/setup-statusline --config .claude/react-status.yml
```

### 3. 마이크로서비스 아키텍처

```bash
# 마이크로서비스 템플릿 적용
/factory command microservice-init
/factory agent "Kubernetes 전문가"
/claude-sync --target infrastructure/
```

## Performance Considerations

- **Factory**: 대용량 문서 처리 시 시간 초과 방지 (분할 처리)
- **Status Line**: 명령어 캐싱으로 반복 실행 방지
- **Sync**: 증분 업데이트로 전체 스캔 방지
- **메모리**: Watch 모드에서 메모리 누수 주의

## Security Notes

- **WebFetch**: 안전한 URL만 허용, 화이트리스트 권장
- **Command 실행**: 사용자 입력 sanitization
- **File 접근**: 프로젝트 경로 내로 제한
- **API 키**: 환경변수 통한 안전한 관리

[parent](../CLAUDE.md)