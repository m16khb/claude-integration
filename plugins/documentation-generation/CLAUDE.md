---
name: documentation-generation
description: '문서 생성 자동화 - CLAUDE.md, 에이전트 문서, 템플릿'
category: documentation
---

# documentation-generation Plugin

계층적 문서 구조와 자동화된 문서 생성을 제공합니다.

## Overview

- **document-builder**: 구조화된 기술 문서 생성 전문가
- **document-templates**: 재사용 가능한 문서 템플릿 모음

## Key Components

### Agents
- `document-builder` - 아키텍처 문서, API 문서, 가이드 생성

### Skills
- `document-templates/` - CLAUDE.md, API 문서, README 템플릿

## Document Types

1. **CLAUDE.md** - 프로젝트 설정 및 지침
2. **Agent Documentation** - 11개 표준 섹션 구조
3. **API Reference** - OpenAPI 기반 자동 생성
4. **Architecture Guides** - 시스템 설계 문서

## Quick Start

```bash
# 프로젝트 문서 생성
"새 프로젝트용 CLAUDE.md 작성해줘"

# API 문서 생성
"NestJS 프로젝트 API 문서 만들어줘"
```

## Features

- **Progressive Disclosure**: 단계별 상세화
- **Template-driven**: 표준화된 문서 구조
- **Code-aware**: 코드베이스 분석 기반 생성

[parent](../CLAUDE.md)