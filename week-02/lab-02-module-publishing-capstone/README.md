# Lab 02: Module Publishing Capstone

## Overview

This is your **capstone project** for the Terraform course. You will design, build, document, test, and **publish a reusable Terraform module to the public Terraform Registry**.

This is a real portfolio piece - anyone will be able to find and use your module at `registry.terraform.io/modules/YOUR-USERNAME/MODULE-NAME/aws`.

**Time**: 2 class sessions + homework  
**Cost**: Varies by module choice ($0 - $5)  
**Difficulty**: Advanced

---

## Learning Objectives

By the end of this lab, you will be able to:

- Design a module interface (inputs, outputs, resource composition)
- Write production-quality Terraform code with validation
- Generate documentation using `terraform-docs`
- Write Terraform native tests (`.tftest.hcl`)
- Publish a module to the Terraform Registry
- Create a portfolio artifact you can reference in job applications

---

## New Tools You'll Learn

This capstone introduces two important tools that professional Terraform developers use daily. Let's understand what they are before diving in.

### Tool 1: terraform-docs 📝

**What is it?**

`terraform-docs` is a utility that automatically generates documentation for your Terraform modules. Instead of manually writing and maintaining a README that lists all your variables, outputs, and requirements, `terraform-docs` reads your `.tf` files and generates beautiful, accurate documentation.

**Why does it matter?**

- **Consistency**: Every module's docs look the same
- **Accuracy**: Docs are generated from code, so they can't get out of sync
- **Time savings**: No manual documentation updates when you add a variable
- **Industry standard**: Most public modules use terraform-docs

**What does it produce?**

Running `terraform-docs markdown .` generates a README with:
- A table of all input variables (name, description, type, default, required)
- A table of all outputs (name, description)
- Provider requirements
- Module requirements

**Example output:**

```markdown
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket | `string` | n/a | yes |
| environment | Environment (dev/staging/prod) | `string` | `"dev"` | no |
| enable_versioning | Enable bucket versioning | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_arn | ARN of the created bucket |
| bucket_id | Name of the created bucket |
```

