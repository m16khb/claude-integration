# Security Analysis

> OWASP Top 10 기반 보안 분석 및 취약점 탐지 가이드

## Overview

code-reviewer 에이전트의 보안 분석 기능은 OWASP Top 10을 기반으로 합니다.

```
SECURITY ANALYSIS PIPELINE:
┌─────────────────────────────────────────────────────────┐
│                    Source Code                           │
└───────────────────────┬─────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
   ┌─────────┐     ┌─────────┐     ┌─────────┐
   │ Static  │     │ Pattern │     │ Config  │
   │ Analysis│     │ Matching│     │ Review  │
   └────┬────┘     └────┬────┘     └────┬────┘
        │               │               │
        └───────────────┼───────────────┘
                        │
                        ▼
              ┌─────────────────┐
              │  Security       │
              │  Report         │
              └─────────────────┘
```

---

## OWASP Top 10 체크리스트

### A01: Broken Access Control

```
ACCESS CONTROL CHECKS:
├─ 인증 우회 취약점
│   ├─ 하드코딩된 자격증명
│   ├─ 인증 없는 엔드포인트
│   └─ 세션 관리 결함
│
├─ 인가 결함
│   ├─ IDOR (Insecure Direct Object Reference)
│   ├─ 수평적 권한 상승
│   └─ 수직적 권한 상승
│
└─ CORS 설정
    ├─ 과도한 허용 Origin
    ├─ Credentials 노출
    └─ 와일드카드 사용
```

**취약/안전 패턴 비교:**
```typescript
// 취약 패턴: 인가 없이 리소스 접근
@Get(':id')
async getUser(@Param('id') id: string) {
  return this.userService.findById(id); // 누구나 접근 가능
}

// 안전 패턴: 권한 검증 추가
@Get(':id')
@UseGuards(AuthGuard, OwnerGuard)
async getUser(
  @Param('id') id: string,
  @CurrentUser() user: User,
) {
  if (user.id !== id && !user.isAdmin) {
    throw new ForbiddenException();
  }
  return this.userService.findById(id);
}
```

### A02: Cryptographic Failures

```
CRYPTOGRAPHY CHECKS:
├─ 약한 알고리즘
│   ├─ MD5, SHA1 사용
│   ├─ DES, 3DES 사용
│   └─ ECB 모드 사용
│
├─ 키 관리
│   ├─ 하드코딩된 비밀키
│   ├─ 안전하지 않은 키 저장
│   └─ 키 로테이션 부재
│
└─ 민감 데이터
    ├─ 평문 비밀번호 저장
    ├─ 불충분한 암호화
    └─ 전송 중 암호화 부재
```

### A03: Injection

```
INJECTION CHECKS:
├─ SQL Injection
│   ├─ 동적 쿼리 문자열
│   ├─ 매개변수화되지 않은 쿼리
│   └─ ORM 바이패스
│
├─ NoSQL Injection
│   ├─ MongoDB 연산자 인젝션
│   ├─ JSON 조작
│   └─ 객체 프로퍼티 인젝션
│
├─ Command Injection
│   ├─ 검증되지 않은 쉘 명령어 입력
│   ├─ 경로 조작
│   └─ 환경변수 인젝션
│
└─ XSS (Cross-Site Scripting)
    ├─ 반사형 XSS
    ├─ 저장형 XSS
    └─ DOM 기반 XSS
```

**안전한 코드 패턴:**
```typescript
// SQL 쿼리는 항상 ORM 또는 매개변수화된 쿼리 사용
const user = await this.userRepository.findOne({
  where: { id: userId }
});

// 쉘 명령 실행은 execFile 사용 (exec 대신)
// 입력은 반드시 검증 후 인자 배열로 전달
import { execFile } from 'child_process';
const safeBranch = branch.replace(/[^a-zA-Z0-9_-]/g, '');
execFile('git', ['log', safeBranch], callback);
```

### A04: Insecure Design

