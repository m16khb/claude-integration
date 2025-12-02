# CLAUDE.md

## 프로젝트 개요

**claude-integration**은 Claude Code 생산성 향상을 위한 스마트 커맨드 및 스킬 플러그인입니다.

MoAI-ADK, Spec-Kit, claude-code-skill-factory 등 검증된 프레임워크의 베스트 프랙티스를 반영했습니다.

## 기술 스택

- **언어**: Markdown (커맨드/스킬 정의)
- **플랫폼**: Claude Code CLI
- **스키마**: Anthropic 2025 Skills/Commands Schema
- **패턴**: Orchestrator-Worker, Progressive Disclosure, SPEC-First TDD

## 프로젝트 구조

```
claude-integration/
├── .claude-plugin/
│   └── plugin.json          # 플러그인 메타데이터
├── commands/                # 슬래시 커맨드
│   ├── git-commit.md
│   ├── claude-md.md
│   ├── continue-context.md
│   ├── inject-context.md
│   ├── setup-statusline.md
│   └── factory.md           # 컴포넌트 생성기
├── skills/                  # 자동 활성화 스킬
│   └── factory/
│       ├── SKILL.md         # 메인 스킬 정의
│       └── templates/       # 생성 템플릿
│           ├── command.md
│           ├── skill.md
│           └── agent.md
├── templates/               # 기타 템플릿 (statusline 등)
├── docs/                    # 개발 문서
│   ├── command-writing.md
│   └── development.md
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
| `/factory [type] [name]` | Agent, Skill, Command 컴포넌트 생성기 | sonnet |

## 스킬 목록

| 스킬 | 설명 | 트리거 |
|------|------|--------|
| `factory` | agent/skill/command 생성 자동 활성화 | "agent 만들", "스킬 생성", "create command" 등 |

## 설치 및 사용 (HOW)

```bash
# 방법 1: 마켓플레이스 추가 후 설치 (권장)
/plugin marketplace add m16khb/claude-integration
/plugin install claude-integration

# 방법 2: 직접 설치
/plugin add m16khb/claude-integration
```

## 커맨드 작성 3원칙

1. **목적 정확성**: MISSION을 명확히 정의, 모든 분기 케이스 명시
2. **영어 로직**: 내부 로직은 영어로 (토큰 효율성)
3. **한글 TUI**: 사용자 인터페이스는 한글로 (UX)

## 참고 프레임워크

- [Anthropic Skills](https://github.com/anthropics/skills) - 공식 스킬 스키마
- [MoAI-ADK](https://github.com/modu-ai/moai-adk) - SPEC-First TDD, Orchestrator 패턴
- [claude-code-skill-factory](https://github.com/alirezarezvani/claude-code-skill-factory) - 5 Factory 시스템
- [Spec Kit](https://github.com/github/spec-kit) - 스펙 기반 개발

## 상세 문서

- [docs/command-writing.md](docs/command-writing.md) - 커맨드 작성 가이드
- [docs/development.md](docs/development.md) - 개발 가이드
