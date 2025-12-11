# Testing Patterns Skill (Suites 3.x)

**Suites 3.x (구 Automock)** 기반 NestJS 테스트 작성 패턴 가이드입니다.

## MCP Integration

```
SKILL ACTIVATION:
├─ Context7 MCP 호출 (최신 Suites 문서 조회)
│   ├─ resolve-library-id("@suites/unit")
│   ├─ get-library-docs(topic="TestBed solitary sociable")
│   └─ 최신 API 변경사항 확인
│
└─ 적용 시점:
    ├─ 이 스킬 활성화 시 자동
    └─ 최신 Suites 패턴 필요 시
```

---

## Triggers

- "테스트", "test", "testing"
- "suites", "automock"
- "jest", "vitest"
- "unit test", "단위 테스트"
- "integration test", "통합 테스트"
- "e2e", "end-to-end"
- "mock", "모킹", "stub"
- "coverage", "커버리지"
- "solitary", "sociable"

---

## Suites 3.x 핵심 개념

### 설치

```bash
# 기본 패키지
npm i -D @suites/unit

# NestJS + Jest
npm i -D @suites/doubles.jest @suites/di.nestjs

# NestJS + Vitest
npm i -D @suites/doubles.vitest @suites/di.nestjs
```

### 핵심 API

| API | 설명 |
|-----|------|
| `TestBed.solitary(Class)` | 모든 의존성 자동 모킹 (격리 테스트) |
| `TestBed.sociable(Class)` | 선택적 실제 구현 (통합 테스트) |
| `await .compile()` | **비동기** - 반드시 await 필요 |
| `unit` | 테스트 대상 인스턴스 |
| `unitRef.get(Dep)` | 모킹된 의존성 접근 |
| `Mocked<T>` | Jest/Vitest 통합 타입 |
| `.expose(Dep)` | Sociable에서 실제 구현 유지 |
| `.impl(fn)` | 커스텀 모킹 구현 |

---

## Solitary Mode (격리 테스트)

모든 의존성을 자동으로 모킹하여 단일 유닛을 완전히 격리합니다.

### 기본 패턴

```typescript
import { TestBed, type Mocked } from '@suites/unit';
import { UserService } from './user.service';
import { UserRepository } from './user.repository';

describe('UserService', () => {
  let userService: UserService;
  let userRepository: Mocked<UserRepository>;

  beforeAll(async () => {
    // ⚠️ await 필수! compile()은 비동기
    const { unit, unitRef } = await TestBed.solitary(UserService).compile();

    userService = unit;
    userRepository = unitRef.get(UserRepository);
  });

  it('should find user by id', async () => {
    // Arrange
    const mockUser = { id: '1', email: 'test@example.com' };
    userRepository.findOne.mockResolvedValue(mockUser);

    // Act
    const result = await userService.findById('1');

    // Assert
    expect(result).toEqual(mockUser);
    expect(userRepository.findOne).toHaveBeenCalledWith({ where: { id: '1' } });
  });
});
```

---

## Sociable Mode (선택적 통합)

선택한 의존성은 실제 구현을 사용하고, 나머지는 모킹합니다.

```typescript
import { TestBed, type Mocked } from '@suites/unit';

describe('OrderService (Sociable)', () => {
  let orderService: OrderService;
  let paymentGateway: Mocked<PaymentGateway>;

  beforeAll(async () => {
    const { unit, unitRef } = await TestBed.sociable(OrderService)
      .expose(OrderValidator)  // OrderValidator는 실제 구현 사용
      .compile();

    orderService = unit;
    paymentGateway = unitRef.get(PaymentGateway);
  });

  it('should validate order with real validator', async () => {
    const invalidOrder = { items: [], total: 0 };
    paymentGateway.charge.mockResolvedValue({ success: true });

    await expect(orderService.processOrder(invalidOrder))
      .rejects.toThrow('Empty order');
  });
});
```

---

## AAA Pattern (Arrange-Act-Assert)

```typescript
it('should calculate total with discount', async () => {
  // Arrange - 테스트 데이터 준비
  const items = [{ id: 1, price: 1000, quantity: 2 }];
  const discount = 0.1;

  // Act - 테스트 대상 실행
  const result = await orderService.calculateTotal(items, discount);

  // Assert - 결과 검증
  expect(result).toBe(1800);
});
```

---

## Test Naming Conventions

### 권장 형식

```typescript
// ✅ should_동작_when_조건
it('should return user when found by id', async () => {});
it('should throw NotFoundException when user not found', async () => {});

// ❌ 나쁜 예
it('test1', async () => {});
it('works', async () => {});
```

### describe 그룹화

```typescript
describe('UserService', () => {
  describe('findById', () => {
    it('should return user when found', async () => {});
    it('should throw when not found', async () => {});
  });

  describe('create', () => {
    it('should create user with valid data', async () => {});
    it('should throw on duplicate email', async () => {});
  });
});
```

---

## Anti-Patterns to Avoid

### 1. await 누락

```typescript
// ❌ BAD - compile()에 await 누락
beforeAll(() => {
  const { unit } = TestBed.solitary(UserService).compile();
});

// ✅ GOOD
beforeAll(async () => {
  const { unit } = await TestBed.solitary(UserService).compile();
});
```

### 2. 구현 세부사항 테스트

```typescript
// ❌ BAD - 내부 구현 테스트
it('should call repository.save once', () => {
  service.createUser(dto);
  expect(mockRepo.save).toHaveBeenCalledTimes(1);
});

// ✅ GOOD - 동작 결과 테스트
it('should return created user with id', async () => {
  const result = await service.createUser(dto);
  expect(result).toHaveProperty('id');
});
```

---

## Quick Reference

| 시나리오 | 패턴 |
|----------|------|
| 값 반환 테스트 | `expect(fn()).toBe(value)` |
| 비동기 성공 | `await expect(fn()).resolves.toBe(value)` |
| 동기 에러 | `expect(() => fn()).toThrow(Error)` |
| 비동기 에러 | `await expect(fn()).rejects.toThrow(Error)` |
| 호출 검증 | `expect(mock.method).toHaveBeenCalledWith(arg)` |
| 호출 횟수 | `expect(mock.method).toHaveBeenCalledTimes(n)` |

---

## Sources

- [Suites GitHub](https://github.com/suites-dev/suites)
- [NestJS Suites Recipe](https://docs.nestjs.com/recipes/suites)
- [Suites Migration Guide](https://suites.dev/docs/migration-guides/from-automock)
