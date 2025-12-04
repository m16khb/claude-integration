---
name: automation-tools:prompt-optimizer
description: 'TUI 기반 프롬프트 최적화 엔진 (Context7 + Sequential-Thinking)'
argument-hint: '[prompt-text-or-file]'
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

# Prompt Optimizer

## MISSION

Transform user prompts into production-ready, task-oriented prompts using TUI interaction, latest documentation, systematic decomposition, and dynamic resource discovery.

**Key Innovation**: Scans the user's actual project directory to discover and integrate available plugins, agents, and skills into optimized prompts.

**Input**: $ARGUMENTS

---

## CORE OPTIMIZATION FRAMEWORK

### 3-Layer Optimization Model

```
LAYER 1 - UNDERSTANDING (이해)
├─ Intent Analysis: 사용자 진짜 의도 파악
├─ Context Extraction: 암묵적 맥락 명시화
└─ Task Identification: 수행해야 할 작업 목록화

LAYER 2 - RESEARCH (조사)
├─ Context7: 최신 문서 및 베스트 프랙티스
├─ Web Search: 실제 사용 예시 및 패턴
└─ Sequential-Thinking: 단계별 분해 및 검증

LAYER 3 - OPTIMIZATION (최적화)
├─ Task Decomposition: 실행 가능한 단위로 분할
├─ Prompt Engineering: 구조화된 프롬프트 설계
└─ Quality Validation: 품질 기준 충족 확인
```

---

## EXECUTION FLOW

### Phase 1: Input Collection
```
1. PARSE $ARGUMENTS
   ├─ Direct text → use as-is
   ├─ File path → Read and extract
   ├─ URL → Fetch with web-reader
   └─ Empty → Interactive TUI collection

2. INITIAL ANALYSIS
   ├─ Prompt type identification
   ├─ Complexity assessment
   └─ Optimization scope determination
```

### Phase 2: TUI Interaction
```
3. AskUserQuestion - Optimization Goal
   question: "어떤 종류의 최적화를 원하시나요?"
   options:
     - label: "작업 자동화"
       description: "반복 작업을 자동화하는 프롬프트로 변환"
     - label: "문서 생성"
       description: "구조화된 문서 생성용 프롬프트로 개선"
     - label: "코드 생성"
       description: "코드 생성 및 리뷰용 프롬프트로 최적화"
     - label: "분석 및 리서치"
       description: "데이터 분석 및 리서치용 프롬프트로 변환"
```

### Phase 3: Sequential Analysis
```
4. mcp__sequential-thinking__sequentialthinking
   Goal: Prompt 분해 및 최적화 전략 수립

   Steps:
   - 의도 파악 및 명확화
   - 필수 구성 요소 식별
   - 누락된 정보 확인
   - 구조 개선 방안 모색
   - 실행 가능성 평가
```

### Phase 4: Dynamic Resource Discovery
```
5. SCAN USER PROJECT RESOURCES
   # Execute in user's project directory
   AVAILABLE_PLUGINS=$(find .claude-plugin/ plugins/ -name "CLAUDE.md" -type f 2>/dev/null | wc -l)
   AVAILABLE_AGENTS=$(find .claude-plugin/ plugins/ -name "*.md" -path "*/agents/*" -type f 2>/dev/null | wc -l)
   AVAILABLE_SKILLS=$(find .claude-plugin/ plugins/ -name "SKILL.md" -type f 2>/dev/null | wc -l)
   AVAILABLE_COMMANDS=$(find .claude-plugin/ plugins/ -name "*.md" -path "*/commands/*" -type f 2>/dev/null | wc -l)

   # List actual resources found
   echo "=== DISCOVERED RESOURCES ==="
   echo "Plugins ($AVAILABLE_PLUGINS):"
   find .claude-plugin/ plugins/ -name "CLAUDE.md" -type f 2>/dev/null | sed 's|^.||' | sort
   echo ""
   echo "Commands ($AVAILABLE_COMMANDS):"
   find .claude-plugin/ plugins/ -name "*.md" -path "*/commands/*" -type f 2>/dev/null | sed 's|^.||' | sort

6. CONTEXT7 INTEGRATION
   ├─ 관련 라이브러리/도구 최신 문서 검색
   ├─ Best practices 패턴 추출
   ├─ 코드 예시 획득
   └─ 현행 표준 준수 확인

7. WEB SUPPLEMENTARY RESEARCH
   ├─ 실제 사용 사례 검색
   ├─ 커뮤니티 추천 패턴
   └─ 성공적인 프롬프트 예시
```

---

## PROMPT OPTIMIZATION PATTERNS

