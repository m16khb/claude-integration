---
name: documentation-generation
description: '문서 생성 자동화 - CLAUDE.md, 에이전트 문서, 템플릿'
category: documentation
---

# documentation-generation Plugin

지능적인 문서 생성 시스템으로 코드베이스를 자동으로 분석하고 최신 문서를 생성합니다. 개발자들이 문서 작성이 아닌 개발에 집중할 수 있도록 돕습니다.

## Core Philosophy

```
문서 생성 원칙:
├─ 코드 분석 기반: 실제 코드 구조를 반영한 문서
├─ 자동 동기화: 코드 변경 시 문서 자동 업데이트
├─ 계층적 구조: 개요 → 상세 → 참조의 3단계 구성
├─ 템플릿 기반: 일관된 형식과 품질 보장
└─ 상호 연결: 문서 간의 링크로 네비게이션 용이
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                Document Generation System                   │
│                                                             │
│  Code Analysis ──► Template Engine ──► Output Docs          │
│       │               │                   │                │
│       ▼               ▼                   ▼                │
│  ┌─────────┐    ┌─────────────┐    ┌─────────────────┐    │
│  │ AST/AST │    │ Jinja2/Mustache│   │ Markdown/HTML   │    │
│  │ Parser  │    │ Templates    │    │ with Diagrams   │    │
│  └─────────┘    └─────────────┘    └─────────────────┘    │
│         │               │                   │               │
│         └───────────────┼───────────────────┘               │
│                         │                                   │
│                ┌────────▼─────────┐                         │
│                │  Document Types  │                         │
│  ┌─────────────┼──────────────────┼─────────────┐          │
│  │ CLAUDE.md   │   API Docs      │ Architecture │          │
│  └─────────────┴──────────────────┴─────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. document-builder Agent

**역할**: 코드베이스 분석을 통한 지능적 문서 생성 전문가

#### 핵심 기능
- **코드 분석**: AST 파싱, 의존성 분석, 패턴 인식
- **문서 유추**: 코드에서 자동으로 문서 내용 추출
- **구조화**: 계층적인 문서 구조 자동 생성
- **다이어그램**: Mermaid를 통한 시각화 자동 생성
- **검증**: 생성된 문서의 정확성 검증

#### 분석 대상

```
ANALYSIS TARGETS:
├─ 소스 코드
│   ├─ TypeScript/JavaScript 인터페이스
│   ├─ Python 클래스와 메서드
│   ├─ Go 구조체와 인터페이스
│   └─ Java 클래스와 패키지
│
├─ 설정 파일
│   ├─ package.json, requirements.txt
│   ├─ Dockerfile, docker-compose.yml
│   ├─ Kubernetes 매니페스트
│   └─ CI/CD 파이프라인
│
├─ API 정의
│   ├─ OpenAPI/Swagger 스펙
│   ├─ GraphQL 스키마
│   ├─ gRPC 프로토콜
│   └─ REST API 엔드포인트
│
└─ 아키텍처
    ├─ 모듈 의존성 그래프
    ├─ 데이터 흐름 다이어그램
    ├─ 시퀀스 다이어그램
    └─ 배포 아키텍처
```

### 2. Document Templates

**용도**: 재사용 가능한 문서 템플릿 모음

#### 템플릿 카테고리

```
TEMPLATE LIBRARY:
├─ 프로젝트 문서
│   ├─ CLAUDE.md (Claude Code 설정)
│   ├─ README.md (프로젝트 소개)
│   ├─ CONTRIBUTING.md (기여 가이드)
│   └─ CHANGELOG.md (변경 이력)
│
├─ API 문서
│   ├─ OpenAPI 3.0 스펙
│   ├─ Postman 컬렉션
│   ├─ API 사용 가이드
│   └─ SDK 생성 템플릿
│
├─ 아키텍처 문서
│   ├─ 시스템 아키텍처
│   ├─ 데이터 모델
│   ├─ 배포 가이드
│   └─ 운영 가이드
│
└─ 기술 문서
    ├─ 튜토리얼
    ├─ How-to 가이드
    ├─ 트러블슈팅
    └─ FAQ
```

## Document Generation Workflow

### 1. Discovery Phase

```bash
# 코드베이스 스캔
/doc-scan --path ./src --output ./.claude/discovery.json

