# Expert Profiles

> 7명의 NestJS Backend 전문가 상세 프로필

## Architecture Overview

```
EXPERT HIERARCHY:
                    ┌─────────────────────────┐
                    │  nestjs-fastify-expert  │ ← Orchestrator
                    │     (백엔드 총괄)         │
                    └───────────┬─────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │           │           │           │           │
        ▼           ▼           ▼           ▼           ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
   │ TypeORM │ │  Redis  │ │ BullMQ  │ │  CQRS   │ │  Micro  │
   │ Expert  │ │ Expert  │ │ Expert  │ │ Expert  │ │ Services│
   └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘
        │           │           │           │           │
        └───────────┴───────────┼───────────┴───────────┘
                                │
                                ▼
                        ┌─────────────┐
                        │   Suites    │ ← Testing Expert
                        │   Testing   │
                        └─────────────┘
```

---

## 1. nestjs-fastify-expert (Orchestrator)

### 역할

백엔드 개발 요청을 분석하고 적절한 전문가를 배정하는 오케스트레이터입니다.

### 핵심 기능

```
ORCHESTRATOR CAPABILITIES:
├─ 요청 분석
│   ├─ 복잡도 평가 (단순/중간/복잡)
│   ├─ 도메인 식별
│   └─ 의존성 분석
│
├─ 전문가 배정
│   ├─ 최적 전문가 선택
│   ├─ 실행 순서 결정
│   └─ 병렬/순차 전략
│
├─ 결과 통합
│   ├─ 개별 결과 수집
│   ├─ 일관성 검증
│   └─ 최종 출력 구성
│
└─ 아키텍처 결정
    ├─ 프로젝트 구조 설계
    ├─ 모듈 분리 전략
    └─ 기술 스택 선택
```

### 활성화 조건

```yaml
triggers:
  primary:
    - "nestjs"
    - "fastify"
    - "백엔드"
    - "backend"
    - "아키텍처"
  context:
    - "복합 요청"
    - "전체 시스템"
    - "마이그레이션"
```

---

## 2. typeorm-expert

### 역할

데이터베이스 설계, ORM 최적화, 마이그레이션을 담당하는 DB 전문가입니다.

### 전문 분야

```
DATABASE EXPERTISE:
├─ Entity Modeling
│   ├─ 관계 정의 (1:1, 1:N, M:N)
│   ├─ 인덱스 전략
│   ├─ 파티셔닝 설계
│   ├─ 소프트 삭제 패턴
│   └─ 버전 관리 (Optimistic Lock)
│
├─ Repository Pattern
│   ├─ Custom Repository 구현
│   ├─ Query Builder 최적화
│   ├─ N+1 문제 해결 (Eager/Lazy)
│   ├─ 동적 쿼리 생성
│   └─ Raw Query 최적화
│
├─ Migration Management
│   ├─ 버전 관리 전략
│   ├─ 롤백 시나리오
│   ├─ 데이터 마이그레이션
│   └─ 제로 다운타임 배포
│
└─ Performance
    ├─ Connection Pooling
    ├─ Query Caching
    ├─ Lazy Loading 전략
    └─ Bulk Operations
```

### 코드 예시

```typescript
// Entity with Relations
@Entity()
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @OneToMany(() => Post, post => post.author)
  posts: Post[];

  @CreateDateColumn()
  createdAt: Date;

  @DeleteDateColumn()
  deletedAt: Date; // Soft delete
}

// Custom Repository
@Injectable()
export class UserRepository extends Repository<User> {
  async findActiveUsers(): Promise<User[]> {
    return this.createQueryBuilder('user')
      .leftJoinAndSelect('user.posts', 'post')
      .where('user.deletedAt IS NULL')
      .orderBy('user.createdAt', 'DESC')
      .getMany();
  }
}
```

---

## 3. redis-cache-expert

### 역할

캐시 전략, 세션 관리, 분산 락을 담당하는 캐싱 전문가입니다.

### 전문 분야

