---
name: project-init-local
description: Initialize new modules or components within the {{PROJECT_NAME}} project following established patterns
---

# /project-init-local - Local Module Initialization

Initialize new modules, services, or components within the project following established patterns and conventions.

## Usage

```bash
/project-init-local <module-name> [--type service|handler|repository|entity]
```

## Parameters

- `module-name`: Name of the new module (lowercase, hyphen-separated)
- `--type`: Type of module to create
  - `service`: Business logic service
  - `handler`: API handler/controller
  - `repository`: Data access layer
  - `entity`: Domain entity

## Workflow

1. **Analyze Existing Patterns**
   - Read existing modules of the same type
   - Identify naming conventions and structure
   - Note import patterns and dependencies

2. **Create Module Structure**
   - Create necessary directories
   - Generate boilerplate files following patterns
   - Add appropriate interfaces and types

3. **Setup Testing**
   - Create test file with basic test cases
   - Setup mocks for dependencies
   - Add integration test skeleton if applicable

4. **Update Documentation**
   - Add module to architecture docs
   - Update README if needed
   - Add API documentation for handlers

## Example

```bash
# Create a new notification service
/project-init-local notification --type service

# This will create:
# - internal/service/notification_service.go
# - internal/service/notification_service_test.go
# - Update relevant documentation
```

## Templates

The skill uses templates from `.claude/templates/` directory:
- `service.go.tmpl` - Service boilerplate
- `handler.go.tmpl` - Handler boilerplate
- `repository.go.tmpl` - Repository boilerplate
- `entity.go.tmpl` - Entity boilerplate

## Notes

- Always follow existing project patterns
- Ensure proper dependency injection setup
- Include appropriate logging and error handling
- Reference `@PROJECT_RULES.md` for coding standards
