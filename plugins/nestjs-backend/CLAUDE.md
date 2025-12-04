---
name: nestjs-backend
description: 'NestJS 백엔드 에코시스템 - 7개 전문가 + 자동 라우팅'
category: development
---

# nestjs-backend Plugin

NestJS 백엔드 개발의 모든 것을 다루는 전문가 시스템입니다. 7명의 전문 에이전트와 지능형 라우팅 시스템으로 생산성을 극대화합니다.

## Architecture Overview

```
System Architecture:
┌─────────────────────────────────────────────────────────┐
│                    User Request                         │
│                  "Redis 캐시 설정해줘"                  │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│            nestjs-fastify-expert (Orchestrator)        │
│  ┌─────────────┬──────────────┬─────────────────┐     │
│  │   Request   │   Routing    │   Coordination  │     │
│  │  Analysis   │   System     │     Layer       │     │
│  └─────────────┴──────────────┴─────────────────┘     │
└─────────────────────┬───────────────────────────────────┘
                      │
         ┌────────────┼────────────┐
         ▼            ▼            ▼
┌──────────┐  ┌─────────────┐  ┌──────────┐
│   Redis  │  │  TypeORM    │  │  BullMQ  │
│  Expert  │  │   Expert    │  │  Expert  │
└──────────┘  └─────────────┘  └──────────┘
```

## Core Philosophy

```
전문가 시스템 원칙:
├─ 단일 책임: 각 에이전트는 명확한 도메인 전문성
├─ 협업 능력: 복합 작업을 위한 에이전트 간 조율
├─ 자동 라우팅: 키워드 기반 지능형 전문가 선택
├─ NestJS 네이티브: 프레임워크 패턴과 모범 사례 충실
└─ 확장성: 새로운 전문가 용이하게 추가
```

## Expert Agents

### 1. nestjs-fastify-expert (Orchestrator)

**역할**: 백엔드 개발 요청 분석 및 전문가 배정

#### 핵심 기능
- 요청 복잡도 분석 (단일 vs 복합)
- 필수 전문가 식별 및 우선순위 결정
- 병렬/순차 실행 전략 수립
- 결과 통합 및 검증

#### 활성화 조건
```
TRIGGERS:
├─ 복합 요청: "캐시와 큐 함께 설정"
├─ 아키텍처: "백엔드 구조 설계"
├─ 마이그레이션: "Express → NestJS 전환"
└─ 최적화: "전체 성능 개선"
```

### 2. typeorm-expert

**전문 분야**: 데이터베이스 설계, ORM 최적화, 마이그레이션

#### 상세 기능
```
DATABASE DESIGN:
├─ Entity Modeling
│   ├─ 관계 정의 (1:1, 1:N, M:N)
│   ├─ 인덱스 전략
│   ├─ 파티셔닝 설계
│   └─ 소프트 삭제 패턴
│
├─ Repository Pattern
│   ├─ Custom Repository 구현
│   ├─ Query Builder 최적화
│   ├─ N+1 문제 해결
│   └─ 동적 쿼리 생성
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

#### 코드 예시
```typescript
// 복잡한 관계 매핑 예시
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

// Query Builder 예시
const users = await this.userRepository
  .createQueryBuilder('user')
  .leftJoinAndSelect('user.orders', 'order')
  .where('user.status = :status', { status: 'active' })
  .andWhere('order.total > :minTotal', { minTotal: 100 })
  .orderBy('user.createdAt', 'DESC')
  .take(10)
  .getMany();
```

### 3. redis-cache-expert

**전문 분야**: 캐시 전략, 세션 관리, 분산 락

#### 캐시 전략
```
CACHE PATTERNS:
├─ Cache-Aside Pattern
│   ├─ Read-through 구현
│   ├─ Write-back 전략
│   └─ TTL 관리
│
├─ Multi-level Caching
│   ├─ L1: In-memory (Node.js)
│   ├─ L2: Redis (shared)
│   └─ L3: Database
│
├─ Cache Invalidation
│   ├─ Tag-based 기반
│   ├─ Event-driven 무효화
│   └─ TTL 자동 만료
│
└─ Advanced Patterns
    ├─ Distributed Lock
    ├─ Rate Limiting
    ├─ Session Store
    └─ Pub/Sub
```

#### 구현 예시
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

  // Distributed lock
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
}
```

### 4. bullmq-queue-expert

**전문 분야**: 작업 큐, 백그라운드 처리, 스케줄링

