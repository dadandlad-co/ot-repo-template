#!/bin/bash
#----------------------------------------------------------------------------
# OpenTofu Repository Template - Development Environment Setup
# macOS-focused setup script with conditional tool installation
#----------------------------------------------------------------------------

set -euo pipefail

# Source environment configuration
if [[ -f .envrc ]]; then
    # shellcheck source=.envrc
    source .envrc
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Output functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_header() {
    echo -e "\n${BOLD}${BLUE}$1${NC}"
    echo -e "${BLUE}$(printf '=%.0s' {1..60})${NC}"
}

# Global variables
TOOLS_MISSING=0
TOOLS_INSTALLED=0
TOOLS_SKIPPED=0

# Check if tool exists
check_tool() {
    local tool=$1
    local install_cmd=$2
    local required=${3:-false}
    local condition=${4:-true}

    if [[ "${condition}" != "true" ]]; then
        log_info "Skipping $tool (disabled in configuration)"
        TOOLS_SKIPPED=$((TOOLS_SKIPPED + 1))
        return 0
    fi

    if command -v "$tool" &> /dev/null; then
        log_success "$tool is installed"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            log_error "$tool is required but not installed"
            TOOLS_MISSING=$((TOOLS_MISSING + 1))
        else
            log_warning "$tool is not installed (optional)"
        fi
        
        if [[ -n "$install_cmd" ]]; then
            log_info "   Install with: $install_cmd"
        fi
        return 1
    fi
}

# Install tool with brew
install_brew_tool() {
    local tool=$1
    local formula=${2:-$tool}
    local condition=${3:-true}
    local description=${4:-$tool}

    if [[ "${condition}" != "true" ]]; then
        log_info "Skipping $description (disabled in configuration)"
        TOOLS_SKIPPED=$((TOOLS_SKIPPED + 1))
        return 0
    fi

    if command -v "$tool" &> /dev/null; then
        log_success "$description is already installed"
        return 0
    fi

    if [[ "${AUTO_APPROVE_SETUP:-false}" == "true" ]]; then
        local response="y"
    else
        echo -n "Install $description? [y/N] "
        read -r response
    fi

    if [[ "$response" =~ ^[Yy]$ ]]; then
        log_info "Installing $description..."
        if brew install "$formula"; then
            log_success "$description installed successfully"
            TOOLS_INSTALLED=$((TOOLS_INSTALLED + 1))
        else
            log_error "Failed to install $description"
            TOOLS_MISSING=$((TOOLS_MISSING + 1))
        fi
    else
        log_warning "Skipped installation of $description"
        TOOLS_SKIPPED=$((TOOLS_SKIPPED + 1))
    fi
}

# Check system requirements
check_system() {
    log_header "System Requirements Check"

    # Check macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        log_warning "This script is optimized for macOS. Some features may not work on other systems."
    else
        log_success "Running on macOS"
    fi

    # Check Homebrew
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew is required but not installed"
        log_info "Install Homebrew from: https://brew.sh/"
        log_info "Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    else
        log_success "Homebrew is installed"
    fi

    # Update Homebrew
    log_info "Updating Homebrew..."
    brew update || log_warning "Failed to update Homebrew (continuing anyway)"
}

# Setup directories
setup_directories() {
    log_header "Directory Setup"

    local directories=(
        "${TF_PLUGIN_CACHE_DIR:-$HOME/.terraform.d/plugin-cache}"
        "tmp"
        "logs"
    )

    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_info "Creating directory: $dir"
            mkdir -p "$dir"
            log_success "Created $dir"
        else
            log_success "$dir already exists"
        fi
    done
}

