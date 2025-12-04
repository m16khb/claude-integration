# 예제 모음

## 커맨드 예제

### 1. 최적화 커맨드

```markdown
---
name: optimize-command
description: '프롬프트 엔지니어링 원칙으로 커맨드 최적화'
argument-hint: <command-file-path>
model: claude-opus-4-5-20251101
allowed-tools:
  - Read
  - Write
  - Edit
---

# 커맨드 최적화

## 실행 방법
```bash
/optimize-command plugins/my-plugin/commands/my-command.md
```

## 최적화 원칙
1. 명확한 목적 정의
2. 최소한의 인자
3. 선제적인 에러 핸들링
```

### 2. 에이전트 생성 커맨드

```markdown
---
name: agent-creator
description: '전문가 에이전트 생성'
argument-hint: [agent-description]
model: claude-opus-4-5-20251101
---

에이전트 생성을 위한 상세 가이드 제공
```

## 에이전트 예제

### 1. TypeORM 전문가

```markdown
---
name: typeorm-expert
description: 'TypeORM 전문가 - 엔티티, 리포지토리, 마이그레이션'
model: claude-opus-4-5-20251101
allowed-tools:
  - Read
  - Write
  - Edit
---

## Purpose
TypeORM의 모든 측면을 다루는 데이터베이스 전문가

## Capabilities
- 엔티티 설계 및 관계 정의
- 복잡한 쿼리 최적화
- 마이그레이션 전략 수립
```

### 2. 코드 리뷰 전문가

```markdown
---
name: code-reviewer
description: '코드 리뷰 전문가 - 보안, 성능, 품질 분석'
model: claude-3-5-sonnet-20241022
allowed-tools:
  - Read
  - Grep
  - Bash
---

## Purpose
프로덕션 수준의 코드 품질 보장

## Behavioral Traits
- 보안 취약점에 대한 민감도
- 성능 병목 현상 식별
- 유지보수성 고려
```

## 스킬 예제

### 1. 에이전트 라우팅 스킬

```markdown
---
name: agent-routing
description: 'NestJS 백엔드 요청 → 전문가 에이전트 자동 선택'
triggers: ['백엔드', 'nestjs', 'redis', 'typeorm']
auto_activate: true
---

## 라우팅 로직
1. 키워드 추출
2. 점수 계산 (primary: 3, secondary: 2, context: 1)
3. 최고 점수 에이전트 선택
4. 실행 전략 결정 (SINGLE, SEQUENTIAL, PARALLEL)
```

### 2. 테스트 패턴 스킬

```markdown
---
name: testing-patterns
description: 'Suites 3.x 기반 테스트 패턴 지식'
triggers: ['테스트', 'suites', 'automock']
auto_activate: true
---

## 패턴 라이브러리
- Unit Test: TestBed.solitary()
- Integration: TestBed.sociable()
- E2E: 실제 환경 모킹
```

## 워크플로우 예제

### 1. 개발 플로우 (/dev-flow)

```bash
# 1. 코드 구현
# User: "게임 유저 API 구현"

# 2. /dev-flow 실행
/dev-flow

# 3. 자동 실행
# └─ code-reviewer: 보안 및 성능 검토
# └─ test-automator: Suites 3.x 테스트 생성
# └─ git-commit: 스마트 커밋
```

### 2. 복합 요청 처리

```bash
# User: "Redis 캐시와 BullMQ 큐 설정"

# 1. 키워드 감지
# - Redis (3점), 캐시 (3점)
# - BullMQ (3점), 큐 (3점)
# - 총점: 6점 (동점)

# 2. 병렬 실행
# └─ redis-cache-expert: 캐시 전략 수립
# └─ bullmq-queue-expert: 큐 시스템 설계

# 3. 결과 통합
# 통합된 설정 파일 제공
```

## 실제 시나리오

### 시나리오 1: 게임 서버 아키텍처

