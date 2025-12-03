# agents/document/ CLAUDE.md

## 전문 분야

**문서화 전문 에이전트 모음**입니다. CLAUDE.md 및 agent-docs 문서 생성/관리를 담당합니다.

## 파일 구조

```
document/
├── CLAUDE.md                    # 이 파일
├── document-builder.md          # 계층적 문서 생성 에이전트
└── agent-docs/
    └── document-builder-templates.md  # 문서 템플릿
```

## 포함된 에이전트

| 에이전트 | 전문 분야 |
|---------|----------|
| `document-builder` | 계층적 CLAUDE.md 및 agent-docs 생성/수정 |

## 사용법

```
Task(
  subagent_type="document-builder",
  prompt="""
  Action: CREATE
  Target Path: commands
  Target Type: MODULE
  Context: ...
  """
)
```

## 상세 문서

- [agent-docs/document-builder-templates.md](agent-docs/document-builder-templates.md) - 문서 템플릿

## 참조

- [상위 모듈](../CLAUDE.md)
- [루트](../../CLAUDE.md)
