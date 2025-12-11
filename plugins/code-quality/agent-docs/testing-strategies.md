# Testing Strategies

> Suites 3.x 기반 테스트 전략 및 패턴 가이드

## Overview

test-automator 에이전트는 Suites 3.x (구 Automock)를 기반으로 테스트를 자동 생성합니다.

```
TESTING PYRAMID:
                    ┌─────────┐
                    │   E2E   │  10%
                    │  Tests  │
                    ├─────────┤
                    │ Integra │  20%
                    │  tion   │
            ┌───────┴─────────┴───────┐
            │      Unit Tests         │  70%
            │                         │
            └─────────────────────────┘
```

---

## Suites 3.x 핵심 개념

### TestBed API

```typescript
import { TestBed, type Mocked } from '@suites/unit';

// Solitary Test: 모든 의존성 자동 모킹
const { unit, unitRef } = await TestBed
  .solitary(ServiceUnderTest)
  .compile();

// Sociable Test: 실제 의존성 사용
const { unit, unitRef } = await TestBed
  .sociable(ServiceUnderTest)
  .expose(RealDependency)  // 실제 구현 노출
  .compile();
```

### Mocked 타입

```typescript
// 타입 안전한 모킹
let repository: Mocked<UserRepository>;

beforeAll(async () => {
  const { unit, unitRef } = await TestBed
    .solitary(UserService)
    .compile();

  repository = unitRef.get(UserRepository);
});

// 자동 완성 지원
repository.findOne.mockResolvedValue(mockUser);
repository.save.mockImplementation(async (user) => user);
```

---

## 테스트 패턴

### 1. Service Layer Test

```typescript
import { TestBed, type Mocked } from '@suites/unit';

describe('UserService', () => {
  let service: UserService;
  let repository: Mocked<UserRepository>;
  let cacheService: Mocked<CacheService>;

  beforeAll(async () => {
    const { unit, unitRef } = await TestBed
      .solitary(UserService)
      .compile();

    service = unit;
    repository = unitRef.get(UserRepository);
    cacheService = unitRef.get(CacheService);
  });

  describe('findById', () => {
    it('should return cached user if exists', async () => {
      // Given
      const cachedUser = { id: '1', email: 'cached@test.com' };
      cacheService.get.mockResolvedValue(cachedUser);

      // When
      const result = await service.findById('1');

      // Then
      expect(result).toEqual(cachedUser);
      expect(repository.findOne).not.toHaveBeenCalled();
    });

    it('should fetch from DB and cache if not cached', async () => {
      // Given
      const dbUser = { id: '1', email: 'db@test.com' };
      cacheService.get.mockResolvedValue(null);
      repository.findOne.mockResolvedValue(dbUser);

      // When
      const result = await service.findById('1');

      // Then
      expect(result).toEqual(dbUser);
      expect(cacheService.set).toHaveBeenCalledWith('user:1', dbUser);
    });

    it('should throw NotFoundException if user not found', async () => {
      // Given
      cacheService.get.mockResolvedValue(null);
      repository.findOne.mockResolvedValue(null);

      // When/Then
      await expect(service.findById('1'))
        .rejects
        .toThrow(NotFoundException);
    });
  });
});
```

### 2. Controller Test

```typescript
import { TestBed, type Mocked } from '@suites/unit';

describe('UserController', () => {
  let controller: UserController;
  let userService: Mocked<UserService>;

  beforeAll(async () => {
    const { unit, unitRef } = await TestBed
      .solitary(UserController)
      .compile();

    controller = unit;
    userService = unitRef.get(UserService);
  });

  describe('GET /users/:id', () => {
    it('should return user dto', async () => {
      // Given
      const user = { id: '1', email: 'test@test.com', password: 'hashed' };
      userService.findById.mockResolvedValue(user);

      // When
      const result = await controller.getUser('1');

      // Then
      expect(result).toEqual({
        id: '1',
        email: 'test@test.com',
        // password should be excluded
      });
    });
  });
});
```

### 3. Repository Test (Sociable)

```typescript
import { TestBed } from '@suites/unit';
import { DataSource } from 'typeorm';

describe('UserRepository (Sociable)', () => {
  let repository: UserRepository;
  let dataSource: DataSource;

  beforeAll(async () => {
    // 실제 TypeORM 연결 사용
    dataSource = new DataSource({
      type: 'sqlite',
      database: ':memory:',
      entities: [User],
      synchronize: true,
    });
    await dataSource.initialize();

    const { unit } = await TestBed
      .sociable(UserRepository)
      .expose(DataSource) // 실제 DataSource 사용
      .mock(DataSource)
      .using(dataSource)
      .compile();

    repository = unit;
  });

  afterAll(async () => {
    await dataSource.destroy();
  });

  it('should find active users', async () => {
    // Given
    await repository.save([
      { email: 'active@test.com', deletedAt: null },
      { email: 'deleted@test.com', deletedAt: new Date() },
    ]);

    // When
    const result = await repository.findActiveUsers();

    // Then
    expect(result).toHaveLength(1);
    expect(result[0].email).toBe('active@test.com');
  });
});
```

