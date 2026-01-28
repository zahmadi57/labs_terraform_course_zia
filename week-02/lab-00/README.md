# Lab 00: State Operations

## Overview

In this lab, you'll work with Terraform state directly. You'll learn to inspect state, move resources, and use the declarative `moved` and `removed` blocks for safe refactoring.

**Time**: 2-3 hours  
**Cost**: $0.00 (S3 buckets only)  
**Difficulty**: Intermediate

---

## Learning Objectives

By the end of this lab, you will be able to:

- Inspect resources using `terraform state list` and `terraform state show`
- Move/rename resources using `terraform state mv`
- Remove resources from state using `terraform state rm`
- Use `moved` blocks for declarative refactoring
- Use `removed` blocks to cleanly remove resources from state

---

## Prerequisites

- Completed Week 00 and Week 01 labs
- Terraform >= 1.9.0
- AWS credentials configured
- Existing S3 state bucket from Week 00

---

## Part 1: Setup - Create Resources to Manage (20 min)

First, let's create some infrastructure that we'll manipulate throughout this lab.

### 1.1 Create Working Directory

```bash
cd week-02/lab-00
mkdir -p student-work
cd student-work
```

### 1.2 Create Initial Configuration

Create `main.tf`:

```hcl
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Use your existing state bucket from Week 00
  backend "s3" {
    bucket       = "YOUR-STATE-BUCKET-NAME"
    key          = "week-02/lab-00/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Course      = "terraform-course"
      Week        = "02"
      Lab         = "00"
      AutoTeardown = "24h"
    }
  }
}
```

Create `variables.tf`:

```hcl
variable "student_name" {
  description = "Your name or identifier (used in resource names)"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
```

Create `buckets.tf`:

```hcl
# We'll create several buckets to practice state operations
resource "aws_s3_bucket" "data" {
  bucket = "tf-state-lab-${var.student_name}-data-${var.environment}"
}

resource "aws_s3_bucket" "logs" {
  bucket = "tf-state-lab-${var.student_name}-logs-${var.environment}"
}

resource "aws_s3_bucket" "backup" {
  bucket = "tf-state-lab-${var.student_name}-backup-${var.environment}"
}
```

Create `outputs.tf`:

```hcl
output "data_bucket_name" {
  description = "Name of the data bucket"
  value       = aws_s3_bucket.data.id
}

output "logs_bucket_name" {
  description = "Name of the logs bucket"
  value       = aws_s3_bucket.logs.id
}

output "backup_bucket_name" {
  description = "Name of the backup bucket"
  value       = aws_s3_bucket.backup.id
}
```

Create `terraform.tfvars`:

```hcl
student_name = "YOUR-NAME-HERE"
environment  = "dev"
```

### 1.3 Deploy Initial Infrastructure

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

**Checkpoint**: You should have 3 S3 buckets created.

---

## Part 2: Inspecting State (20 min)

Now let's explore what's in our state file.

### 2.1 List All Resources

```bash
terraform state list
```

**Expected output:**
```
aws_s3_bucket.backup
aws_s3_bucket.data
aws_s3_bucket.logs
```

### 2.2 Show Resource Details

Pick a resource and inspect it:

```bash
terraform state show aws_s3_bucket.data
```

**Questions to answer** (write answers in your notes):
1. What is the bucket's ARN?
2. What region is it in?
3. What is the `id` attribute?
4. Are there any tags beyond the default tags?

### 2.3 Pull Full State (Advanced)

You can dump the entire state as JSON:

```bash
terraform state pull | head -50
```

Or use `jq` for specific queries:

```bash
terraform state pull | jq '.resources[] | .type + "." + .name'
```

---

## Part 3: Moving Resources in State (30 min)

### Scenario

Your team has decided to rename resources to follow a new naming convention: `bucket_data` instead of `data`.

### 3.1 The Wrong Way (Don't Do This!)

If you just rename the resource in your `.tf` file without updating state, Terraform will:
1. Plan to **destroy** the old resource
2. Plan to **create** a new resource

This would delete your data! Let's see this (but not apply it):

In `buckets.tf`, rename `aws_s3_bucket.data` to `aws_s3_bucket.bucket_data`. Then run:

```bash
terraform plan
```

**Observe**: Terraform wants to destroy and recreate. This is dangerous!

**Revert your change** - put the resource name back to `data`.

### 3.2 The Right Way: state mv (Dry Run First!)

First, always do a dry run:

```bash
terraform state mv -dry-run aws_s3_bucket.data aws_s3_bucket.bucket_data
```

If that looks correct, do the actual move:

```bash
terraform state mv aws_s3_bucket.data aws_s3_bucket.bucket_data
```

### 3.3 Update Configuration to Match

Now update `buckets.tf` to match the new state:

```hcl
# Changed from: resource "aws_s3_bucket" "data"
resource "aws_s3_bucket" "bucket_data" {
  bucket = "tf-state-lab-${var.student_name}-data-${var.environment}"
}
```

Update `outputs.tf` as well:

```hcl
output "data_bucket_name" {
  description = "Name of the data bucket"
  value       = aws_s3_bucket.bucket_data.id  # Changed reference
}
```

