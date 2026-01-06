# Project Documentation Guide

This document aims to standardize the project's documentation management process, ensuring that team members can efficiently find, write, and maintain project documents.

## 1. Documentation Directory Structure

Project documents are uniformly stored in the `docs/` directory, using a hierarchical, modular structure:

| Directory | Description | Content Examples |
| :--- | :--- | :--- |
| **`01_requirements/`** | **Requirements Documentation** | PRD, User Requirements Specification (URS), Software Requirements Specification (SRS), User Stories |
| **`02_design/`** | **Design Documentation** | UI Designs, UX Interaction Flows, Frontend Component Design, Visual Specifications |
| **`03_architecture/`** | **Architecture Design** | System Architecture Diagrams, Technology Selection, High-Level Design, Detailed Design, Topology Diagrams |
| **`04_api/`** | **API Documentation** | API Definitions (Swagger/OpenAPI), Interface Contracts, Error Code Specifications |
| **`05_database/`** | **Database Design** | ER Diagrams, Data Dictionary, SQL Scripts, Data Migration Plans |
| **`06_development/`** | **Development Guide** | Code Standards, Environment Setup Guide, Git Workflow, FAQ, Debugging Tips |
| **`07_testing/`** | **Testing Documentation** | Test Plans, Test Cases, Test Reports, Performance Test Data |
| **`08_deployment/`** | **Deployment & Operations** | Deployment Manual, CI/CD Configuration, Monitoring & Alerting Guide, Release Notes |
| **`09_project/`** | **Project Management** | Meeting Notes, Milestone Plans, Risk Management, Weekly/Monthly Reports |
| **`assets/`** | **Resource Files** | Images referenced in documents, Diagram source files (draw.io, puml, etc.), Attachments |

## 2. Document Writing Standards

### 2.1 File Format
* **Recommended Format**: Use **Markdown (`.md`)** format for all documents.
* **Other Formats**: For binary files like Excel, PPT, PDF, convert to online document links when possible, or store in the appropriate directory and create an index in `README.md`.

### 2.2 Naming Conventions
* **File/Directory Names**: Use **lowercase letters**, separate words with **underscores (`_`)**.
    * Correct: `user_guide.md`, `api_v1_spec.md`
    * Wrong: `UserGuide.md`, `API-Spec.md`
* **Image Resources**:
    * Store in `docs/assets/` directory.
    * Naming should include the related document identifier, e.g., `architecture_overview_diagram.png`.

### 2.3 Content Standards
* **Titles**: Clear and concise with proper hierarchy structure.
* **Change Log**: Important documents (design docs, API docs) should include a changelog header noting modifier, time, and changes.
* **References**: Use relative paths for images, e.g., `![Architecture](./assets/architecture_diagram.png)`.

## 3. Document Maintenance Process

1. **New Documents**: Create files in the appropriate subdirectory based on document type.
2. **Modify Documents**:
    * When modifying code logic, sync corresponding technical documentation.
    * Major changes should be submitted via Pull Request for review.
3. **Deprecate Documents**: Don't delete outdated documents directly. Move to `docs/archive/` (create if needed) or add `_deprecated` suffix to filename.

## 4. Recommended Tools

* **Markdown Editors**: VS Code, Typora, Obsidian
* **Diagramming Tools**: Draw.io, Mermaid (supports writing directly in Markdown), Excalidraw

## 5. Claude Code Integration

### Related Configuration Files

| File | Description |
| :--- | :--- |
| `.claude/CLAUDE.md` | Main Claude Code configuration entry point |
| `.claude/PROJECT_RULES.md` | Project-specific development rules |
| `.claude/TEAM_WORKFLOW.md` | Team workflow and collaboration standards |
| `.claude/ARCHITECTURE_GUIDE.md` | System architecture reference guide |
| `.claude/API_STANDARDS.md` | API design and development specifications |

### Using Claude Code for Documentation

```bash
# Generate API documentation
/sc:document --focus api

# Generate architecture documentation
/sc:document --focus architecture

# Analyze existing documentation
/sc:analyze --focus docs
```

---

**Last Updated**: {{DATE}}
