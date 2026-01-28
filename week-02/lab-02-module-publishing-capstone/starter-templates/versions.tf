# versions.tf - Required provider and Terraform version constraints
#
# This file tells Terraform:
# 1. What minimum Terraform version is required
# 2. What providers are needed and their version constraints
#
# Copy this to your module repository and adjust as needed.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

# NOTE: Do NOT include a provider block in your module!
# The calling code (root module) configures the provider.
# Modules should only declare what providers they REQUIRE.
