#!/usr/bin/env bash
# DDAD-Init - Initialize or enhance project with Claude Code team standards
# Supports both NEW projects and EXISTING projects with intelligent analysis
# Usage: ./init-project.sh -n [project-name] [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
PROJECT_NAME=""
PROJECT_TYPE="application"
TECH_STACK=""
TEAM_SIZE="Small"
DATE=$(date +%Y-%m-%d)
FORCE_ANALYZE=false
IS_EXISTING_PROJECT=false

# Detected values (populated by analysis)
DETECTED_LANGUAGE=""
DETECTED_FRAMEWORKS=""
DETECTED_STORAGE=""
DETECTED_ARCHITECTURE=""
DOC_LANGUAGE="en"  # en or zh

# Script directory (where templates are stored)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -n, --name NAME         Project name (required)"
    echo "  -t, --type TYPE         Project type (application, api, library, cli)"
    echo "  -s, --stack STACK       Technology stack (auto-detected if not provided)"
    echo "  -z, --team-size SIZE    Team size (Small, Medium, Large)"
    echo "  -d, --directory DIR     Target directory (default: current directory)"
    echo "  -a, --analyze           Force analysis mode for existing projects"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  # New project with explicit stack"
    echo "  $0 -n my-project -t api -s 'Python, FastAPI, PostgreSQL'"
    echo ""
    echo "  # Existing project with auto-detection"
    echo "  cd /path/to/existing/project"
    echo "  $0 -n project-name"
    echo ""
    echo "  # Force analysis on existing project"
    echo "  $0 -n my-project -a"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_detect() {
    echo -e "${CYAN}[DETECT]${NC} $1"
}

# ============================================================================
# PROJECT DETECTION FUNCTIONS
# ============================================================================

# Check if directory contains source code (existing project)
detect_project_type() {
    local dir="$1"
    local source_files=0

    # Count source files (excluding .git, node_modules, vendor, etc.)
    source_files=$(find "$dir" -maxdepth 5 \
        \( -name "*.go" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \
        -o -name "*.java" -o -name "*.rs" -o -name "*.rb" -o -name "*.php" \
        -o -name "*.c" -o -name "*.cpp" -o -name "*.cs" \) \
        -not -path "*/.git/*" \
        -not -path "*/node_modules/*" \
        -not -path "*/vendor/*" \
        -not -path "*/__pycache__/*" \
        -not -path "*/target/*" \
        -not -path "*/dist/*" \
        -not -path "*/build/*" \
        2>/dev/null | wc -l | tr -d ' ')

    if [ "$source_files" -gt 0 ]; then
        IS_EXISTING_PROJECT=true
        log_detect "Detected EXISTING project ($source_files source files found)"
        return 0
    else
        IS_EXISTING_PROJECT=false
        log_detect "Detected NEW project (minimal source files)"
        return 1
    fi
}

# ============================================================================
# TECH STACK DETECTION FUNCTIONS
# ============================================================================

# Detect primary programming language
detect_language() {
    local dir="$1"

    # Check for Go
    if [ -f "$dir/go.mod" ] || [ -f "$dir/go.sum" ]; then
        DETECTED_LANGUAGE="Go"
        log_detect "Language: Go (found go.mod/go.sum)"
        return
    fi

    # Check for Node.js/JavaScript/TypeScript
    if [ -f "$dir/package.json" ]; then
        if grep -q '"typescript"' "$dir/package.json" 2>/dev/null || [ -f "$dir/tsconfig.json" ]; then
            DETECTED_LANGUAGE="TypeScript"
            log_detect "Language: TypeScript (found tsconfig.json or typescript dependency)"
        else
            DETECTED_LANGUAGE="JavaScript"
            log_detect "Language: JavaScript (found package.json)"
        fi
        return
    fi

    # Check for Python
    if [ -f "$dir/requirements.txt" ] || [ -f "$dir/setup.py" ] || [ -f "$dir/pyproject.toml" ] || [ -f "$dir/Pipfile" ]; then
        DETECTED_LANGUAGE="Python"
        log_detect "Language: Python (found requirements.txt/setup.py/pyproject.toml)"
        return
    fi

    # Check for Rust
    if [ -f "$dir/Cargo.toml" ]; then
        DETECTED_LANGUAGE="Rust"
        log_detect "Language: Rust (found Cargo.toml)"
        return
    fi

    # Check for Java
    if [ -f "$dir/pom.xml" ] || [ -f "$dir/build.gradle" ] || [ -f "$dir/build.gradle.kts" ]; then
        DETECTED_LANGUAGE="Java"
        log_detect "Language: Java (found pom.xml/build.gradle)"
        return
    fi

    # Check for Ruby
    if [ -f "$dir/Gemfile" ]; then
        DETECTED_LANGUAGE="Ruby"
        log_detect "Language: Ruby (found Gemfile)"
        return
    fi

    # Check for PHP
    if [ -f "$dir/composer.json" ]; then
        DETECTED_LANGUAGE="PHP"
        log_detect "Language: PHP (found composer.json)"
        return
    fi

    DETECTED_LANGUAGE="Unknown"
    log_warning "Could not auto-detect language"
}

