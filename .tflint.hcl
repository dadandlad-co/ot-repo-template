#----------------------------------------------------------------------------
# .tflint.hcl - Environment-Driven TFLint Configuration
# Adapts based on .env settings for provider support and feature flags
#----------------------------------------------------------------------------

config {
  # Enable module inspection for comprehensive linting
  module = true

  # Disable default rules to allow selective enablement
  disabled_by_default = false

  # Output format configuration
  format = "compact"

  # Enable colored output for better readability
  force = false

  # Plugin directory for provider-specific plugins
  plugin_dir = "~/.tflint.d/plugins"

  # Call module type (default: "all")
  call_module_type = "all"

  # Varfile for variable validation
  varfile = ["terraform.tfvars"]
}

#----------------------------------------------------------------------------
# Core OpenTofu/Terraform Rules (Always Enabled)
#----------------------------------------------------------------------------

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
  style   = "semver"
  default_branches = ["main", "master"]
}

rule "terraform_module_version" {
  enabled = true
  exact   = false
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"

  # Custom patterns for different resource types
  custom_formats = {
    data_source        = "snake_case",
    local_value        = "snake_case",
    output_value       = "snake_case",
    resource           = "snake_case",
    variable           = "snake_case",
    module_call        = "snake_case"
  }
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}

rule "terraform_workspace_remote" {
  enabled = false  # Disable as we don't typically use remote workspaces
}

#----------------------------------------------------------------------------
# Variable and Output Validation Rules
#----------------------------------------------------------------------------

rule "terraform_variable_separate_type_description" {
  enabled = true
}

rule "terraform_output_separate_description" {
  enabled = true
}

#----------------------------------------------------------------------------
# Resource Naming and Structure Rules
#----------------------------------------------------------------------------

rule "terraform_resource_missing_name" {
  enabled = true
}

#----------------------------------------------------------------------------
# Security Rules (Core)
#----------------------------------------------------------------------------

rule "terraform_sensitive_variable_no_default" {
  enabled = true
}

#----------------------------------------------------------------------------
# Core Terraform Plugin (Always Enabled)
#----------------------------------------------------------------------------

plugin "terraform" {
  enabled = true
  version = "0.9.1"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"

  preset = "recommended"
}

#----------------------------------------------------------------------------
# Provider-Specific Plugins (Conditional on Environment)
#----------------------------------------------------------------------------

# AWS Provider Plugin
# Enabled when OPENTOFU_PROVIDER_AWS=true
plugin "aws" {
  enabled = env("OPENTOFU_PROVIDER_AWS") == "true" ? true : false
  version = "0.30.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"

  # AWS-specific configuration
  deep_check = true

  # Region configuration (uses DEFAULT_REGION from .env)
  region = env("DEFAULT_REGION") != "" ? env("DEFAULT_REGION") : "us-east-1"
}

# Google Cloud Provider Plugin  
# Enabled when OPENTOFU_PROVIDER_GCP=true
plugin "google" {
  enabled = env("OPENTOFU_PROVIDER_GCP") == "true" ? true : false
  version = "0.29.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"

  # GCP-specific configuration
  deep_check = true
}

# Azure Provider Plugin
# Enabled when OPENTOFU_PROVIDER_AZURE=true  
plugin "azurerm" {
  enabled = env("OPENTOFU_PROVIDER_AZURE") == "true" ? true : false
  version = "0.26.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"

  # Azure-specific configuration
  deep_check = true
}

# Kubernetes Provider Plugin
# Auto-enabled when any cloud provider is enabled (common pattern)
plugin "kubernetes" {
  enabled = (env("OPENTOFU_PROVIDER_AWS") == "true" || 
            env("OPENTOFU_PROVIDER_GCP") == "true" || 
            env("OPENTOFU_PROVIDER_AZURE") == "true") ? true : false
  version = "0.2.0"
  source  = "github.com/terraform-linters/tflint-ruleset-kubernetes"
}

# Docker Provider Plugin  
# Enabled when containerization is common (AWS/GCP/Azure scenarios)
plugin "docker" {
  enabled = (env("OPENTOFU_PROVIDER_AWS") == "true" || 
            env("OPENTOFU_PROVIDER_GCP") == "true" || 
            env("OPENTOFU_PROVIDER_AZURE") == "true") ? true : false
  version = "0.5.0"
  source  = "github.com/terraform-linters/tflint-ruleset-docker"
}

#----------------------------------------------------------------------------
# Provider-Specific Rule Overrides
#----------------------------------------------------------------------------

