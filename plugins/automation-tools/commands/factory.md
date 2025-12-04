---
name: automation-tools:factory
description: 'Agent, Skill, Command 컴포넌트 생성기 (WebFetch 기반 문서 분석)'
argument-hint: '[type] [name]'
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - Bash(mkdir *)
  - Task
model: claude-opus-4-5-20251101
---

# Component Factory

## MISSION

Generate Claude Code components (agent, skill, command) following Anthropic 2025 schema and best practices. Support research-driven generation via WebFetch and orchestrator composition from existing experts.

**Input**: $ARGUMENTS

---

## SKILL INTEGRATION

This command uses four specialized skills for component generation:

### 1. Factory Generator Skill
- **Path**: `skills/factory-generator/`
- **Role**: Core generation logic (parsing, creation, file writing)
- **Triggers**: Component type selection, user input collection

### 2. Factory Researcher Skill
- **Path**: `skills/factory-researcher/`
- **Role**: Web documentation and GitHub example analysis
- **Triggers**: Research request, keyword extraction

### 3. Factory Validator Skill
- **Path**: `skills/factory-validator/`
- **Role**: Component validation and quality assurance
- **Triggers**: Schema validation, quality scoring

### 4. Factory Orchestrator Skill
- **Path**: `skills/factory-orchestrator/`
- **Role**: Orchestrator agent creation and expert composition
- **Triggers**: Multi-expert selection, composition patterns

---

## EXECUTION FLOW

### Phase 1: Initial Setup
```
1. PARSE $ARGUMENTS → extract type, name
2. USE factory-generator skill:
   - Handle argument parsing
   - Show type selection TUI if needed
   - Collect basic info (name, purpose)
```

### Phase 2: Research (Optional)
```
3. IF user wants research → USE factory-researcher skill:
   - Execute WebSearch/WebFetch
   - Extract best practices and examples
   - Return structured research_context
```

### Phase 3: Advanced Configuration
```
4. RETURN to factory-generator skill:
   - Collect location, model, tools preferences
   - Handle agent-specific configuration
   - Prepare generation context
```

### Phase 4: Agent Composition (Agent only)
```
5. IF type = "agent" AND wants composition:
   USE factory-orchestrator skill:
   - Present composition options
   - Select and compose experts
   - Generate orchestration structure
```

### Phase 5: Generation
```
6. SYNTHESIZE all inputs:
   - User preferences
   - Research findings (if any)
   - Composition design (if agent)
   - Generation templates

7. USE factory-generator skill:
   - Generate component content
   - Write files to disk
   - Update plugin.json if needed
```

### Phase 6: Validation
```
8. USE factory-validator skill:
   - Validate schema compliance
   - Assess content quality
   - Generate validation report
   - Apply auto-fixes if approved
```

---

## COORDINATION EXAMPLES

### Example 1: Command with Research
```
User: /factory command typescript-linter "예, 공식문서 분석"

Flow:
1. factory-generator: Parse args, collect info
2. factory-researcher: Analyze TypeScript linting docs
3. factory-generator: Generate with research context
4. factory-validator: Validate and report
```

### Example 2: Agent Orchestrator
```
User: /factory agent fullstack-reviewer

Flow:
1. factory-generator: Parse args, collect info
2. factory-orchestrator:
   - Select code-reviewer + testing-expert
   - Design orchestration pattern
3. factory-generator: Generate with orchestration
4. factory-validator: Validate and report
```

---

## INTEGRATION BENEFITS

### Modular Design
- Each component has single responsibility
- Easy to maintain and update individually
- Clear interfaces between components

### Flexible Research
- Research is optional and on-demand
- Results cached and reused when possible
- Multiple research sources supported

### Quality Assurance
- Automatic validation for all components
- Consistent schema compliance
- Quality scoring and improvement suggestions

### Expert Composition
- Powerful orchestrator creation
- Reuse existing specialized agents
- Dynamic routing and delegation patterns

---

## ERROR HANDLING

| Component | Common Errors | Recovery |
|-----------|--------------|----------|
| Generator | Invalid arguments, permission errors | Clear error messages, suggestions |
| Researcher | No results, rate limits | Try alternative sources, use defaults |
| Validator | Schema violations, low scores | Auto-fix suggestions, manual review |
| Orchestrator | Expert conflicts, timeout | Fallback to single agent, retry |

---

## EXECUTE NOW

```
1. Start orchestration
2. Route to appropriate components
3. Coordinate information flow
4. Synthesize final results
5. Ensure quality standards met
6. Provide completion report
```