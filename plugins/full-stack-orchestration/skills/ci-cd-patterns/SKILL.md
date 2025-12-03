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
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

      redis:
        image: redis:7
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run tests
        run: npm run test:cov
        env:
          DATABASE_URL: postgres://test:test@localhost:5432/test
          REDIS_URL: redis://localhost:6379

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
```

### Build and Push Docker Image

```yaml
# .github/workflows/docker.yml
name: Build and Push Docker

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

## Dockerfile Patterns

### Multi-stage NestJS Dockerfile

```dockerfile
# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# 의존성 파일만 먼저 복사 (캐시 활용)
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# 소스 복사 및 빌드
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine AS production

WORKDIR /app

# 보안: non-root 사용자
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001

# 필요한 파일만 복사
COPY --from=builder --chown=nestjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nestjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nestjs:nodejs /app/package.json ./

USER nestjs

EXPOSE 3000

CMD ["node", "dist/main.js"]
```

---

## Deployment Strategies

### Blue-Green Deployment

```yaml
# k8s/blue-green/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  selector:
    app: api
    version: blue  # blue 또는 green으로 전환
  ports:
    - port: 80
      targetPort: 3000
```

### Canary Deployment (Istio)

```yaml
# istio/virtual-service.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: api-canary
spec:
  hosts:
    - api.example.com
  http:
    - route:
        - destination:
            host: api-stable
            port:
              number: 80
          weight: 90
        - destination:
            host: api-canary
            port:
              number: 80
          weight: 10
```

### Rolling Update (Kubernetes)

```yaml
# k8s/deployment.yaml
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
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 15
            periodSeconds: 20
```

---

## GitOps with ArgoCD

### Application Manifest

```yaml
# argocd/application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: api-production
  namespace: argocd
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
    syncOptions:
      - CreateNamespace=true
```

---

## Environment Configuration

### Secrets Management

```yaml
# GitHub Actions에서 secrets 사용
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  JWT_SECRET: ${{ secrets.JWT_SECRET }}

# Kubernetes Secrets
kubectl create secret generic api-secrets \
  --from-literal=DATABASE_URL='postgres://...' \
  --from-literal=JWT_SECRET='...'
```

### Environment Variables Pattern

```yaml
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-config
data:
  NODE_ENV: production
  LOG_LEVEL: info
  PORT: "3000"

# deployment에서 사용
envFrom:
  - configMapRef:
      name: api-config
  - secretRef:
      name: api-secrets
```

---

## Health Checks

### NestJS Health Module

```typescript
// health.controller.ts
@Controller('health')
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private db: TypeOrmHealthIndicator,
    private redis: RedisHealthIndicator,
  ) {}

  @Get()
  @HealthCheck()
  check() {
    return this.health.check([
      () => this.db.pingCheck('database'),
      () => this.redis.pingCheck('redis'),
    ]);
  }

  @Get('liveness')
  liveness() {
    return { status: 'ok' };
  }

  @Get('readiness')
  @HealthCheck()
  readiness() {
    return this.health.check([
      () => this.db.pingCheck('database'),
    ]);
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