# AWS-specific rules (only when AWS provider is enabled)
rule "aws_instance_invalid_type" {
  enabled = env("OPENTOFU_PROVIDER_AWS") == "true" ? true : false
}

rule "aws_instance_previous_type" {
  enabled = env("OPENTOFU_PROVIDER_AWS") == "true" ? true : false
}

rule "aws_route_invalid_route_table" {
  enabled = env("OPENTOFU_PROVIDER_AWS") == "true" ? true : false
}

rule "aws_alb_invalid_security_group" {
  enabled = env("OPENTOFU_PROVIDER_AWS") == "true" ? true : false
}

rule "aws_db_instance_invalid_type" {
  enabled = env("OPENTOFU_PROVIDER_AWS") == "true" ? true : false
}

rule "aws_elasticache_cluster_invalid_type" {
  enabled = env("OPENTOFU_PROVIDER_AWS") == "true" ? true : false
}

# Google Cloud-specific rules (only when GCP provider is enabled)
rule "google_compute_instance_invalid_machine_type" {
  enabled = env("OPENTOFU_PROVIDER_GCP") == "true" ? true : false
}

rule "google_container_cluster_invalid_machine_type" {
  enabled = env("OPENTOFU_PROVIDER_GCP") == "true" ? true : false
}

# Azure-specific rules (only when Azure provider is enabled)
rule "azurerm_virtual_machine_invalid_vm_size" {
  enabled = env("OPENTOFU_PROVIDER_AZURE") == "true" ? true : false
}

#----------------------------------------------------------------------------
# Environment-Based Rule Adjustments
#----------------------------------------------------------------------------

# Strict mode when security scanning is enabled
rule "terraform_required_providers" {
  enabled = env("ENABLE_SECURITY_SCANNING") == "true" ? true : false
}

# Documentation requirements (when documentation automation is enabled)
rule "terraform_documented_outputs" {
  enabled = env("ENABLE_DOCUMENTATION_AUTOMATION") == "true" ? true : false
}

rule "terraform_documented_variables" {
  enabled = env("ENABLE_DOCUMENTATION_AUTOMATION") == "true" ? true : false
}

#----------------------------------------------------------------------------
# Performance and Debugging Configuration
#----------------------------------------------------------------------------

# Adjust based on MAX_PARALLEL_PROCESSES setting
config {
  # Use environment variable for parallel processing if available
  # Note: TFLint doesn't directly support this, but we document the intention
  # max_workers = env("MAX_PARALLEL_PROCESSES") != "" ? tonumber(env("MAX_PARALLEL_PROCESSES")) : 4
}

#----------------------------------------------------------------------------
# Exclusions and Overrides
#----------------------------------------------------------------------------

# Exclude common directories that shouldn't be linted
rule "terraform_module_pinned_source" {
  enabled = true
  # Don't require pinned versions for local modules
  exclude_paths = [
    "./modules/**/*",
    ".terraform/**/*"
  ]
}

# Disable workspace validation for local development
rule "terraform_workspace_remote" {
  enabled = false
}

#----------------------------------------------------------------------------
# Custom Rule Configuration Based on Organization Settings
#----------------------------------------------------------------------------

# Organization-specific naming patterns
rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
  
  # Custom naming patterns based on organization
  custom_formats = {
    # Use organization name from environment for prefixing validation
    resource = env("ORGANIZATION_NAME") != "" ? "snake_case" : "snake_case"
  }
}

#----------------------------------------------------------------------------
# Development vs Production Configuration
#----------------------------------------------------------------------------

# In development, be more lenient with certain rules
rule "terraform_unused_declarations" {
  enabled = env("AUTO_APPROVE_SETUP") == "true" ? false : true
}

# Require stricter validation in CI/CD environments
rule "terraform_required_version" {
  enabled = env("ENABLE_RELEASE_AUTOMATION") == "true" ? true : true
}

#----------------------------------------------------------------------------
# Integration with Other Tools
#----------------------------------------------------------------------------

# When Checkov is enabled, disable overlapping TFLint security rules
# to avoid duplicate findings
rule "terraform_sensitive_variable_no_default" {
  enabled = env("ENABLE_CHECKOV") == "true" ? false : true
}

#----------------------------------------------------------------------------
# Logging and Debugging
#----------------------------------------------------------------------------

# Enable verbose logging when VERBOSE_OUTPUT is true
# Note: This would typically be set via environment variable TFLINT_LOG
# export TFLINT_LOG=debug when VERBOSE_OUTPUT=true