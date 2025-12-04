---
name: context-management
description: '컨텍스트 관리 - 대용량 파일 처리, 작업 추천, 인지 부하 감소'
category: productivity
---

# context-management Plugin

대용량 파일 처리와 스마트 작업 추천으로 개발 흐름을 최적화합니다.

## Overview

- **continue-context**: 현재 컨텍스트 분석 및 다음 작업 추천
- **inject-context**: 대용량 파일 구조 인식 및 청킹 주입

## Key Components

### Commands
- `/continue-context [focus-area]` - 컨텍스트 분석 후 작업 추천
- `/inject-context <file_path> [task_instruction]` - 대용량 파일 청킹 처리

## Use Cases

### Workflow Analysis
```bash
# 현재 상황 분석 및 다음 단계 추천
/continue-context
```

### Large File Handling
```bash
# 대용량 파일 인식 청킹
/inject-context src/nestia.config.ts "컨피그 분석해줘"
```

## Features

- **인지 부하 감소**: 대용량 파일을 자동으로 청킹하여 처리
- **스마트 라우팅**: 분석 결과를 기반으로 적절한 전문가 추천
- **상태 보존**: 작업 중단 후 컨텍스트 유지

## Integration

- full-stack-orchestration과 연동하여 워크플로우 최적화
- code-quality와 연동하여 집중 영역 리뷰

[parent](../CLAUDE.md)