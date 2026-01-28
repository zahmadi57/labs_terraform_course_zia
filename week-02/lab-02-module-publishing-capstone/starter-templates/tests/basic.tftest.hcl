# tests/basic.tftest.hcl - Terraform Native Tests
#
# This file contains tests for your module using Terraform's native test framework.
# Tests run with `terraform test` and validate your module works correctly.
#
# Copy this to your module's tests/ directory and customize.

# =============================================================================
# PROVIDER CONFIGURATION FOR TESTS
# =============================================================================
# Tests need a provider configured. This runs against real AWS (but plan only).

provider "aws" {
  region = "us-east-1"
}

# =============================================================================
# TEST VARIABLES
# =============================================================================
# Set default values for required variables used across all tests.
# These can be overridden in individual run blocks.

variables {
  # TODO: Add your required variables here with test values
  # Example:
  # bucket_name = "test-bucket-12345"
  # environment = "test"
}

# =============================================================================
# TEST 1: Resource Creation
# =============================================================================
# Verify the primary resource is created with expected attributes.

run "primary_resource_is_created" {
  command = plan

  assert {
    # TODO: Replace with your resource type and attribute
    # Example: condition = aws_s3_bucket.this.bucket != ""
    condition     = true  # Replace this!
    error_message = "Primary resource should be created"
  }
}

# =============================================================================
# TEST 2: Default Configuration
# =============================================================================
# Verify optional variables have sensible defaults.

run "default_configuration_is_correct" {
  command = plan

  # Don't override optional variables - test the defaults

  assert {
    # TODO: Test that default values work correctly
    # Example: condition = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    condition     = true  # Replace this!
    error_message = "Default configuration should be applied"
  }
}

# =============================================================================
# TEST 3: Tags Are Applied
# =============================================================================
# Verify required tags are present on resources.

run "required_tags_are_present" {
  command = plan

  assert {
    # TODO: Check that your tagging logic works
    # Example: condition = contains(keys(aws_s3_bucket.this.tags), "Environment")
    condition     = true  # Replace this!
    error_message = "Required tags should be present"
  }
}

# =============================================================================
# OPTIONAL: Test Variable Validation
# =============================================================================
# Verify that invalid input is rejected.
# Uncomment and customize if you have validation blocks.

# run "rejects_invalid_input" {
#   command = plan
#
#   variables {
#     # Provide invalid input that should fail validation
#     # Example: bucket_name = "ab"  # Too short
#   }
#
#   # Tell Terraform we EXPECT this to fail
#   expect_failures = [
#     var.bucket_name  # The variable that should fail validation
#   ]
# }

# =============================================================================
# OPTIONAL: Test Optional Features
# =============================================================================
# Verify optional features can be enabled/disabled.

# run "optional_feature_can_be_disabled" {
#   command = plan
#
#   variables {
#     enable_versioning = false
#   }
#
#   assert {
#     condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Suspended"
#     error_message = "Versioning should be suspended when disabled"
#   }
# }