# Install core tools
install_core_tools() {
    log_header "Core Tools Installation"

    # Essential tools (always required)
    check_tool "git" "brew install git" true
    check_tool "tofu" "brew install opentofu/tap/opentofu" true
    check_tool "direnv" "brew install direnv" true
    check_tool "task" "brew install go-task" true

    # Install missing core tools
    if ! command -v git &> /dev/null; then
        install_brew_tool "git" "git" "true" "Git version control"
    fi

    if ! command -v tofu &> /dev/null; then
        install_brew_tool "tofu" "opentofu/tap/opentofu" "true" "OpenTofu"
    fi

    if ! command -v direnv &> /dev/null; then
        install_brew_tool "direnv" "direnv" "true" "direnv environment manager"
    fi

    if ! command -v task &> /dev/null; then
        install_brew_tool "task" "go-task" "true" "Task runner"
    fi
}

# Install development tools
install_development_tools() {
    log_header "Development Tools Installation"

    # Conditional development tools
    install_brew_tool "terraform-docs" "terraform-docs" "${ENABLE_DOCUMENTATION_AUTOMATION}" "Terraform documentation generator"
    install_brew_tool "pre-commit" "pre-commit" "${ENABLE_PRE_COMMIT_HOOKS}" "Pre-commit hooks manager"
    install_brew_tool "tflint" "tflint" "true" "OpenTofu linter"
    install_brew_tool "jq" "jq" "true" "JSON processor"
}

# Install security tools
install_security_tools() {
    log_header "Security Tools Installation"

    if [[ "${ENABLE_SECURITY_SCANNING}" == "true" ]]; then
        install_brew_tool "tfsec" "tfsec" "${ENABLE_TFSEC}" "Infrastructure security scanner"
        install_brew_tool "checkov" "checkov" "${ENABLE_CHECKOV}" "Policy-as-code scanner"
        install_brew_tool "trufflehog" "trufflesecurity/trufflehog/trufflehog" "true" "Secret scanner"
    else
        log_info "Security scanning disabled - skipping security tools"
        TOOLS_SKIPPED=$((TOOLS_SKIPPED + 3))
    fi
}