```bash
# 사용자 요청
"게임 서버 백엔드 설계해줘. NestJS 사용하고, Redis 캐시도 필요하고,
실시간 처리는 WebSocket으로 구현해줘."

# 라우팅 분석
- nestjs (3점) → nestjs-fastify-expert
- redis (3점) → redis-cache-expert
- websocket (2점) → microservices-expert

# 실행 계획
1. nestjs-fastify-expert (오케스트레이터)
   ├─ 프로젝트 구조 설계
   ├─ Fastify 설정
   └─ WebSocket 통합
2. redis-cache-expert (병렬)
   └─ 캐시 전략 수립
3. suites-testing-expert (순차)
   └─ 통합 테스트 작성
```

### 시나리오 2: API 보강

```bash
# 사용자 요청
"/auth API에 보안 취약점 점검하고 테스트 코드 추가해줘"

# 자동 활성화
- code-reviewer (보안 검토)
- test-automator (테스트 생성)

# 실행 결과
1. 보안 취약점 보고서
2. 수정된 코드
3. Suites 3.x 테스트 코드
4. 커버리지 리포트
```

## Git 커밋 예제

### 1. 스마트 커밋

```bash
# 실행
/git-commit push

# 자동 분석
- 변경된 파일: 15개
- 주요 변경: Auth 모듈 추가
- 영향 도메인: 보안, API

# 생성된 커밋 메시지
feat: JWT 기반 인증 시스템 구현

- AccessToken, RefreshToken 발급 로직 추가
- Passport JWT 전략 설정
- AuthGuard 적용으로 보안 강화
- 로그인/회원가입 API 완료

Closes #123

🤖 Generated with Claude Code
```

### 2. 프리훅 통합

```bash
# 커밋 전 자동 실행
.git/hooks/pre-commit

1. code-reviewer 자동 실행
2. 테스트 실패 시 커밋 중단
3. 보안 취약점 발견 시 경고
```

## MCP 서버 통합 예제

### 1. Playwright 자동화

```typescript
// 자동 생성된 테스트 코드
import { test, expect } from '@playwright/test';

test('게임 로그인', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'test@example.com');
  await page.fill('[data-testid="password"]', 'password123');
  await page.click('[data-testid="login-button"]');

  await expect(page.locator('[data-testid="user-menu"]')).toBeVisible();
});
```

### 2. Context7 문서 조회

```bash
# 사용자 요청
"Next.js 15 최신 문서 보여줘"

# Context7 자동 조회
- 라이브러리 ID 해석: /vercel/next.js/v15
- 관련 주제 추출: app router, server components
- 최신 문서 주입
```

## 에러 핸들링 예제

### 1. 라우팅 실패

```bash
# 사용자 요청
"양자 컴퓨팅 알고리즘 구현"

# 라우팅 결과
- 매칭되는 에이전트 없음
- 유사 키워드: '알고리즘' (2점)

# 응답
"죄송합니다, 양자 컴퓨팅은 현재 지원하지 않는 도메인입니다.
일반 알고리즘 구현이 필요하시면 알려주세요."
```

### 2. 병렬 실행 충돌

```bash
# 충돌 상황
- redis-cache-expert: localhost:6379 제안
- 기존 설정: localhost:6380 사용 중

# 해결
- 사용자에게 선택지 제공
- 자동 포트 충돌 감지
- 안전한 기본값 제안
```

## 성능 최적화 예제

### 1. 캐시 전략

```typescript
// redis-cache-expert 제안
@Injectable()
export class GameService {
  @CacheKey('game:${id}')
  @CacheTTL(3600) // 1시간
  async findGame(id: string) {
    return this.repository.findOne(id);
  }
}
```

### 2. 큐 최적화

```typescript
// bullmq-queue-expert 제안
@Processor('game-events')
export class GameEventProcessor {
  @Process(GameEventTypes.USER_ACTION)
  async handleUserAction(job: Job<UserActionEvent>) {
    // 배치 처리로 성능 향상
    const batch = await job.getChildren();
    // ...
  }
}
```