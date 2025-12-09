---
name: git-workflows
description: 'Git 워크플로우 자동화 - 스마트 커밋, Git Flow 지원'
category: development
---

# git-workflows Plugin

지능적인 Git 워크플로우 자동화 시스템으로 변경사항을 분석하고 최적의 커밋 메시지를 생성합니다.

## Core Philosophy

```
Git 워크플로우 원칙:
├─ 의미 있는 커밋: 변경의 "왜"와 "무엇"을 명확히 전달
├─ 일관된 형식: Conventional Commits 표준
├─ 자동화: 반복적인 Git 작업을 자동으로 처리
└─ 컨텍스트 인식: 브랜치와 작업 유형에 따른 적절한 메시지
```

## 파일 구조

```
plugins/git-workflows/
├── CLAUDE.md              # 본 문서
├── agent-docs/            # 상세 문서
│   ├── detailed-guides.md # Git Flow, 커밋 규약 상세
│   ├── examples.md        # 사용 예제
│   └── references.md      # Best Practices, 문제 해결
├── commands/
│   └── git-commit.md      # 스마트 커밋 커맨드
├── agents/
│   └── .gitkeep
└── skills/
    └── .gitkeep
```

## Commands

| 커맨드 | 설명 | 인자 |
|--------|------|------|
| `git-commit` | 변경사항 분석 및 스마트 커밋 | `push` - 커밋 후 자동 푸시 |

## 주요 기능

| 기능 | 설명 |
|------|------|
| **변경 분석** | Git diff 분석, 파일 유형 식별, 그룹화 |
| **메시지 생성** | Conventional Commits 형식 자동 생성 |
| **다중 커밋** | 논리적 단위로 자동 분할 및 개별 커밋 |
| **Git Flow** | 브랜치 타입별 컨텍스트 인식 |
| **보안 검사** | 민감 파일 자동 감지 및 경고 |

## 커밋 타입

| 타입 | 설명 |
|------|------|
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `refactor` | 코드 구조 개선 |
| `docs` | 문서 변경 |
| `test` | 테스트 추가/수정 |
| `chore` | 빌드/설정 변경 |

## 사용법

```bash
# 기본 커밋
/git-workflows:git-commit

# 커밋 후 푸시
/git-workflows:git-commit push
```

## 상세 문서

- [detailed-guides.md](agent-docs/detailed-guides.md) - Git Flow, 커밋 규약
- [examples.md](agent-docs/examples.md) - 사용 예제
- [references.md](agent-docs/references.md) - Best Practices, Troubleshooting

[parent](../CLAUDE.md)