# 참고 프레임워크

## 핵심 참고 자료

| 프레임워크 | 설명 | 적용 패턴 |
|-----------|------|----------|
| [Anthropic Skills](https://github.com/anthropics/skills) | 공식 스킬 스키마 | Skills Schema |
| [MoAI-ADK](https://github.com/modu-ai/moai-adk) | AI 에이전트 개발 키트 | SPEC-First TDD, Orchestrator |
| [claude-code-skill-factory](https://github.com/alirezarezvani/claude-code-skill-factory) | 스킬 팩토리 시스템 | 5 Factory 패턴 |
| [Spec Kit](https://github.com/github/spec-kit) | 스펙 기반 개발 | 명세 우선 개발 |

## 적용 패턴 설명

### Orchestrator-Worker 패턴
- 복잡한 작업을 하위 작업으로 분해
- 각 Worker가 독립적으로 처리

### SPEC-First TDD
- 명세 정의 → 테스트 작성 → 구현 순서
- 명확한 요구사항 기반 개발

### Progressive Disclosure
- CLAUDE.md는 최소한으로 유지
- 상세 내용은 agent_docs/로 분리
- Claude가 필요 시 상세 문서 참조

### 5 Factory 시스템
- Agent, Skill, Command 등 컴포넌트별 생성기
- 일관된 템플릿 기반 생성