**Learn more:**
- [terraform-docs Official Site](https://terraform-docs.io/)
- [terraform-docs GitHub Repository](https://github.com/terraform-docs/terraform-docs)
- [Configuration Reference](https://terraform-docs.io/user-guide/configuration/)
- [Output Formats](https://terraform-docs.io/reference/terraform-docs/)

---

### Tool 2: Terraform Test Framework 🧪

**What is it?**

Terraform 1.6+ includes a **native testing framework** that lets you write tests for your modules using `.tftest.hcl` files. These tests validate that your module behaves correctly before you ship it.

**Why does it matter?**

- **Catch bugs early**: Find issues during development, not in production
- **Confidence to refactor**: Change code knowing tests will catch regressions
- **Documentation**: Tests show how your module is supposed to work
- **Professional practice**: Testing is expected in production codebases

**How does it work?**

You write test files with `run` blocks. Each `run` block:
1. Sets up variables
2. Runs either `plan` or `apply`
3. Checks assertions about the result

**Simple example:**

```hcl
# tests/basic.tftest.hcl

# Set variables for all tests in this file
variables {
  bucket_name = "test-bucket-12345"
  environment = "test"
}

# Test 1: Verify the bucket is created
run "bucket_is_created" {
  command = plan  # Just plan, don't actually create resources

  assert {
    condition     = aws_s3_bucket.this.bucket == "test-bucket-12345"
    error_message = "Bucket should be created with the specified name"
  }
}

# Test 2: Verify tags are applied
run "bucket_has_environment_tag" {
  command = plan

  assert {
    condition     = aws_s3_bucket.this.tags["Environment"] == "test"
    error_message = "Bucket should have Environment tag"
  }
}
```

**Running tests:**

```bash
$ terraform test

tests/basic.tftest.hcl... in progress
  run "bucket_is_created"... pass
  run "bucket_has_environment_tag"... pass
tests/basic.tftest.hcl... tearing down
tests/basic.tftest.hcl... pass

Success! 2 passed, 0 failed.
```

**Learn more:**
- [Terraform Test Documentation](https://developer.hashicorp.com/terraform/language/tests)
- [Write Terraform Tests Tutorial](https://developer.hashicorp.com/terraform/tutorials/configuration-language/test)
- [Test Command Reference](https://developer.hashicorp.com/terraform/cli/commands/test)
- [Testing Best Practices](https://developer.hashicorp.com/terraform/language/tests#best-practices)

---

## The Assignment

### Choose Your Domain

Pick **ONE** of the following AWS service categories and build a module for it:

| Category | Module Ideas | Complexity | Estimated Cost |
|----------|--------------|------------|----------------|
| **Compute** | EC2 instance with security group | ⭐⭐ | ~$0.01/hr (t3.micro) |
| **Compute** | Lambda function with IAM role | ⭐⭐ | $0.00 (free tier) |
| **Database** | DynamoDB table with optional GSI | ⭐ | $0.00 (on-demand) |
| **Database** | RDS MySQL/PostgreSQL instance | ⭐⭐⭐ | ~$0.02/hr (db.t3.micro) |
| **Network** | VPC with public subnet | ⭐⭐ | $0.00 |
| **Network** | Security group with dynamic rules | ⭐⭐ | $0.00 |
| **Storage** | S3 bucket with lifecycle rules | ⭐ | $0.00 |

> **Sandbox Reminder**: Stay within [AWS Academy sandbox constraints](../../../sandboxrules.txt): t3.micro/small for EC2, db.t3.micro/small for RDS, no Multi-AZ, no domain registration.

### Module Requirements

Your module **MUST** include:

#### 1. Standard File Structure
```
terraform-aws-<your-module>/
├── README.md              # Auto-generated by terraform-docs
├── main.tf                # Primary resources (2-5 resources minimum)
├── variables.tf           # At least 4 input variables
├── outputs.tf             # At least 3 outputs
├── versions.tf            # Required providers + Terraform version
└── tests/
    └── basic.tftest.hcl   # At least 3 passing tests
```

#### 2. Input Variables (minimum 4)
- At least **2 required** variables (no default)
- At least **2 optional** variables (with sensible defaults)
- All variables must have `description`
- All variables must have explicit `type`
- At least **1 variable** must have a `validation` block

#### 3. Resources (minimum 2)
- Create at least 2 related AWS resources
- Use `locals` for computed values or tag merging
- Follow the naming convention: use `this` for single resources of a type

#### 4. Outputs (minimum 3)
- Output the primary resource's ID
- Output the primary resource's ARN (if applicable)
- Output at least one other useful attribute
- All outputs must have `description`

#### 5. Documentation
- Generated `README.md` using `terraform-docs`
- Must include: description, usage example, inputs table, outputs table

#### 6. Tests (minimum 3)
- At least 3 `run` blocks in your test file
- Tests must use `command = plan` (no apply needed)
- Tests must all pass

---

## Module Ideas by Category

### Compute: `terraform-aws-ec2-webserver`

Create an EC2 instance configured as a basic web server.

**Resources:**
- `aws_instance` - The EC2 instance
- `aws_security_group` - Allow HTTP/HTTPS/SSH
- `aws_eip` (optional) - Elastic IP

**Variables:**
- `instance_name` (required) - Name tag for the instance
- `instance_type` (optional, default: "t3.micro") - Instance size
- `allowed_ssh_cidr` (required) - CIDR block allowed to SSH
- `enable_elastic_ip` (optional, default: false) - Whether to attach an EIP

**Outputs:**
- `instance_id`
- `public_ip`
- `security_group_id`

---

### Compute: `terraform-aws-lambda-function`

Create a Lambda function with proper IAM role.

**Resources:**
- `aws_lambda_function` - The function
- `aws_iam_role` - Execution role
- `aws_iam_role_policy_attachment` - Basic execution policy
- `aws_cloudwatch_log_group` - Log group for the function

**Variables:**
- `function_name` (required)
- `runtime` (optional, default: "python3.11")
- `handler` (optional, default: "index.handler")
- `timeout` (optional, default: 30)

**Outputs:**
- `function_arn`
- `function_name`
- `role_arn`
- `log_group_name`

---

### Database: `terraform-aws-dynamodb-table`

Create a DynamoDB table with optional Global Secondary Index.

**Resources:**
- `aws_dynamodb_table` - The table

**Variables:**
- `table_name` (required)
- `hash_key` (required) - Partition key name
- `hash_key_type` (optional, default: "S") - S, N, or B
- `enable_point_in_time_recovery` (optional, default: true)
- `tags` (optional)

**Outputs:**
- `table_id`
- `table_arn`
- `table_name`

---

### Database: `terraform-aws-rds-mysql`

Create an RDS MySQL instance (sandbox-safe).

**Resources:**
- `aws_db_instance` - The RDS instance
- `aws_db_subnet_group` - Subnet group
- `aws_security_group` - Database security group

**Variables:**
- `identifier` (required) - DB instance identifier
- `db_name` (required) - Initial database name
- `username` (required) - Master username
- `instance_class` (optional, default: "db.t3.micro")
- `allocated_storage` (optional, default: 20)
- `vpc_id` (required) - VPC to deploy into
- `subnet_ids` (required) - List of subnet IDs

**Outputs:**
- `endpoint`
- `port`
- `db_instance_id`

> ⚠️ **Note**: For the password, use `random_password` resource or accept it as a sensitive variable. Never hardcode!

---

### Network: `terraform-aws-vpc-simple`

Create a basic VPC with public subnet.

**Resources:**
- `aws_vpc` - The VPC
- `aws_subnet` - Public subnet
- `aws_internet_gateway` - Internet gateway
- `aws_route_table` - Route table with internet route
- `aws_route_table_association` - Associate subnet with route table

**Variables:**
- `vpc_name` (required)
- `vpc_cidr` (optional, default: "10.0.0.0/16")
- `public_subnet_cidr` (optional, default: "10.0.1.0/24")
- `availability_zone` (required)

**Outputs:**
- `vpc_id`
- `vpc_cidr`
- `public_subnet_id`
- `internet_gateway_id`

---

### Network: `terraform-aws-security-group`

Create a security group with dynamic ingress/egress rules.

**Resources:**
- `aws_security_group` - The security group (using `dynamic` blocks)

**Variables:**
- `name` (required)
- `description` (required)
- `vpc_id` (required)
- `ingress_rules` (required) - List of objects: `{port, protocol, cidr_blocks, description}`
- `tags` (optional)

**Outputs:**
- `security_group_id`
- `security_group_arn`
- `security_group_name`

> **Tip**: This is a great module for demonstrating `dynamic` blocks!

---

### Storage: `terraform-aws-s3-secure`

Create an S3 bucket with security best practices.

**Resources:**
- `aws_s3_bucket`
- `aws_s3_bucket_versioning`
- `aws_s3_bucket_server_side_encryption_configuration`
- `aws_s3_bucket_public_access_block`
- `aws_s3_bucket_lifecycle_configuration` (optional)

**Variables:**
- `bucket_name` (required)
- `enable_versioning` (optional, default: true)
- `enable_lifecycle_rules` (optional, default: false)
- `noncurrent_version_expiration_days` (optional, default: 90)
- `tags` (optional)

**Outputs:**
- `bucket_id`
- `bucket_arn`
- `bucket_domain_name`

---

## Timeline

### Class 1: Design & Build

**Before Class:**
- Review module ideas above
- Pick your module category
- Sketch out your variables, resources, and outputs

**In Class (2 hours):**
1. Create your GitHub repository with correct naming: `terraform-aws-<module-name>`
2. Build your module (main.tf, variables.tf, outputs.tf, versions.tf)
3. Test locally with `terraform init`, `validate`, `plan`
4. Get it working end-to-end

**Deliverable:** Working module that can be applied

### Homework: Documentation & Tests

**Between Classes (1-2 hours):**
1. Install terraform-docs (see guide below)
2. Generate README: `terraform-docs markdown . > README.md`
3. Write at least 3 tests in `tests/basic.tftest.hcl`
4. Run tests: `terraform test`
5. Push to GitHub

**Deliverable:** Module with README.md and passing tests

### Class 2: Publish & Demo

**In Class (1.5 hours):**
1. Connect GitHub to Terraform Registry
2. Create version tag: `git tag v1.0.0 && git push --tags`
3. Publish module to Registry
4. Verify module appears on registry.terraform.io
5. Demo: Show a classmate can use your module with `source = "your-username/module-name/aws"`
6. Update your portfolio to link to your published module

**Deliverable:** Published module on Terraform Registry

---

## Deep Dive: Using terraform-docs

### Installation

```bash
# macOS
brew install terraform-docs

# Linux / WSL (download binary)
curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.18.0/terraform-docs-v0.18.0-linux-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
sudo mv terraform-docs /usr/local/bin/

# Via Go (if you have Go installed)
go install github.com/terraform-docs/terraform-docs@latest

# Verify installation
terraform-docs --version
```

### Basic Usage

The simplest usage generates Markdown from your current directory:

```bash
# Generate markdown and print to stdout
terraform-docs markdown .

# Generate markdown and save to README.md
terraform-docs markdown . > README.md

# Generate markdown table format (most common)
terraform-docs markdown table . > README.md
```

### What terraform-docs Reads

terraform-docs parses your `.tf` files and extracts:

| From | What it extracts |
|------|------------------|
| `variables.tf` | Variable name, description, type, default, required status |
| `outputs.tf` | Output name, description, sensitive status |
| `versions.tf` | Required Terraform version, required providers |
| `main.tf` | Resources and data sources used |

**This is why good descriptions matter!** Whatever you write in `description` shows up in your docs:

```hcl
# This description becomes your documentation
variable "bucket_name" {
  description = "Name of the S3 bucket. Must be globally unique."
  type        = string
}
```

### Customizing Output

You can create a `.terraform-docs.yml` file to customize the output:

```yaml
# .terraform-docs.yml
formatter: "markdown table"

sections:
  show:
    - header
    - inputs
    - outputs
    - providers
    - requirements

content: |-
  {{ .Header }}

  ## Usage

  ```hcl
  module "example" {
    source  = "your-username/module-name/aws"
    version = "1.0.0"

    bucket_name = "my-bucket"
  }
  ```

  {{ .Requirements }}
  {{ .Providers }}
  {{ .Inputs }}
  {{ .Outputs }}
```

Then just run:

```bash
terraform-docs .  # It will find the config file automatically
```

### Documentation References

- [terraform-docs Installation](https://terraform-docs.io/user-guide/installation/)
- [Configuration File](https://terraform-docs.io/user-guide/configuration/)
- [Available Formatters](https://terraform-docs.io/reference/terraform-docs/)
- [Content Template](https://terraform-docs.io/user-guide/configuration/content/)

---

## Deep Dive: Writing Terraform Tests

### Test File Location

Tests live in a `tests/` directory in your module root:

```
terraform-aws-my-module/
├── main.tf
├── variables.tf
├── outputs.tf
└── tests/
    ├── basic.tftest.hcl      # Basic functionality tests
    └── validation.tftest.hcl  # Input validation tests (optional)
```

### Anatomy of a Test File

```hcl
# tests/basic.tftest.hcl

# ============================================
# PROVIDER CONFIGURATION (required for AWS)
# ============================================
provider "aws" {
  region = "us-east-1"
}

# ============================================
# GLOBAL VARIABLES
# ============================================
# These apply to all run blocks unless overridden
variables {
  bucket_name = "test-bucket-abc123"
  environment = "test"
}

# ============================================
# TEST: Resource Creation
# ============================================
run "bucket_is_created" {
  # Use 'plan' to test without creating real resources
  command = plan

  # Assert checks a condition and fails if false
  assert {
    condition     = aws_s3_bucket.this.bucket == "test-bucket-abc123"
    error_message = "Bucket name should match the input variable"
  }
}

# ============================================
# TEST: Default Values
# ============================================
run "versioning_enabled_by_default" {
  command = plan

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning should be enabled by default"
  }
}

# ============================================
# TEST: Tags
# ============================================
run "required_tags_are_applied" {
  command = plan

  assert {
    condition     = aws_s3_bucket.this.tags["Environment"] == "test"
    error_message = "Environment tag should be set"
  }

  # You can have multiple asserts in one run block
  assert {
    condition     = contains(keys(aws_s3_bucket.this.tags), "ManagedBy")
    error_message = "ManagedBy tag should be present"
  }
}
```

### The `command` Option

| Command | What it does | Use when |
|---------|--------------|----------|
| `plan` | Runs `terraform plan` only | Most tests - fast, no resources created |
| `apply` | Runs `terraform apply` | Integration tests that need real resources |

**Recommendation:** Use `command = plan` for this capstone. It's fast and doesn't cost money.

### Writing Good Assertions

**Check equality:**
```hcl
condition = aws_instance.this.instance_type == "t3.micro"
```

**Check a value is not empty:**
```hcl
condition = aws_s3_bucket.this.arn != ""
```

**Check a string contains something:**
```hcl
condition = strcontains(aws_s3_bucket.this.bucket, "prod")
```

**Check a key exists in a map:**
```hcl
condition = contains(keys(aws_s3_bucket.this.tags), "Environment")
```

**Check a list has items:**
```hcl
condition = length(aws_security_group.this.ingress) > 0
```

**Combine conditions (AND):**
```hcl
condition = aws_instance.this.instance_type == "t3.micro" && aws_instance.this.tags["Environment"] == "dev"
```

**Safe navigation with try():**
```hcl
# Won't crash if the path doesn't exist
condition = try(aws_s3_bucket_versioning.this.versioning_configuration[0].status, "") == "Enabled"
```

### Testing Variable Validation

You can test that your validation blocks work correctly:

```hcl
run "rejects_invalid_bucket_name" {
  command = plan

  variables {
    bucket_name = "ab"  # Too short - should fail validation
  }

  # Tell Terraform we EXPECT this to fail
  expect_failures = [
    var.bucket_name
  ]
}
```

### Running Tests

```bash
# Run all tests
terraform test

# Run with verbose output (shows each assertion)
terraform test -verbose

# Run only tests in a specific file
terraform test -filter=tests/basic.tftest.hcl

# Run tests and show the plan output
terraform test -verbose
```

### Expected Output

```
$ terraform test

tests/basic.tftest.hcl... in progress
  run "bucket_is_created"... pass
  run "versioning_enabled_by_default"... pass
  run "required_tags_are_applied"... pass
tests/basic.tftest.hcl... tearing down
tests/basic.tftest.hcl... pass

Success! 3 passed, 0 failed.
```

### Documentation References

- [Terraform Tests Overview](https://developer.hashicorp.com/terraform/language/tests)
- [Tests Tutorial](https://developer.hashicorp.com/terraform/tutorials/configuration-language/test)
- [Test Command Reference](https://developer.hashicorp.com/terraform/cli/commands/test)
- [Assertions Reference](https://developer.hashicorp.com/terraform/language/tests#assertions)
- [Testing Best Practices](https://developer.hashicorp.com/terraform/language/tests#best-practices)

---

## Step-by-Step: Publishing to the Registry

### Step 1: Create GitHub Repository

Your repository **must** follow this naming convention:

```
terraform-<PROVIDER>-<NAME>
```

Examples:
- `terraform-aws-ec2-webserver`
- `terraform-aws-dynamodb-table`
- `terraform-aws-vpc-simple`

> ⚠️ The registry will reject repositories that don't match this pattern!

Create the repo on GitHub:
1. Go to github.com → New Repository
2. Name: `terraform-aws-<your-module-name>`
3. Public (required for registry)
4. Initialize with README: No (you'll generate this)
5. Create repository

Clone and add your code:
```bash
git clone git@github.com:YOUR-USERNAME/terraform-aws-<module-name>.git
cd terraform-aws-<module-name>

# Copy your module files here
# main.tf, variables.tf, outputs.tf, versions.tf, tests/
```

### Step 2: Generate Documentation

```bash
# Generate your README
terraform-docs markdown table . > README.md

# Edit README.md to add a usage example at the top
# (The generated content will be below your custom intro)
```

**Recommended README structure:**

```markdown
# terraform-aws-<your-module>

Brief description of what this module creates.

## Usage

```hcl
module "example" {
  source  = "YOUR-USERNAME/<module-name>/aws"
  version = "1.0.0"

  # Required variables
  name = "my-resource"

  # Optional variables
  environment = "prod"
}
```

<!-- Everything below is auto-generated by terraform-docs -->

## Requirements
...

## Inputs
...

## Outputs
...
```

### Step 3: Write and Run Tests

```bash
# Create tests directory
mkdir -p tests

# Create your test file (use the template in starter-templates/)
# Edit tests/basic.tftest.hcl

# Run tests
terraform test
```

### Step 4: Create versions.tf

```hcl
# versions.tf

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}
```

### Step 5: Commit and Tag

```bash
git add .
git commit -m "Initial module release"
git push origin main

# Create a semantic version tag
git tag v1.0.0
git push --tags
```

### Step 6: Connect to Terraform Registry

1. Go to [registry.terraform.io](https://registry.terraform.io/)
2. Click "Sign In" → Sign in with GitHub
3. Click "Publish" → "Module"
4. Select your repository from the list
5. Click "Publish Module"

The registry will:
- Validate your repository name follows the pattern
- Check for required files (main.tf, etc.)
- Parse your version tags
- Generate documentation from your code

### Step 7: Verify Publication

Your module should now be live at:
```
https://registry.terraform.io/modules/YOUR-USERNAME/<module-name>/aws/latest
```

Test that someone can use it:
```hcl
module "test" {
  source  = "YOUR-USERNAME/<module-name>/aws"
  version = "1.0.0"

  # ... variables
}
```

---

## Grading Rubric

See [RUBRIC.md](./RUBRIC.md) for detailed grading criteria.

| Category | Points |
|----------|--------|
| Module Structure & Code Quality | 25 |
| Variables & Validation | 20 |
| Resources & Outputs | 20 |
| Documentation (terraform-docs) | 15 |
| Tests (terraform test) | 15 |
| Registry Publication | 5 |
| **Total** | **100** |

---

## Submission

Your submission consists of:

1. **GitHub Repository URL**: `github.com/YOUR-USERNAME/terraform-aws-<module-name>`
2. **Terraform Registry URL**: `registry.terraform.io/modules/YOUR-USERNAME/<module-name>/aws`
3. **Brief Write-up** (in your PR or SUBMISSION.md):
   - What module did you build and why?
   - What was the hardest part?
   - What would you add in v2.0.0?

Create a PR to this repo with a `SUBMISSION.md` file in `week-02/lab-02-module-publishing-capstone/submissions/YOUR-NAME/`:

```
week-02/lab-02-module-publishing-capstone/
└── submissions/
    └── YOUR-NAME/
        └── SUBMISSION.md
```

---

## Resources

### Terraform Registry
- [Publishing Modules](https://developer.hashicorp.com/terraform/registry/modules/publish)
- [Module Requirements](https://developer.hashicorp.com/terraform/registry/modules/publish#requirements)
- [Version Constraints](https://developer.hashicorp.com/terraform/language/modules/syntax#version)

### terraform-docs
- [Official Website](https://terraform-docs.io/)
- [GitHub Repository](https://github.com/terraform-docs/terraform-docs)
- [Installation Guide](https://terraform-docs.io/user-guide/installation/)
- [Configuration Reference](https://terraform-docs.io/user-guide/configuration/)
- [Available Formatters](https://terraform-docs.io/reference/terraform-docs/)

### Terraform Testing
- [Tests Overview](https://developer.hashicorp.com/terraform/language/tests)
- [Write Tests Tutorial](https://developer.hashicorp.com/terraform/tutorials/configuration-language/test)
- [Test Command](https://developer.hashicorp.com/terraform/cli/commands/test)
- [Assertions](https://developer.hashicorp.com/terraform/language/tests#assertions)
- [Best Practices](https://developer.hashicorp.com/terraform/language/tests#best-practices)

### Module Best Practices
- [Module Creation - Recommended Pattern](https://developer.hashicorp.com/terraform/tutorials/modules/pattern-module-creation)
- [Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)
- [Module Composition](https://developer.hashicorp.com/terraform/language/modules/develop/composition)

---

## FAQ

**Q: Can I build something not on the list?**
A: Yes! As long as it meets the minimum requirements (2+ resources, 4+ variables, 3+ outputs, 3+ tests) and stays within sandbox constraints.

**Q: What if my module costs money?**
A: Use `terraform plan` to validate without creating resources. Only `apply` briefly to verify it works, then `destroy` immediately. Most modules can be validated with just `plan`, and that's all the tests require.

**Q: Can I work with a partner?**
A: No, this is an individual capstone. However, you can review each other's code and help debug.

**Q: What if the Registry rejects my module?**
A: Common issues:
- Repository name doesn't match `terraform-<PROVIDER>-<NAME>` pattern
- No version tags (must be `v1.0.0` format)
- Missing required files
- Repository is private (must be public)

**Q: How long does publishing take?**
A: Usually instant. The registry webhooks respond to new tags within seconds.

**Q: Do I need to run `terraform apply` for my tests?**
A: No! Using `command = plan` is sufficient for this capstone. The tests validate your configuration without creating real resources.

**Q: What if terraform-docs isn't generating my variable descriptions?**
A: Make sure every variable has a `description` field. terraform-docs can only document what you describe!

---

## Portfolio Value

After completing this lab, you can add to your resume/LinkedIn:

> **Published Terraform Module** - Designed, tested, and published a reusable Terraform module to the HashiCorp Terraform Registry. Module includes input validation, automated documentation, and native Terraform tests.
>
> 🔗 registry.terraform.io/modules/username/module-name/aws

This demonstrates:
- Infrastructure as Code expertise
- Understanding of module design patterns
- Documentation discipline
- Testing practices
- Ability to publish professional-grade open source work