#### 큐 아키텍처
```
QUEUE ARCHITECTURE:
├─ Queue Types
│   ├─ Default Queue: 일반 작업
│   ├─ Priority Queue: 우선순위 작업
│   ├─ Delayed Queue: 지연 작업
│   └─ Repeat Queue: 반복 작업
│
├─ Worker Patterns
│   ├─ Single Worker: 순차 처리
│   ├─ Multiple Workers: 병렬 처리
│   ├─ Dedicated Workers: 특정 작업 전용
│   └─ Shared Workers: 범용 처리
│
├─ Job Strategies
│   ├─ Retry Logic: 지수 백오프
│   ├─ Dead Letter Queue: 실패 작업 처리
│   ├─ Job Dependencies: 작업 순서
│   └─ Job Chaining: 파이프라인
│
└─ Monitoring
    ├─ Job Metrics: 성능 측정
    ├─ Queue Health: 상태 모니터링
    ├─ Error Tracking: 오류 추적
    └─ Auto-scaling: 동적 확장
```

### 5. cqrs-expert

**전문 분야**: CQRS 패턴, Event Sourcing, 도메인 이벤트

#### CQRS 구현
```
CQRS IMPLEMENTATION:
├─ Command Side
│   ├─ Command Handlers
│   ├─ Validation Pipes
│   ├─ Transaction Management
│   └─ Event Publishing
│
├─ Query Side
│   ├─ Query Handlers
│   ├─ Read Models
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
    ├─ Orchestration
    ├─ Choreography
    ├─ Compensation
    └─ Timeout Handling
```

### 6. microservices-expert

**전문 분야**: 마이크로서비스 아키텍처, 서비스 통신

#### 통신 패턴
```
COMMUNICATION PATTERNS:
├─ Synchronous
│   ├─ gRPC: 고성능 RPC
│   ├─ HTTP/REST: 범용 API
│   └─ GraphQL: 유연한 쿼리
│
├─ Asynchronous
│   ├─ Message Broker: RabbitMQ, Kafka
│   ├─ Event Bus: 내부 이벤트
│   └─ Pub/Sub: Redis, NATS
│
├─ Service Discovery
│   ├─ Consul: 서비스 레지스트리
│   ├─ Eureka: Netflix OSS
│   └─ Kubernetes: Native 서비스
│
└─ API Gateway
    ├─ Routing: 요청 분배
    ├─ Authentication: 인증 처리
    ├─ Rate Limiting: 사용량 제한
    └─ Load Balancing: 부하 분산
```

### 7. suites-testing-expert

**전문 분야**: Suites 3.x 기반 테스트 전략, E2E 테스트

#### 테스트 전략
```
TESTING PYRAMID:
├─ Unit Tests (70%)
│   ├─ Service Layer
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

## Agent Routing System

### 라우팅 알고리즘

```
ROUTING ALGORITHM:
1. 키워드 추출
   ├─ 기술 키워드: "Redis", "TypeORM", "BullMQ"
   ├─ 동작 키워드: "설정", "최적화", "마이그레이션"
   ├─ 패턴 키워드: "CQRS", "Microservices", "Testing"
   └─ 복합 키워드: "A와 B 함께", "전체 시스템"

2. 점수 계산
   ├─ Primary 키워드: +3점
   ├─ Secondary 키워드: +2점
   ├─ Contextual 키워드: +1점
   └─ 복합도 보너스: +2점

3. 전문가 선택
   ├─ 최고 점수 전문가: 주 담당
   ├─ 2위 전문가: 보조 또는 병렬
   ├─ 오케스트레이터: 3개 이상 필요 시
   └─ 순차/병렬 결정
```

### 라우팅 테이블 예시

```json
{
  "routing_rules": [
    {
      "keywords": ["redis", "캐시", "cache"],
      "experts": ["redis-cache-expert"],
      "priority": "primary",
      "score": 3
    },
    {
      "keywords": ["typeorm", "entity", "데이터베이스"],
      "experts": ["typeorm-expert"],
      "priority": "primary",
      "score": 3
    },
    {
      "keywords": ["큐", "queue", "bullmq", "백그라운드"],
      "experts": ["bullmq-queue-expert"],
      "priority": "primary",
      "score": 3
    },
    {
      "keywords": ["redis", "bullmq", "캐시", "큐"],
      "experts": ["redis-cache-expert", "bullmq-queue-expert"],
      "execution": "parallel",
      "orchestrator": true
    },
    {
      "keywords": ["cqrs", "event sourcing", "이벤트"],
      "experts": ["cqrs-expert"],
      "priority": "primary",
      "score": 3
    },
    {
      "keywords": ["마이크로서비스", "microservices", "gRPC"],
      "experts": ["microservices-expert"],
      "priority": "primary",
      "score": 3
    },
    {
      "keywords": ["테스트", "test", "e2e", "unit"],
      "experts": ["suites-testing-expert"],
      "priority": "primary",
      "score": 3
    },
    {
      "keywords": ["백엔드", "전체", "아키텍처", "시스템"],
      "experts": ["nestjs-fastify-expert"],
      "priority": "orchestrator",
      "score": 3
    }
  ]
}
```

## Usage Examples

### 단일 전문가 호출

```bash
# 간단한 요청 - 자동 라우팅
"Redis 캐시 TTL 1시간으로 설정"

