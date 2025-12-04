---
name: code-quality
description: '코드 품질 관리 - 리뷰, 테스트 자동화, 보안 분석'
category: quality
---

# code-quality Plugin

코드 품질 향상과 보안 강화를 위한 전문 도구 모음입니다.

## Overview

- **code-reviewer**: 보안, 성능, 품질 분석
- **test-automator**: Suites 3.x 기반 테스트 자동 생성
- **/review**: 통합 코드 리뷰 실행

## Key Components

### Agents
- `code-reviewer` - 보안 취약점, 성능 문제, 코드 스타일 분석
- `test-automator` - Suites 3.x 패턴 기반 테스트 코드 생성

### Commands
- `/review [file-path]` - 전체 코드베이스 또는 특정 파일 리뷰

### Skills
- `testing-patterns/` - Suites 3.x 테스트 패턴 모음

## Quick Start

```bash
# 전체 코드베이스 리뷰
/review

# 특정 파일 리뷰
/review src/user.service.ts

# 테스트 자동 생성 (agent 호출)
# "UserService에 대한 테스트 작성해줘"
```

## Integration Flow

`/review` → `code-reviewer` agent 호출 → 품질 분석 → 개선 제안

[parent](../CLAUDE.md)