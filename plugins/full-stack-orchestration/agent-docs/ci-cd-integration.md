# CI/CD Integration

> 다양한 CI/CD 플랫폼과의 통합 가이드 및 템플릿

## GitHub Actions

### Node.js 프로젝트 기본 템플릿

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '20'

jobs:
  review:
    name: Code Review
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npm run type-check

      - name: Security audit
        run: npm audit --audit-level=high

  test:
    name: Testing
    runs-on: ubuntu-latest
    needs: review
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Unit tests
        run: npm run test:unit -- --coverage

      - name: Integration tests
        run: npm run test:integration

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to production
        run: |
          # 배포 스크립트
          echo "Deploying..."
```

### Docker 빌드 템플릿

```yaml
# .github/workflows/docker.yml
name: Docker Build

on:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Extract version
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: myapp/backend
          tags: |
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Matrix 테스트 템플릿

```yaml
# .github/workflows/matrix-test.yml
name: Matrix Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        node: [18, 20, 22]
      fail-fast: false

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}

      - name: Install and test
        run: |
          npm ci
          npm test
```

---

## GitLab CI

### 기본 파이프라인

```yaml
# .gitlab-ci.yml
stages:
  - review
  - test
  - build
  - deploy

variables:
  NODE_VERSION: "20"

default:
  image: node:${NODE_VERSION}
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/

.node_setup: &node_setup
  before_script:
    - npm ci --cache .npm --prefer-offline

lint:
  stage: review
  <<: *node_setup
  script:
    - npm run lint
    - npm run type-check

security:
  stage: review
  <<: *node_setup
  script:
    - npm audit --audit-level=high
  allow_failure: true

unit-test:
  stage: test
  <<: *node_setup
  script:
    - npm run test:unit -- --coverage
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
  artifacts:
    reports:
      junit: junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

integration-test:
  stage: test
  <<: *node_setup
  services:
    - postgres:15
    - redis:7
  variables:
    DATABASE_URL: "postgresql://postgres:postgres@postgres:5432/test"
    REDIS_URL: "redis://redis:6379"
  script:
    - npm run test:integration

build:
  stage: build
  <<: *node_setup
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

deploy-staging:
  stage: deploy
  script:
    - echo "Deploying to staging..."
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy-production:
  stage: deploy
  script:
    - echo "Deploying to production..."
  environment:
    name: production
    url: https://example.com
  only:
    - main
  when: manual
```

---

## Jenkins

### Jenkinsfile (Declarative)

```groovy
// Jenkinsfile
pipeline {
    agent {
        docker {
            image 'node:20'
        }
    }

    environment {
        NPM_CONFIG_CACHE = "${WORKSPACE}/.npm"
    }

    stages {
        stage('Setup') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Review') {
            parallel {
                stage('Lint') {
                    steps {
                        sh 'npm run lint'
                    }
                }
                stage('Type Check') {
                    steps {
                        sh 'npm run type-check'
                    }
                }
                stage('Security') {
                    steps {
                        sh 'npm audit --audit-level=high || true'
                    }
                }
            }
        }

        stage('Test') {
            steps {
                sh 'npm run test:coverage'
            }
            post {
                always {
                    junit 'junit.xml'
                    publishCoverage adapters: [istanbulCoberturaAdapter('coverage/cobertura-coverage.xml')]
                }
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'npm run deploy'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            slackSend color: 'good', message: "Build succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        }
        failure {
            slackSend color: 'danger', message: "Build failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        }
    }
}
```

---

## AWS CodePipeline

### CloudFormation 템플릿

```yaml
# cloudformation/pipeline.yml
AWSTemplateFormatVersion: '2010-09-09'
Description: CI/CD Pipeline

Parameters:
  GitHubRepo:
    Type: String
  GitHubBranch:
    Type: String
    Default: main

Resources:
  CodeBuildProject:
    Type: AWS::CodeBuild::Project
    Properties:
      Name: !Sub ${AWS::StackName}-build
      ServiceRole: !GetAtt CodeBuildRole.Arn
      Artifacts:
        Type: CODEPIPELINE
      Environment:
        Type: LINUX_CONTAINER
        ComputeType: BUILD_GENERAL1_SMALL
        Image: aws/codebuild/standard:7.0
      Source:
        Type: CODEPIPELINE
        BuildSpec: |
          version: 0.2
          phases:
            install:
              runtime-versions:
                nodejs: 20
              commands:
                - npm ci
            pre_build:
              commands:
                - npm run lint
                - npm run test
            build:
              commands:
                - npm run build
          artifacts:
            files:
              - '**/*'
            base-directory: dist

  Pipeline:
    Type: AWS::CodePipeline::Pipeline
    Properties:
      Name: !Sub ${AWS::StackName}
      RoleArn: !GetAtt PipelineRole.Arn
      Stages:
        - Name: Source
          Actions:
            - Name: GitHub
              ActionTypeId:
                Category: Source
                Owner: ThirdParty
                Provider: GitHub
                Version: '1'
              Configuration:
                Owner: !Ref GitHubOwner
                Repo: !Ref GitHubRepo
                Branch: !Ref GitHubBranch
              OutputArtifacts:
                - Name: SourceOutput

        - Name: Build
          Actions:
            - Name: Build
              ActionTypeId:
                Category: Build
                Owner: AWS
                Provider: CodeBuild
                Version: '1'
              Configuration:
                ProjectName: !Ref CodeBuildProject
              InputArtifacts:
                - Name: SourceOutput
              OutputArtifacts:
                - Name: BuildOutput

        - Name: Deploy
          Actions:
            - Name: Deploy
              ActionTypeId:
                Category: Deploy
                Owner: AWS
                Provider: S3
                Version: '1'
              Configuration:
                BucketName: !Ref DeploymentBucket
                Extract: 'true'
              InputArtifacts:
                - Name: BuildOutput
```

---

## 통합 Best Practices

### 1. 환경 변수 관리

```yaml
# 민감 정보는 항상 Secrets 사용
env:
  # 공개 가능 설정
  NODE_ENV: production
  LOG_LEVEL: info

secrets:
  # GitHub Secrets
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  API_KEY: ${{ secrets.API_KEY }}
```

### 2. 캐싱 전략

| 플랫폼 | 캐시 대상 | 키 전략 |
|--------|----------|---------|
| GitHub Actions | node_modules | hash(package-lock.json) |
| GitLab CI | node_modules, .npm | branch + hash |
| Jenkins | node_modules | workspace-based |

### 3. 병렬화

```yaml
# 독립적인 작업은 병렬 실행
parallel:
  - lint
  - type-check
  - security-scan

# 의존성 있는 작업은 순차 실행
sequential:
  - build (depends: test)
  - deploy (depends: build)
```

---

[CLAUDE.md](../CLAUDE.md) | [pipeline-architecture.md](pipeline-architecture.md) | [workflow-patterns.md](workflow-patterns.md)