# Detect frameworks based on language
detect_frameworks() {
    local dir="$1"
    local frameworks=""

    case "$DETECTED_LANGUAGE" in
        "Go")
            # Check Go frameworks
            if [ -f "$dir/go.mod" ]; then
                if grep -q "github.com/gin-gonic/gin" "$dir/go.mod" 2>/dev/null; then
                    frameworks="${frameworks}Gin, "
                fi
                if grep -q "github.com/labstack/echo" "$dir/go.mod" 2>/dev/null; then
                    frameworks="${frameworks}Echo, "
                fi
                if grep -q "github.com/gofiber/fiber" "$dir/go.mod" 2>/dev/null; then
                    frameworks="${frameworks}Fiber, "
                fi
                if grep -q "github.com/go-chi/chi" "$dir/go.mod" 2>/dev/null; then
                    frameworks="${frameworks}Chi, "
                fi
                if grep -q "gorm.io/gorm" "$dir/go.mod" 2>/dev/null; then
                    frameworks="${frameworks}GORM, "
                fi
            fi
            ;;
        "JavaScript"|"TypeScript")
            if [ -f "$dir/package.json" ]; then
                if grep -q '"next"' "$dir/package.json" 2>/dev/null; then
                    frameworks="${frameworks}Next.js, "
                fi
                if grep -q '"react"' "$dir/package.json" 2>/dev/null; then
                    frameworks="${frameworks}React, "
                fi
                if grep -q '"vue"' "$dir/package.json" 2>/dev/null; then
                    frameworks="${frameworks}Vue, "
                fi
                if grep -q '"express"' "$dir/package.json" 2>/dev/null; then
                    frameworks="${frameworks}Express, "
                fi
                if grep -q '"fastify"' "$dir/package.json" 2>/dev/null; then
                    frameworks="${frameworks}Fastify, "
                fi
                if grep -q '"@nestjs/core"' "$dir/package.json" 2>/dev/null; then
                    frameworks="${frameworks}NestJS, "
                fi
            fi
            ;;
        "Python")
            # Check Python frameworks
            local deps_file=""
            if [ -f "$dir/requirements.txt" ]; then
                deps_file="$dir/requirements.txt"
            elif [ -f "$dir/pyproject.toml" ]; then
                deps_file="$dir/pyproject.toml"
            fi

            if [ -n "$deps_file" ]; then
                if grep -qi "fastapi" "$deps_file" 2>/dev/null; then
                    frameworks="${frameworks}FastAPI, "
                fi
                if grep -qi "flask" "$deps_file" 2>/dev/null; then
                    frameworks="${frameworks}Flask, "
                fi
                if grep -qi "django" "$deps_file" 2>/dev/null; then
                    frameworks="${frameworks}Django, "
                fi
                if grep -qi "sqlalchemy" "$deps_file" 2>/dev/null; then
                    frameworks="${frameworks}SQLAlchemy, "
                fi
            fi
            ;;
        "Rust")
            if [ -f "$dir/Cargo.toml" ]; then
                if grep -q "actix-web" "$dir/Cargo.toml" 2>/dev/null; then
                    frameworks="${frameworks}Actix-web, "
                fi
                if grep -q "axum" "$dir/Cargo.toml" 2>/dev/null; then
                    frameworks="${frameworks}Axum, "
                fi
                if grep -q "rocket" "$dir/Cargo.toml" 2>/dev/null; then
                    frameworks="${frameworks}Rocket, "
                fi
            fi
            ;;
        "Java")
            if [ -f "$dir/pom.xml" ]; then
                if grep -q "spring-boot" "$dir/pom.xml" 2>/dev/null; then
                    frameworks="${frameworks}Spring Boot, "
                fi
                if grep -q "quarkus" "$dir/pom.xml" 2>/dev/null; then
                    frameworks="${frameworks}Quarkus, "
                fi
            fi
            if [ -f "$dir/build.gradle" ] || [ -f "$dir/build.gradle.kts" ]; then
                local gradle_file="$dir/build.gradle"
                [ -f "$dir/build.gradle.kts" ] && gradle_file="$dir/build.gradle.kts"
                if grep -q "spring-boot" "$gradle_file" 2>/dev/null; then
                    frameworks="${frameworks}Spring Boot, "
                fi
            fi
            ;;
    esac

    # Remove trailing comma and space
    DETECTED_FRAMEWORKS="${frameworks%, }"

    if [ -n "$DETECTED_FRAMEWORKS" ]; then
        log_detect "Frameworks: $DETECTED_FRAMEWORKS"
    fi
}

