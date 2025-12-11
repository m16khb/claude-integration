# CI/CD Patterns Skill

CI/CD 파이프라인 구성, GitHub Actions, 배포 전략에 대한 패턴 가이드입니다.

## MCP Integration

```
SKILL ACTIVATION:
├─ Context7 MCP 호출 (최신 문서 조회)
│   ├─ resolve-library-id("github-actions")
│   ├─ get-library-docs(topic="workflow jobs matrix")
│   └─ 최신 GitHub Actions 문법 확인
│
└─ 적용 시점:
    ├─ CI/CD 파이프라인 설계 시
    ├─ GitHub Actions 워크플로우 작성 시
    └─ 배포 전략 구성 시
```

---

## Triggers

- "ci", "cd", "ci/cd", "파이프라인", "pipeline"
- "github actions", "workflow", "워크플로우"
- "deploy", "배포", "deployment"
- "docker", "container", "컨테이너"
- "kubernetes", "k8s"
- "argocd", "gitops"

---

## GitHub Actions Patterns

### Basic NestJS CI

```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env: { POSTGRES_USER: test, POSTGRES_PASSWORD: test, POSTGRES_DB: test }
        ports: ['5432:5432']
        options: --health-cmd pg_isready
      redis:
        image: redis:7
        ports: ['6379:6379']

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npm run lint
      - run: npm run test:cov
        env:
          DATABASE_URL: postgres://test:test@localhost:5432/test
          REDIS_URL: redis://localhost:6379
      - uses: codecov/codecov-action@v4
```

### Docker Build

```yaml
name: Build Docker
on:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.ref_name }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

## Dockerfile Patterns

### Multi-stage NestJS

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && adduser -S nestjs -u 1001
COPY --from=builder --chown=nestjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nestjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nestjs:nodejs /app/package.json ./
USER nestjs
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

---

## Deployment Strategies

| 전략 | 설명 | 장점 | 단점 |
|------|------|------|------|
| **Blue-Green** | 두 환경 전환 | 빠른 롤백 | 리소스 2배 |
| **Canary** | 트래픽 점진 증가 | 안전한 배포 | 복잡한 구성 |
| **Rolling Update** | 순차적 업데이트 | 다운타임 없음 | 느린 롤백 |

### Kubernetes Rolling Update

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # 최대 1개 추가 Pod
      maxUnavailable: 0  # 항상 최소 replicas 유지
  template:
    spec:
      containers:
        - name: api
          image: ghcr.io/org/api:latest
          readinessProbe:
            httpGet: { path: /health, port: 3000 }
            initialDelaySeconds: 5
          livenessProbe:
            httpGet: { path: /health, port: 3000 }
            initialDelaySeconds: 15
```

---

## GitOps with ArgoCD

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: api-production
spec:
  project: default
  source:
    repoURL: https://github.com/org/k8s-manifests
    targetRevision: main
    path: production/api
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## Environment Configuration

### Secrets Management

```yaml
# GitHub Actions Secrets
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  JWT_SECRET: ${{ secrets.JWT_SECRET }}

# Kubernetes Secrets
kubectl create secret generic api-secrets \
  --from-literal=DATABASE_URL='postgres://...' \
  --from-literal=JWT_SECRET='...'
```

---

## Health Checks (NestJS)

```typescript
@Controller('health')
export class HealthController {
  @Get()
  @HealthCheck()
  check() {
    return this.health.check([
      () => this.db.pingCheck('database'),
      () => this.redis.pingCheck('redis'),
    ]);
  }

  @Get('liveness')
  liveness() { return { status: 'ok' }; }

  @Get('readiness')
  @HealthCheck()
  readiness() {
    return this.health.check([() => this.db.pingCheck('database')]);
  }
}
```

---

## Best Practices Checklist

### CI Pipeline

- [ ] 의존성 캐싱 활성화
- [ ] 병렬 작업으로 실행 시간 단축
- [ ] 테스트 커버리지 리포팅
- [ ] 보안 스캔 (CodeQL, Snyk)
- [ ] PR에서만 실행되는 검사 분리

### CD Pipeline

- [ ] 이미지 태깅 전략 (semver + sha)
- [ ] 롤백 메커니즘 확보
- [ ] Health check 구현
- [ ] Graceful shutdown 처리
- [ ] 환경별 설정 분리

### Security

- [ ] Secrets를 코드에 포함하지 않기
- [ ] 최소 권한 원칙 적용
- [ ] 컨테이너 non-root 실행
- [ ] 이미지 취약점 스캔
- [ ] HTTPS 강제
