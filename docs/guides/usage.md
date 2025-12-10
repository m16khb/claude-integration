# Usage Guide

## 설치

### 1. 마켓플레이스 추가

```bash
/plugin marketplace add m16khb/claude-integration
```

### 2. 플러그인 설치

```bash
# 모든 플러그인 설치
/plugin install claude-integration

# 또는 개별 플러그인 설치
/plugin install backend-development
/plugin install documentation-generation
/plugin install git-workflows
/plugin install context-management
/plugin install automation-tools
```

## 커맨드 사용법

### Git 워크플로우

#### `/git-commit`
Git Flow 기반 스마트 커밋

```bash
# 기본 커밋
/git-commit

# 커밋 후 자동 푸시
/git-commit push
```

**기능:**
- Conventional Commits 형식 자동 생성
- 변경 사항 분석 및 적절한 커밋 타입 선택
- 한글 커밋 메시지 지원

---

### 컨텍스트 관리

#### `/continue-context`
현재 컨텍스트를 분석하여 다음 작업 추천

```bash
/continue-context

# 특정 영역에 집중
/continue-context backend
```

**기능:**
- 최근 대화 분석
- 미완료 작업 식별
- 다음 단계 제안

#### `/inject-context`
대용량 파일 구조 인식 청킹 및 컨텍스트 주입

```bash
/inject-context ./large-file.ts

# 특정 작업과 함께
/inject-context ./large-file.ts "이 파일 리팩토링해줘"
```

**기능:**
- 대용량 파일 자동 청킹
- 구조 인식 분할 (클래스, 함수 단위)
- 점진적 컨텍스트 주입

---

### 자동화 도구

#### `/factory`
Agent, Skill, Command 컴포넌트 생성기

```bash
# 에이전트 생성
/factory agent user-auth

# 스킬 생성
/factory skill database-optimization

# 커맨드 생성
/factory command deploy-staging
```

**기능:**
- Anthropic 2025 스키마 준수
- 표준화된 템플릿 사용
- 자동 등록 지원

#### `/setup-statusline`
YAML 기반 status line 환경 구성

```bash
/setup-statusline
```

**기능:**
- 대화형 설정 UI
- YAML 설정 파일 생성
- 실시간 미리보기

#### `/claude-sync`
코드베이스 변경 감지 및 CLAUDE.md 자동 동기화

```bash
/claude-sync
```

**기능:**
- 파일 구조 변경 감지
- CLAUDE.md 자동 업데이트
- 계층적 문서 동기화

---

## 에이전트 사용법

### Orchestrator를 통한 사용 (권장)

```typescript
// NestJS 백엔드 개발 - Orchestrator가 자동 위임
Task(
  subagent_type="nestjs-fastify-expert",
  prompt="Redis 캐시 설정하고 BullMQ 큐도 추가해줘"
)
```

Orchestrator는 자동으로:
1. 요청 분석
2. 적절한 전문가 선택
3. 순차/병렬 실행
4. 결과 통합

### 직접 전문가 호출

```typescript
// TypeORM 전문가 직접 호출
Task(
  subagent_type="typeorm-expert",
  prompt="User 엔티티 만들어줘"
)

// 문서 빌더 직접 호출
Task(
  subagent_type="document-builder",
  prompt="""
  Action: CREATE
  Target Path: commands
  Target Type: MODULE
  Context: 새로운 커맨드 모듈 문서화
  """
)
```

---

## 라우팅 예시

```
USER REQUEST → ROUTING DECISION

"Redis 캐시 설정해줘"
  → SINGLE_EXPERT: redis-cache-expert

"TypeORM으로 User 엔티티 만들고 테스트도 작성해줘"
  → SEQUENTIAL: typeorm-expert → suites-testing-expert

"BullMQ 큐랑 Redis 캐시 둘 다 설정"
  → PARALLEL: [bullmq-queue-expert, redis-cache-expert]

"Fastify 어댑터 설정하고 helmet, cors 플러그인 추가"
  → DIRECT: (Orchestrator 직접 처리)
```

---

## MCP 서버 사용법

플러그인 활성화 시 자동으로 로드되는 MCP 서버:

### Playwright (브라우저 자동화)

```bash
# 브라우저 열기
"playwright로 example.com 열어줘"

# 스크린샷 캡처
"현재 페이지 스크린샷 찍어줘"
```

### Context7 (최신 문서 주입)

```bash
# 라이브러리 문서 조회
"use context7 React 19 새 기능 알려줘"

# 특정 토픽 조회
"use context7 TypeORM migrations 사용법"
```

### Sequential Thinking (단계별 사고)

복잡한 문제 분석 시 자동 활성화됩니다.

### Chrome DevTools (크롬 개발자 도구)

```bash
# 열린 크롬 탭 분석
"현재 열린 크롬 탭 분석해줘"

# 성능 분석
"이 페이지 성능 분석해줘"
```

---

## 팁

### 효율적인 사용을 위한 권장 사항

1. **Orchestrator 활용**: 복합 작업은 `nestjs-fastify-expert`를 통해 자동 위임
2. **컨텍스트 관리**: 대용량 파일은 `/inject-context`로 청킹 후 주입
3. **작업 연속성**: `/continue-context`로 다음 작업 확인
4. **커밋 자동화**: `/git-commit`으로 일관된 커밋 메시지 유지

### 트러블슈팅

```bash
# MCP 서버 상태 확인
claude mcp list

# 플러그인 목록 확인
/plugin list

# 플러그인 재설치
/plugin uninstall backend-development
/plugin install backend-development
```
