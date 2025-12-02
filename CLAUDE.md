# CLAUDE.md

## 프로젝트 개요

**claude-integration**은 Claude Code 생산성 향상을 위한 스마트 커맨드 플러그인입니다.

## 기술 스택

- **언어**: Markdown (커맨드 정의)
- **플랫폼**: Claude Code CLI
- **구성**: plugin.json + .claude/commands/*.md

## 프로젝트 구조

```
claude-integration/
├── .claude-plugin/
│   └── plugin.json          # 플러그인 메타데이터 및 커맨드 등록
├── commands/                # 슬래시 커맨드 정의 파일
├── templates/               # 템플릿 파일 (statusline 등)
├── agent_docs/              # 상세 개발 문서
└── README.md
```

## 커맨드 목록

| 커맨드 | 설명 | 모델 |
|--------|------|------|
| `/git-commit [push]` | Conventional Commits 형식 커밋 | haiku |
| `/claude-md [action]` | CLAUDE.md 생성/분석/구조화 | default |
| `/continue-context [focus]` | 현재 컨텍스트 분석 및 다음 작업 추천 | default |
| `/inject-context <file>` | 대용량 파일 청크 로드 | haiku |
| `/setup-statusline [config]` | YAML 설정 기반 status line 환경 구성 | opus |

## 설치 및 사용 (HOW)

```bash
# 방법 1: 마켓플레이스 추가 후 설치 (권장)
/plugin marketplace add m16khb/claude-integration
/plugin install claude-integration

# 방법 2: 직접 설치
/plugin add m16khb/claude-integration
```

## 상세 문서

- [agent_docs/command-writing.md](agent_docs/command-writing.md) - 커맨드 작성 가이드
- [agent_docs/development.md](agent_docs/development.md) - 개발 가이드
