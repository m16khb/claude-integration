# Document Builder Templates

document-builder 에이전트가 사용하는 CLAUDE.md 생성 템플릿입니다.

## ROOT CLAUDE.md Template

```markdown
# CLAUDE.md

## 프로젝트 개요

**{project_name}**은(는) {short_description}입니다.

## 기술 스택

- **언어**: {language}
- **프레임워크**: {framework}
- **패턴**: {patterns}

## 프로젝트 구조

\`\`\`
{project_name}/
├── CLAUDE.md                    # 루트 오케스트레이터
├── agent-docs/                  # 루트 공통 문서
{structure_tree}
\`\`\`

## 주요 커맨드/에이전트

| 이름 | 설명 |
|------|------|
{main_items_table}

## 모듈별 컨텍스트

| 모듈 | CLAUDE.md | 설명 |
|------|-----------|------|
{modules_table}

## 상세 문서

- [agent-docs/architecture.md](agent-docs/architecture.md) - 아키텍처 가이드
{additional_docs}
```

---

## MODULE CLAUDE.md Template

```markdown
# {module_name}/ CLAUDE.md

## 모듈 개요

{module_description}

## 파일 구조

\`\`\`
{module_name}/
├── CLAUDE.md
{file_tree}
\`\`\`

## 포함된 항목

| 이름 | 설명 |
|------|------|
{items_table}

## 작성 가이드

{writing_guide_summary}

상세 내용은 [agent-docs/{module}-guide.md](agent-docs/{module}-guide.md) 참조

## 상세 문서

{docs_links}

## 참조

- [Root CLAUDE.md](../CLAUDE.md)
```

---

## SUBMODULE CLAUDE.md Template

```markdown
# {submodule_name}/ CLAUDE.md

## 전문 분야

{specialization}

## 포함된 에이전트

| 에이전트 | 전문 분야 |
|---------|----------|
{agents_table}

## 사용법

\`\`\`
{usage_example}
\`\`\`

## 상세 문서

{docs_links}

## 참조

- [상위 모듈](../CLAUDE.md)
- [루트](../../CLAUDE.md)
```

---

## agent-docs/ Recommended Structure

### ROOT level agent-docs/

```
agent-docs/
├── architecture.md      # 전체 아키텍처 다이어그램 및 설명
├── installation.md      # 설치 가이드
├── references.md        # 외부 참고 문서 링크
└── development.md       # 개발 가이드
```

### MODULE level agent-docs/

```
{module}/agent-docs/
├── {module}-schema.md   # 스키마/구조 정의
├── {module}-guide.md    # 모듈별 작성 상세 가이드
└── examples.md          # 코드 예시
```

### SUBMODULE level agent-docs/

```
{submodule}/agent-docs/
├── patterns.md          # 패턴/예시
└── best-practices.md    # 모범 사례
```

---

## Placeholder Reference

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{project_name}` | 프로젝트 이름 | claude-integration |
| `{short_description}` | 1줄 설명 | Claude Code 생산성 향상 플러그인 |
| `{language}` | 주요 언어 | TypeScript, Markdown |
| `{framework}` | 프레임워크 | Claude Code CLI |
| `{patterns}` | 설계 패턴 | Orchestrator-Worker |
| `{structure_tree}` | 디렉토리 트리 | ├── commands/... |
| `{main_items_table}` | 주요 항목 테이블 | \| /git-commit \| Git 커밋 \| |
| `{modules_table}` | 모듈 링크 테이블 | \| commands/ \| ... \| |
| `{module_name}` | 모듈 이름 | commands |
| `{module_description}` | 모듈 설명 | 슬래시 커맨드 정의 모듈 |
| `{file_tree}` | 파일 목록 | ├── git-commit.md |
| `{items_table}` | 포함 항목 테이블 | \| git-commit \| ... \| |
| `{writing_guide_summary}` | 작성 가이드 요약 | 3-5줄 요약 |
| `{docs_links}` | 문서 링크 목록 | - [guide.md](agent-docs/guide.md) |
| `{submodule_name}` | 서브모듈 이름 | backend |
| `{specialization}` | 전문 분야 | NestJS 생태계 전문 에이전트 |
| `{agents_table}` | 에이전트 테이블 | \| typeorm-expert \| ... \| |
| `{usage_example}` | 사용법 예시 | Task(subagent_type="...") |

---

## Line Count Guidelines

| Type | Max Lines | Recommended |
|------|-----------|-------------|
| ROOT | 150 | 80-120 |
| MODULE | 80 | 40-60 |
| SUBMODULE | 50 | 30-40 |

### Over Limit? Extract to agent-docs/

```
Extractable sections:
├─ Detailed code blocks (> 10 lines)
├─ Comprehensive guides (> 20 lines)
├─ Large tables (> 15 rows)
├─ Architecture diagrams
└─ Examples collection
```
