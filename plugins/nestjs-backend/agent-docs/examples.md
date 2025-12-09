# NestJS Backend - 코드 예제 및 사용 시나리오

> 통합 패턴, 코드 예시, 실행 시나리오 모음

---

## TypeORM 코드 예시

### 복잡한 관계 매핑

```typescript
// Entity 설계 예시
@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @OneToMany(() => Order, order => order.user, {
    cascade: true,
    eager: false, // N+1 방지
  })
  @JoinColumn([{ name: 'activeOrderId', referencedColumnName: 'id' }])
  activeOrder?: Order;

  // 인덱스 최적화
  @Index(['email', 'createdAt'])
  @CreateDateColumn()
  createdAt: Date;
}
```

### Query Builder 최적화

```typescript
// 효율적인 조회 쿼리
const users = await this.userRepository
  .createQueryBuilder('user')
  .leftJoinAndSelect('user.orders', 'order')
  .where('user.status = :status', { status: 'active' })
  .andWhere('order.total > :minTotal', { minTotal: 100 })
  .orderBy('user.createdAt', 'DESC')
  .take(10)
  .getMany();
```

---

## Redis Cache 구현 예시

### Multi-level Caching

```typescript
@Injectable()
export class CacheService {
  constructor(
    @InjectRedis() private readonly redis: Redis,
  ) {}

  // Multi-level caching
  async get<T>(key: string): Promise<T | null> {
    // L1: Memory cache
    if (this.memoryCache.has(key)) {
      return this.memoryCache.get(key);
    }

    // L2: Redis
    const cached = await this.redis.get(key);
    if (cached) {
      const data = JSON.parse(cached);
      this.memoryCache.set(key, data);
      return data;
    }

    return null;
  }
}
```

### Distributed Lock

```typescript
// 분산 락 구현
async acquireLock(
  resource: string,
  ttl: number = 10000,
): Promise<string | null> {
  const lockKey = `lock:${resource}`;
  const lockValue = uuidv4();

  const result = await this.redis.set(
    lockKey,
    lockValue,
    'PX',
    ttl,
    'NX',
  );

  return result === 'OK' ? lockValue : null;
}
```

---

## Usage Scenarios

### 1. 단일 전문가 호출

```bash
# 간단한 요청 - 자동 라우팅
"Redis 캐시 TTL 1시간으로 설정"

# 결과: redis-cache-expert 자동 활성화
```

### 2. 병렬 전문가 호출

```bash
# 복합 요청 - 병렬 실행
"Redis 캐시와 BullMQ 큐 함께 설정"

# 결과:
# 1. nestjs-fastify-expert 활성화
# 2. redis-cache-expert & bullmq-queue-expert 병렬 실행
# 3. 결과 통합
```

### 3. 오케스트레이션 시나리오

```bash
# 복잡한 아키텍처 요청
"사용자 인증 시스템 구축해줘. Redis 세션, TypeORM 유저, 이메일 발송 큐"

# 실행 플로우:
# 1. nestjs-fastify-expert 요청 분석
# 2. 전문가들 할당:
#    - typeorm-expert: User 엔티티 설계
#    - redis-cache-expert: 세션 관리
#    - bullmq-queue-expert: 이메일 큐
# 3. 병렬로 기본 구조 생성
# 4. 순차로 통합 및 테스트
```

---

## Integration Patterns

### 1. Module Generator 패턴

```typescript
// 자동 생성된 모듈 예시
@Module({
  imports: [
    TypeOrmModule.forFeature([User]),
    CacheModule.register({
      store: 'redis',
      host: 'localhost',
      port: 6379,
    }),
    BullModule.registerQueue({
      name: 'email-queue',
    }),
  ],
  providers: [
    UserService,
    CacheService,
    {
      provide: 'USER_REPOSITORY',
      useFactory: (dataSource: DataSource) =>
        dataSource.getRepository(User),
      inject: [DataSource],
    },
  ],
  exports: [UserService, CacheService],
})
export class UserModule {}
```