### Task-Oriented Structure Template
```markdown
# Optimized Prompt Template

## Role & Context
{명확한 역할 정의}

## Input
{입력 형식 및 제약 조건}

## Tasks
1. {구체적 작업 1}
2. {구체적 작업 2}
3. {구체적 작업 3}

## Output Format
{원하는 출력 형식}

## Constraints
{제약 조건 및 주의사항}

## Examples
{입출력 예시}
```

### Decomposition Strategy
```
COMPLEX PROMPT → SUB-TASKS:
├─ Task 1: Information Gathering
├─ Task 2: Analysis & Processing
├─ Task 3: Generation & Formatting
└─ Task 4: Validation & Review

EACH SUB-TASK:
├─ Clear objective
├─ Specific tools needed
├─ Success criteria
└─ Error handling
```

---

## TUI WORKFLOW EXAMPLES

### Example 1: Vague to Specific
```
USER INPUT: "블로그 글 써줘"

TUI INTERACTION:
1. Goal clarification
   - "어떤 주제의 블로그 글인가요?"
   - "타겟 독자는 누구인가요?"
   - "원하는 길이와 스타일은?"

2. Research integration
   - Context7: "블로그 writing best practices"
   - Web Search: "viral blog post structures"

3. Optimized Output
   - Structured prompt with role, constraints, examples
```

### Example 2: Multi-step Task
```
USER INPUT: "React 프로젝트 분석해줘"

TUI INTERACTION:
1. Task decomposition
   - Code structure analysis?
   - Performance review?
   - Security audit?
   - Documentation generation?

2. Sequential processing
   - Step 1: Code parsing
   - Step 2: Pattern identification
   - Step 3: Report generation

3. Tool integration
   - AST parsing tools
   - Linting configuration
   - Custom analyzers
```

---

## OPTIMIZATION DIMENSIONS

### 1. Clarity & Specificity
- ✅ 명확한 동사 사용
- ✅ 구체적 대상 지정
- ✅ 측정 가능한 결과물
- ✅ 명시적 제약 조건

### 2. Structure & Organization
- ✅ 논리적 흐름
- ✅ 섹션 명확히 분리
- ✅ 예시 및 샘플
- ✅ 에러 핸들링

### 3. Tool Integration
- ✅ 적절한 도구 지정
- ✅ MCP 서버 활용
- ✅ API 호출 패턴
- ✅ 데이터 소스 명시

### 4. Best Practices
- ✅ 최신 문서 반영
- ✅ 커뮤니티 표준
- ✅ 성공 사례 적용
- ✅ 검증된 패턴

---

## QUALITY METRICS

### Optimization Score
```
TOTAL SCORE: 100 points
├─ Clarity (30 points)
│   ├─ Intent clarity: 10
│   ├─ Task specificity: 10
│   └─ Output definition: 10
├─ Structure (30 points)
│   ├─ Logical flow: 10
│   ├─ Completeness: 10
│   └─ Examples: 10
├─ Research (25 points)
│   ├─ Documentation: 10
│   ├─ Best practices: 10
│   └─ Current trends: 5
└─ Execution (15 points)
    ├─ Tool usage: 5
    ├─ Error handling: 5
    └─ Efficiency: 5
```

### Validation Checklist
- [ ] Role is clearly defined
- [ ] Tasks are actionable
- [ ] Output format specified
- [ ] Examples provided
- [ ] Error cases considered
- [ ] Latest docs referenced
- [ ] Tools properly integrated

---

## IMPLEMENTATION STRATEGY

### File Structure
```
plugins/automation-tools/
├── commands/
│   ├── prompt-optimizer.md (본 파일)
│   └── prompt-optimizer-examples.md
├── skills/
│   └── prompt-analysis/
│       ├── SKILL.md
│       ├── templates/
│       │   ├── code-generation.md
│       │   ├── document-creation.md
│       │   └── data-analysis.md
│       └── patterns/
│           ├── task-decomposition.json
│           └── optimization-rules.json
```

### Integration Points
```
RELATED COMPONENTS:
├─ optimize-command: 기존 커맨드 최적화
├─ factory: 새 컴포넌트 생성
├─ claude-sync: 문서 동기화
└─ context-management: 대용량 처리
```

---

## EXECUTION EXAMPLES

