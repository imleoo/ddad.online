# {{PROJECT_NAME}} - Claude Code Team Collaboration Standards

## Project Overview

**Project Name**: {{PROJECT_NAME}}
**Type**: {{PROJECT_TYPE}}
**Tech Stack**: {{TECH_STACK}}
**Team Size**: {{TEAM_SIZE}}

> Please fill in the project description here.

---

## Quick Start

### Development Commands

```bash
# Install dependencies
# TODO: Add install command

# Run development server
# TODO: Add dev command

# Run tests
# TODO: Add test command

# Build for production
# TODO: Add build command
```

### Project Structure

```
{{PROJECT_NAME}}/
├── src/                  # Source code
├── tests/                # Test files
├── docs/                 # Documentation
├── .claude/              # Claude Code configuration
└── ...
```

---

## Development Workflow

### Branch Strategy

- `main` - Production-ready code
- `develop` - Development integration
- `feature/*` - New features
- `fix/*` - Bug fixes
- `hotfix/*` - Emergency fixes

### Commit Convention

```
<type>(<scope>): <description>

Types: feat, fix, refactor, perf, docs, test, chore
```

### Standard Flow

```
Requirement Analysis → Technical Design → Implementation → Unit Test → Integration Test → Code Review → Release
```

---

## Architecture Guidelines

### Layered Architecture

- **API Layer**: RESTful API endpoints
- **Service Layer**: Business logic processing
- **Data Access Layer**: Storage operation abstraction
- **Infrastructure Layer**: Cache, message queue, monitoring

### Design Principles

- Service boundaries divided by business capability
- Inter-service communication through API
- Independent deployment and scaling
- Fault isolation

---

## API Design Standards

### URL Naming Convention

```
# Resource naming (noun plural form)
GET    /v1/resources              # List resources
POST   /v1/resources              # Create resource
GET    /v1/resources/{id}         # Get single resource
PUT    /v1/resources/{id}         # Full update
PATCH  /v1/resources/{id}         # Partial update
DELETE /v1/resources/{id}         # Delete resource
GET    /v1/resources/{id}/items   # Nested resource (max 2 levels)
```

### Response Format

```json
{
  "code": 0,
  "message": "Success",
  "data": { ... },
  "request_id": "req-uuid",
  "timestamp": "2026-01-04T10:30:45.123Z"
}
```

### Error Codes

- `1000-1999`: Client errors (param, auth, permission)
- `2000-2999`: Server errors (internal, db, cache)
- `3000-3999`: Business errors (limit exceeded, conflict)

---

## Project Rules

### Critical Constraints

**Data Security**:
```go
// Always include tenant isolation in data operations
func GetData(ctx context.Context, userID, tenantID string) (*Data, error) {
    if tenantID == "" {
        return nil, fmt.Errorf("tenant_id is required")
    }
    return db.Where("user_id = ? AND tenant_id = ?", userID, tenantID).First(&data)
}
```

**Error Handling**:
```go
// Use structured errors with context
if err := storage.Save(ctx, data); err != nil {
    logger.Error("Storage failed", zap.Error(err), zap.String("tenant_id", tenantID))
    return errors.Wrap(ErrStorage, "failed to save data")
}
```

### Quality Standards

- Test coverage > 80%
- All critical paths must have tests
- Mock external dependencies in unit tests
- Code review required before merge

---

## Security Checklist

- [ ] All database queries include `tenant_id` filter
- [ ] PII data is masked in logs
- [ ] User inputs are validated and sanitized
- [ ] No hardcoded secrets in code
- [ ] API endpoints have proper authentication
- [ ] SQL queries use parameterized queries

---

## Claude Code Usage

### Starting a Session

```bash
# Load project context
/sc:load

# For complex tasks, use brainstorming
/sc:brainstorm
```

### During Development

- Use `--think` for complex analysis
- Use `--validate` before major changes
- Use `--c7` for framework documentation

### Ending a Session

```bash
# Save context for next session
/sc:save
```

---

**Last Updated**: {{DATE}}
