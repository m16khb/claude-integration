# automation-tools 사용 예제

이 문서는 automation-tools 플러그인의 실제 사용 예제와 통합 패턴을 제공합니다.

---

## 1. Factory 명령어 예제

### 에이전트 생성

```bash
# 기본 문서 기반 생성
/automation-tools:factory agent "React 컴포넌트 전문가"

# 특정 문서 기반 생성
/automation-tools:factory agent https://docs.nestjs.com/controllers

# 복합 전문가 생성
/automation-tools:factory agent "PostgreSQL + Redis 전문가"
```

**결과물 예시**:
- `plugins/database-experts/CLAUDE.md`
- `plugins/database-experts/agents/postgresql-expert.md`
- `plugins/database-experts/agents/redis-expert.md`
- `plugins/database-experts/skills/database-routing.md`

### Skill 및 Command 생성

```bash
# Skill 생성
/automation-tools:factory skill react-component-generator

# Command 생성
/automation-tools:factory command microservice-init
```

---

## 2. Prompt Optimizer 예제

```bash
# 직접 텍스트 입력 최적화
/automation-tools:prompt-optimizer "React 컴포넌트 만들어줘"

# 파일에서 프롬프트 읽어 최적화
/automation-tools:prompt-optimizer prompt.txt

# 대화형 최적화
/automation-tools:prompt-optimizer

# URL 기반 문서를 프롬프트로 변환
/automation-tools:prompt-optimizer https://docs.example.com/guide
```

---

## 3. Status Line 설정 예제

```bash
# 대화형 설정
/automation-tools:setup-statusline

# 특정 설정 파일로 설정
/automation-tools:setup-statusline --config .claude/custom-status.yml

# 템플릿 적용
/automation-tools:setup-statusline --template fullstack
```

---

## 4. Claude Sync 예제

```bash
# 전체 프로젝트 동기화
/automation-tools:claude-sync

# 특정 플러그인만 동기화
/automation-tools:claude-sync --target plugins/nestjs-backend

# 워치 모드 시작
/automation-tools:claude-sync --watch
```

---

## 5. 통합 시나리오

### NestJS 프로젝트 자동화

```bash
# 전체 NestJS 스택 설정
/automation-tools:factory agent "NestJS 전문가"
/automation-tools:setup-statusline --template nestjs
/automation-tools:claude-sync --watch
```

### React 개발 환경

```bash
# React 관련 컴포넌트 생성
/automation-tools:factory skill react-component-generator
/automation-tools:factory command react-component-create
/automation-tools:setup-statusline --config .claude/react-status.yml
```

### 마이크로서비스 아키텍처

```bash
# 마이크로서비스 템플릿 적용
/automation-tools:factory command microservice-init
/automation-tools:factory agent "Kubernetes 전문가"
/automation-tools:claude-sync --target infrastructure/
```

---

## 6. 결과물 예시

### 생성된 Agent 구조

```
plugins/my-expert/
├─ CLAUDE.md           # 플러그인 메타데이터
├─ agents/
│   └─ my-expert.md    # 에이전트 정의
├─ skills/
│   └─ routing.md      # 라우팅 스킬
└─ commands/
    └─ init.md         # 초기화 커맨드
```

### 생성된 Status Line 출력

```
[main] DEV 0 errors PASS | 12:34:56
```

---

[parent](../CLAUDE.md) | [detailed-guides](detailed-guides.md) | [references](references.md)
