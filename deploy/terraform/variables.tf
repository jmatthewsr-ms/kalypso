# Define variables for the GitHub Provider
variable "github_token" {
  description = "The GitHub token to use for authentication"
  type        = string
}

variable "github_owner" {
  description = "The GitHub name to manage"
  type        = string
}

variable "azure_ad_tenantId" {
  description = "Azure AD Tenant ID"
  type        = string
}

variable "kalypso_prefix" {
  description = "For naming all resources, prefix with this string"
  type        = string
}
