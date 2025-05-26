# OpenTofu Repository Template

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/dadandlad.co)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)
[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)

**A production-ready, environment-driven OpenTofu module template with comprehensive tooling, security scanning, and multi-cloud provider support.**

## 🚀 Quick Start

```bash
# 1. Clone or use this template
git clone <this-repo> my-opentofu-module
cd my-opentofu-module

# 2. Configure your environment
cp .env.example .env
# Edit .env to match your needs

# 3. Run the automated setup
chmod +x setup.sh
./setup.sh

# 4. Activate your environment
direnv allow

# 5. See available commands
task
```

## ✨ Key Features

### 🎯 **Environment-Driven Configuration**
- **Smart defaults**: Works out of the box with sensible configurations
- **Conditional tooling**: Only installs and configures tools you actually need
- **Provider-specific support**: Enable AWS, GCP, Azure, or GitHub providers as needed
- **Development vs Production**: Different rule sets for different environments

### 🔒 **Comprehensive Security**
- **Multi-layer scanning**: TFSec, Checkov, and TruffleHog integration
- **Secret detection**: Prevents credentials from being committed
- **Policy enforcement**: Infrastructure compliance as code
- **Provider-specific rules**: Tailored security checks for each cloud provider

### 🛠️ **Developer Experience**
- **Automated setup**: One-command environment configuration
- **Pre-commit hooks**: Catch issues before they reach your repository
- **Task automation**: Common workflows automated with Task runner
- **IDE integration**: VS Code/Cursor/Windsurf configurations included

### 📚 **Documentation & Quality**
- **Auto-generated docs**: OpenTofu documentation automatically maintained
- **Consistent formatting**: Automated code, YAML, and Markdown formatting
- **Quality gates**: Comprehensive linting and validation
- **Example validation**: Ensures your examples actually work

## 🏗️ Architecture

This template follows a **configuration-driven architecture** where your `.env` file controls which tools and features are enabled:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Environment   │────│  Conditional     │────│    Tooling      │
│  Configuration  │    │  Logic           │    │   Installation  │
│    (.env)       │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│    Security     │    │  Documentation   │    │   Development   │
│   Scanning      │    │   Generation     │    │     Tools       │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## ⚙️ Configuration

### Core Features (`.env` file)

| Variable | Default | Description |
|----------|---------|-------------|
| `ENABLE_SECURITY_SCANNING` | `true` | Enable TFSec, Checkov, TruffleHog |
| `ENABLE_DOCUMENTATION_AUTOMATION` | `true` | Auto-generate OpenTofu docs |
| `ENABLE_RELEASE_AUTOMATION` | `true` | Automated changelog and releases |
| `ENABLE_PRE_COMMIT_HOOKS` | `true` | Git pre-commit validation |
| `ENABLE_EXAMPLE_VALIDATION` | `true` | Validate example configurations |

### Provider Support

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENTOFU_PROVIDER_AWS` | `false` | AWS-specific tooling and examples |
| `OPENTOFU_PROVIDER_GCP` | `false` | Google Cloud tooling and examples |
| `OPENTOFU_PROVIDER_AZURE` | `false` | Azure tooling and examples |
| `OPENTOFU_PROVIDER_GITHUB` | `false` | GitHub provider tooling |

### Security Tools

| Variable | Default | Description |
|----------|---------|-------------|
| `ENABLE_TFSEC` | `true` | Infrastructure security scanner |
| `ENABLE_CHECKOV` | `true` | Policy-as-code scanner |
| `ENABLE_INFRACOST` | `false` | Cost estimation (requires API key) |

### Organization Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `ORGANIZATION_NAME` | `"dadandlad.co"` | Your organization name |
| `DEFAULT_LICENSE` | `"MIT"` | License for new projects |
| `DEFAULT_REGION` | `"us-east-1"` | Default cloud region |

## 🔧 Usage

### Basic Commands

```bash
# View all available commands
task

# Validate your OpenTofu configuration
task validate

# Format all files
task fmt

# Run comprehensive tests
task test

# Run security scans
task security-scan

# Generate documentation
task docs

# Clean temporary files
task clean
```

### Development Workflow

```bash
# 1. Make your changes
vim main.tf

# 2. Validate and format (happens automatically with pre-commit)
task validate