### 4. Integration/E2E Test with Testcontainers

> 상세 가이드: [test-container.md](test-container.md)

실제 DB, Redis 등을 Docker 컨테이너로 실행하여 테스트합니다.

```
테스트 레벨별 전략:
├─ Unit: 모킹 (Suites 3.x)
├─ Integration: Testcontainers (실제 DB/캐시)
└─ E2E: Testcontainers (전체 스택)
```

### 5. CQRS Handler Test

```typescript
describe('CreateOrderHandler', () => {
  let handler: CreateOrderHandler;
  let orderRepository: Mocked<OrderRepository>;
  let eventBus: Mocked<EventBus>;

  beforeAll(async () => {
    const { unit, unitRef } = await TestBed
      .solitary(CreateOrderHandler)
      .compile();

    handler = unit;
    orderRepository = unitRef.get(OrderRepository);
    eventBus = unitRef.get(EventBus);
  });

  it('should create order and publish event', async () => {
    // Given
    const command = new CreateOrderCommand('user-1', [
      { productId: 'prod-1', quantity: 2 },
    ]);
    const savedOrder = { id: 'order-1', ...command };
    orderRepository.save.mockResolvedValue(savedOrder);

    // When
    const result = await handler.execute(command);

    // Then
    expect(result.id).toBe('order-1');
    expect(eventBus.publish).toHaveBeenCalledWith(
      expect.any(OrderCreatedEvent)
    );
  });
});
```

---

## 테스트 자동 생성

### test-automator 워크플로우

```
TEST GENERATION FLOW:
┌─────────────────┐
│  Source File    │ ─── user.service.ts
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  AST Analysis   │ ─── 메서드, 의존성 분석
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Test Template   │ ─── Suites 3.x 템플릿
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Test Cases     │ ─── Happy path, Edge cases
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Output File    │ ─── user.service.spec.ts
└─────────────────┘
```

### 생성 규칙

```
TEST GENERATION RULES:
├─ 메서드당 최소 테스트
│   ├─ 정상 케이스 (Happy path)
│   ├─ 에러 케이스 (예외 상황)
│   └─ 경계 조건 (Edge cases)
│
├─ 모킹 전략
│   ├─ 외부 서비스: 항상 모킹
│   ├─ Repository: 기본 모킹, 옵션으로 실제 DB
│   └─ 유틸리티: 상황에 따라 결정
│
└─ 명명 규칙
    ├─ describe: 클래스명
    ├─ nested describe: 메서드명
    └─ it: should + 동작 설명
```

---

## 커버리지 전략

### 목표 커버리지

| 레이어 | 목표 | 우선순위 |
|--------|------|----------|
| Service | 90%+ | 높음 |
| Controller | 80%+ | 중간 |
| Repository | 70%+ | 중간 |
| Utils | 95%+ | 높음 |
| E2E | 핵심 플로우 | 필수 |

### 커버리지 측정

```bash
# 전체 커버리지
npm run test:cov

# 특정 파일/디렉토리
npm run test:cov -- --collectCoverageFrom='src/users/**/*.ts'

# 최소 임계값 설정
# jest.config.js
coverageThreshold: {
  global: {
    branches: 80,
    functions: 80,
    lines: 80,
    statements: 80,
  },
},
```

---

## Best Practices

### 1. Given-When-Then 패턴

```typescript
it('should return user when found', async () => {
  // Given (준비)
  const mockUser = { id: '1', email: 'test@test.com' };
  repository.findOne.mockResolvedValue(mockUser);

  // When (실행)
  const result = await service.findById('1');

  // Then (검증)
  expect(result).toEqual(mockUser);
});
```

### 2. 테스트 격리

```typescript
describe('UserService', () => {
  // 각 테스트마다 새로운 인스턴스
  beforeEach(async () => {
    const { unit, unitRef } = await TestBed
      .solitary(UserService)
      .compile();
    // ...
  });

  // 또는 모킹 리셋
  afterEach(() => {
    jest.clearAllMocks();
  });
});
```

### 3. 테스트 이름은 한글로

```typescript
// 좋은 예 - 한글로 명확하게
it('존재하지 않는 사용자 조회 시 NotFoundException을 던진다')
it('DB에서 조회 후 캐시에 저장한다')
it('사용자 수정 시 캐시를 무효화한다')

// 나쁜 예 - 영어 또는 모호한 이름
it('should work')
it('test findById')
it('error case')
```

한글 테스트 이름의 장점:
- 테스트 실패 시 즉시 이해 가능
- 비개발자도 테스트 결과 파악 가능
- 요구사항과 테스트 매핑이 명확

---

**관련 문서**: [CLAUDE.md](../CLAUDE.md) | [security-analysis.md](security-analysis.md) | [review-workflow.md](review-workflow.md)
