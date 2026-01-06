---
name: review
description: "Code review assistant for {{PROJECT_NAME}} following team standards"
category: quality
complexity: basic
mcp-servers: []
personas: []
---

# /review - Project Code Review

Perform comprehensive code review following {{PROJECT_NAME}} team standards and best practices.

## Usage

```bash
/review [target] [--focus quality|security|performance|all]
```

## Parameters

- `target`: File, directory, or git diff to review (default: staged changes)
- `--focus`: Review focus area
  - `quality`: Code quality, maintainability, patterns
  - `security`: Security vulnerabilities, data safety
  - `performance`: Performance issues, optimization opportunities
  - `all`: Comprehensive review (default)

## Review Checklist

### Code Quality
- [ ] Follows project naming conventions
- [ ] Proper error handling implemented
- [ ] Functions/methods are appropriately sized
- [ ] Code is DRY (Don't Repeat Yourself)
- [ ] Comments explain "why" not "what"

### Security (for {{PROJECT_TYPE}} projects)
- [ ] Input validation present
- [ ] No hardcoded credentials
- [ ] SQL injection prevention (parameterized queries)
- [ ] Proper authentication/authorization checks
- [ ] Sensitive data handling (logging, storage)

### Performance
- [ ] No N+1 query problems
- [ ] Appropriate use of caching
- [ ] Efficient data structures
- [ ] Resource cleanup (connections, files)

### Testing
- [ ] Unit tests for new functionality
- [ ] Edge cases covered
- [ ] Mocks used appropriately
- [ ] Test coverage maintained

## Output Format

```markdown
## Code Review Summary

### Files Reviewed
- file1.go
- file2.go

### Issues Found

#### Critical
- [file:line] Description of critical issue

#### Warnings
- [file:line] Description of warning

#### Suggestions
- [file:line] Optional improvement

### Positive Highlights
- Good use of pattern X in file Y
```

## Examples

```bash
# Review staged changes
/review

# Review specific file
/review internal/service/memory_service.go

# Security-focused review
/review --focus security

# Review recent commits
/review HEAD~3..HEAD
```

## Integration

This command references:
- `@PROJECT_RULES.md` for coding standards
- `@TEAM_WORKFLOW.md` for review process
- `@API_STANDARDS.md` for API-related code
