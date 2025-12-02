# 개발 가이드

## 새 커맨드 추가

1. `.claude/commands/` 디렉토리에 `.md` 파일 생성
2. Frontmatter에 메타데이터 정의
3. `plugin.json`의 commands 섹션에 등록
4. 테스트: `/plugin reload` → `/새커맨드`

## 모델 선택 기준

| 모델 | 용도 | 예시 |
|------|------|------|
| **haiku** | 빠른 파싱, 단순 작업 | inject-context |
| **default** | 일반 작업 | git-commit, claude-md |
| **opus** | 복잡한 추론, 코드 생성 | continue-task |
