# 커맨드 작성 가이드

## Frontmatter 구조

```yaml
---
name: command-name
description: "커맨드 설명"
argument-hint: <required> [optional]
allowed-tools:
  - Read
  - Write
  - Bash
model: opus|haiku  # 생략시 기본 모델
---
```

## 커맨드 본문 작성

- **$ARGUMENTS**: 사용자 입력 인자 참조
- **TUI 패턴**: AskUserQuestion으로 사용자 선택 제공
- **후속 작업**: 작업 완료 후 다음 단계 선택 TUI 필수

## 주의사항

- 커맨드에서 민감 정보(API 키, 패스워드) 노출 금지
- Bash 도구 사용시 allowed-tools에 패턴 명시 (예: `Bash(git *)`)
- 사용자 컨텍스트 윈도우 고려하여 청크 크기 조절