### 2. Controller-Service-Repository 패턴

```typescript
// 자동 생성된 계층 구조
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post()
  @UsePipes(new ValidationPipe())
  async create(@Body() createUserDto: CreateUserDto): Promise<User> {
    return this.userService.create(createUserDto);
  }

  @Get(':id')
  @CacheKey('user:id')
  @CacheTTL(3600)
  async findOne(@Param('id') id: string): Promise<User> {
    return this.userService.findById(id);
  }
}
```

### 3. CQRS Command/Query 패턴

```typescript
// Command Handler
@CommandHandler(CreateUserCommand)
export class CreateUserHandler implements ICommandHandler<CreateUserCommand> {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly eventBus: EventBus,
  ) {}

  async execute(command: CreateUserCommand): Promise<User> {
    const user = await this.userRepository.create(command.data);
    this.eventBus.publish(new UserCreatedEvent(user));
    return user;
  }
}

// Query Handler
@QueryHandler(GetUserQuery)
export class GetUserHandler implements IQueryHandler<GetUserQuery> {
  constructor(private readonly readModel: UserReadModel) {}

  async execute(query: GetUserQuery): Promise<UserDto> {
    return this.readModel.findById(query.userId);
  }
}
```

### 4. BullMQ Job Processor 패턴

```typescript
@Processor('email-queue')
export class EmailProcessor {
  @Process('send-welcome')
  async sendWelcomeEmail(job: Job<WelcomeEmailData>): Promise<void> {
    const { email, name } = job.data;

    await this.emailService.send({
      to: email,
      template: 'welcome',
      context: { name },
    });

    await job.updateProgress(100);
  }

  @OnQueueCompleted()
  onCompleted(job: Job) {
    console.log(`Job ${job.id} completed`);
  }

  @OnQueueFailed()
  onFailed(job: Job, error: Error) {
    console.error(`Job ${job.id} failed: ${error.message}`);
  }
}
```

### 5. Microservices Transport 패턴

```typescript
// gRPC Client
@Injectable()
export class UserGrpcClient {
  @Client({
    transport: Transport.GRPC,
    options: {
      package: 'user',
      protoPath: join(__dirname, 'user.proto'),
    },
  })
  private client: ClientGrpc;

  private userService: UserServiceClient;

  onModuleInit() {
    this.userService = this.client.getService<UserServiceClient>('UserService');
  }

  async findUser(id: string): Promise<User> {
    return firstValueFrom(this.userService.findOne({ id }));
  }
}

// Event Pattern (Kafka/RabbitMQ)
@EventPattern('user.created')
async handleUserCreated(@Payload() data: UserCreatedEvent) {
  await this.notificationService.sendWelcome(data.userId);
}
```

---

## 테스트 예시 (Suites 3.x)

### Unit Test with Automock

```typescript
import { TestBed } from '@automock/jest';

describe('UserService', () => {
  let service: UserService;
  let userRepository: jest.Mocked<UserRepository>;

  beforeEach(() => {
    const { unit, unitRef } = TestBed.create(UserService).compile();
    service = unit;
    userRepository = unitRef.get(UserRepository);
  });

  it('should create a user', async () => {
    const userData = { email: 'test@example.com' };
    userRepository.create.mockResolvedValue({ id: '1', ...userData });

    const result = await service.create(userData);

    expect(result.id).toBe('1');
    expect(userRepository.create).toHaveBeenCalledWith(userData);
  });
});
```

### Integration Test

```typescript
describe('UserController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/users (POST)', () => {
    return request(app.getHttpServer())
      .post('/users')
      .send({ email: 'test@example.com' })
      .expect(201)
      .expect((res) => {
        expect(res.body.id).toBeDefined();
      });
  });
});
```

---

[parent](../CLAUDE.md)