# 3. Commit (pre-commit hooks run automatically)
git add .
git commit -m "feat: add new resource"

# 4. Push changes
task push
```

### Provider-Specific Usage

Enable AWS provider in your `.env`:
```bash
OPENTOFU_PROVIDER_AWS=true
```

Then run setup again:
```bash
./setup.sh
```

This will:
- Install AWS CLI
- Configure AWS-specific TFLint rules
- Enable AWS security checks in TFSec and Checkov
- Add AWS examples and documentation

## 🛡️ Security

### Multi-Layer Security Approach

1. **Secret Detection** (TruffleHog)
   - Scans for hardcoded credentials
   - Supports 200+ secret types
   - Custom patterns for your organization

2. **Infrastructure Security** (TFSec)
   - Static analysis of OpenTofu code
   - Provider-specific security rules
   - Compliance framework support

3. **Policy Enforcement** (Checkov)
   - Policy-as-code validation
   - GDPR, SOC2, PCI-DSS compliance
   - Custom organizational policies

4. **Pre-commit Validation**
   - Prevents issues before they reach your repo
   - Multi-tool integration
   - Fast feedback loop

### Security Configuration

Security scanning adapts to your providers:

```bash
# Enable comprehensive security for AWS
OPENTOFU_PROVIDER_AWS=true
ENABLE_SECURITY_SCANNING=true
ENABLE_TFSEC=true
ENABLE_CHECKOV=true
```

This automatically enables:
- AWS-specific security rules
- IAM policy validation
- S3 bucket security checks
- EC2 security group validation
- And 100+ more AWS checks

## 📖 Documentation

### Auto-Generated Documentation

When `ENABLE_DOCUMENTATION_AUTOMATION=true`, documentation is automatically generated and maintained:

- **Module documentation**: Inputs, outputs, requirements
- **Example documentation**: Working examples with explanations
- **Security documentation**: Security considerations and best practices
- **Usage documentation**: How to use your module

### Documentation Structure

```
docs/
├── README.md              # This file
├── USAGE.md              # Detailed usage examples
├── SECURITY.md           # Security considerations
├── CONTRIBUTING.md       # Contribution guidelines
└── examples/
    ├── basic/            # Basic usage example
    ├── advanced/         # Advanced configuration
    └── multi-cloud/      # Multi-provider examples
```

## 🧪 Testing

### Comprehensive Testing Strategy

```bash
# Run all tests
task test

