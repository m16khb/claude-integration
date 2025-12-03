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

# NestJS + Jest 조합
npm i -D @suites/doubles.jest @suites/di.nestjs

# NestJS + Vitest 조합
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

### 여러 의존성 테스트

```typescript
import { TestBed, type Mocked } from '@suites/unit';
import { OrderService } from './order.service';
import { OrderRepository } from './order.repository';
import { PaymentService } from './payment.service';
import { NotificationService } from './notification.service';

describe('OrderService', () => {
  let orderService: OrderService;
  let orderRepository: Mocked<OrderRepository>;
  let paymentService: Mocked<PaymentService>;
  let notificationService: Mocked<NotificationService>;

  beforeAll(async () => {
    const { unit, unitRef } = await TestBed.solitary(OrderService).compile();

    orderService = unit;
    orderRepository = unitRef.get(OrderRepository);
    paymentService = unitRef.get(PaymentService);
    notificationService = unitRef.get(NotificationService);
  });

  it('should process order and send notification', async () => {
    // Arrange
    const order = { id: '1', total: 100 };
    orderRepository.findOne.mockResolvedValue(order);
    paymentService.charge.mockResolvedValue({ success: true });
    notificationService.send.mockResolvedValue(undefined);

    // Act
    await orderService.processOrder('1');

    // Assert
    expect(paymentService.charge).toHaveBeenCalledWith(100);
    expect(notificationService.send).toHaveBeenCalled();
  });
});
```

---

## Sociable Mode (선택적 통합)

선택한 의존성은 실제 구현을 사용하고, 나머지는 모킹합니다.

```typescript
import { TestBed, type Mocked } from '@suites/unit';
import { OrderService } from './order.service';
import { OrderValidator } from './order.validator';
import { PaymentGateway } from './payment.gateway';

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
    // Arrange
    const invalidOrder = { items: [], total: 0 };
    paymentGateway.charge.mockResolvedValue({ success: true });

    // Act & Assert - OrderValidator의 실제 검증 로직 실행
    await expect(orderService.processOrder(invalidOrder)).rejects.toThrow('Empty order');
  });
});
```

---

## Custom Mock Implementation

### .impl() 메서드

```typescript
import { TestBed, type Mocked } from '@suites/unit';

describe('UserService with Custom Mocks', () => {
  let userService: UserService;
  let userRepository: Mocked<UserRepository>;

  beforeAll(async () => {
    const { unit, unitRef } = await TestBed.solitary(UserService)
      .mock(UserRepository)
      .impl((stubFn) => ({
        findOne: stubFn().mockImplementation((criteria) => {
          if (criteria.where.id === 'admin') {
            return Promise.resolve({ id: 'admin', role: 'admin' });
          }
          return Promise.resolve(null);
        }),
        save: stubFn().mockImplementation((entity) => {
          return Promise.resolve({ ...entity, id: 'generated-id' });
        }),
      }))
      .compile();

    userService = unit;
    userRepository = unitRef.get(UserRepository);
  });

  it('should find admin user', async () => {
    const result = await userService.findById('admin');
    expect(result.role).toBe('admin');
  });

  it('should return null for non-admin', async () => {
    const result = await userService.findById('user-1');
    expect(result).toBeNull();
  });
});
```

---

## AAA Pattern (Arrange-Act-Assert)

### 표준 구조

```typescript
it('should calculate total with discount', async () => {
  // Arrange - 테스트 데이터 준비
  const items = [
    { id: 1, price: 1000, quantity: 2 },
    { id: 2, price: 500, quantity: 1 },
  ];
  const discount = 0.1; // 10% 할인

  // Act - 테스트 대상 실행
  const result = await orderService.calculateTotal(items, discount);

  // Assert - 결과 검증
  expect(result).toBe(2250); // (1000*2 + 500) * 0.9
});
```

### 에러 케이스