```
DESIGN CHECKS:
├─ 비즈니스 로직 결함
│   ├─ 경쟁 조건 (Race Condition)
│   ├─ 중복 요청 처리 부재
│   └─ 상태 관리 결함
│
├─ 입력 검증
│   ├─ 클라이언트 측만 검증
│   ├─ 화이트리스트 부재
│   └─ 스키마 검증 부재
│
└─ 에러 처리
    ├─ 상세한 에러 메시지 노출
    ├─ 스택 트레이스 노출
    └─ 시스템 정보 노출
```

### A05: Security Misconfiguration

```
CONFIGURATION CHECKS:
├─ 기본 자격증명
│   ├─ 기본 비밀번호 미변경
│   ├─ 샘플 계정 활성화
│   └─ 관리자 경로 노출
│
├─ 불필요한 기능
│   ├─ 디버그 모드 활성화
│   ├─ 개발 엔드포인트 노출
│   └─ 미사용 서비스 활성화
│
└─ 보안 헤더
    ├─ CSP 미설정
    ├─ HSTS 미설정
    └─ X-Frame-Options 미설정
```

---

## 자동 탐지 패턴

### 정규식 패턴

```javascript
// 하드코딩된 비밀키 탐지
const secretPatterns = [
  /password\s*=\s*["'][^"']+["']/i,
  /api[_-]?key\s*[:=]\s*["'][^"']+["']/i,
  /secret\s*[:=]\s*["'][^"']+["']/i,
  /token\s*[:=]\s*["'][a-zA-Z0-9]{20,}["']/i,
];

// SQL Injection 취약 패턴
const sqlInjectionPatterns = [
  /query\s*\(\s*`.*\$\{.*\}.*`\s*\)/,
  /raw\s*\(\s*["'].*\+.*["']\s*\)/,
];

// XSS 취약 패턴
const xssPatterns = [
  /innerHTML\s*=\s*[^"']/,
  /dangerouslySetInnerHTML/,
];
```

### AST 분석

```typescript
// 위험한 함수 호출 탐지
const dangerousFunctions = [
  'eval',
  'Function',
  'child_process.exec', // execFile 사용 권장
];

// 안전하지 않은 설정 탐지
const insecureConfigs = {
  cors: {
    origin: '*',           // 위험
    credentials: true,     // origin: '*'와 함께 사용 시 위험
  },
  cookie: {
    secure: false,         // 프로덕션에서 위험
    httpOnly: false,       // XSS에 취약
    sameSite: 'none',      // CSRF에 취약
  },
};
```

---

## 보안 리포트

### 리포트 형식

```json
{
  "summary": {
    "total_issues": 12,
    "critical": 2,
    "high": 3,
    "medium": 5,
    "low": 2
  },
  "issues": [
    {
      "severity": "CRITICAL",
      "category": "A03:Injection",
      "title": "SQL Injection vulnerability",
      "file": "src/users/user.service.ts",
      "line": 45,
      "description": "User input directly interpolated into SQL query",
      "recommendation": "Use parameterized queries or ORM methods",
      "cwe": "CWE-89"
    }
  ],
  "compliance": {
    "owasp_top_10": {
      "A01": "PASS",
      "A02": "WARN",
      "A03": "FAIL",
      "A04": "PASS",
      "A05": "WARN"
    }
  }
}
```

---

## 심각도 기준

| 심각도 | 조건 | 예시 |
|--------|------|------|
| CRITICAL | 즉시 악용 가능, 데이터 유출 위험 | SQL Injection, 인증 우회 |
| HIGH | 악용 가능, 중요 영향 | XSS, IDOR, 권한 상승 |
| MEDIUM | 조건부 악용, 제한적 영향 | 정보 노출, 약한 암호화 |
| LOW | 낮은 위험, 모범 사례 위반 | 미사용 의존성, 오래된 라이브러리 |

---

[CLAUDE.md](../CLAUDE.md) | [testing-strategies.md](testing-strategies.md) | [review-workflow.md](review-workflow.md)