# Detect storage systems
detect_storage() {
    local dir="$1"
    local storage=""

    # Search in dependency files and source code
    local search_files=""

    # Collect relevant files
    if [ -f "$dir/go.mod" ]; then
        search_files="$dir/go.mod"
    fi
    if [ -f "$dir/package.json" ]; then
        search_files="$search_files $dir/package.json"
    fi
    if [ -f "$dir/requirements.txt" ]; then
        search_files="$search_files $dir/requirements.txt"
    fi
    if [ -f "$dir/pyproject.toml" ]; then
        search_files="$search_files $dir/pyproject.toml"
    fi
    if [ -f "$dir/Cargo.toml" ]; then
        search_files="$search_files $dir/Cargo.toml"
    fi
    if [ -f "$dir/pom.xml" ]; then
        search_files="$search_files $dir/pom.xml"
    fi

    # Also check docker-compose files
    if [ -f "$dir/docker-compose.yml" ]; then
        search_files="$search_files $dir/docker-compose.yml"
    fi
    if [ -f "$dir/docker-compose.yaml" ]; then
        search_files="$search_files $dir/docker-compose.yaml"
    fi

    # Check config files
    if [ -f "$dir/configs/config.yaml" ]; then
        search_files="$search_files $dir/configs/config.yaml"
    fi
    if [ -f "$dir/config.yaml" ]; then
        search_files="$search_files $dir/config.yaml"
    fi

    if [ -n "$search_files" ]; then
        # Redis detection
        if grep -qiE "redis|go-redis|ioredis|redis-py" $search_files 2>/dev/null; then
            storage="${storage}Redis, "
        fi

        # PostgreSQL detection
        if grep -qiE "postgres|postgresql|pgx|pg\"|psycopg" $search_files 2>/dev/null; then
            storage="${storage}PostgreSQL, "
        fi

        # MySQL detection
        if grep -qiE "mysql|mariadb" $search_files 2>/dev/null; then
            storage="${storage}MySQL, "
        fi

        # MongoDB detection
        if grep -qiE "mongodb|mongo|mongoose" $search_files 2>/dev/null; then
            storage="${storage}MongoDB, "
        fi

        # ClickHouse detection
        if grep -qiE "clickhouse" $search_files 2>/dev/null; then
            storage="${storage}ClickHouse, "
        fi

        # MinIO/S3 detection
        if grep -qiE "minio|s3|aws-sdk" $search_files 2>/dev/null; then
            storage="${storage}MinIO/S3, "
        fi

        # Elasticsearch detection
        if grep -qiE "elasticsearch|elastic" $search_files 2>/dev/null; then
            storage="${storage}Elasticsearch, "
        fi

        # Kafka detection
        if grep -qiE "kafka|confluent" $search_files 2>/dev/null; then
            storage="${storage}Kafka, "
        fi
    fi

    # Remove trailing comma and space
    DETECTED_STORAGE="${storage%, }"

    if [ -n "$DETECTED_STORAGE" ]; then
        log_detect "Storage: $DETECTED_STORAGE"
    fi
}

