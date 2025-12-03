# 커맨드 상세

## 커맨드 목록

| 커맨드 | 설명 | 모델 |
|--------|------|------|
| `/git-commit [push]` | Conventional Commits 형식 커밋 | haiku |
| `/claude-sync` | 계층적 CLAUDE.md 동기화 (document-builder 병렬 호출) | opus |
| `/continue-context [focus]` | 현재 컨텍스트 분석 및 다음 작업 추천 | default |
| `/inject-context <file>` | 대용량 파일 청크 로드 | haiku |
| `/setup-statusline [config]` | YAML 설정 기반 status line 환경 구성 | opus |
| `/factory [type] [name]` | Agent, Skill, Command 컴포넌트 생성기 | sonnet |
| `/optimize-command <path>` | 커맨드 최적화 (프롬프트 엔지니어링) | opus |
| `/optimize-agents <path>` | 에이전트 최적화 (프롬프트 엔지니어링) | opus |

---

## 커맨드 작성 3원칙

1. **목적 정확성**: MISSION을 명확히 정의, 모든 분기 케이스 명시
2. **영어 로직**: 내부 로직은 영어로 (토큰 효율성)
3. **한글 TUI**: 사용자 인터페이스는 한글로 (UX)

---

## 사용 예시

```bash
# Git 커밋 (자동 메시지 생성)
/git-commit

# 커밋 후 즉시 푸시
/git-commit push

# 계층적 CLAUDE.md 동기화
/claude-sync

# 컴포넌트 생성
/factory agent my-agent
/factory skill my-skill
/factory command my-command

# 커맨드/에이전트 최적화
/optimize-command commands/my-command.md
/optimize-agents agents/backend/my-agent.md
```

---

## claude-sync 상세

계층적 문서 오케스트레이션 시스템 구축:

```
EXECUTION FLOW:
├─ Phase 1: 프로젝트 계층 구조 스캔
├─ Phase 2: Gap 분석 (CLAUDE.md, agent-docs 유무)
├─ Phase 2.5: 라인 초과 시 agent-docs 자동 분리
├─ Phase 3-4: 리포트 및 사용자 확인
├─ Phase 5: document-builder 병렬/순차 호출
├─ Phase 6: 루트 CLAUDE.md 업데이트
├─ Phase 7: 최종 검증
└─ Phase 8: 후속 TUI
```

### 라인 수 제한

| Type | Max Lines |
|------|-----------|
| ROOT | 150 |
| MODULE | 80 |
| SUBMODULE | 50 |

초과 시 자동으로 agent-docs/로 분리

---

## 상세 가이드

자세한 커맨드 작성 방법은 [command-writing.md](command-writing.md) 참조