# Test specific components
task validate-examples    # Validate example configurations
task security-scan      # Security validation
task validate           # OpenTofu validation
```

### Test Types

1. **Static Analysis**
   - OpenTofu syntax validation
   - Security policy checks
   - Code quality validation

2. **Example Testing**
   - All examples can be planned
   - Examples use realistic configurations
   - Examples are tested in CI/CD

3. **Security Testing**
   - Secret detection
   - Policy compliance
   - Infrastructure security

## 🔄 CI/CD Integration

### GitHub Actions Ready

The template includes GitHub Actions workflows for:

- **Pull Request Validation**
  - Run all tests and security scans
  - Generate documentation
  - Validate examples

- **Release Automation**
  - Semantic versioning
  - Automated changelog generation
  - Release notes creation

- **Security Monitoring**
  - Continuous security scanning
  - Vulnerability alerts
  - Compliance reporting

### Pre-commit Integration

Pre-commit hooks ensure quality before code reaches your repository:

```yaml
# Automatically runs on git commit
- OpenTofu formatting and validation
- Security scanning
- Documentation updates
- YAML and Markdown linting
- Secret detection
```

## 🌍 Multi-Cloud Support

### Supported Providers

| Provider | Status | Features |
|----------|--------|----------|
| **AWS** | ✅ Full Support | TFLint rules, security checks, examples |
| **Google Cloud** | ✅ Full Support | TFLint rules, security checks, examples |
| **Azure** | ✅ Full Support | TFLint rules, security checks, examples |
| **GitHub** | ✅ Full Support | Repository management, security |

### Provider-Agnostic Mode

The template works without any cloud providers enabled:

```bash
# All provider flags set to false
OPENTOFU_PROVIDER_AWS=false
OPENTOFU_PROVIDER_GCP=false
OPENTOFU_PROVIDER_AZURE=false
OPENTOFU_PROVIDER_GITHUB=false
```

Perfect for:
- Generic OpenTofu modules
- Learning and experimentation
- Provider-independent utilities

## 📊 Tools Included

### Core Development Tools

| Tool | Purpose | Auto-Installed |
|------|---------|---------------|
| [OpenTofu](https://opentofu.org/) | Infrastructure as Code | ✅ |
| [Task](https://taskfile.dev/) | Task runner | ✅ |
| [direnv](https://direnv.net/) | Environment management | ✅ |
| [pre-commit](https://pre-commit.com/) | Git hooks | ✅ |

### Security Tools

| Tool | Purpose | Conditional |
|------|---------|-------------|
| [TFSec](https://tfsec.dev/) | Infrastructure security | `ENABLE_TFSEC` |
| [Checkov](https://checkov.io/) | Policy as code | `ENABLE_CHECKOV` |
| [TruffleHog](https://trufflesecurity.com/) | Secret detection | Always enabled |

### Documentation Tools

| Tool | Purpose | Conditional |
|------|---------|-------------|
| [terraform-docs](https://terraform-docs.io/) | Documentation generation | `ENABLE_DOCUMENTATION_AUTOMATION` |
| [markdownlint](https://github.com/igorshubovych/markdownlint-cli) | Markdown linting | `ENABLE_DOCUMENTATION_AUTOMATION` |

### Provider-Specific Tools

| Provider | Tools | Conditional |
|----------|-------|-------------|
| AWS | AWS CLI, AWS TFLint rules | `OPENTOFU_PROVIDER_AWS` |
| Google Cloud | gcloud, GCP TFLint rules | `OPENTOFU_PROVIDER_GCP` |
| Azure | Azure CLI, Azure TFLint rules | `OPENTOFU_PROVIDER_AZURE` |
| GitHub | GitHub CLI | `OPENTOFU_PROVIDER_GITHUB` |

## 🤝 Contributing

1. **Fork the repository**
2. **Create your feature branch**: `git checkout -b feature/amazing-feature`
3. **Configure your environment**: `cp .env.example .env`
4. **Run setup**: `./setup.sh`
5. **Make your changes**
6. **Test thoroughly**: `task test`
7. **Commit your changes**: `git commit -m 'feat: add amazing feature'`
8. **Push to the branch**: `git push origin feature/amazing-feature`
9. **Open a Pull Request**

### Development Guidelines

- **Follow semantic versioning** for releases
- **Write comprehensive tests** for new features
- **Update documentation** for any changes
- **Run security scans** before submitting
- **Use conventional commits** for clear history

## 📝 Examples

### Basic Module Structure

```hcl
# main.tf
terraform {
  required_version = ">= 1.8.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
  
  tags = var.tags
}
```

### Variables with Validation

```hcl
# variables.tf
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
```

### Outputs with Descriptions

```hcl
# outputs.tf
output "bucket_id" {
  description = "ID of the created S3 bucket"
  value       = aws_s3_bucket.example.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.example.arn
}
```

## 🆘 Troubleshooting

### Common Issues

**Setup script fails on macOS**
```bash
# Install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Pre-commit hooks not running**
```bash
# Reinstall hooks
task install-hooks
```

**Security scan false positives**
```bash
# Check allowlist patterns in .trufflehog.yaml
# Add organization-specific patterns to reduce noise
```

**OpenTofu validation fails**
```bash
# Check your provider configuration
task validate-config
```

### Getting Help

1. **Check the documentation** in the `docs/` directory
2. **Review the configuration** in your `.env` file
3. **Run diagnostics**: `task validate-config`
4. **Check issues** in the repository
5. **Open a new issue** with detailed information

## 📜 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 🙏 Acknowledgments

- [OpenTofu](https://opentofu.org/) for the excellent IaC tool
- [HashiCorp](https://hashicorp.com/) for the original Terraform ecosystem
- [Aqua Security](https://aquasec.com/) for TFSec
- [Bridgecrew](https://bridgecrew.io/) for Checkov
- [Truffle Security](https://trufflesecurity.com/) for TruffleHog
- The open-source community for all the amazing tools

---

<div align="center">

**[⭐ Star this repository](https://github.com/your-org/repo) if it helped you!**

Made with ❤️ by [dadandlad.co](https://dadandlad.co)

</div>

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->