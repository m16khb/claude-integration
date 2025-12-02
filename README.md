# Claude Integration

Claude Code 생산성 향상을 위한 스마트 커맨드 플러그인입니다.

## 설치

### 방법 1: 마켓플레이스 추가 후 설치 (권장)

```bash
# 1. 마켓플레이스 추가
/plugin marketplace add m16khb/claude-integration

# 2. 플러그인 설치
/plugin install claude-integration
```

### 방법 2: 직접 설치

```bash
/plugin add m16khb/claude-integration
```

## 커맨드 목록

| 커맨드              | 설명                            | 모델  |
| ------------------- | ------------------------------- | ----- |
| `/git-commit`       | Git Flow 기반 스마트 커밋       | 기본  |
| `/claude-md`        | CLAUDE.md 생성/분석/구조화      | Opus  |
| `/continue-context` | 컨텍스트 분석 및 다음 작업 추천 | 기본  |
| `/inject-context`   | 대용량 파일 컨텍스트 주입       | Haiku |
| `/setup-statusline` | Status line 환경 자동 구성      | Opus  |

## 커맨드 상세

### /git-commit

Git 커밋을 스마트하게 생성합니다.

**특징**:

- Git Flow 브랜치 컨텍스트 인식 (feature/release/hotfix)
- Conventional Commits 형식 자동 적용
- 민감 파일 자동 감지 및 경고
- main/master 브랜치 보호

**사용법**:

```bash
# 커밋만
/git-commit

# 커밋 + 푸시
/git-commit push
```

### /claude-md

WHAT/WHY/HOW 프레임워크 기반으로 CLAUDE.md를 관리합니다.

**핵심 원칙**:

- Less is More: 60줄 이하 권장, 300줄 초과 금지
- Universal Relevance: 모든 세션에 관련된 내용만
- Progressive Disclosure: 상세 내용은 agent_docs/로 분리

**사용법**:

```bash
# 작업 선택 TUI
/claude-md

# 직접 실행
/claude-md 분석      # 품질 분석
/claude-md 생성      # 새 파일 생성
/claude-md 구조화    # Progressive Disclosure 설정
/claude-md 검사      # 린트 검사
```

### /continue-context

현재 대화 컨텍스트를 분석하여 다음 작업을 스마트하게 추천합니다.

**분석 항목**:

- 로드된 파일 및 수정된 파일
- 완료된 작업 및 미완료 항목
- Git 상태 (커밋되지 않은 변경사항)
- 현재 포커스 영역

**추천 카테고리**:

- 즉시 작업: 커밋, 테스트 수정, 오류 해결
- 다음 단계: 테스트 작성, 문서화, PR 생성
- 품질 개선: 리팩토링, 보안 검토

**사용법**:

```bash
# 전체 컨텍스트 분석
/continue-context

# 특정 영역에 포커스
/continue-context 테스트
```

### /inject-context

대용량 파일을 구조 인식 청킹으로 분할 로드합니다.

**특징**:

- 코드 경계 인식 (함수, 클래스 단위)
- 500줄 청크 + 20줄 오버랩
- 자동 Opus 위임 옵션

**사용법**:

```bash
/inject-context src/large-file.ts
/inject-context src/api.ts "API 엔드포인트 분석"
```

### /setup-statusline

Claude Code status line 환경을 YAML 기반으로 자동 구성합니다.

**특징**:

- Single Source of Truth 아키텍처 (YAML → Shell)
- 크로스 플랫폼 지원 (macOS/Linux)
- 이모지 지원 자동 감지
- 터미널별 자동 설정 (zsh, bash)

**사용법**:

```bash
# 기본 설정 (대화형)
/setup-statusline

# 설정 파일 지정
/setup-statusline ~/.claude/statusline.yaml
```

## 프로젝트 구조

```
claude-integration/
├── .claude-plugin/
│   ├── plugin.json        # 마켓플레이스용 플러그인 메타데이터
│   └── marketplace.json   # 마켓플레이스 정의
├── commands/              # 슬래시 커맨드 (5개)
│   ├── git-commit.md
│   ├── claude-md.md
│   ├── continue-context.md
│   ├── inject-context.md
│   └── setup-statusline.md
├── templates/             # 템플릿 파일
│   ├── statusline.sh      # Status line 스크립트
│   └── statusline-config.yaml
├── agent_docs/            # 상세 개발 문서
│   ├── command-writing.md
│   └── development.md
├── CLAUDE.md              # 프로젝트 컨텍스트
├── LICENSE                # MIT 라이선스
└── README.md
```

## 기여

이슈와 PR을 환영합니다!

## 라이선스

MIT License - 자유롭게 사용, 수정, 배포할 수 있습니다.