```typescript
it('should throw when user not found', async () => {
  // Arrange
  userRepository.findOne.mockResolvedValue(null);

  // Act & Assert
  await expect(userService.findById('nonexistent'))
    .rejects.toThrow(NotFoundException);
});
```

---

## Test Naming Conventions

### 권장 형식

```typescript
// ✅ should_동작_when_조건
it('should return user when found by id', async () => {});
it('should throw NotFoundException when user not found', async () => {});
it('should send email when user registered', async () => {});

// ❌ 나쁜 예
it('test1', async () => {});
it('works', async () => {});
it('user test', async () => {});
```

### describe 그룹화

```typescript
describe('UserService', () => {
  describe('findById', () => {
    it('should return user when found', async () => {});
    it('should throw when not found', async () => {});
    it('should include relations when requested', async () => {});
  });

  describe('create', () => {
    it('should create user with valid data', async () => {});
    it('should throw on duplicate email', async () => {});
    it('should hash password before saving', async () => {});
  });

  describe('delete', () => {
    it('should soft delete user', async () => {});
    it('should throw when user not found', async () => {});
  });
});
```

---

## Edge Cases 테스트

```typescript
describe('Edge Cases', () => {
  // Null/Undefined
  it('should throw on null input', async () => {
    await expect(service.process(null)).rejects.toThrow(ValidationError);
  });

  // Empty collections
  it('should return empty array when no results', async () => {
    repository.find.mockResolvedValue([]);
    const result = await service.findAll();
    expect(result).toEqual([]);
  });

  // Boundary values
  it('should accept minimum valid age', () => {
    expect(() => service.setAge(0)).not.toThrow();
  });

  it('should reject negative age', () => {
    expect(() => service.setAge(-1)).toThrow(ValidationError);
  });

  // Large data
  it('should handle large dataset', async () => {
    const largeArray = Array.from({ length: 10000 }, (_, i) => ({ id: i }));
    repository.find.mockResolvedValue(largeArray);
    const result = await service.findAll();
    expect(result).toHaveLength(10000);
  });
});
```

---

## Async Testing

```typescript
// Promise 테스트
it('should resolve with data', async () => {
  repository.findOne.mockResolvedValue({ id: '1' });
  const result = await service.findById('1');
  expect(result).toBeDefined();
});

// 에러 Promise 테스트
it('should reject with error', async () => {
  repository.findOne.mockRejectedValue(new Error('DB Error'));
  await expect(service.findById('1')).rejects.toThrow('DB Error');
});

// 타임아웃 테스트
it('should complete within timeout', async () => {
  const result = await service.slowOperation();
  expect(result).toBeDefined();
}, 10000); // 10초 타임아웃
```

---

## Anti-Patterns to Avoid

### 1. await 누락

```typescript
// ❌ BAD - compile()에 await 누락
beforeAll(() => {
  const { unit } = TestBed.solitary(UserService).compile();
  // TypeError: Cannot destructure property 'unit' of 'undefined'
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

### 3. 테스트 간 상태 공유

```typescript
// ❌ BAD - 테스트 간 상태 오염
let user: User;
beforeAll(() => { user = new User(); });

it('test 1', () => { user.name = 'Test1'; }); // 다음 테스트에 영향
it('test 2', () => { expect(user.name).toBe(''); }); // 실패

// ✅ GOOD - 각 테스트마다 새로운 상태
beforeEach(() => { user = new User(); });
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
| 부분 매칭 | `expect(obj).toMatchObject({ key: value })` |
| 배열 포함 | `expect(arr).toContain(item)` |
| 타입 확인 | `expect(val).toBeInstanceOf(Class)` |

---

## Sources

- [Suites GitHub](https://github.com/suites-dev/suites)
- [NestJS Suites Recipe](https://docs.nestjs.com/recipes/suites)
- [Suites Migration Guide](https://suites.dev/docs/migration-guides/from-automock)