# 결과 예시
{
  "project": {
    "name": "my-app",
    "language": "typescript",
    "framework": "nestjs",
    "architecture": "microservices"
  },
  "apis": [
    {
      "path": "/api/users",
      "method": "GET",
      "controller": "UserController",
      "auth": "required"
    }
  ],
  "entities": [
    {
      "name": "User",
      "fields": ["id", "email", "name"],
      "relations": ["Profile", "Posts"]
    }
  ]
}
```

### 2. Template Selection

자동으로 적절한 템플릿을 선택하고 조합합니다.

```typescript
// 템플릿 선택 로직
function selectTemplates(discovery: DiscoveryResult): Template[] {
  const templates = [];

  // 기본 템플릿
  templates.push('project/CLAUDE.md');
  templates.push('project/README.md');

  // API가 있는 경우
  if (discovery.apis.length > 0) {
    templates.push('api/openapi.yml');
    templates.push('api/usage-guide.md');
  }

  // 마이크로서비스인 경우
  if (discovery.architecture === 'microservices') {
    templates.push('architecture/microservices.md');
    templates.push('deployment/kubernetes.md');
  }

  return templates;
}
```

### 3. Generation Process

```
GENERATION PIPELINE:
1. Template Loading
   ├─ 템플릿 파일 로드
   ├─ 변수 플레이스홀더 식별
   └─ 상속 관계 확인

2. Context Preparation
   ├─ 코드베이스 메타데이터 수집
   ├─ API 엔드포인트 파싱
   ├─ 의존성 그래프 생성
   └─ 설정 값 추출

3. Template Rendering
   ├─ 변수 값 치환
   ├─ 조건부 블록 처리
   ├─ 루프 반복 처리
   └─ 매크로 확장

4. Post-processing
   ├� 다이어그램 생성
   ├─ 링크 검증
   ├─ 스펠링 체크
   └─ 형식 정리

5. Output Generation
   ├─ Markdown 파일 생성
   ├─ HTML 변환 (선택)
   ├─ PDF 내보내기 (선택)
   └─ 웹사이트 배포 (선택)
```

## Advanced Features

### 1. Interactive Documentation

```typescript
// 인터랙티브 API 문서 예시
/**
 * @api {get} /api/users Get user list
 * @apiGroup Users
 * @apiDescription 사용자 목록을 페이지네이션하여 조회합니다.
 *
 * @apiParam {Number} [page=1] 페이지 번호
 * @apiParam {Number} [limit=10] 페이지당 항목 수
 *
 * @apiSuccess {Object[]} data 사용자 목록
 * @apiSuccess {String} data.id 사용자 ID
 * @apiSuccess {String} data.email 이메일
 * @apiSuccess {Object} meta 페이지 정보
 * @apiSuccess {Number} meta.total 전체 항목 수
 *
 * @apiExample {bash} 요청 예시
 * curl -X GET "https://api.example.com/users?page=1&limit=10"
 *
 * @apiExample {javascript} JavaScript 예시
 * const users = await api.users.list({ page: 1, limit: 10 });
 */
```

### 2. Code Examples Generation

자동으로 다양한 언어의 코드 예시를 생성합니다.

```
CODE EXAMPLE TEMPLATES:
├─ JavaScript/TypeScript
│   ├─ Fetch API
│   ├─ Axios
│   ├─ GraphQL Client
│   └─ WebSocket
│
├─ Python
│   ├─ Requests
│   ├─ Asyncio
│   ├─ GraphQL
│   └─ gRPC
│
├─ Go
│   ├─ Net/http
│   ├─ Gin
│   ├─ gRPC
│   └─ GraphQL
│
└─ 기타
    ├─ Java (OkHttp, Retrofit)
    ├─ C# (HttpClient)
    ├─ PHP (Guzzle)
    └─ Ruby (Faraday)
```

### 3. Documentation Versioning

```yaml
# .claude/docs-config.yml
versioning:
  strategy: "semantic"  # semantic, date, custom
  auto_tag: true
  changelog:
    generate: true
    format: "keepachangelog"
    sections:
      - "Added"
      - "Changed"
      - "Deprecated"
      - "Removed"
      - "Fixed"
      - "Security"

multiversion:
  enabled: true
  max_versions: 5
  latest_alias: "current"
  legacy_redirect: true