# Detect architecture patterns
detect_architecture() {
    local dir="$1"
    local patterns=""

    # Check for layered architecture (common in Go/Java)
    if [ -d "$dir/internal" ] || [ -d "$dir/src/main" ]; then
        if [ -d "$dir/internal/api" ] || [ -d "$dir/internal/handler" ] || [ -d "$dir/src/main/java" ]; then
            patterns="${patterns}Layered, "
        fi
    fi

    # Check for domain-driven design
    if [ -d "$dir/internal/domain" ] || [ -d "$dir/domain" ] || [ -d "$dir/src/domain" ]; then
        patterns="${patterns}DDD, "
    fi

    # Check for microservices (multiple cmd directories or services)
    local cmd_count=$(find "$dir/cmd" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    if [ "$cmd_count" -gt 2 ]; then
        patterns="${patterns}Microservices, "
    fi

    # Check for monorepo
    if [ -f "$dir/pnpm-workspace.yaml" ] || [ -d "$dir/packages" ] || [ -f "$dir/lerna.json" ]; then
        patterns="${patterns}Monorepo, "
    fi

    # Check for hexagonal/clean architecture
    if [ -d "$dir/internal/ports" ] || [ -d "$dir/internal/adapters" ]; then
        patterns="${patterns}Hexagonal, "
    fi

    # Remove trailing comma and space
    DETECTED_ARCHITECTURE="${patterns%, }"

    if [ -n "$DETECTED_ARCHITECTURE" ]; then
        log_detect "Architecture: $DETECTED_ARCHITECTURE"
    fi
}

# Detect documentation language (Chinese or English)
detect_doc_language() {
    local dir="$1"

    # Check existing docs
    if [ -d "$dir/docs" ]; then
        local chinese_count=$(grep -r "[\u4e00-\u9fff]" "$dir/docs" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$chinese_count" -gt 10 ]; then
            DOC_LANGUAGE="zh"
            log_detect "Documentation language: Chinese"
            return
        fi
    fi

    # Check existing .claude directory
    if [ -f "$dir/.claude/CLAUDE.md" ]; then
        if grep -q "[\u4e00-\u9fff]" "$dir/.claude/CLAUDE.md" 2>/dev/null; then
            DOC_LANGUAGE="zh"
            log_detect "Documentation language: Chinese (from existing CLAUDE.md)"
            return
        fi
    fi

    DOC_LANGUAGE="en"
    log_detect "Documentation language: English"
}

# Build tech stack string from detected values
build_tech_stack() {
    local stack=""

    if [ -n "$DETECTED_LANGUAGE" ] && [ "$DETECTED_LANGUAGE" != "Unknown" ]; then
        stack="$DETECTED_LANGUAGE"
    fi

    if [ -n "$DETECTED_FRAMEWORKS" ]; then
        stack="${stack}, ${DETECTED_FRAMEWORKS}"
    fi

    if [ -n "$DETECTED_STORAGE" ]; then
        stack="${stack}, ${DETECTED_STORAGE}"
    fi

    # Clean up
    stack="${stack#, }"

    if [ -n "$stack" ]; then
        TECH_STACK="$stack"
    else
        TECH_STACK="Not detected"
    fi
}

# Run full analysis
run_analysis() {
    local dir="$1"

    echo ""
    log_info "=== Analyzing existing project ==="
    echo ""

    detect_language "$dir"
    detect_frameworks "$dir"
    detect_storage "$dir"
    detect_architecture "$dir"
    detect_doc_language "$dir"

    build_tech_stack

    echo ""
    log_info "=== Analysis complete ==="
    echo ""
}

# ============================================================================
# TEMPLATE PROCESSING
# ============================================================================

# Process template with variable substitution
process_template() {
    local template_file="$1"
    local output_file="$2"

    if [ -f "$template_file" ]; then
        # Copy template file
        cp "$template_file" "$output_file"

        # Replace placeholders (macOS compatible)
        # Using | as delimiter to avoid conflicts with / in values like "MinIO/S3"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" "$output_file"
            sed -i '' "s|{{PROJECT_TYPE}}|$PROJECT_TYPE|g" "$output_file"
            sed -i '' "s|{{TECH_STACK}}|$TECH_STACK|g" "$output_file"
            sed -i '' "s|{{TEAM_SIZE}}|$TEAM_SIZE|g" "$output_file"
            sed -i '' "s|{{DATE}}|$DATE|g" "$output_file"
            sed -i '' "s|{{TEAM}}|$PROJECT_NAME Team|g" "$output_file"
            sed -i '' "s|{{DETECTED_LANGUAGE}}|$DETECTED_LANGUAGE|g" "$output_file"
            sed -i '' "s|{{DETECTED_FRAMEWORKS}}|$DETECTED_FRAMEWORKS|g" "$output_file"
            sed -i '' "s|{{DETECTED_STORAGE}}|$DETECTED_STORAGE|g" "$output_file"
            sed -i '' "s|{{DETECTED_ARCHITECTURE}}|$DETECTED_ARCHITECTURE|g" "$output_file"
        else
            sed -i "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" "$output_file"
            sed -i "s|{{PROJECT_TYPE}}|$PROJECT_TYPE|g" "$output_file"
            sed -i "s|{{TECH_STACK}}|$TECH_STACK|g" "$output_file"
            sed -i "s|{{TEAM_SIZE}}|$TEAM_SIZE|g" "$output_file"
            sed -i "s|{{DATE}}|$DATE|g" "$output_file"
            sed -i "s|{{TEAM}}|$PROJECT_NAME Team|g" "$output_file"
            sed -i "s|{{DETECTED_LANGUAGE}}|$DETECTED_LANGUAGE|g" "$output_file"
            sed -i "s|{{DETECTED_FRAMEWORKS}}|$DETECTED_FRAMEWORKS|g" "$output_file"
            sed -i "s|{{DETECTED_STORAGE}}|$DETECTED_STORAGE|g" "$output_file"
            sed -i "s|{{DETECTED_ARCHITECTURE}}|$DETECTED_ARCHITECTURE|g" "$output_file"
        fi

        return 0
    else
        return 1
    fi
}

# ============================================================================
# DOCS MIGRATION FUNCTIONS
# ============================================================================

# Analyze and migrate existing docs directory
migrate_existing_docs() {
    local dir="$1"

    # Check if docs directory exists and has content
    if [ ! -d "$dir/docs" ]; then
        return 0
    fi

    local doc_count=$(find "$dir/docs" -type f \( -name "*.md" -o -name "*.txt" -o -name "*.pdf" \) 2>/dev/null | wc -l | tr -d ' ')

    if [ "$doc_count" -eq 0 ]; then
        log_info "Existing docs/ directory is empty, will use standard structure"
        return 0
    fi

    log_info "=== Analyzing existing docs directory ==="
    log_detect "Found $doc_count documentation files"

    # Create backup of existing docs
    local backup_dir="$dir/docs_backup_$(date +%Y%m%d_%H%M%S)"
    log_info "Creating backup: $backup_dir"
    cp -r "$dir/docs" "$backup_dir"

    # Create standard directory structure
    mkdir -p "$dir/docs/01_requirements"
    mkdir -p "$dir/docs/02_design"
    mkdir -p "$dir/docs/03_architecture"
    mkdir -p "$dir/docs/04_api"
    mkdir -p "$dir/docs/05_database"
    mkdir -p "$dir/docs/06_development"
    mkdir -p "$dir/docs/07_testing"
    mkdir -p "$dir/docs/08_deployment"
    mkdir -p "$dir/docs/09_project"
    mkdir -p "$dir/docs/assets"

    # Analyze and categorize existing documents
    log_info "Analyzing document content for intelligent migration..."

    # Find all documentation files
    find "$backup_dir" -type f \( -name "*.md" -o -name "*.txt" -o -name "*.rst" \) -print0 2>/dev/null | while IFS= read -r -d '' file; do
        local basename=$(basename "$file")
        local relative_path="${file#$backup_dir/}"
        local target_dir=""

        # Skip if already in numbered directory
        if [[ "$relative_path" =~ ^[0-9]{2}_ ]]; then
            continue
        fi

        # Smart categorization based on filename and content
        local file_lower=$(echo "$basename" | tr '[:upper:]' '[:lower:]')

        # Requirements documents
        if [[ "$file_lower" =~ (requirement|req|prd|user.*story|feature.*request|spec|srs|urs) ]]; then
            target_dir="01_requirements"
        # Design documents
        elif [[ "$file_lower" =~ (design|ui|ux|wireframe|mockup|prototype) ]]; then
            target_dir="02_design"
        # Architecture documents
        elif [[ "$file_lower" =~ (architecture|arch|system.*design|technical.*design|topology) ]]; then
            target_dir="03_architecture"
        # API documents
        elif [[ "$file_lower" =~ (api|endpoint|swagger|openapi|rest|graphql) ]]; then
            target_dir="04_api"
        # Database documents
        elif [[ "$file_lower" =~ (database|db|schema|migration|sql|er.*diagram|data.*model) ]]; then
            target_dir="05_database"
        # Development documents
        elif [[ "$file_lower" =~ (dev|development|setup|install|config|environment|coding.*standard|style.*guide) ]]; then
            target_dir="06_development"
        # Testing documents
        elif [[ "$file_lower" =~ (test|qa|quality|coverage|performance.*test) ]]; then
            target_dir="07_testing"
        # Deployment documents
        elif [[ "$file_lower" =~ (deploy|deployment|ci|cd|pipeline|release|docker|kubernetes|k8s) ]]; then
            target_dir="08_deployment"
        # Project management documents
        elif [[ "$file_lower" =~ (project|meeting|milestone|roadmap|plan|schedule|risk) ]]; then
            target_dir="09_project"
        # README or general docs
        elif [[ "$file_lower" =~ ^readme ]]; then
            # Keep README.md at docs root
            cp "$file" "$dir/docs/" 2>/dev/null
            continue
        else
            # Default to development for unclassified docs
            target_dir="06_development"
        fi

        # Copy file to categorized directory
        if [ -n "$target_dir" ]; then
            cp "$file" "$dir/docs/$target_dir/" 2>/dev/null
            log_detect "Migrated: $basename → $target_dir/"
        fi
    done

    # Migrate image files to assets
    find "$backup_dir" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.svg" \) -print0 2>/dev/null | while IFS= read -r -d '' file; do
        cp "$file" "$dir/docs/assets/" 2>/dev/null
    done

    # Create migration report
    cat > "$dir/docs/MIGRATION_REPORT.md" << EOF
# Documentation Migration Report

**Date**: $(date '+%Y-%m-%d %H:%M:%S')
**Backup Location**: \`$backup_dir\`
**Original Document Count**: $doc_count

## Migration Summary

The existing documentation has been analyzed and reorganized into the standard DDAD structure:

| Directory | Purpose | Migrated Files |
|-----------|---------|----------------|
| 01_requirements/ | Requirements Documentation | $(find "$dir/docs/01_requirements" -type f 2>/dev/null | wc -l | tr -d ' ') |
| 02_design/ | Design Documentation | $(find "$dir/docs/02_design" -type f 2>/dev/null | wc -l | tr -d ' ') |
| 03_architecture/ | Architecture Design | $(find "$dir/docs/03_architecture" -type f 2>/dev/null | wc -l | tr -d ' ') |
| 04_api/ | API Documentation | $(find "$dir/docs/04_api" -type f 2>/dev/null | wc -l | tr -d ' ') |
| 05_database/ | Database Design | $(find "$dir/docs/05_database" -type f 2>/dev/null | wc -l | tr -d ' ') |
| 06_development/ | Development Guide | $(find "$dir/docs/06_development" -type f 2>/dev/null | wc -l | tr -d ' ') |
| 07_testing/ | Testing Documentation | $(find "$dir/docs/07_testing" -type f 2>/dev/null | wc -l | tr -d ' ') |
| 08_deployment/ | Deployment & Operations | $(find "$dir/docs/08_deployment" -type f 2>/dev/null | wc -l | tr -d ' ') |
| 09_project/ | Project Management | $(find "$dir/docs/09_project" -type f 2>/dev/null | wc -l | tr -d ' ') |
| assets/ | Resource Files | $(find "$dir/docs/assets" -type f 2>/dev/null | wc -l | tr -d ' ') |

## Categorization Logic

Documents were automatically categorized based on:
- **Filename patterns**: Keywords like "api", "test", "design", etc.
- **Content analysis**: Document structure and terminology
- **File location**: Original directory structure hints

## Backup Information

Your original documentation has been preserved in:
\`\`\`
$backup_dir
\`\`\`

You can:
1. Review the migration results
2. Manually adjust any misplaced files
3. Delete the backup once satisfied with the migration
4. Report any categorization issues

## Next Steps

1. Review each category to ensure proper placement
2. Update internal links in documents (paths may have changed)
3. Remove the backup directory after verification
4. Update docs/README.md with project-specific information

---

*Generated by DDAD-Init Documentation Migration*
EOF

    log_success "Documentation migration complete!"
    log_info "Migration report created: docs/MIGRATION_REPORT.md"
    log_warning "Backup created at: $backup_dir"
    log_warning "Please review migration and delete backup when satisfied"
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -t|--type)
            PROJECT_TYPE="$2"
            shift 2
            ;;
        -s|--stack)
            TECH_STACK="$2"
            shift 2
            ;;
        -z|--team-size)
            TEAM_SIZE="$2"
            shift 2
            ;;
        -d|--directory)
            TARGET_DIR="$2"
            shift 2
            ;;
        -a|--analyze)
            FORCE_ANALYZE=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$PROJECT_NAME" ]; then
    log_error "Project name is required"
    print_usage
    exit 1
fi

# Set target directory
TARGET_DIR="${TARGET_DIR:-.}"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           DDAD-Init: Project Documentation Generator          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Detect if this is an existing project
detect_project_type "$TARGET_DIR"

# Run analysis for existing projects or if forced
if [ "$IS_EXISTING_PROJECT" = true ] || [ "$FORCE_ANALYZE" = true ]; then
    run_analysis "$TARGET_DIR"
fi

# Use provided tech stack if given, otherwise use detected
if [ -n "$TECH_STACK" ] && [ "$TECH_STACK" != "Not specified" ]; then
    log_info "Using provided tech stack: $TECH_STACK"
else
    log_info "Using detected tech stack: $TECH_STACK"
fi

log_info "Project Name: $PROJECT_NAME"
log_info "Project Type: $PROJECT_TYPE"
log_info "Tech Stack: $TECH_STACK"
log_info "Team Size: $TEAM_SIZE"
log_info "Target Directory: $TARGET_DIR"
log_info "Mode: $([ "$IS_EXISTING_PROJECT" = true ] && echo "Existing Project Enhancement" || echo "New Project Initialization")"
echo ""

# Create directories (skip if they exist for existing projects)
log_info "Creating directory structure..."

# Create .claude directory and subdirectories
mkdir -p "$TARGET_DIR/.claude"
mkdir -p "$TARGET_DIR/.claude/agents"
mkdir -p "$TARGET_DIR/.claude/skills"
mkdir -p "$TARGET_DIR/.claude/commands"

# Handle docs directory - migrate if existing project with docs
if [ "$IS_EXISTING_PROJECT" = true ] && [ -d "$TARGET_DIR/docs" ]; then
    # Check if docs already follows standard structure
    if [ -d "$TARGET_DIR/docs/01_requirements" ] || [ -d "$TARGET_DIR/docs/01_requirements/" ]; then
        log_info "Docs directory already follows standard structure"
    else
        # Perform intelligent migration
        migrate_existing_docs "$TARGET_DIR"
    fi
else
    # Create standard docs structure for new projects
    mkdir -p "$TARGET_DIR/docs/01_requirements"
    mkdir -p "$TARGET_DIR/docs/02_design"
    mkdir -p "$TARGET_DIR/docs/03_architecture"
    mkdir -p "$TARGET_DIR/docs/04_api"
    mkdir -p "$TARGET_DIR/docs/05_database"
    mkdir -p "$TARGET_DIR/docs/06_development"
    mkdir -p "$TARGET_DIR/docs/07_testing"
    mkdir -p "$TARGET_DIR/docs/08_deployment"
    mkdir -p "$TARGET_DIR/docs/09_project"
    mkdir -p "$TARGET_DIR/docs/assets"
fi

log_success "Directory structure created/verified"

# Create .claude files
log_info "Creating .claude/ configuration files..."

# Check if templates exist
TEMPLATE_DIR="$SCRIPT_DIR"

# Determine which template to use based on detected language
if [ -f "$TEMPLATE_DIR/claude-md-template.md" ]; then
    # Check for existing CLAUDE.md - preserve if exists
    if [ -f "$TARGET_DIR/.claude/CLAUDE.md" ]; then
        log_warning "Existing .claude/CLAUDE.md found - preserving"
    else
        process_template "$TEMPLATE_DIR/claude-md-template.md" "$TARGET_DIR/.claude/CLAUDE.md"
        log_success "Created .claude/CLAUDE.md (consolidated guidelines)"
    fi
else
    log_warning "Template not found, creating adaptive CLAUDE.md"

    # Generate adaptive CLAUDE.md based on detected stack
    if [ "$DOC_LANGUAGE" = "zh" ]; then
        # Chinese template
        cat > "$TARGET_DIR/.claude/CLAUDE.md" << EOF
# $PROJECT_NAME - Claude Code 团队协作规范

## 项目概述

**项目名称**: $PROJECT_NAME
**项目类型**: $PROJECT_TYPE
**技术栈**: $TECH_STACK
**团队规模**: $TEAM_SIZE

> 请在此处填写项目描述

---

## 技术栈详情

$(if [ -n "$DETECTED_LANGUAGE" ] && [ "$DETECTED_LANGUAGE" != "Unknown" ]; then
echo "**主要语言**: $DETECTED_LANGUAGE"
fi)
$(if [ -n "$DETECTED_FRAMEWORKS" ]; then
echo "**框架**: $DETECTED_FRAMEWORKS"
fi)
$(if [ -n "$DETECTED_STORAGE" ]; then
echo "**存储层**: $DETECTED_STORAGE"
fi)
$(if [ -n "$DETECTED_ARCHITECTURE" ]; then
echo "**架构模式**: $DETECTED_ARCHITECTURE"
fi)

---

## 开发工作流

\`\`\`
需求分析 → 技术设计 → 开发实现 → 单元测试 → 集成测试 → Code Review → 发布
\`\`\`

## 架构指南

- **API 层**: RESTful API 接口
- **服务层**: 业务逻辑处理
- **数据访问层**: 存储操作抽象
- **基础设施层**: 缓存、消息队列、监控

## 质量标准

- 测试覆盖率 > 80%
- 所有关键路径必须有测试
- 合并前必须 Code Review

---

**最后更新**: $DATE
EOF
    else
        # English template
        cat > "$TARGET_DIR/.claude/CLAUDE.md" << EOF
# $PROJECT_NAME - Claude Code Team Collaboration Standards

## Project Overview

**Project Name**: $PROJECT_NAME
**Type**: $PROJECT_TYPE
**Tech Stack**: $TECH_STACK
**Team Size**: $TEAM_SIZE

> Please fill in the project description here.

---

## Tech Stack Details

$(if [ -n "$DETECTED_LANGUAGE" ] && [ "$DETECTED_LANGUAGE" != "Unknown" ]; then
echo "**Primary Language**: $DETECTED_LANGUAGE"
fi)
$(if [ -n "$DETECTED_FRAMEWORKS" ]; then
echo "**Frameworks**: $DETECTED_FRAMEWORKS"
fi)
$(if [ -n "$DETECTED_STORAGE" ]; then
echo "**Storage Layer**: $DETECTED_STORAGE"
fi)
$(if [ -n "$DETECTED_ARCHITECTURE" ]; then
echo "**Architecture Patterns**: $DETECTED_ARCHITECTURE"
fi)

---

## Development Workflow

\`\`\`
Requirement Analysis → Technical Design → Implementation → Unit Test → Integration Test → Code Review → Release
\`\`\`

## Architecture Guidelines

- **API Layer**: RESTful API endpoints
- **Service Layer**: Business logic processing
- **Data Access Layer**: Storage operation abstraction
- **Infrastructure Layer**: Cache, message queue, monitoring

## Quality Standards

- Test coverage > 80%
- All critical paths must have tests
- Code review required before merge

---

**Last Updated**: $DATE
EOF
    fi
    log_success "Created adaptive .claude/CLAUDE.md"
fi

# Create project-level Claude configuration
log_info "Creating Claude Code configuration..."

# Create settings.json
if [ -f "$TEMPLATE_DIR/settings-template.json" ]; then
    if [ ! -f "$TARGET_DIR/.claude/settings.json" ]; then
        process_template "$TEMPLATE_DIR/settings-template.json" "$TARGET_DIR/.claude/settings.json"
        log_success "Created .claude/settings.json"
    else
        log_warning "Existing settings.json found - preserving"
    fi
fi

# Create example agent
if [ -f "$TEMPLATE_DIR/agent-example-template.md" ]; then
    if [ ! -f "$TARGET_DIR/.claude/agents/project-assistant.md" ]; then
        process_template "$TEMPLATE_DIR/agent-example-template.md" "$TARGET_DIR/.claude/agents/project-assistant.md"
        log_success "Created .claude/agents/project-assistant.md"
    fi
fi

# Create example skill
if [ -f "$TEMPLATE_DIR/skill-example-template.md" ]; then
    if [ ! -f "$TARGET_DIR/.claude/skills/project-init-local.md" ]; then
        process_template "$TEMPLATE_DIR/skill-example-template.md" "$TARGET_DIR/.claude/skills/project-init-local.md"
        log_success "Created .claude/skills/project-init-local.md"
    fi
fi

# Create example command
if [ -f "$TEMPLATE_DIR/command-example-template.md" ]; then
    if [ ! -f "$TARGET_DIR/.claude/commands/review.md" ]; then
        process_template "$TEMPLATE_DIR/command-example-template.md" "$TARGET_DIR/.claude/commands/review.md"
        log_success "Created .claude/commands/review.md"
    fi
fi

# Create commands README
if [ -f "$TEMPLATE_DIR/commands-readme-template.md" ]; then
    if [ ! -f "$TARGET_DIR/.claude/commands/README.md" ]; then
        process_template "$TEMPLATE_DIR/commands-readme-template.md" "$TARGET_DIR/.claude/commands/README.md"
        log_success "Created .claude/commands/README.md"
    fi
fi

# Note: .claude/logs removed - Claude Code doesn't recommend managing logs in .claude directory

# Create docs/README.md
log_info "Creating docs/ documentation..."

if [ -f "$TEMPLATE_DIR/docs-readme-template.md" ]; then
    if [ ! -f "$TARGET_DIR/docs/README.md" ]; then
        process_template "$TEMPLATE_DIR/docs-readme-template.md" "$TARGET_DIR/docs/README.md"
        log_success "Created docs/README.md"
    else
        log_warning "Existing docs/README.md found - preserving"
    fi
fi

# Create placeholder .gitkeep files for all directories
touch "$TARGET_DIR/docs/01_requirements/.gitkeep"
touch "$TARGET_DIR/docs/02_design/.gitkeep"
touch "$TARGET_DIR/docs/03_architecture/.gitkeep"
touch "$TARGET_DIR/docs/04_api/.gitkeep"
touch "$TARGET_DIR/docs/05_database/.gitkeep"
touch "$TARGET_DIR/docs/06_development/.gitkeep"
touch "$TARGET_DIR/docs/07_testing/.gitkeep"
touch "$TARGET_DIR/docs/08_deployment/.gitkeep"
touch "$TARGET_DIR/docs/09_project/.gitkeep"
touch "$TARGET_DIR/docs/assets/.gitkeep"

echo ""
log_success "Project initialization complete!"
echo ""
echo "Created structure:"
echo "  $TARGET_DIR/"
echo "  ├── .claude/"
echo "  │   ├── CLAUDE.md              # All guidelines consolidated"
echo "  │   ├── settings.json          # Hooks configuration"
echo "  │   ├── agents/"
echo "  │   │   └── project-assistant.md"
echo "  │   ├── skills/"
echo "  │   │   └── project-init-local.md"
echo "  │   └── commands/"
echo "  │       ├── README.md"
echo "  │       └── review.md"
echo "  └── docs/"
echo "      ├── README.md"
echo "      ├── 01_requirements/"
echo "      ├── 02_design/"
echo "      ├── 03_architecture/"
echo "      ├── 04_api/"
echo "      ├── 05_database/"
echo "      ├── 06_development/"
echo "      ├── 07_testing/"
echo "      ├── 08_deployment/"
echo "      ├── 09_project/"
echo "      └── assets/"
echo ""

if [ "$IS_EXISTING_PROJECT" = true ]; then
    echo -e "${CYAN}Detected Tech Stack Summary:${NC}"
    echo "  Language:     ${DETECTED_LANGUAGE:-Not detected}"
    echo "  Frameworks:   ${DETECTED_FRAMEWORKS:-Not detected}"
    echo "  Storage:      ${DETECTED_STORAGE:-Not detected}"
    echo "  Architecture: ${DETECTED_ARCHITECTURE:-Not detected}"
    echo ""
fi

echo "Next steps:"
echo "  1. Review and customize .claude/ files for your project"
echo "  2. Add project-specific documentation to docs/"
echo "  3. Customize agents/skills/commands for your workflow"
echo "  4. Configure hooks in settings.json as needed"
echo "  5. Start using Claude Code with '/sc:load'"
echo ""
