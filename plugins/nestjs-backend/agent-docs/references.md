# NestJS Backend - 참조 문서

> Best Practices, 트러블슈팅, 성능 최적화, 보안 가이드

---

## Best Practices

### 1. 모듈 설계

| 원칙 | 설명 |
|------|------|
| 단일 책임 | 모듈은 하나의 명확한 도메인 담당 |
| 의존성 주입 | 인터페이스 기반 의존성 관리 |
| 환경 설정 | ConfigModule 통한 설정 관리 |
| 에러 핸들링 | 전역 예외 필터 사용 |

### 2. 데이터베이스

| 원칙 | 설명 |
|------|------|
| DTO 사용 | 데이터 전송 객체 검증 |
| 트랜잭션 | 여러 작업 시 명시적 트랜잭션 |
| 연결 풀 | 적절한 풀 크기 설정 |
| 마이그레이션 | 버전 관리 철저 |

### 3. 캐싱

| 원칙 | 설명 |
|------|------|
| 전략적 캐싱 | 자주 변경되지 않는 데이터 우선 |
| TTL 관리 | 데이터 신선도 보장 |
| 캐시 키 | 일관된 네이밍 규칙 |
| 무효화 | 데이터 변경 시 즉시 갱신 |

### 4. 성능

| 원칙 | 설명 |
|------|------|
| 비동기 처리 | 무거운 작업은 큐에 위임 |
| 로깅 | 구조화된 로깅 사용 |
| 모니터링 | health check 엔드포인트 |
| 프로파일링 | 병목 지점 식별 |

---

## Troubleshooting

### TypeORM N+1 문제

```typescript
// 문제: Lazy loading으로 인한 N+1
const users = await userRepo.find();
for (const user of users) {
  console.log(user.orders); // 각 사용자마다 쿼리 실행
}

// 해결: Eager loading
const users = await userRepo.find({
  relations: ['orders']
});
```

### Redis 연결 누수

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

### BullMQ Job 중단

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

### Circular Dependency

```typescript
// 문제: 순환 의존성
@Module({
  imports: [ModuleB], // ModuleB도 ModuleA를 import
})
export class ModuleA {}

// 해결: forwardRef 사용
@Module({
  imports: [forwardRef(() => ModuleB)],
})
export class ModuleA {}
```

### Memory Leak in Event Listeners

```typescript
// 문제: 리스너 해제 안함
@Injectable()
export class BadService implements OnModuleInit {
  onModuleInit() {
    process.on('message', this.handleMessage);
  }
}

// 해결: OnModuleDestroy 구현
@Injectable()
export class GoodService implements OnModuleInit, OnModuleDestroy {
  private handler = this.handleMessage.bind(this);

  onModuleInit() {
    process.on('message', this.handler);
  }

  onModuleDestroy() {
    process.off('message', this.handler);
  }
}
```

---

## Performance Optimization Guide

### 1. 데이터베이스 최적화

| 기법 | 설명 |
|------|------|
| 인덱스 | 조회 조건에 맞는 인덱스 추가 |
| 쿼리 최적화 | EXPLAIN ANALYZE 사용 |
| 배치 작업 | bulk operations 활용 |
| 연결 풀링 | 적절한 크기 설정 (기본 10-20) |

```typescript
// 배치 삽입 예시
await this.userRepository
  .createQueryBuilder()
  .insert()
  .into(User)
  .values(users)
  .execute();
```

### 2. 캐시 전략

| 기법 | 설명 |
|------|------|
| 멀티 레벨 | Memory + Redis 조합 |
| 프리페칭 | 예측적 데이터 로드 |
| 웜업 | 자주 사용하는 데이터 미리 로드 |
| 캐시 사이징 | 메모리 사용량 모니터링 |

### 3. 큐 최적화

| 기법 | 설명 |
|------|------|
| 작업 그룹핑 | 유사 작업 묶음 처리 |
| 우선순위 | 중요 작업 우선 처리 |
| 동적 워커 | 부하에 따른 워커 수 조절 |
| 모니터링 | 큐 길이, 처리시간 추적 |

### 4. HTTP 응답 최적화

```typescript
// 압축 활성화
app.use(compression());

// 응답 캐싱
@CacheInterceptor()
@Controller('products')
export class ProductController {
  @Get()
  @CacheTTL(300) // 5분 캐시
  findAll() {
    return this.productService.findAll();
  }
}
```

---

## Security Considerations

### 1. 인증/인가

| 항목 | 권장 사항 |
|------|----------|
| JWT | 안전한 토큰 관리, 만료 시간 설정 |
| RBAC | 역할 기반 접근 제어 |
| Guard | 다층적 보호 (JWT + Role) |
| Rate Limiting | API 호출 제한 |

```typescript
// Rate Limiting 설정
@Controller('api')
@UseGuards(ThrottlerGuard)
export class ApiController {
  @Throttle(10, 60) // 60초에 10번
  @Get()
  findAll() {}
}
```

### 2. 데이터 보호

| 항목 | 권장 사항 |
|------|----------|
| Encryption | 민감 데이터 암호화 (AES-256) |
| Hashing | 비밀번호 해싱 (bcrypt, argon2) |
| Sanitization | 입력 데이터 정제 |
| SQL Injection | Parameterized query 사용 |

```typescript
// 비밀번호 해싱
import * as bcrypt from 'bcrypt';

async hashPassword(password: string): Promise<string> {
  const salt = await bcrypt.genSalt(12);
  return bcrypt.hash(password, salt);
}
```

### 3. 인프라 보안

| 항목 | 권장 사항 |
|------|----------|
| CORS | 허용된 오리진만 접근 |
| Helmet | HTTP 헤더 보안 설정 |
| HTTPS | SSL/TLS 필수 |
| Secret Management | 환경 변수로 관리 |

```typescript
// Helmet 설정
import helmet from 'helmet';

app.use(helmet());
app.enableCors({
  origin: ['https://myapp.com'],
  credentials: true,
});
```

### 4. 보안 체크리스트

- [ ] JWT secret 충분히 복잡한가?
- [ ] 비밀번호 정책 적용했는가?
- [ ] SQL Injection 방지했는가?
- [ ] XSS 방지했는가?
- [ ] CSRF 토큰 적용했는가?
- [ ] 민감 데이터 암호화했는가?
- [ ] 로그에 민감 정보 제외했는가?
- [ ] Rate limiting 적용했는가?

---

## 관련 문서

- [상세 가이드](./detailed-guides.md)
- [코드 예제](./examples.md)

---

[parent](../CLAUDE.md)
