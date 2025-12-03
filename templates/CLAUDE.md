# templates/ CLAUDE.md

## 모듈 개요

**생성 템플릿 모듈**입니다. `/factory` 커맨드 및 기타 생성기에서 사용하는 템플릿을 관리합니다.

## 파일 구조

```
templates/
├── CLAUDE.md              # 이 파일
├── statusline-config.yaml # Status line 기본 설정
├── statusline.sh          # Bash/Zsh status line 스크립트
└── statusline.ps1         # PowerShell status line 스크립트
```

## 포함된 템플릿

| 템플릿 | 용도 | 플랫폼 |
|--------|------|--------|
| `statusline-config.yaml` | Status line 기본 설정 | 공통 |
| `statusline.sh` | Status line 스크립트 | macOS/Linux |
| `statusline.ps1` | Status line 스크립트 | Windows |

## 템플릿 작성 원칙

### 플랫폼 호환성

- **크로스 플랫폼**: YAML, JSON 설정은 OS 독립적
- **OS별 스크립트**: `.sh`(Unix), `.ps1`(Windows) 분리
- **인코딩**: UTF-8 without BOM

### 변수 치환 패턴

```
PLACEHOLDER PATTERNS:
├─ ${VARIABLE} - 환경 변수
├─ {{placeholder}} - 템플릿 변수
└─ $ARGUMENTS - 커맨드 인자
```

### 주의사항

- 민감 정보 기본값 포함 금지
- 경로는 상대 경로 사용
- 실행 권한 설정 확인 (`.sh` 파일)

## 상세 문서

- [agent-docs/development.md](../agent-docs/development.md) - 개발 가이드

## 참조

- [Root CLAUDE.md](../CLAUDE.md)
