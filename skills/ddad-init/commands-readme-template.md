# Custom Commands Guide

Custom slash commands in Claude Code allow you to define frequently used prompts as reusable commands.

## What are Custom Commands?

Custom commands let you:
- Create reusable prompts for common workflows
- Standardize team processes through shared commands
- Pass arguments to customize command behavior
- Control which tools commands can use

## Creating a Command

Create a Markdown file in this directory (`.claude/commands/`) with the following structure:

```markdown
---
description: Brief description of what this command does
argument-hint: "[optional] Hint text shown to user for arguments"
allowed-tools: [Read, Write, Edit, Bash, Grep]  # Optional: restrict tools
model: sonnet  # Optional: sonnet, opus, or haiku
---

# Command Name

Your command prompt goes here. Use $ARGUMENTS or $1, $2, etc. for parameters.

## Examples

Show usage examples here.
```

## Command Scopes

| Scope | Location | Purpose |
|-------|----------|---------|
| **Project Commands** | `.claude/commands/` | Team-shared, project-specific commands |
| **Personal Commands** | `~/.claude/commands/` | Your personal commands across all projects |

## Using Arguments

### All arguments as a single string:
```markdown
Search the codebase for $ARGUMENTS and explain the results.
```

### Positional arguments:
```markdown
Compare $1 with $2 and explain the differences.
```

### Named sections with arguments:
```markdown
Analyze $1 for:
- Performance issues
- Security vulnerabilities
- Code quality concerns
```

## Example Commands

### Simple Command (no arguments)

**File:** `.claude/commands/test-coverage.md`
```markdown
---
description: Run tests and check coverage
allowed-tools: [Bash, Read]
---

Run the test suite and analyze code coverage. Report any files below 80% coverage.
```

Usage: `/test-coverage`

### Command with Arguments

**File:** `.claude/commands/review.md`
```markdown
---
description: Review code for quality and best practices
argument-hint: "[file or directory to review]"
allowed-tools: [Read, Grep]
---

Perform a comprehensive code review of $ARGUMENTS, checking for:
- Code quality and maintainability
- Security vulnerabilities
- Performance issues
- Best practice adherence

Provide specific, actionable feedback.
```

Usage: `/review src/api/handlers/user.go`

### Command with Multiple Arguments

**File:** `.claude/commands/compare.md`
```markdown
---
description: Compare two implementations
argument-hint: "<file1> <file2>"
---

Compare the implementations in $1 and $2. Analyze:
- Design differences
- Performance implications
- Maintainability trade-offs
- Recommendation on which approach is better for {{PROJECT_NAME}}
```

Usage: `/compare service/v1/auth.go service/v2/auth.go`

## Frontmatter Options

| Option | Type | Description |
|--------|------|-------------|
| `description` | string | Brief description (shown in command list) |
| `argument-hint` | string | Help text for expected arguments |
| `allowed-tools` | array | Restrict which tools command can use |
| `model` | string | Force specific model (sonnet/opus/haiku) |
| `category` | string | Group commands by category |

## Best Practices

### 1. Clear Descriptions
```markdown
---
description: Run integration tests for API endpoints
---
```

### 2. Explicit Tool Restrictions
```markdown
---
allowed-tools: [Read, Bash]  # Only allow reading and running tests
---
```

### 3. Argument Hints
```markdown
---
argument-hint: "<component-name> [--focus quality|security|performance]"
---
```

### 4. Include Usage Examples
Always include example usage in the command file to help team members.

### 5. Project Context
Reference project-specific files using `@filename` or project conventions:
```markdown
Review $ARGUMENTS according to the standards in @PROJECT_RULES.md
```

## Organizing Commands

### By Category (using subdirectories)

```
.claude/commands/
├── README.md
├── testing/
│   ├── unit-test.md
│   ├── integration-test.md
│   └── coverage.md
├── review/
│   ├── code-review.md
│   ├── security-review.md
│   └── performance-review.md
└── deploy/
    ├── staging.md
    └── production.md
```

Usage: `/testing:unit-test` or `/review:security-review`

### Naming Conventions

- Use **kebab-case** for filenames: `code-review.md`, `run-tests.md`
- Be **descriptive**: `review-api-security.md` not `review.md`
- Include **scope** when needed: `deploy-staging.md`, `deploy-production.md`

## Integration with {{PROJECT_NAME}}

This project's commands follow these patterns:

### Standard Command Structure
1. **Verification Phase**: Check prerequisites and gather context
2. **Execution Phase**: Perform the main task
3. **Validation Phase**: Verify results and report
4. **Documentation Phase**: Update relevant docs if needed

### Project References
Commands should reference project documentation:
- `@PROJECT_RULES.md` - Coding standards and rules
- `@ARCHITECTURE_GUIDE.md` - System architecture
- `@API_STANDARDS.md` - API design patterns

## Resources

- **Official Docs**: https://code.claude.com/docs/en/slash-commands
- **Best Practices**: https://www.anthropic.com/engineering/claude-code-best-practices
- **SDK Documentation**: https://platform.claude.com/docs/en/agent-sdk/slash-commands

---

**Last Updated**: {{DATE}}