```
CACHE EXPERTISE:
├─ Cache Patterns
│   ├─ Cache-Aside (Read-through)
│   ├─ Write-through
│   ├─ Write-back (Write-behind)
│   └─ Refresh-ahead
│
├─ Multi-level Caching
│   ├─ L1: In-memory (Node.js)
│   ├─ L2: Redis (Shared)
│   └─ L3: Database
│
├─ Cache Invalidation
│   ├─ Tag-based 무효화
│   ├─ Event-driven 무효화
│   ├─ TTL 자동 만료
│   └─ Pattern 기반 삭제
│
└─ Advanced Patterns
    ├─ Distributed Lock (Redlock)
    ├─ Rate Limiting
    ├─ Session Store
    ├─ Pub/Sub
    └─ Leaderboard (Sorted Set)
```

### 코드 예시

```typescript
// Cache Interceptor
@Injectable()
export class CacheInterceptor implements NestInterceptor {
  constructor(
    @InjectRedis() private readonly redis: Redis,
  ) {}

  async intercept(context: ExecutionContext, next: CallHandler) {
    const key = this.getCacheKey(context);
    const cached = await this.redis.get(key);

    if (cached) {
      return of(JSON.parse(cached));
    }

    return next.handle().pipe(
      tap(data => {
        this.redis.setex(key, 3600, JSON.stringify(data));
      }),
    );
  }
}

// Distributed Lock
async executeWithLock<T>(
  key: string,
  task: () => Promise<T>,
): Promise<T> {
  const lock = await this.redis.set(
    `lock:${key}`,
    'locked',
    'EX', 30,
    'NX',
  );

  if (!lock) {
    throw new Error('Resource locked');
  }

  try {
    return await task();
  } finally {
    await this.redis.del(`lock:${key}`);
  }
}
```

---

## 4. bullmq-queue-expert

### 역할

작업 큐, 백그라운드 처리, 스케줄링을 담당하는 큐 전문가입니다.

### 전문 분야

```
QUEUE EXPERTISE:
├─ Queue Types
│   ├─ Default Queue: 일반 작업
│   ├─ Priority Queue: 우선순위
│   ├─ Delayed Queue: 지연 실행
│   └─ Repeatable Queue: 반복 작업
│
├─ Worker Patterns
│   ├─ Single Worker: 순차 처리
│   ├─ Concurrent Workers: 병렬 처리
│   ├─ Dedicated Workers: 전용 처리
│   └─ Sandboxed Workers: 격리 처리
│
├─ Job Strategies
│   ├─ Retry Logic (지수 백오프)
│   ├─ Dead Letter Queue
│   ├─ Job Dependencies
│   ├─ Job Chaining
│   └─ Flow Producer
│
└─ Monitoring
    ├─ Job Metrics
    ├─ Queue Health
    ├─ Error Tracking
    └─ Dashboard (Bull Board)
```

### 코드 예시

```typescript
// Queue Producer
@Injectable()
export class EmailService {
  constructor(
    @InjectQueue('email') private emailQueue: Queue,
  ) {}

  async sendWelcomeEmail(userId: string) {
    await this.emailQueue.add('welcome', {
      userId,
      template: 'welcome',
    }, {
      delay: 5000, // 5초 후 실행
      attempts: 3,
      backoff: {
        type: 'exponential',
        delay: 1000,
      },
    });
  }
}

// Queue Consumer
@Processor('email')
export class EmailProcessor {
  @Process('welcome')
  async handleWelcome(job: Job<EmailData>) {
    const { userId, template } = job.data;
    // 이메일 발송 로직
  }

  @OnQueueFailed()
  async onFailed(job: Job, error: Error) {
    // 실패 처리 및 알림
  }
}
```

---

## 5. cqrs-expert

### 역할

CQRS 패턴, Event Sourcing, 도메인 이벤트를 담당하는 패턴 전문가입니다.

### 전문 분야

