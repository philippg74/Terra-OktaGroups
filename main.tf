# Configure the Okta provider
terraform {
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 3.20"
    }
  }
}

provider "okta" {
  org_name  = var.okta_org_name
  base_url  = var.okta_base_url
  api_token = var.okta_api_token
}

# Variables
variable "okta_org_name" {
  description = "The name of your Okta organization"
  type        = string
}

variable "okta_base_url" {
  description = "The base URL of your Okta organization"
  type        = string
}

variable "okta_api_token" {
  description = "The API token for your Okta organization"
  type        = string
}

variable "groups_file" {
  description = "Path to the file containing group names"
  type        = string
  default     = "groups.txt"
}

# Read groups from file
data "local_file" "groups" {
  filename = var.groups_file
}

# Create Okta groups
resource "okta_group" "groups" {
  for_each = toset([
    for line in split("\n", data.local_file.groups.content) :
    trimspace(replace(line, "/[\\x00-\\x1F\\x7F]/", ""))
    if length(trimspace(replace(line, "/[\\x00-\\x1F\\x7F]/", ""))) > 0
  ])
  name        = each.key
  description = "Group created via Terraform: ${each.key}"
}

# Output created groups
output "created_groups" {
  value = values(okta_group.groups)[*].name
}