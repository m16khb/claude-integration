# 참고 자료

## 공식 문서

### Claude Code
- [Claude Code CLI Guide](https://docs.anthropic.com/claude/docs/claude-code)
- [Skills Schema](https://docs.anthropic.com/claude/docs/skills-schema)
- [Commands Schema](https://docs.anthropic.com/claude/docs/commands-schema)
- [Agents Schema](https://docs.anthropic.com/claude/docs/agents-schema)

### 프레임워크
- [NestJS Documentation](https://docs.nestjs.com/)
- [Fastify Documentation](https://www.fastify.io/docs/latest/)
- [TypeORM Documentation](https://typeorm.io/)
- [Suites Testing Framework](https://suites.dev/)
- [BullMQ Documentation](https://docs.bullmq.io/)

## MCP 서버

### 내장 서버
- **Playwright**: 브라우저 자동화 테스트
  - GitHub: https://github.com/microsoft/playwright
  - 주요 기능: E2E 테스트, 스크린샷, 네트워크 모의

- **Context7**: 최신 문서 주입 시스템
  - 지원 라이브러리: 1000+ 개
  - 실시간 API 문서 접근

- **Sequential Thinking**: 단계별 사고 프로세스
  - 복잡한 문제 해결
  - 사고 과정 시각화

- **Chrome DevTools**: 브라우저 개발자 도구
  - 성능 분석
  - 디버깅 및 최적화

### 외부 MCP 서버 레지스트리
- [MCP Server Registry](https://github.com/modelcontextprotocol/servers)
- 커뮤니티 서버 목록

## 아키텍처 패턴

### 오케스트레이션 패턴

#### 1. Orchestrator-Worker
```
Orchestrator (조율자)
├── 요청 분석
├── 작업 분배
└── 결과 통합

Workers (실행자)
├── 전문 도메인 처리
└── 결과 반환
```

#### 2. Agent Routing
```
Keyword Detection
├── Primary (3점): 핵심 키워드
├── Secondary (2점): 관련 키워드
└── Context (1점): 문맥 키워드

Score Calculation
├── 점수 합산
├── 최고 점수 선택
└── 동점 시 PARALLEL 실행
```

### 문서 구조 패턴

#### Progressive Disclosure
```
Level 1: Root CLAUDE.md (150줄)
├── 핵심 개요
├── 빠른 시작
└── 상세 문서 링크

Level 2: Module CLAUDE.md (80줄)
├── 모듈 개요
├── 주요 컴포넌트
└── 심화 링크

Level 3: agent-docs/ (상세)
├── 가이드
├── 예제
└── 참조
```

## 베스트 프랙티스

### 1. 에이전트 설계
- **단일 책임**: 하나의 명확한 도메인만 담당
- **명확한 인터페이스**: 입력과 출력이 명확하게 정의
- **상태 비저장**: 각 호출은 독립적으로 처리

### 2. 스킬 설계
- **재사용성**: 여러 에이전트가 공유 가능
- **자동 활성화**: 키워드 기반 자동 로드
- **경량화**: 최소한의 지식만 포함

### 3. 커맨드 설계
- **단일 목적**: 하나의 명확한 목표
- **최소 인자**: 필수 인자만 요구
- **선제적 검증**: 입력값 미리 검증

## 성능 가이드라인

### 1. 라우팅 성능
- 키워드 수 제한 (Primary: 5개, Secondary: 10개)
- 정규표현식 최적화
- 캐싱 활용

### 2. 병렬 처리
- 독립적 작업은 PARALLEL 실행
- 의존성은 SEQUENTIAL 실행
- 타임아웃 설정 (기본 30초)

### 3. 모델 선택
| 복잡도 | 추천 모델 | 예시 |
|--------|----------|------|
| 높음 | Opus 4.5 | 아키텍처 설계, 복잡 분석 |
| 중간 | Sonnet 3.5 | 코드 리뷰, 일반 구현 |
| 낮음 | Haiku 3.5 | 단순 작업, 결정론적 출력 |

## 보안 가이드라인

### 1. 데이터 처리
- 민감정보 노출 금지 (API 키, 패스워드)
- 입력값 항상 검증
- SQL Injection 방지

### 2. 실행 환경
- 샌드박스 환경 실행
- 네트워크 접근 제어
- 파일 시스템 권한 최소화

### 3. 코드 품질
- 정적 분석 도구 사용
- 취약점 스캔 주기적 실행
- 의존성 최신화

## 테스트 전략

### 1. 단위 테스트
- Suites 3.x 활용
- 100% 커버리지 목표
- 모의 객체 적극 활용

### 2. 통합 테스트
- 에이전트 간 통합
- 라우팅 시스템 검증
- 병렬 실행 테스트

### 3. E2E 테스트
- 실제 시나리오 기반
- Playwright 자동화
- 성능 벤치마크

## 디버깅 가이드

### 1. 로깅 전략
```typescript
// 구조화된 로깅
logger.info('Agent execution', {
  agent: 'typeorm-expert',
  input: { action: 'create-entity', type: 'User' },
  duration: 1250,
  result: 'success'
});
```

### 2. 오류 처리
- 상세한 에러 메시지
- 복구 가능한 오류 처리
- 롤백 전략

### 3. 모니터링
- 실행 시간 추적
- 성능 지표 수집
- 예외 패턴 분석

## 커뮤니티 리소스

### 1. 저장소
- [Examples Repository](https://github.com/anthropics/claude-code-examples)
- [Community Plugins](https://github.com/topics/claude-code-plugin)
- [Template Gallery](https://github.com/topics/claude-code-template)

### 2. 포럼
- [Discord Community](https://discord.gg/claude-ai)
- [GitHub Discussions](https://github.com/anthropics/claude-code/discussions)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/claude-code)

## 변경 로그

### v2.2.0 (2025-12-04)
- routing-table.json 스키마 업데이트
- 프리픽스 기반 컴포넌트 관리
- 동기화 개선

### v2.1.0 (2025-11-15)
- MCP 서버 내장
- 계층적 문서 구조 도입
- Progressive Disclosure 패턴

### v2.0.0 (2025-11-01)
- Agent Routing System 도입
- Suite 3.x 테스트 프레임워크 통합
- 워크플로우 오케스트레이션

## 라이선스

- 프로젝트: MIT License
- 개별 컴포넌트: 각자의 라이선스 준수
- 서드파티: 해당 라이브러리 라이선스

## 기여 가이드

### 1. 코드 기여
- Fork 후 Pull Request
- 테스트 코드 포함
- 문서 업데이트

### 2. 버그 보고
- GitHub Issues 사용
- 재현 단계 포함
- 환경 정보 명시

### 3. 기능 요청
- 사용 사례 명시
- 제안 구현 포함
- 영향도 분석