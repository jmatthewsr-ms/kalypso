# Configure the GitHub Provider
provider "github" {
  token = var.github_token
  owner = var.github_owner
}

terraform {
  required_providers {

    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

# Configure the Azure Active Directory Provider
provider "azuread" {
  tenant_id = var.azure_ad_tenantId
}

# Create a new repository from a template repo
resource "github_repository" gitops_repo {
  name        = local.gitops_repo_name
  description = "GitOps Repo"
  template {
    owner                = "microsoft"      # The owner of the template repo
    repository           = "kalypso-gitops" # The name of the template repo
    include_all_branches = true             # Whether to include all branches from the template repo
  }
  visibility = "public"
}
resource "github_repository" control_plane_repo {
  name        = local.controlplane_repo_name
  description = "Control Plane Repo"
  template {
    owner                = "microsoft"             # The owner of the template repo
    repository           = "kalypso-control-plane" # The name of the template repo
    include_all_branches = true                    # Whether to include all branches from the template repo
  }
  visibility = "public"
}

resource "github_actions_secret" "gitops_repo" {
  repository      = local.controlplane_repo_name
  secret_name     = "GITOPS_REPO"
  plaintext_value = local.gitops_repo_name
}

resource "github_actions_secret" "gitops_repo_token" {
  repository      = local.controlplane_repo_name
  secret_name     = "GITOPS_REPO_TOKEN"
  plaintext_value = var.github_token
}

resource "github_actions_environment_secret" "next_environment" {
  environment     = "dev"
  secret_name     = "NEXT_ENVIRONMENT"
  plaintext_value = "stage"
  repository      = local.controlplane_repo_name
}


#######
# Azure
#######

data "azuread_client_config" "current" {}

resource "azuread_application" "example" {
  display_name = "kalypso-${var.kalypso_prefix}"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "example" {
  application_id               = azuread_application.example.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "example" {
  service_principal_id = azuread_service_principal.example.object_id
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_assignment" "example" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.example.object_id
}

resource "github_actions_secret" "azure_credentials" {
  repository      = local.controlplane_repo_name
  secret_name     = "AZURE_CREDENTIALS"
  plaintext_value = var.github_token
}
