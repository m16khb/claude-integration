# Testcontainers Guide

> Integration/E2E 테스트를 위한 Testcontainers 설정 및 패턴 가이드

## Overview

실제 DB, Redis, 메시지 큐 등을 Docker 컨테이너로 실행하여 테스트합니다.

```
테스트 레벨별 전략:
├─ Unit: 모킹 (Suites 3.x)
├─ Integration: Testcontainers (실제 DB/캐시)
└─ E2E: Testcontainers (전체 스택)
```

---

## 설치

```bash
npm install -D testcontainers @testcontainers/mysql @testcontainers/redis
```

---

## MySQL Integration Test

```typescript
import { MySqlContainer, StartedMySqlContainer } from '@testcontainers/mysql';
import { DataSource } from 'typeorm';

describe('UserRepository (Integration)', () => {
  let container: StartedMySqlContainer;
  let dataSource: DataSource;
  let repository: UserRepository;

  beforeAll(async () => {
    // MySQL 8.x 컨테이너 시작
    container = await new MySqlContainer('mysql:8.0')
      .withDatabase('test_db')
      .withUsername('test')
      .withUserPassword('test')
      .start();

    // TypeORM 연결
    dataSource = new DataSource({
      type: 'mysql',
      host: container.getHost(),
      port: container.getPort(),
      username: container.getUsername(),
      password: container.getUserPassword(),
      database: container.getDatabase(),
      entities: [User],
      synchronize: true,
    });
    await dataSource.initialize();

    repository = dataSource.getRepository(User);
  }, 60000); // 컨테이너 시작 대기

  afterAll(async () => {
    await dataSource?.destroy();
    await container?.stop();
  });

  it('트랜잭션 롤백이 정상 동작한다', async () => {
    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.startTransaction();

    try {
      await queryRunner.manager.save(User, { email: 'test@test.com' });
      throw new Error('강제 에러');
    } catch {
      await queryRunner.rollbackTransaction();
    } finally {
      await queryRunner.release();
    }

    const users = await repository.find();
    expect(users).toHaveLength(0);
  });

  it('Soft Delete가 정상 동작한다', async () => {
    // Given
    const user = await repository.save({ email: 'delete@test.com' });

    // When
    await repository.softDelete(user.id);

    // Then
    const deleted = await repository.findOne({ where: { id: user.id } });
    expect(deleted).toBeNull();

    const withDeleted = await repository.findOne({
      where: { id: user.id },
      withDeleted: true,
    });
    expect(withDeleted?.deletedAt).not.toBeNull();
  });
});
```

---

## Redis Integration Test

```typescript
import { RedisContainer, StartedRedisContainer } from '@testcontainers/redis';
import { Redis } from 'ioredis';

describe('CacheService (Integration)', () => {
  let container: StartedRedisContainer;
  let redis: Redis;
  let cacheService: CacheService;

  beforeAll(async () => {
    container = await new RedisContainer('redis:7-alpine').start();

    redis = new Redis({
      host: container.getHost(),
      port: container.getPort(),
    });

    cacheService = new CacheService(redis);
  }, 30000);

  afterAll(async () => {
    await redis?.quit();
    await container?.stop();
  });

  it('TTL 만료 후 캐시가 삭제된다', async () => {
    await cacheService.set('key', 'value', 1); // 1초 TTL

    expect(await cacheService.get('key')).toBe('value');

    await new Promise((r) => setTimeout(r, 1100));

    expect(await cacheService.get('key')).toBeNull();
  });

  it('Hash 타입이 정상 동작한다', async () => {
    await redis.hset('user:1', { name: 'John', age: '30' });

    const result = await redis.hgetall('user:1');

    expect(result).toEqual({ name: 'John', age: '30' });
  });
});
```

---

## E2E Test (NestJS + Testcontainers)

```typescript
import { MySqlContainer, StartedMySqlContainer } from '@testcontainers/mysql';
import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';

describe('UserController (E2E)', () => {
  let app: INestApplication;
  let container: StartedMySqlContainer;

  beforeAll(async () => {
    container = await new MySqlContainer('mysql:8.0').start();

    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider('DATABASE_URL')
      .useValue(
        `mysql://${container.getUsername()}:${container.getUserPassword()}@${container.getHost()}:${container.getPort()}/${container.getDatabase()}`
      )
      .compile();

    app = moduleRef.createNestApplication();
    await app.init();
  }, 60000);

  afterAll(async () => {
    await app?.close();
    await container?.stop();
  });

  it('POST /users 사용자 생성 성공', () => {
    return request(app.getHttpServer())
      .post('/users')
      .send({ email: 'test@test.com', password: 'password123' })
      .expect(201)
      .expect((res) => {
        expect(res.body.id).toBeDefined();
        expect(res.body.email).toBe('test@test.com');
      });
  });

  it('GET /users/:id 존재하지 않는 사용자 조회 시 404', () => {
    return request(app.getHttpServer())
      .get('/users/999999')
      .expect(404);
  });
});
```

---

## 공통 설정 패턴

### 전역 Setup/Teardown

```typescript
// jest.setup.ts
import { GenericContainer, StartedTestContainer } from 'testcontainers';

let mysqlContainer: StartedTestContainer;
let redisContainer: StartedTestContainer;

beforeAll(async () => {
  // 병렬로 컨테이너 시작
  [mysqlContainer, redisContainer] = await Promise.all([
    new MySqlContainer('mysql:8.0').start(),
    new RedisContainer('redis:7-alpine').start(),
  ]);

  // 환경변수로 연결 정보 전달
  process.env.DATABASE_HOST = mysqlContainer.getHost();
  process.env.DATABASE_PORT = mysqlContainer.getPort().toString();
  process.env.REDIS_HOST = redisContainer.getHost();
  process.env.REDIS_PORT = redisContainer.getPort().toString();
}, 120000);

afterAll(async () => {
  await Promise.all([
    mysqlContainer?.stop(),
    redisContainer?.stop(),
  ]);
});
```

### Jest 설정

```javascript
// jest.config.js
module.exports = {
  // Integration 테스트 분리
  projects: [
    {
      displayName: 'unit',
      testMatch: ['**/*.spec.ts'],
      setupFilesAfterEnv: ['<rootDir>/jest.unit.setup.ts'],
    },
    {
      displayName: 'integration',
      testMatch: ['**/*.integration.spec.ts'],
      setupFilesAfterEnv: ['<rootDir>/jest.integration.setup.ts'],
      testTimeout: 60000,
    },
    {
      displayName: 'e2e',
      testMatch: ['**/*.e2e.spec.ts'],
      setupFilesAfterEnv: ['<rootDir>/jest.e2e.setup.ts'],
      testTimeout: 120000,
    },
  ],
};
```

---

## Best Practices

| 항목 | 권장 사항 |
|------|----------|
| 타임아웃 | `beforeAll`에 60000ms 이상 설정 |
| 이미지 태그 | `latest` 대신 명시적 버전 사용 (mysql:8.0) |
| 병렬 실행 | 독립적인 컨테이너로 테스트 격리 |
| CI 환경 | Docker-in-Docker 또는 권한 설정 필요 |
| 리소스 정리 | `afterAll`에서 반드시 `stop()` 호출 |

---

@../CLAUDE.md | @testing-strategies.md