```

### 4. Custom Documentation Sections

```yaml
# .claude/custom-sections.yml
sections:
  - name: "Quick Start"
    template: "sections/quick-start.md"
    priority: 1

  - name: "Authentication"
    template: "sections/auth.md"
    required: true
    conditions:
      - has_auth: true

  - name: "Rate Limiting"
    template: "sections/rate-limiting.md"
    auto_generate: true
    source: "rate-limiter.config"
```

## Integration Examples

### 1. NestJS 프로젝트 문서화

```bash
# 전체 문서 생성
/generate-docs --framework nestjs

# 결과물:
# - CLAUDE.md (Claude Code 설정)
# - README.md (프로젝트 소개)
# - docs/api/ (OpenAPI 스펙)
# - docs/guides/ (사용 가이드)
# - docs/architecture/ (아키텍처 다이어그램)
```

### 2. 모놀리스 to 마이크로서비스 마이그레이션 문서

```bash
# 마이그레이션 가이드 생성
/generate-docs --type migration --from monolith --to microservices

# 생성되는 문서:
# - migration-strategy.md
# - service-boundaries.md
# - data-consistency.md
# - deployment-strategy.md
```

### 3. API 변경에 따른 문서 업데이트

```bash
# 코드 변경 후 자동 문서 업데이트
/update-docs --since HEAD~5

# 변경사항:
# - 새로운 엔드포인트 추가
# - 기존 엔드포인트 수정
# - 변경 로그 업데이트
# - 영향받는 클라이언트 코드 예시 업데이트
```

## Best Practices

### 1. 문서 구조
- **金字塔 구조**: 개요 → 상세 → 참조
- **사용자 중심**: 사용자 관점에서 정보 구성
- **일관성**: 전체 문서에서 일관된 용어와 형식
- **탐색 용이**: 명확한 네비게이션과 검색

### 2. 내용 작성
- **간결함**: 불필요한 설명 제거
- **예시 중심**: 코드 예시로 실제 사용법 보여줌
- **시각적 요소**: 다이어그램, 스크린샷 적극 활용
- **실용성**: 바로 적용할 수 있는 정보 제공

### 3. 유지보수
- **자동화**: 코드와 동기화 자동화
- **정기 검토**: 정기적으로 문서 정확성 검토
- **피드백 루프**: 사용자 피드백 반영
- **버전 관리**: 문서 변경 이력 추적

## Performance Considerations

- **증분 생성**: 변경된 부분만 재생성
- **병렬 처리**: 독립적인 섹션은 병렬로 생성
- **캐싱**: 템플릿 파싱 결과 캐싱
- **프리컴파일**: 자주 사용되는 다이어그램 미리 생성

## Configuration

### 문서 생성 설정 (.claude/docs.yml)

```yaml
project:
  name: "${PROJECT_NAME}"
  version: "${PROJECT_VERSION}"
  description: "${PROJECT_DESCRIPTION}"

generation:
  sources:
    - path: "src/**/*.ts"
      parser: "typescript"
    - path: "src/**/*.py"
      parser: "python"
    - path: "api/**/*.yml"
      parser: "openapi"

  output:
    directory: "docs"
    format: ["markdown", "html"]
    theme: "default"

  templates:
    base_dir: ".claude/templates"
    custom_dir: "docs/templates"

  features:
    diagrams: true
    code_examples: true
    search_index: true
    version_comparison: true

  exclude:
    paths: ["**/*.test.ts", "**/*.spec.ts"]
    patterns: ["internal/", "debug/"]

  post_processing:
    - spell_check
    - link_validation
    - markdown_lint
    - accessibility_check
```

## Troubleshooting

### 일반적인 문제

#### 생성된 문서가 불완전할 때
```
원인: 코드 분석 실패 또는 템플릿 오류
해결:
1. 로그 확인: /generate-docs --verbose
2. 소스 코드 검증: 주석과 타입 정의 확인
3. 템플릿 디버깅: --debug-template
```

#### API 문서가 올바르지 않을 때
```
원인: 데코레이터 미사용 또는 스펙 오류
해결:
1. API 데코레이터 확인 (@ApiOperation, @ApiResponse)
2. OpenAPI 스펙 검증
3. 엔드포인트 그룹화 확인
```

[parent](../CLAUDE.md)