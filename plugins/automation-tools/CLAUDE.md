---
name: automation-tools
description: '자동화 도구 모음 - 컴포넌트 생성기, 상태 라인 설정, 동기화 도구'
category: productivity
---

# automation-tools Plugin

생산성 향상을 위한 자동화 도구 모음입니다.

## Overview

- **factory**: Agent, Skill, Command 컴포넌트 생성기
- **setup-statusline**: YAML 기반 상태 라인 환경 구성
- **claude-sync**: 코드베이스 변경 감지 및 CLAUDE.md 자동 동기화

## Key Components

### Commands
- `/factory` - WebFetch 기반 문서 분석으로 컴포넌트 자동 생성
- `/setup-statusline` - YAML 설정으로 status line 환경 구성
- `/claude-sync` - 변경 감지 및 CLAUDE.md 동기화 오케스트레이터

## Quick Start

```bash
# 새로운 Agent 생성
/factory agent typescript-validator

# Status line 설정
/setup-statusline

# CLAUDE.md 자동 동기화
/claude-sync
```

## Integration

- claude-sync가 모든 플러그인의 문서 변경을 감지
- routing-table.json 자동 갱신 지원
- WebFetch를 통한 실시간 문서 분석

[parent](../CLAUDE.md)