```
CQRS EXPERTISE:
├─ Command Side
│   ├─ Command Handlers
│   ├─ Validation Pipes
│   ├─ Transaction Management
│   └─ Event Publishing
│
├─ Query Side
│   ├─ Query Handlers
│   ├─ Read Models (Projections)
│   ├─ Materialized Views
│   └─ Query Optimization
│
├─ Event Sourcing
│   ├─ Event Store
│   ├─ Snapshots
│   ├─ Event Replay
│   └─ Version Control
│
└─ Sagas
    ├─ Orchestration Saga
    ├─ Choreography Saga
    ├─ Compensation Logic
    └─ Timeout Handling
```

### 코드 예시

```typescript
// Command
export class CreateOrderCommand {
  constructor(
    public readonly userId: string,
    public readonly items: OrderItem[],
  ) {}
}

// Command Handler
@CommandHandler(CreateOrderCommand)
export class CreateOrderHandler implements ICommandHandler<CreateOrderCommand> {
  async execute(command: CreateOrderCommand) {
    const order = Order.create(command.userId, command.items);

    await this.orderRepository.save(order);

    order.apply(new OrderCreatedEvent(order.id, command.userId));

    return order;
  }
}

// Event Handler
@EventsHandler(OrderCreatedEvent)
export class OrderCreatedHandler implements IEventHandler<OrderCreatedEvent> {
  async handle(event: OrderCreatedEvent) {
    // 이메일 발송, 재고 차감 등
  }
}

// Saga
@Saga()
orderCreated$ = (events$: Observable<OrderCreatedEvent>) =>
  events$.pipe(
    ofType(OrderCreatedEvent),
    mergeMap(event => [
      new SendOrderConfirmationCommand(event.orderId),
      new UpdateInventoryCommand(event.items),
    ]),
  );
```

---

## 6. microservices-expert

### 역할

마이크로서비스 아키텍처, 서비스 통신을 담당하는 MSA 전문가입니다.

### 전문 분야

```
MICROSERVICES EXPERTISE:
├─ Communication Patterns
│   ├─ Synchronous
│   │   ├─ gRPC (고성능)
│   │   ├─ REST (범용)
│   │   └─ GraphQL (유연)
│   │
│   └─ Asynchronous
│       ├─ RabbitMQ
│       ├─ Kafka
│       ├─ Redis Pub/Sub
│       └─ NATS
│
├─ Service Discovery
│   ├─ Consul
│   ├─ Eureka
│   └─ Kubernetes Native
│
├─ API Gateway
│   ├─ Routing
│   ├─ Authentication
│   ├─ Rate Limiting
│   └─ Load Balancing
│
└─ Resilience
    ├─ Circuit Breaker
    ├─ Retry Pattern
    ├─ Bulkhead
    └─ Timeout
```

---

## 7. suites-testing-expert

### 역할

Suites 3.x 기반 테스트 전략, E2E 테스트를 담당하는 테스팅 전문가입니다.

### 전문 분야

```
TESTING EXPERTISE:
├─ Unit Tests (70%)
│   ├─ Service Layer (Solitary)
│   ├─ Controller Mocking
│   ├─ Repository Fakes
│   └─ Utility Functions
│
├─ Integration Tests (20%)
│   ├─ API Endpoints
│   ├─ Database Integration
│   ├─ External Services
│   └─ Message Queues
│
└─ E2E Tests (10%)
    ├─ User Workflows
    ├─ Cross-service Scenarios
    ├─ Performance Tests
    └─ Security Tests
```

### 코드 예시

```typescript
// Suites 3.x Unit Test
import { TestBed, type Mocked } from '@suites/unit';

describe('UserService', () => {
  let service: UserService;
  let repository: Mocked<UserRepository>;

  beforeAll(async () => {
    const { unit, unitRef } = await TestBed
      .solitary(UserService)
      .compile();

    service = unit;
    repository = unitRef.get(UserRepository);
  });

  it('should find user by id', async () => {
    // Given
    const mockUser = { id: '1', email: 'test@test.com' };
    repository.findOne.mockResolvedValue(mockUser);

    // When
    const result = await service.findById('1');

    // Then
    expect(result).toEqual(mockUser);
    expect(repository.findOne).toHaveBeenCalledWith({ where: { id: '1' } });
  });
});
```

---

@../CLAUDE.md | @routing-algorithm.md | @integration-patterns.md
