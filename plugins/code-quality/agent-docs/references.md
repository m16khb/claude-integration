# Code Quality - References

code-quality 플러그인의 베스트 프랙티스, 트러블슈팅, 성능 최적화 가이드입니다.

---

## Best Practices

### Code Review

| 원칙 | 설명 |
|------|------|
| 사전 분석 | PR 전에 자동 분석 실행 |
| 우선순위화 | 심각도 기반으로 문제 정렬 |
| 구체적 제안 | 문제점과 함께 해결책 제공 |
| 긍정적 피드백 | 잘된 부분도 언급 |

### Test Automation

| 원칙 | 설명 |
|------|------|
| 경계 중심 | 경계값과 예외 케이스 우선 |
| 유지보수성 | 테스트 코드도 리뷰 대상 |
| 빠른 피드백 | 테스트 실행 후 즉시 결과 제공 |
| 커버리지 균형 | 단위/통합/E2E 균형 유지 |

### Quality Improvement

| 원칙 | 설명 |
|------|------|
| 측정 | 모든 품질 지표 데이터화 |
| 추적 | 시간에 따른 품질 변화 모니터링 |
| 목표 설정 | 구체적인 품질 목표 수립 |
| 지속적 학습 | 리뷰를 통한 팀 능력 향상 |

---

## Troubleshooting

### Analysis Timeout

```
문제: 대규모 코드베이스 분석이 너무 오래 걸림
원인: 모든 파일을 순차적으로 분석

해결:
1. --incremental 옵션 사용
2. --parallel 병렬 처리
3. --exclude로 제외 파일 지정
4. 캐싱 활성화
```

### False Positives

```
문제: 실제 문제가 아닌 것을 오류로 보고
원인: 규칙이 너무 엄격하거나 컨텍스트 부족

해결:
1. 규칙 조정 (.claude/custom-rules.yml)
2. 프로젝트별 설정 파일 추가
3. 팀 피드백 수집 후 규칙 개선
4. --confidence 옵션으로 임계값 조절
```

### Memory Issues

```
문제: 대용량 파일 분석 시 메모리 부족
원인: 파일 전체를 메모리에 로드

해결:
1. --max-file-size 옵션으로 제한
2. 스트리밍 분석 모드 사용
3. 파일별 분석 후 결과 병합
```

### Inconsistent Results

```
문제: 같은 코드에서 다른 결과 출력
원인: 캐시 불일치 또는 설정 충돌

해결:
1. /clear-quality-cache 실행
2. .claude/config 파일 확인
3. 규칙 버전 동기화
```

---

## Performance Optimization

### Caching Strategy

```yaml
# .claude/analysis-cache.yml
cache:
  enabled: true
  strategy: "content-based"  # content-based, time-based
  ttl: "24h"

  cache_keys:
    - file_hash
    - rule_version
    - configuration

  invalidation:
    on_config_change: true
    on_rule_update: true
    manual_flush: "/clear-quality-cache"
```

### Parallel Processing

```bash
# 병렬 분석 활성화
/review --parallel --workers 4

# 메모리 제한과 함께
/review --parallel --workers 2 --max-memory 2048
```

### Incremental Analysis

```bash
# 마지막 5 커밋 이후 변경사항만
/review --incremental --base HEAD~5

# 특정 브랜치와 비교
/review --incremental --base main
```

### File Exclusions

```yaml
# .claude/quality-config.yml
exclude:
  patterns:
    - "**/*.test.ts"
    - "**/*.spec.ts"
    - "**/node_modules/**"
    - "**/dist/**"
    - "**/*.generated.ts"

  max_file_size: "1MB"
  max_files: 500
```

---

## Configuration Reference

### Quality Thresholds

```yaml
# .claude/quality-thresholds.yml
thresholds:
  quality_score:
    minimum: 7.0
    target: 8.5

  test_coverage:
    minimum: 60%
    target: 80%

  cyclomatic_complexity:
    warning: 10
    error: 20

  code_duplication:
    maximum: 5%

  security_issues:
    critical: 0
    high: 0
```

### Severity Levels

| Level | Description | Auto-fix | Block PR |
|-------|-------------|----------|----------|
| critical | 즉시 수정 필요 | No | Yes |
| high | 릴리즈 전 수정 | No | Configurable |
| medium | 가능한 빨리 수정 | Partial | No |
| low | 개선 권장 | Yes | No |

---

## Related Resources

- [OWASP Top 10](https://owasp.org/Top10/)
- [Suites 3.x Documentation](https://suites.dev/)
- [Code Complexity Metrics](https://en.wikipedia.org/wiki/Cyclomatic_complexity)

---

[Back to CLAUDE.md](../CLAUDE.md) | [Detailed Guides](detailed-guides.md) | [Examples](examples.md)