### Example 1: Code Generation Prompt with Dynamic Resources
```
INPUT: "타입스크립트로 API 만들어줘"

OPTIMIZATION PROCESS:
1. Sequential-Thinking:
   - API 종류 파악 (REST/GraphQL)
   - 필요한 기능 명시
   - 데이터베이스 연동 여부

2. Dynamic Resource Scan:
   # Check user's available resources
   if [ -d "plugins/nestjs-backend" ]; then
       echo "NestJS experts available!"
       AGENTS="typeorm-expert redis-cache-expert"
   elif [ -f "package.json" ]; then
       echo "Node.js project detected"
       FRAMEWORK=$(cat package.json | jq -r '.dependencies.fastify ? "fastify" : "express"')
   else
       echo "Generic TypeScript setup"
   fi

3. Context7 Research:
   - /nestjs/docs 최신 가이드
   - /fastify/docs 성능 팁
   - Best practices 추출

4. Optimized Output:
   - 명확한 역할 정의
   - 단계별 생성 절차
   - 타입 정의 포함
   - 에러 핸들링 패턴
   - Available tools: [${DISCOVERED_COMMANDS}]
```

### Example 2: Document Creation with Project Resources
```
INPUT: "기술 문서 써줘"

OPTIMIZATION PROCESS:
1. TUI Interaction:
   - 문서 종류 선택 (API/사용자 가이드/아키텍처)
   - 타겟 독자 지정
   - 포함할 섹션 명시

2. Dynamic Resource Discovery:
   # Check for documentation-related resources
   DOC_RESOURCES=$(find . -name "*doc*" -o -name "*README*" 2>/dev/null)
   if command -v document-builder >/dev/null 2>&1; then
       echo "Using document-builder agent"
   fi

3. Research Integration:
   - Technical writing best practices
   - Documentation standards (OpenAPI, etc.)
   - Template structures

4. Optimized Output:
   - 구조화된 템플릿
   - 예시 및 가이드
   - Markdown 형식 지정
   - 검토 체크리스트
   - Integration with: [${AVAILABLE_TOOLS}]
```

### Example: Resource Discovery in Action (claude-integration project)
```
When run in claude-integration project, discovered:
- 7 plugins (automation-tools, code-quality, etc.)
- 12 agents (code-reviewer, test-automator, etc.)
- 9 skills (factory-series, testing-patterns, etc.)
- 10 commands (including this prompt-optimizer)

Your project will show YOUR actual resources!
```

---

## ERROR HANDLING

| Error Type | Detection | Recovery |
|------------|-----------|----------|
| Ambiguous input | Sequential analysis | TUI clarification |
| Missing context | Research check | Ask for specifics |
| Tool conflicts | MCP validation | Alternative suggestions |
| Vague output | Quality metrics | Refinement prompts |

---

## EXECUTE NOW

```
# ACTUAL BASH COMMANDS TO RUN:
echo "=== SCANNING YOUR PROJECT RESOURCES ==="
echo ""

# Discover plugins
echo "Available Plugins:"
find .claude-plugin/ plugins/ -name "CLAUDE.md" -type f 2>/dev/null | while read f; do
    name=$(basename $(dirname "$f"))
    desc=$(grep -m1 "^description:" "$f" | cut -d: -f2- | xargs)
    echo "  - $name: $desc"
done
echo ""

# Discover commands
echo "Available Commands:"
find .claude-plugin/ plugins/ -name "*.md" -path "*/commands/*" -type f 2>/dev/null | while read f; do
    name=$(grep -m1 "^name:" "$f" | cut -d: -f2- | xargs)
    desc=$(grep -m1 "^description:" "$f" | cut -d: -f2- | xargs)
    echo "  - /$name: $desc"
done
echo ""

# Discover agents
echo "Available Agents:"
find .claude-plugin/ plugins/ -name "*.md" -path "*/agents/*" -type f 2>/dev/null | while read f; do
    name=$(basename "$f" .md)
    echo "  - $name"
done
echo ""

echo "=== OPTIMIZATION WORKFLOW ==="
echo "1. Parse input from $ARGUMENTS or TUI"
echo "2. Scan YOUR project resources (as shown above)"
echo "3. Start Sequential-Thinking for analysis"
echo "4. Query Context7 for latest documentation"
echo "5. Perform web research for examples"
echo "6. Generate optimized prompt with YOUR resources"
echo "7. Apply task decomposition patterns"
echo "8. Create TUI-guided refinement options"
echo "9. Output final optimized prompt"
echo "10. Provide implementation guidance"
```

---

## FUTURE ENHANCEMENTS

### Planned Features
- [ ] Prompt template library integration
- [ ] A/B testing for prompt variations
- [ ] Performance benchmarking
- [ ] Team sharing capabilities
- [ ] Version control for prompts
- [ ] Custom optimization rules
- [ ] Multi-language support
- [ ] API for programmatic access