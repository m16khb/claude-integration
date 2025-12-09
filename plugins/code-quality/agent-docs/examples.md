# Code Quality - Examples

code-quality 플러그인의 통합 예제 및 코드 스니펫입니다.

---

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/quality-check.yml
name: Code Quality Check

on: [pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run code review
        run: /review --format json --output results.json

      - name: Generate coverage
        run: npm run test:coverage

      - name: Check thresholds
        run: |
          if [ $(cat results.json | jq '.quality_score') -lt 7 ]; then
            echo "Quality score below threshold"
            exit 1
          fi
```

### GitLab CI

```yaml
# .gitlab-ci.yml
code-quality:
  stage: test
  script:
    - /review --format json --output gl-code-quality-report.json
  artifacts:
    reports:
      codequality: gl-code-quality-report.json
```

---

## IDE Integration

### VS Code Settings

```json
// VS Code settings.json
{
  "codeQuality.enabled": true,
  "codeQuality.realTimeAnalysis": true,
  "codeQuality.autoFix": "low",
  "codeQuality.showHints": true,
  "codeQuality.metrics": [
    "complexity",
    "duplication",
    "coverage"
  ]
}
```

### WebStorm Integration

```xml
<!-- .idea/codeQuality.xml -->
<component name="CodeQualityConfig">
  <option name="enabled" value="true" />
  <option name="autoAnalysis" value="on-save" />
  <option name="severityThreshold" value="medium" />
</component>
```

---

## Git Hooks

### Pre-commit Hook

```bash
#!/bin/sh
# .git/hooks/pre-commit
echo "Running code quality checks..."

# 코드 리뷰 실행
/review --quiet --format json > .git/review.json

# 품질 스코어 확인
SCORE=$(cat .git/review.json | jq '.summary.quality_score')
if (( $(echo "$SCORE < 7.0" | bc -l) )); then
  echo "Quality score $SCORE is below minimum 7.0"
  cat .git/review.json | jq '.issues[] | select(.severity == "critical")'
  exit 1
fi

echo "Quality checks passed (Score: $SCORE)"
```

### Pre-push Hook

```bash
#!/bin/sh
# .git/hooks/pre-push
echo "Running full quality analysis before push..."

# 전체 분석 실행
/review --thorough --format json > .git/full-review.json

# Critical/High 이슈 확인
CRITICAL=$(cat .git/full-review.json | jq '.summary.critical')
HIGH=$(cat .git/full-review.json | jq '.summary.high')

if [ "$CRITICAL" -gt 0 ]; then
  echo "BLOCKED: $CRITICAL critical issues found"
  exit 1
fi

if [ "$HIGH" -gt 3 ]; then
  echo "WARNING: $HIGH high severity issues found"
  read -p "Continue anyway? (y/n) " -n 1 -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi
```

---

## Usage Examples

### Basic Review

```bash
# 현재 디렉토리 전체 리뷰
/review

# 특정 파일만 리뷰
/review src/auth/jwt.service.ts

# 특정 디렉토리 리뷰
/review src/modules/
```

### Filtered Review

```bash
# 보안 이슈만
/review --security-only

# 성능 이슈만
/review --performance-only

# 유지보수성 이슈만
/review --maintainability-only

# 복합 필터
/review --filter "security,performance" --severity "critical,high"
```

### Output Formats

```bash
# 터미널 출력 (기본)
/review

# JSON 출력
/review --format json

# Markdown 출력 (PR 댓글용)
/review --format markdown

# SARIF 출력 (GitHub Security 연동)
/review --format sarif --output results.sarif
```

### Auto-fix Options

```bash
# Low severity 이슈 자동 수정
/review --auto-fix low

# 모든 자동 수정 가능 이슈 수정
/review --auto-fix all

# Dry-run (변경사항 미리보기)
/review --auto-fix all --dry-run
```

---

## Test Automator Examples

### Generate Unit Tests

```bash
# 특정 서비스 테스트 생성
/test-generate src/services/user.service.ts

# 전체 모듈 테스트 생성
/test-generate src/modules/auth/
```

### Generated Test Example

```typescript
// user.service.spec.ts (자동 생성됨)
import { TestBed, Mocked } from '@suites/unit';
import { UserService } from './user.service';
import { UserRepository } from './user.repository';

describe('UserService', () => {
  let service: UserService;
  let repository: Mocked<UserRepository>;

  beforeAll(async () => {
    const { unit, unitRef } = await TestBed.solitary(UserService).compile();
    service = unit;
    repository = unitRef.get(UserRepository);
  });

  describe('findById', () => {
    it('should return user when found', async () => {
      // Given
      const mockUser = { id: '1', name: 'Test User' };
      repository.findOne.mockResolvedValue(mockUser);

      // When
      const result = await service.findById('1');

      // Then
      expect(result).toEqual(mockUser);
      expect(repository.findOne).toHaveBeenCalledWith({ where: { id: '1' } });
    });

    it('should throw NotFoundException when user not found', async () => {
      // Given
      repository.findOne.mockResolvedValue(null);

      // When & Then
      await expect(service.findById('invalid')).rejects.toThrow(NotFoundException);
    });
  });
});
```

---

## Parallel Analysis Example

```typescript
// 대규모 코드베이스 분석 최적화
class ParallelAnalyzer {
  private readonly workers: number;

  async analyze(files: string[]): Promise<AnalysisResult> {
    // 파일을 그룹으로 분할
    const chunks = this.chunkFiles(files, this.workers);

    // 병렬로 분석 실행
    const promises = chunks.map(chunk =>
      this.analyzeChunk(chunk)
    );

    const results = await Promise.all(promises);

    // 결과 병합
    return this.mergeResults(results);
  }
}
```

---

## Incremental Analysis

```bash
# 변경된 파일만 분석
/review --incremental --base HEAD~5

# 결과:
# - 이전 커밋과 비교하여 변경된 파일만 분석
# - 새로운 문제점만 보고
# - 전체 분석 시간 90% 단축
```

---

[Back to CLAUDE.md](../CLAUDE.md) | [Detailed Guides](detailed-guides.md) | [References](references.md)
