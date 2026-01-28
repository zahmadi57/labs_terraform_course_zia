# Week 02 Discovery Quiz - Instructor Answer Key

## Part 1: State Fundamentals

### 1.1
**Answer**: 
1. To determine the correct order to destroy/create resources (dependency order)
2. For performance - to avoid querying every resource on every plan (caching)

Also accept: Mapping configuration to real resources, tracking resource metadata

### 1.2
**Answer**: `terraform.tfstate` file in the current working directory (local backend)

### 1.3
**Answer**: Any two of:
- Database passwords
- API keys/tokens
- Private keys
- Initial passwords for resources
- Any sensitive attribute marked in the provider schema

---

## Part 2: Backend Configuration

### 2.1
**Answer**: `use_lockfile = true`

### 2.2
**Answer**: S3 Object Lock with versioning enabled

Note: The bucket must have Object Lock configured.

### 2.3
**Answer**: Terraform will wait and retry, then eventually fail with a lock acquisition error. It will show who holds the lock and when it was acquired.

### 2.4
**Answer**: `-migrate-state`

Full command: `terraform init -migrate-state`

---

## Part 3: State CLI Commands

### 3.1
**Answer**: `-dry-run`

Full command: `terraform state mv -dry-run SOURCE DESTINATION`

### 3.2
**Answer**: Nothing - the infrastructure continues to exist unchanged. It's just no longer tracked by Terraform.

This is a critical concept - `state rm` doesn't destroy infrastructure!

### 3.3
**Answer**: `terraform state list`

### 3.4
**Answer**: `terraform state show <resource_address>`

Example: `terraform state show aws_s3_bucket.example`

---

## Part 4: Moved and Removed Blocks

### 4.1
**Answer**:
1. `from` - the old resource address
2. `to` - the new resource address

### 4.2
**Answer**: Remove the `moved` block from your configuration after the move has been applied to all environments.

Note: You can optionally keep it for documentation, but it's typically removed.

### 4.3
**Answer**: 
- `terraform state rm` is imperative (run once, done)
- `removed` block is declarative (stays in config, can be version controlled, applied across environments)

Also accept: `removed` block allows setting `destroy = true` to also destroy the resource.

### 4.4
**Answer**: `destroy = true`

```hcl
removed {
  from = aws_s3_bucket.old_bucket
  lifecycle {
    destroy = true
  }
}
```

---

## Part 5: Troubleshooting

### 5.1
**Answer**: 
- Command: `terraform force-unlock LOCK_ID`
- When to use: Only when you're certain no other operation is running AND the lock is orphaned (e.g., a process crashed)

⚠️ Emphasize danger: Force-unlocking while another apply is running can corrupt state!

### 5.2
**Answer**: 
- Detected by: `terraform plan` (during the refresh phase)
- Options: 
  1. Run `terraform apply` to update infrastructure to match config
  2. Run `terraform apply -refresh-only` to update state to match infrastructure
  3. Manually revert the external changes

### 5.3
**Answer**: `TF_LOG` (set to DEBUG, TRACE, INFO, WARN, or ERROR)

For state-specific debugging, `TF_LOG=DEBUG` is usually sufficient.

---

## Part 6: Practical Exploration

### 6.1
**Answer**: 
- Outputs the current state as JSON to stdout
- Uses: Backup state, inspect state programmatically, pipe to other tools (like `jq`), troubleshooting

### 6.2
**Answer**: `terraform_version`

The state file structure includes:
```json
{
  "version": 4,
  "terraform_version": "1.9.0",
  "serial": 1,
  ...
}
```

### 6.3
**Answer**: `profile = "profile-name"`

```hcl
backend "s3" {
  bucket  = "my-state-bucket"
  key     = "terraform.tfstate"
  region  = "us-east-1"
  profile = "my-aws-profile"
}
```

---

## Grading Notes

- Grade on effort and completion, not exact answers
- Look for evidence that students explored the documentation
- Partial credit for reasonable answers that show understanding
- Full credit if they attempted all questions and showed their work

## Common Mistakes to Watch For

1. **Confusing `state rm` with `destroy`** - Emphasize that `state rm` does NOT destroy infrastructure
2. **Not understanding lock safety** - Discuss dangers of `force-unlock`
3. **Confusing moved/removed blocks with CLI commands** - One is declarative (config), other is imperative (CLI)

## Discussion Points

Use these in class to debrief the quiz:

1. "What surprised you most about what's stored in state?"
2. "When would you use `moved` block vs `state mv` command?"
3. "You make a console change to an S3 bucket. What happens on next `terraform plan`?"
4. "A teammate's laptop died mid-apply. What do you do about the stuck lock?"
