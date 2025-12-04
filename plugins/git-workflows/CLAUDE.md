---
name: git-workflows
description: 'Git 워크플로우 자동화 - 스마트 커밋, Git Flow 지원'
category: development
---

# git-workflows Plugin

Git Flow 기반의 스마트 커밋 시스템을 제공합니다.

## Overview

- **git-commit**: 변경사항 분석 및 자동 커밋 메시지 생성
- **Git Flow 호환**: feature, hotfix, release 브랜치 지원

## Key Components

### Commands
- `/git-commit` - 스마트 Git 커밋 (인자: push - 커밋 후 푸시)

## Features

### Smart Commit Analysis
- 변경된 파일 유형 감지 (feat, fix, refactor, docs 등)
- 관련 이슈 자동 연결
- 커밋 메시지 한글 자동 생성

### Git Flow Integration
```bash
# 기본 커밋
/git-commit

# 커밋 후 자동 푸시
/git-commit push

# 결과 예시:
# feat: 사용자 인증 API 추가
# - JWT 토큰 발급 기능 구현
# - 로그인/로그아웃 엔드포인트 추가
```

## Commit Types

- **feat**: 새로운 기능
- **fix**: 버그 수정
- **refactor**: 리팩토링
- **docs**: 문서 변경
- **test**: 테스트 코드
- **chore**: 빌드/설정 변경

## Integration

- full-stack-orchestration의 마지막 단계로 호출
- 코드 리뷰 결과를 커밋 메시지에 반영

[parent](../CLAUDE.md)