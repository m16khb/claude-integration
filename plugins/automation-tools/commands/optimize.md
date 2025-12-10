---
name: automation-tools:optimize
description: '통합 최적화 커맨드 (에이전트, 커맨드, 프롬프트)'
argument-hint: '<target> <file-path> [options]'
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - AskUserQuestion
  - Bash
  - Task
  - mcp__sequential-thinking__sequentialthinking
  - mcp__context7__resolve-library-id
  - mcp__context7__get-library-docs
  - mcp__web-reader__webReader
  - mcp__web-search-prime__webSearchPrime
model: claude-opus-4-5-20251101
---

# Universal Optimizer

## MISSION

Unified optimization command for agents, commands, and prompts using prompt engineering best practices and real-time documentation.

**Usage**: `/optimize <target> <file-path> [options]`

**Targets**:
- `agent` - Optimize Claude Code agent
- `command` - Optimize Claude Code command
- `prompt` - Interactive prompt optimization (TUI)

**Options**:
- `--mcp` - Enable MCP integration for latest docs
- `--interactive` - Interactive mode for prompts
- `--dry-run` - Show optimization suggestions only

---

## OPTIMIZATION WORKFLOWS

### 1. Agent Optimization

```bash
# 기본 에이전트 최적화
/optimize agent plugins/code-quality/agents/code-reviewer.md

# MCP 통합으로 최신 문서 반영
/optimize agent plugins/nestjs-backend/agents/typeorm-expert.md --mcp
```

#### Agent Optimization Process

```
1. Current State Analysis
   ├─ Role clarity assessment
   ├─ Trigger effectiveness review
   ├─ Tool utilization check
   └─ MCP integration opportunities

2. Best Practices Application
   ├─ Prompt structure optimization
   ├─ Context window efficiency
   ├─ Response format standardization
   └─ Error handling improvements

3. Integration Testing
   ├─ Simulated task execution
   ├─ Performance benchmarking
   └─ Compatibility validation
```

### 2. Command Optimization

```bash
# 커맨드 최적화
/optimize command plugins/code-quality/commands/review.md

# 배치 최적화
/optimize command plugins/full-stack-orchestration/commands/*.md
```

#### Command Optimization Checklist

```
✓ Argument parsing efficiency
✓ Help text clarity
✓ Error message usefulness
✓ Integration patterns
✓ Performance optimization
✓ Security considerations
```

### 3. Prompt Optimization

```bash
# 대화형 최적화
/optimize prompt --interactive

# 파일에서 프롬프트 최적화
/optimize prompt my-prompt.txt

# URL 기반 문서를 프롬프트로
/optimize prompt https://docs.example.com/guide
```

#### Prompt Enhancement Features

```
ENHANCEMENT TYPES:
├─ Task Decomposition
│   ├─ Complex task breakdown
│   ├─ Step-by-step clarification
│   └─ Dependency identification
│
├─ Context Optimization
│   ├─ Relevant information extraction
│   ├─ Noise reduction
│   └─ Structure organization
│
├─ Output Formatting
│   ├─ Structured responses
│   ├─ Code block optimization
│   └─ Example integration
│
└─ Resource Integration
    ├─ Latest documentation
    ├─ Best practices
    └─ Tool recommendations
```

## OPTIMIZATION PRINCIPLES

### 1. CLARITY
- Clear objectives and constraints
- Unambiguous instructions
- Well-defined success criteria

### 2. EFFICIENCY
- Minimize token usage
- Optimize for context window
- Reduce unnecessary complexity

### 3. EFFECTIVENESS
- Action-oriented prompts
- Measurable outcomes
- Practical applicability

### 4. MAINTAINABILITY
- Modular structure
- Easy to update
- Version-friendly

## ADVANCED FEATURES

### 1. Template-Based Optimization

```yaml
# .claude/optimize-templates.yml
templates:
  agent:
    sections:
      - overview
      - capabilities
      - triggers
      - examples
    max_tokens: 8000

  command:
    sections:
      - description
      - usage
      - examples
      - integration
    max_tokens: 4000
```

### 2. Batch Operations

```bash
# 전체 플러그인 최적화
/optimize agent plugins/nestjs-backend/agents/ --batch

# 특정 패턴의 파일들 최적화
/optimize command "**/*review*.md" --recursive
```

### 3. Performance Analytics

```json
{
  "optimization_report": {
    "file": "code-reviewer.md",
    "improvements": [
      {
        "type": "token_efficiency",
        "before": 2450,
        "after": 1890,
        "improvement": "23%"
      },
      {
        "type": "response_quality",
        "score_before": 7.2,
        "score_after": 8.9,
        "improvement": "24%"
      }
    ]
  }
}
```

## INTEGRATION EXAMPLES

### 1. CI/CD Pipeline

```yaml
# .github/workflows/optimize.yml
- name: Optimize Components
  run: |
    /optimize agent agents/ --batch --dry-run
    /optimize command commands/ --batch --dry-run

    # Check if optimization suggestions exist
    if [ -f .optimizations.md ]; then
      echo "Optimization suggestions found"
      cat .optimizations.md
    fi
```

### 2. Development Workflow

```bash
# 개발 사이클 통합
1. 에이전트/커맨드 작성
2. /optimize로 개선
3. 테스트 실행
4. PR 생성
```

## BEST PRACTICES

### Before Optimization
1. **Backup Originals**: Always keep original versions
2. **Understand Context**: Know the purpose and constraints
3. **Identify Metrics**: Define what improvement means

### During Optimization
1. **Incremental Changes**: Apply changes gradually
2. **Test Each Change**: Validate modifications
3. **Document Rationale**: Note why changes were made

### After Optimization
1. **Benchmark Performance**: Measure improvements
2. **Gather Feedback**: Collect user experiences
3. **Iterate**: Continue refining based on results

## QUALITY ASSURANCE

### Optimization Validation

```
CHECKLIST:
□ Clear objective definition
□ Appropriate complexity level
□ Efficient token usage
□ Proper error handling
□ Consistent formatting
□ Adequate examples
□ Integration compatibility
□ Performance benchmarking
```

### Common Pitfalls to Avoid

1. **Over-optimization**: Don't sacrifice clarity for brevity
2. **Context Loss**: Preserve essential information
3. **Tool Overload**: Don't add unnecessary tools
4. **Generic Responses**: Maintain specificity

## TROUBLESHOOTING

### Optimization Not Applied
```
Issue: Changes not taking effect
Solution:
1. Check file permissions
2. Verify file paths
3. Clear any caches
4. Restart Claude Code
```

### Performance Degradation
```
Issue: Slower responses after optimization
Solution:
1. Profile token usage
2. Check for circular references
3. Simplify complex logic
4. Reduce context window usage
```

## FUTURE ENHANCEMENTS

### Planned Features
- **Auto-optimization**: Scheduled optimization runs
- **A/B Testing**: Compare old vs new versions
- **Custom Metrics**: Define optimization KPIs
- **Integration Templates**: Pre-built optimization patterns

### Community Contributions
- Share optimization templates
- Contribute best practices
- Report optimization success stories
- Suggest new optimization strategies

---

## QUICK REFERENCE

```bash
# Common commands
/optimize agent <file>                    # Optimize agent
/optimize command <file>                  # Optimize command
/optimize prompt --interactive           # Interactive prompt
/optimize prompt <file>                   # Optimize from file
/optimize prompt <url>                    # Convert URL to prompt

# Options
--mcp                                    # Enable MCP
--dry-run                                # Preview only
--batch                                  # Batch mode
--interactive                            # TUI mode
--template <name>                       # Use template
--output <file>                         # Save report
```