# 결과: redis-cache-expert 자동 활성화
```

### 병렬 전문가 호출

```bash
# 복합 요청 - 병렬 실행
"Redis 캐시와 BullMQ 큐 함께 설정"

# 결과:
# 1. nestjs-fastify-expert 활성화
# 2. redis-cache-expert & bullmq-queue-expert 병렬 실행
# 3. 결과 통합
```

### 오케스트레이션 시나리오

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

## Best Practices

### 1. 모듈 설계
- **단일 책임**: 모듈은 하나의 명확한 도메인
- **의존성 주입**: 인터페이스 기반 의존성
- **환경 설정**: ConfigModule 통한 설정 관리
- **에러 핸들링**: 전역 예외 필터 사용

### 2. 데이터베이스
- **DTO 사용**: 데이터 전송 객체 검증
- **트랜잭션**: 여러 작업 시 명시적 트랜잭션
- **연결 풀**: 적절한 풀 크기 설정
- **마이그레이션**: 버전 관리 철저

### 3. 캐싱
- **전략적 캐싱**: 자주 변경되지 않는 데이터
- **TTL 관리**: 데이터 신선도 보장
- **캐시 키**: 일관된 네이밍 규칙
- **무효화**: 데이터 변경 시 즉시 갱신

### 4. 성능
- **비동기 처리**: 무거운 작업은 큐에 위임
- **로깅**: 구조화된 로깅 사용
- **모니터링**: health check 엔드포인트
- **프로파일링**: 병목 지점 식별

## Troubleshooting

### 일반적인 문제들

#### TypeORM N+1 문제
```typescript
// 문제: Lazy loading导致的 N+1
const users = await userRepo.find();
for (const user of users) {
  console.log(user.orders); // 각 사용자마다 쿼리 실행
}

// 해결: Eager loading
const users = await userRepo.find({
  relations: ['orders']
});
```

#### Redis 연결 누수
```typescript
// 문제: 연결 닫지 않음
async badExample() {
  const redis = new Redis(); // 새 연결
  await redis.set('key', 'value');
  // 연결 닫지 않음
}

// 해결: 연결 풀 사용
@Injectable()
export class GoodExample {
  constructor(@InjectRedis() private readonly redis: Redis) {}

  async setKey() {
    await this.redis.set('key', 'value');
    // 자동으로 연결 풀에 반환
  }
}
```

#### BullMQ Job 중단
```typescript
// 문제: 에러 핸들링 없음
@Process('send-email')
async sendEmail(job: Job) {
  await emailService.send(job.data); // 실패 시 job 멈춤
}

// 해결: 에러 핸들링과 재시도
@Process('send-email')
async sendEmail(job: Job) {
  try {
    await emailService.send(job.data);
  } catch (error) {
    throw new Error(`Email send failed: ${error.message}`);
  }
}
```

## Performance Optimization Guide

### 1. 데이터베이스 최적화
- **인덱스**: 조회 조건에 맞는 인덱스 추가
- **쿼리 최적화**: EXPLAIN ANALYZE 사용
- **배치 작업**: bulk operations 활용
- **연결 풀링**: 적절한 크기 설정

### 2. 캐시 전략
- **멀티 레벨**: Memory + Redis
- **프리페칭**: 예측적 데이터 로드
- **웜업**: 자주 사용하는 데이터 미리 로드
- **캐시 사이징**: 메모리 사용량 모니터링

### 3. 큐 최적화
- **작업 그룹핑**: 유사 작업 묶음 처리
- **우선순위**: 중요 작업 우선 처리
- **동적 워커**: 부하에 따른 워커 수 조절
- **모니터링**: 큐 길이, 처리시간 추적

## Security Considerations

### 1. 인증/인가
- **JWT**: 안전한 토큰 관리
- **RBAC**: 역할 기반 접근 제어
- **Guard**: 다층적 보호
- **Rate Limiting**: API 호출 제한

### 2. 데이터 보호
- **Encryption**: 민감 데이터 암호화
- **Hashing**: 비밀번호 해싱
- **Sanitization**: 입력 데이터 정제
- **SQL Injection**: Parameterized query

### 3. 인프라 보안
- **CORS**: 크로스 오리진 정책
- **Helmet**: HTTP 헤더 보안
- **HTTPS**: SSL/TLS 통신
- **Secret Management**: 환경 변수 관리

[parent](../CLAUDE.md)