# Install provider-specific tools
install_provider_tools() {
    log_header "Provider-Specific Tools Installation"

    # AWS tools
    if [[ "${OPENTOFU_PROVIDER_AWS}" == "true" ]]; then
        install_brew_tool "aws" "awscli" "true" "AWS CLI"
    fi

    # Google Cloud tools
    if [[ "${OPENTOFU_PROVIDER_GCP}" == "true" ]]; then
        install_brew_tool "gcloud" "google-cloud-sdk" "true" "Google Cloud SDK"
    fi

    # Azure tools
    if [[ "${OPENTOFU_PROVIDER_AZURE}" == "true" ]]; then
        install_brew_tool "az" "azure-cli" "true" "Azure CLI"
    fi

    # GitHub tools
    if [[ "${OPENTOFU_PROVIDER_GITHUB}" == "true" ]]; then
        install_brew_tool "gh" "gh" "true" "GitHub CLI"
    fi

    # Show summary if no providers enabled
    local enabled_providers=()
    [[ "${OPENTOFU_PROVIDER_AWS}" == "true" ]] && enabled_providers+=("AWS")
    [[ "${OPENTOFU_PROVIDER_GCP}" == "true" ]] && enabled_providers+=("GCP")
    [[ "${OPENTOFU_PROVIDER_AZURE}" == "true" ]] && enabled_providers+=("Azure")
    [[ "${OPENTOFU_PROVIDER_GITHUB}" == "true" ]] && enabled_providers+=("GitHub")

    if [[ ${#enabled_providers[@]} -eq 0 ]]; then
        log_info "No cloud providers enabled - running in provider-agnostic mode"
    else
        log_success "Provider support enabled for: ${enabled_providers[*]}"
    fi
}

# Install optional tools
install_optional_tools() {
    log_header "Optional Tools Installation"

    install_brew_tool "infracost" "infracost" "${ENABLE_INFRACOST}" "Cost estimation tool"
    install_brew_tool "boilr" "solaegis/boilr/boilr" "${ENABLE_BOILR_TEMPLATES}" "Template manager"
    install_brew_tool "shellcheck" "shellcheck" "true" "Shell script linter"
    install_brew_tool "yamllint" "yamllint" "true" "YAML linter"
    install_brew_tool "markdownlint-cli" "markdownlint-cli" "${ENABLE_DOCUMENTATION_AUTOMATION}" "Markdown linter"
}

# Configure tools
configure_tools() {
    log_header "Tool Configuration"

    # Configure direnv
    if command -v direnv &> /dev/null; then
        log_info "Configuring direnv..."
        if ! grep -q 'eval "$(direnv hook bash)"' ~/.bashrc 2>/dev/null && 
           ! grep -q 'eval "$(direnv hook zsh)"' ~/.zshrc 2>/dev/null; then
            log_warning "direnv shell integration not found"
            log_info "Add the following to your shell profile:"
            log_info "  For bash: echo 'eval \"\$(direnv hook bash)\"' >> ~/.bashrc"
            log_info "  For zsh:  echo 'eval \"\$(direnv hook zsh)\"' >> ~/.zshrc"
        else
            log_success "direnv shell integration configured"
        fi
    fi

    # Configure pre-commit
    if [[ "${ENABLE_PRE_COMMIT_HOOKS}" == "true" ]] && command -v pre-commit &> /dev/null; then
        log_info "Installing pre-commit hooks..."
        if pre-commit install; then
            log_success "Pre-commit hooks installed"
        else
            log_warning "Failed to install pre-commit hooks (will retry later)"
        fi
    fi

    # Configure Git (if needed)
    if command -v git &> /dev/null; then
        if [[ -z "$(git config --global user.name 2>/dev/null || echo '')" ]]; then
            log_warning "Git user name not configured"
            log_info "Run: git config --global user.name 'Your Name'"
        fi
        if [[ -z "$(git config --global user.email 2>/dev/null || echo '')" ]]; then
            log_warning "Git user email not configured" 
            log_info "Run: git config --global user.email 'your.email@example.com'"
        fi
    fi

    # Configure OpenTofu plugin cache
    log_info "Configuring OpenTofu plugin cache..."
    if [[ -d "${TF_PLUGIN_CACHE_DIR}" ]]; then
        log_success "OpenTofu plugin cache directory ready: ${TF_PLUGIN_CACHE_DIR}"
    else
        log_error "Failed to create OpenTofu plugin cache directory"
    fi
}

# Setup VS Code configuration
setup_vscode_config() {
    if [[ "${ENABLE_VS_CODE_CONFIG}" == "true" ]]; then
        log_header "VS Code Configuration Setup"
        
        if [[ ! -d .vscode ]]; then
            log_info "Creating .vscode directory for IDE configuration"
            mkdir -p .vscode
            log_success ".vscode directory created"
        else
            log_success ".vscode directory already exists"
        fi
    else
        log_info "VS Code configuration disabled - skipping IDE setup"
    fi
}

# Validate installation
validate_installation() {
    log_header "Installation Validation"

    local validation_errors=0

    # Core tools validation
    local core_tools=("git" "tofu" "direnv" "task")
    for tool in "${core_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "Core tool missing: $tool"
            validation_errors=$((validation_errors + 1))
        fi
    done

    # Conditional tools validation
    if [[ "${ENABLE_SECURITY_SCANNING}" == "true" ]]; then
        [[ "${ENABLE_TFSEC}" == "true" ]] && ! command -v tfsec &> /dev/null && {
            log_error "tfsec not found (required when ENABLE_TFSEC=true)"
            validation_errors=$((validation_errors + 1))
        }
        [[ "${ENABLE_CHECKOV}" == "true" ]] && ! command -v checkov &> /dev/null && {
            log_error "checkov not found (required when ENABLE_CHECKOV=true)"
            validation_errors=$((validation_errors + 1))
        }
    fi

    # Provider tools validation
    [[ "${OPENTOFU_PROVIDER_AWS}" == "true" ]] && ! command -v aws &> /dev/null && {
        log_warning "AWS CLI not found (recommended when OPENTOFU_PROVIDER_AWS=true)"
    }

    if [[ $validation_errors -eq 0 ]]; then
        log_success "All required tools are installed and configured"
        return 0
    else
        log_error "Validation failed with $validation_errors error(s)"
        return 1
    fi
}

# Generate setup summary
generate_summary() {
    log_header "Setup Summary"

    echo -e "${BOLD}Installation Summary:${NC}"
    echo -e "  ✅ Tools installed: ${GREEN}${TOOLS_INSTALLED}${NC}"
    echo -e "  ⏭️  Tools skipped: ${YELLOW}${TOOLS_SKIPPED}${NC}"
    echo -e "  ❌ Tools missing: ${RED}${TOOLS_MISSING}${NC}"

    echo -e "\n${BOLD}Configuration:${NC}"
    echo -e "  🏢 Organization: ${ORGANIZATION_NAME}"
    echo -e "  📄 License: ${DEFAULT_LICENSE}"
    echo -e "  🔐 Security scanning: ${ENABLE_SECURITY_SCANNING}"
    echo -e "  📚 Documentation: ${ENABLE_DOCUMENTATION_AUTOMATION}"
    echo -e "  🚀 Release automation: ${ENABLE_RELEASE_AUTOMATION}"

    local enabled_providers=()
    [[ "${OPENTOFU_PROVIDER_AWS}" == "true" ]] && enabled_providers+=("AWS")
    [[ "${OPENTOFU_PROVIDER_GCP}" == "true" ]] && enabled_providers+=("GCP")
    [[ "${OPENTOFU_PROVIDER_AZURE}" == "true" ]] && enabled_providers+=("Azure")
    [[ "${OPENTOFU_PROVIDER_GITHUB}" == "true" ]] && enabled_providers+=("GitHub")

    if [[ ${#enabled_providers[@]} -gt 0 ]]; then
        echo -e "  ☁️  Providers: ${enabled_providers[*]}"
    else
        echo -e "  ☁️  Providers: Provider-agnostic mode"
    fi

    echo -e "\n${BOLD}Next Steps:${NC}"
    echo -e "  1. Run: ${BLUE}direnv allow${NC} (to load environment)"
    echo -e "  2. Run: ${BLUE}task${NC} (to see available commands)"
    echo -e "  3. Run: ${BLUE}task validate${NC} (to validate setup)"

    if [[ "${ENABLE_PRE_COMMIT_HOOKS}" == "true" ]]; then
        echo -e "  4. Pre-commit hooks are configured"
    fi

    if [[ $TOOLS_MISSING -gt 0 ]]; then
        echo -e "\n${YELLOW}⚠️  Some tools are missing. Re-run this script or install them manually.${NC}"
    fi

    echo -e "\n${GREEN}🎉 Setup completed!${NC}"
}

# Main function
main() {
    echo -e "${BOLD}${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           OpenTofu Repository Template Setup               ║"
    echo "║                                                            ║"
    echo "║  This script will set up your development environment     ║"
    echo "║  with conditional tool installation based on your .env    ║"
    echo "║  configuration.                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"

    # Load configuration
    if [[ ! -f .env ]]; then
        log_warning "No .env file found, using defaults from .env.example"
        log_info "Run 'cp .env.example .env' to customize your configuration"
    fi

    # Run setup steps
    check_system
    setup_directories
    install_core_tools
    install_development_tools
    install_security_tools
    install_provider_tools
    install_optional_tools
    configure_tools
    setup_vscode_config

    # Validate and summarize
    if validate_installation; then
        generate_summary
        exit 0
    else
        generate_summary
        log_error "Setup completed with errors. Please review and fix issues above."
        exit 1
    fi
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi