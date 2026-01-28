# Lab 01: Drift Detection & Resolution

## Overview

"Drift" occurs when infrastructure changes outside of Terraform - someone clicks in the console, runs an AWS CLI command, or another tool modifies resources. In this lab, you'll learn to detect drift, understand its implications, and resolve it safely.

**Time**: 2 hours  
**Cost**: $0.00 (S3 buckets only)  
**Difficulty**: Intermediate

---

## Learning Objectives

By the end of this lab, you will be able to:

- Explain what drift is and why it matters
- Detect drift using `terraform plan`
- Understand the refresh phase of Terraform operations
- Use `terraform plan -refresh-only` to see drift without planning changes
- Use `terraform apply -refresh-only` to accept drift into state
- Choose between "revert to config" vs "accept drift" strategies
- Implement practices to prevent drift

---

## Prerequisites

- Completed Week 02 Lab 00
- Terraform >= 1.9.0
- AWS credentials configured
- AWS Console access (to make manual changes)

---

## Part 1: Setup (15 min)

### 1.1 Create Working Directory

```bash
cd week-02/lab-01
mkdir -p student-work
cd student-work
```

### 1.2 Create Configuration

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

  backend "s3" {
    bucket       = "YOUR-STATE-BUCKET-NAME"
    key          = "week-02/lab-01/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Course       = "terraform-course"
      Week         = "02"
      Lab          = "01"
      AutoTeardown = "24h"
    }
  }
}
```

Create `variables.tf`:

```hcl
variable "student_name" {
  description = "Your name or identifier"
  type        = string
}
```

Create `drift_bucket.tf`:

```hcl
resource "aws_s3_bucket" "drift_test" {
  bucket = "tf-drift-lab-${var.student_name}"

  tags = {
    Name        = "Drift Test Bucket"
    Environment = "dev"
    Purpose     = "Drift detection lab"
  }
}

resource "aws_s3_bucket_versioning" "drift_test" {
  bucket = aws_s3_bucket.drift_test.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "drift_test" {
  bucket = aws_s3_bucket.drift_test.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

Create `outputs.tf`:

```hcl
output "bucket_name" {
  value = aws_s3_bucket.drift_test.id
}

output "bucket_arn" {
  value = aws_s3_bucket.drift_test.arn
}
```

Create `terraform.tfvars`:

```hcl
student_name = "YOUR-NAME-HERE"
```

### 1.3 Deploy

```bash
terraform init
terraform apply
```

**Checkpoint**: One S3 bucket with versioning disabled.

---

## Part 2: Understanding the Refresh Phase (15 min)

Before we create drift, let's understand how Terraform detects it.

### 2.1 What Happens During Plan?

When you run `terraform plan`, Terraform:

1. **Reads state** - What does Terraform think exists?
2. **Refreshes** - Queries AWS for actual current state
3. **Compares** - Finds differences between config, state, and reality
4. **Plans** - Proposes changes to make reality match config

### 2.2 Observe a Normal Plan

```bash
terraform plan
```

**Expected**: "No changes. Your infrastructure matches the configuration."

This means:
- State matches reality (refresh found no drift)
- Config matches state (no changes to apply)

### 2.3 Skip Refresh (Not Recommended)

You can skip the refresh phase:

```bash
terraform plan -refresh=false
```

⚠️ **Warning**: This is dangerous in production! You might miss drift.

---

## Part 3: Creating and Detecting Tag Drift (25 min)

Let's simulate a common scenario: someone adds a tag via the AWS Console.

### 3.1 Add a Tag in AWS Console

1. Open the [S3 Console](https://s3.console.aws.amazon.com/s3/buckets)
2. Find your bucket (`tf-drift-lab-YOUR-NAME`)
3. Go to **Properties** → **Tags**
4. Click **Edit** and add a tag:
   - Key: `AddedManually`
   - Value: `true`
5. Save changes

### 3.2 Detect the Drift

```bash
terraform plan
```

**Observe the output carefully:**

```
Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the
last "terraform apply" which may have affected this plan:

  # aws_s3_bucket.drift_test has changed
  ~ resource "aws_s3_bucket" "drift_test" {
        id                          = "tf-drift-lab-your-name"
      ~ tags                        = {
          + "AddedManually" = "true"
            # (3 unchanged elements hidden)
        }
      ~ tags_all                    = {
          + "AddedManually" = "true"
            # (7 unchanged elements hidden)
        }
        # (8 unchanged attributes hidden)
    }
```

Terraform shows:
- `~` = Changed outside of Terraform
- `+` = New tag added

### 3.3 Understand Your Options

You have two choices:

**Option A: Revert to Config** (remove the manual tag)
```bash
terraform apply
```
This will remove the `AddedManually` tag because it's not in your config.

**Option B: Accept the Drift** (update state to match reality)
```bash
terraform apply -refresh-only
```
This will update state to include the tag, but your config still won't have it.

### 3.4 Let's Try Option A First

```bash
terraform apply
```

Check the console - the `AddedManually` tag is gone.

---

## Part 4: Configuration Drift (30 min)

Tag drift is minor. Let's try something more significant.

### 4.1 Enable Versioning in Console

1. Go to your S3 bucket in the console
2. Go to **Properties** → **Bucket Versioning**
3. Click **Edit**
4. Select **Enable**
5. Save changes

### 4.2 Detect the Drift

```bash
terraform plan
```

**Observe**:

```
  # aws_s3_bucket_versioning.drift_test has changed
  ~ resource "aws_s3_bucket_versioning" "drift_test" {
        id     = "tf-drift-lab-your-name"
      ~ versioning_configuration {
          ~ status = "Enabled" -> "Disabled"
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

Terraform wants to **disable** versioning because your config says `status = "Disabled"`.

### 4.3 Decide: Revert or Accept?

**Scenario A**: The console change was a mistake → Revert

```bash
terraform apply  # This will disable versioning
```

**Scenario B**: The console change was intentional → Accept and update config

First, see what the drift looks like without planning config changes:

```bash
terraform plan -refresh-only
```

This shows drift without proposing to change anything.

Accept the drift into state:

```bash
terraform apply -refresh-only
```

Now update your config to match (`drift_bucket.tf`):

```hcl
resource "aws_s3_bucket_versioning" "drift_test" {
  bucket = aws_s3_bucket.drift_test.id

  versioning_configuration {
    status = "Enabled"  # Changed from "Disabled"
  }
}
```

Verify:

```bash
terraform plan
```

**Expected**: No changes.

---

## Part 5: Destructive Drift (25 min)

What happens when someone deletes a resource outside Terraform?

### 5.1 Delete Bucket Versioning Config in Console

Actually, let's do something simpler - delete a tag we're managing:

1. Go to your bucket in console
2. Go to **Properties** → **Tags**
3. Remove the `Purpose` tag (keep the others)
4. Save

### 5.2 Detect

```bash
terraform plan
```

**Observe**: Terraform wants to ADD the `Purpose` tag back.

### 5.3 More Serious: Delete the Bucket

⚠️ **For demonstration only** - we'll recreate it.

1. Go to AWS Console
2. Empty the bucket (if it has objects)
3. Delete the bucket

### 5.4 See What Terraform Does

```bash
terraform plan
```

**Observe**: Terraform wants to CREATE the bucket because it's in config but doesn't exist.

### 5.5 Recreate

```bash
terraform apply
```

The bucket is recreated with all configured settings.

---

## Part 6: Best Practices (15 min)

### 6.1 Preventing Drift

| Practice | Description |
|----------|-------------|
| **No Console Changes** | All changes through Terraform |
| **Read-Only Console Access** | Give most users read-only AWS access |
| **Drift Detection Jobs** | Run `terraform plan` in CI on a schedule |
| **PR Reviews** | Require approval for infrastructure changes |
| **Tagging Policy** | Enforce `ManagedBy = Terraform` tags |

### 6.2 Handling Drift When It Happens

```
Drift Detected
     │
     ▼
Was it intentional?
     │
  ┌──┴──┐
  │     │
  ▼     ▼
 No    Yes
  │     │
  ▼     ▼
terraform apply     terraform apply -refresh-only
(revert to config)  then update config
```

### 6.3 Document Your Decision

When you resolve drift, document:
1. What drifted and how it was detected
2. Why the drift occurred
3. How you resolved it (revert or accept)
4. What you'll do to prevent it

---

## Part 7: Cleanup (10 min)

```bash
terraform destroy
```

---

## Submission

Create a PR with:

1. Your completed `student-work/` directory
2. A `NOTES.md` file answering:
   - What is drift and why does it matter?
   - What's the difference between `terraform plan` and `terraform plan -refresh-only`?
   - When would you use `apply -refresh-only`?
   - Describe a real scenario where drift might occur in a production environment
   - What practices would you implement to prevent drift?

---

## Common Mistakes

1. **Ignoring drift warnings** - Always investigate "Objects have changed outside of Terraform"
2. **Using `-refresh=false` in production** - You'll miss drift
3. **Not updating config after accepting drift** - State and config will diverge
4. **Panicking about drift** - It's normal and manageable; just have a process

---

## Stretch Goals

If you finish early:

1. **Scheduled Drift Detection**: Write a GitHub Action that runs `terraform plan` daily
2. **Drift Alerting**: How would you alert on drift? (Hint: exit codes)
3. **Import as Drift Resolution**: What if someone creates a resource manually that you want to manage?

---

## Resources

- [Refresh Command](https://developer.hashicorp.com/terraform/cli/commands/refresh)
- [Plan -refresh-only](https://developer.hashicorp.com/terraform/cli/commands/plan#refresh-only-mode)
- [Apply -refresh-only](https://developer.hashicorp.com/terraform/cli/commands/apply#refresh-only-mode)
- [Manage Resource Drift](https://developer.hashicorp.com/terraform/tutorials/state/resource-drift)