### 3.4 Verify No Changes

```bash
terraform plan
```

**Expected**: "No changes. Your infrastructure matches the configuration."

🎉 You successfully renamed a resource without destroying it!

---

## Part 4: Using Moved Blocks (Better Way!) (30 min)

The `moved` block is the modern, declarative way to refactor. It's safer because it's version controlled and works across team members.

### 4.1 Set Up Another Rename

Let's rename `aws_s3_bucket.logs` to `aws_s3_bucket.bucket_logs` using a `moved` block.

Add to `buckets.tf`:

```hcl
# Declare the move
moved {
  from = aws_s3_bucket.logs
  to   = aws_s3_bucket.bucket_logs
}

# Update the resource name
resource "aws_s3_bucket" "bucket_logs" {
  bucket = "tf-state-lab-${var.student_name}-logs-${var.environment}"
}
```

Update `outputs.tf`:

```hcl
output "logs_bucket_name" {
  description = "Name of the logs bucket"
  value       = aws_s3_bucket.bucket_logs.id  # Changed reference
}
```

### 4.2 Plan and Apply

```bash
terraform plan
```

**Observe**: The plan shows the resource will be moved, not destroyed/recreated.

```bash
terraform apply
```

### 4.3 Verify

```bash
terraform state list
```

You should see `aws_s3_bucket.bucket_logs` instead of `aws_s3_bucket.logs`.

### 4.4 Clean Up the Moved Block

After applying, you can remove the `moved` block from your configuration. It's served its purpose.

---

## Part 5: Using Removed Blocks (30 min)

### Scenario

You decide the backup bucket is no longer needed by Terraform (maybe another team will manage it), but you don't want to destroy the actual bucket.

### 5.1 The Wrong Way

If you just delete the resource from your `.tf` file, Terraform will plan to destroy the bucket!

### 5.2 The Right Way: removed Block

Add to `buckets.tf`:

```hcl
removed {
  from = aws_s3_bucket.backup
  
  lifecycle {
    destroy = false  # Keep the infrastructure, just remove from state
  }
}
```

Delete the original resource block for `aws_s3_bucket.backup` and its output.

### 5.3 Apply

```bash
terraform plan
```

**Observe**: The plan shows the resource will be "forgotten" but not destroyed.

```bash
terraform apply
```

### 5.4 Verify

```bash
terraform state list
```

The backup bucket is no longer in state, but check the AWS console - the bucket still exists!

### 5.5 (Optional) Destroy with Removed Block

If you wanted to actually destroy the resource while using a `removed` block, you would set:

```hcl
removed {
  from = aws_s3_bucket.backup
  
  lifecycle {
    destroy = true  # Actually destroy the resource
  }
}
```

---

## Part 6: State rm Command (15 min)

Let's practice the imperative approach to removing from state.

### 6.1 Create a Temporary Resource

Add to `buckets.tf`:

```hcl
resource "aws_s3_bucket" "temp" {
  bucket = "tf-state-lab-${var.student_name}-temp-${var.environment}"
}
```

```bash
terraform apply
```

### 6.2 Remove from State

```bash
terraform state rm aws_s3_bucket.temp
```

### 6.3 Observe the Result

```bash
terraform state list  # temp bucket is gone from state
terraform plan        # Terraform wants to CREATE the resource (it exists but TF doesn't know)
```

### 6.4 Clean Up

The bucket still exists in AWS! Options:

**Option A**: Delete manually in AWS Console, then remove the resource from your `.tf` file

**Option B**: Run `terraform apply` to bring it back under management, then `terraform destroy`

For this lab, let's go with Option A - delete it from the console and remove the resource block.

---

## Part 7: Cleanup (10 min)

### 7.1 Final State Check

```bash
terraform state list
```

You should have:
- `aws_s3_bucket.bucket_data`
- `aws_s3_bucket.bucket_logs`

### 7.2 Destroy

```bash
terraform destroy
```

---

## Submission

Create a PR with:

1. Your completed `student-work/` directory
2. A `NOTES.md` file answering:
   - What's the difference between `terraform state mv` and a `moved` block?
   - When would you use `terraform state rm` vs a `removed` block?
   - What happens to infrastructure when you remove it from state?
   - Describe a real scenario where you'd need to use `moved` blocks.

---

## Common Mistakes

1. **Forgetting to update config after `state mv`** - State and config must match
2. **Using `state rm` when you mean `destroy`** - `state rm` doesn't delete infrastructure!
3. **Not using dry-run** - Always use `-dry-run` before `state mv`
4. **Leaving `moved` blocks forever** - Remove them after they've been applied everywhere

---

## Stretch Goals

If you finish early:

1. **Module Refactor**: Try moving a resource INTO a module using `moved` blocks
2. **State Pull/Push**: Experiment with `terraform state pull` and `terraform state push` (carefully!)
3. **Multiple Moves**: Chain multiple `moved` blocks in one apply

---

## Resources

- [State Command Reference](https://developer.hashicorp.com/terraform/cli/commands/state)
- [Moved Blocks](https://developer.hashicorp.com/terraform/language/moved)
- [Removed Blocks](https://developer.hashicorp.com/terraform/language/removed)
