# Context Management 사용 예제

이 문서는 context-management 플러그인의 사용 예제와 통합 패턴을 제공합니다.

## 목차

- [continue-context 예제](#continue-context-예제)
- [inject-context 예제](#inject-context-예제)
- [통합 패턴](#통합-패턴)
- [결과물 예시](#결과물-예시)

---

## continue-context 예제

### 기본 사용법

```bash
# 기본 분석
/context-management:continue-context

# 특정 영역 집중
/context-management:continue-context authentication

# 배포 준비 상태 분석
/context-management:continue-context deployment
```

### 분석 결과 예시

```json
{
  "current_state": {
    "branch": "feature/user-auth",
    "changes": 15,
    "uncommitted_files": ["src/auth/", "test/auth.spec.ts"],
    "last_action": "created JWT service"
  },
  "analysis": {
    "work_type": "feature_development",
    "completion_rate": 0.65,
    "blockers": [],
    "risks": ["missing tests", "security review needed"]
  },
  "recommendations": [
    {
      "action": "Write unit tests",
      "priority": "high",
      "agent": "suites-testing-expert",
      "command": "Generate tests for AuthService",
      "estimated_time": "15min"
    },
    {
      "action": "Security review",
      "priority": "high",
      "agent": "code-reviewer",
      "command": "Review auth module for vulnerabilities",
      "estimated_time": "10min"
    },
    {
      "action": "Update documentation",
      "priority": "medium",
      "agent": "document-builder",
      "command": "Document authentication flow",
      "estimated_time": "5min"
    }
  ],
  "next_steps": [
    "Run: /code-quality:review src/auth/",
    "Execute: test generation for AuthService",
    "Commit with message: 'feat: implement JWT authentication'"
  ]
}
```

### 컨텍스트 리포트 예시

```markdown
## 컨텍스트 분석 결과

### 로드된 파일 (5개)
| 파일 | 라인 | 역할 | 핵심 요소 |
|------|------|------|----------|
| src/auth/auth.service.ts | 150 | 서비스 | JWT 생성, 검증 |
| src/auth/auth.controller.ts | 80 | 컨트롤러 | login, logout |

### 파일 관계
auth.controller → auth.service → jwt.service

### 완료된 작업
- JWT 서비스 구현
- 로그인 엔드포인트 생성

### 진행 중/중단된 작업
- 테스트 작성 (진행률: 0%)
- 중단 지점: 서비스 구현 완료 후

### 마지막 작업 지점
| 항목 | 내용 |
|------|------|
| 작업 | JWT 서비스 생성 |
| 상태 | 완료 |
```

---

## inject-context 예제

### 기본 사용법

```bash
# 기본 파일 주입
/context-management:inject-context src/app.module.ts

# 태스크와 함께 주입
/context-management:inject-context src/database/ "데이터베이스 설정 최적화"

# 여러 파일 주입
/context-management:inject-context src/**/*.entity.ts "엔티티 관계 분석"

# 심층 분석 모드
/context-management:inject-context --deep src/user.service.ts
```

### 청크 결과 예시

```json
{
  "file": "src/app.module.ts",
  "total_chunks": 4,
  "selected_chunks": 2,
  "chunks": [
    {
      "id": "chunk-1",
      "type": "imports",
      "relevance_score": 0.9,
      "content": "import { Module } from '@nestjs/common';...",
      "dependencies": ["ConfigModule", "DatabaseModule"],
      "token_count": 156
    },
    {
      "id": "chunk-2",
      "type": "module_definition",
      "relevance_score": 0.95,
      "content": "@Module({\n  imports: [...],\n  controllers: [...],...",
      "dependencies": ["UserController", "UserService"],
      "token_count": 289
    }
  ],
  "summary": {
    "primary_components": ["AppModule", "DatabaseModule"],
    "key_patterns": ["dependency_injection", "module_structure"],
    "suggestions": ["Consider splitting into feature modules"]
  }
}
```

### 완료 리포트 예시

```
+------------------------------------------------------------+
|              파일 컨텍스트 로딩 완료                          |
+------------------------------------------------------------+
| 파일: src/auth/auth.service.ts                              |
| 크기: 350줄 (12KB)                                          |
| 청크: 2개 (오버랩 20줄)                                      |
| 구조점: 8개 탐지                                             |
+------------------------------------------------------------+
| 파일 내용이 컨텍스트에 원문 그대로 로드되었습니다.            |
| 이제 자유롭게 질문하거나 작업을 진행하세요.                   |
+------------------------------------------------------------+
```

---

## 통합 패턴

### IDE 통합

```json
// VS Code 확장 설정
{
  "contextManagement": {
    "autoAnalyze": true,
    "showSuggestions": true,
    "keybindings": {
      "analyzeContext": "ctrl+shift+a",
      "injectContext": "ctrl+shift+i"
    },
    "statusBar": {
      "showContextStatus": true,
      "showRecommendations": true
    }
  }
}
```

### Git Hooks 통합

```bash
#!/bin/sh
# .git/hooks/post-checkout
# 브랜치 변경 시 컨텍스트 자동 로드
/context-management:continue-context --branch $GIT_BRANCH

# .git/hooks/pre-commit
# 커밋 전 컨텍스트 분석
/context-management:continue-context --commit-prep
```

### CI/CD 통합

```yaml
# .github/workflows/context-analysis.yml
name: Context Analysis

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Analyze context
        run: /context-management:continue-context --pr-analysis
      - name: Update PR with recommendations
        uses: actions/github-script@v6
        with:
          script: |
            const recommendations = require('./context-analysis.json');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: formatRecommendations(recommendations)
            });
```

### MCP Memory 통합

```
MCP Memory 연동 시 이점:
├─ 이전 분석 결과 자동 로드
├─ 해당 파일 관련 작업 히스토리
├─ 팀원이 남긴 노트/메모
├─ 관련 버그 수정 기록
└─ 세션 간 컨텍스트 연속성 보장
```

Memory 검색 예시:

```
# 1. 파일 경로로 관련 메모리 검색
mcp__memory__retrieve_memory:
  query: "src/auth/auth.service.ts"

# 2. 모듈명으로 추가 검색
mcp__memory__search_memories:
  query: "auth"
  tags: ["auth", "project_name"]
```

---

## 결과물 예시

### 동적 추천 로직

```
GENERATE recommendations based on context:

IF uncommitted_changes:
  ADD: "변경사항 커밋" → /git-commit

IF loaded_files AND no_work_done:
  ADD: "파일 분석 및 설명"

IF code_written AND no_tests:
  ADD: "테스트 작성"

IF tests_exist AND not_run:
  ADD: "테스트 실행"

IF tests_failed:
  ADD: "테스트 수정"

IF todo_items_pending:
  ADD: "할 일 처리: {todo}"

IF complex_code:
  ADD: "리팩토링 제안"

IF no_documentation:
  ADD: "문서 작성"
```

### 작업 히스토리 추적

```
TRACK conversation history:

1. COMPLETED TASKS:
   ├─ 파일 생성/수정
   ├─ 커밋 수행
   ├─ 테스트 실행
   ├─ 분석/설명 제공
   └─ 오류 해결

2. IN-PROGRESS TASKS:
   ├─ 시작했으나 완료되지 않은 작업
   ├─ 중단된 구현
   ├─ 대기 중인 확인 사항
   └─ 미해결 질문

3. LAST WORK POINT:
   ├─ 마지막 사용자 요청
   ├─ 마지막 Claude 작업
   ├─ 마지막 파일 수정
   └─ 중단 지점의 상태
```

---

[메인 문서](../CLAUDE.md) | [상세 가이드](detailed-guides.md) | [참고 자료](references.md)
