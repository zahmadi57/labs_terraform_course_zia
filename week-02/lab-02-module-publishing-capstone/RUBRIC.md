# Module Publishing Capstone - Grading Rubric

## Total Points: 100

---

## 1. Module Structure & Code Quality (25 points)

### File Structure (10 points)

| Criteria | Points | Description |
|----------|--------|-------------|
| Correct repository naming | 3 | `terraform-aws-<n>` pattern |
| All required files present | 3 | main.tf, variables.tf, outputs.tf, versions.tf |
| Tests directory with test file | 2 | tests/basic.tftest.hcl (or similar) |
| Clean repository | 2 | No .terraform/, *.tfstate, credentials, or unnecessary files |

### Code Quality (15 points)

| Criteria | Points | Description |
|----------|--------|-------------|
| `terraform fmt` passes | 3 | All files properly formatted |
| `terraform validate` passes | 3 | No syntax or reference errors |
| Consistent naming conventions | 3 | Resources named `this` for single instances, descriptive for multiples |
| Uses `locals` appropriately | 3 | Computed values, tag merging, DRY principle |
| No hardcoded values | 3 | Region, account IDs, etc. are variables or data sources |

---

## 2. Variables & Validation (20 points)

### Variable Definitions (12 points)

| Criteria | Points | Description |
|----------|--------|-------------|
| Minimum 4 variables defined | 2 | At least 4 input variables |
| At least 2 required variables | 2 | Variables without defaults |
| At least 2 optional variables | 2 | Variables with sensible defaults |
| All variables have `description` | 3 | Clear, helpful descriptions |
| All variables have explicit `type` | 3 | string, number, bool, list(), map(), object() |

### Input Validation (8 points)

| Criteria | Points | Description |
|----------|--------|-------------|
| At least 1 validation block | 4 | Custom validation on at least one variable |
| Validation has clear error message | 2 | Helpful error message that guides user |
| Validation logic is correct | 2 | Condition actually validates what it claims |

**Example of good validation:**
```hcl
variable "instance_type" {
  type    = string
  default = "t3.micro"

  validation {
    condition     = can(regex("^t[23]\\.(micro|small|medium)$", var.instance_type))
    error_message = "Instance type must be t2 or t3, size micro/small/medium (sandbox constraint)."
  }
}
```

---

## 3. Resources & Outputs (20 points)

### Resources (12 points)

| Criteria | Points | Description |
|----------|--------|-------------|
| Minimum 2 AWS resources | 4 | At least 2 related resources |
| Resources are properly connected | 4 | Correct references between resources |
| Tags applied consistently | 2 | All taggable resources have tags |
| Follows AWS best practices | 2 | Encryption enabled, proper IAM, etc. |

### Outputs (8 points)

| Criteria | Points | Description |
|----------|--------|-------------|
| Minimum 3 outputs defined | 3 | At least 3 output values |
| All outputs have `description` | 2 | Clear descriptions |
| Outputs are useful | 3 | ID, ARN, and at least one other useful attribute |

**Example of good outputs:**
```hcl
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "The public IP address of the instance (null if no public IP)"
  value       = aws_instance.this.public_ip
}

output "security_group_id" {
  description = "The ID of the security group attached to the instance"
  value       = aws_security_group.this.id
}
```

---

## 4. Documentation (15 points)

### README.md (15 points)

| Criteria | Points | Description |
|----------|--------|-------------|
| Generated with terraform-docs | 3 | Evidence of terraform-docs output |
| Includes module description | 2 | Brief explanation of what the module does |
| Includes usage example | 4 | Working HCL example showing how to use the module |
| Inputs table present | 3 | All variables documented with types and defaults |
| Outputs table present | 3 | All outputs documented |

**Example README structure:**
```markdown
# terraform-aws-ec2-webserver

Creates an EC2 instance configured as a web server with security group.

## Usage

​```hcl
module "webserver" {
  source  = "username/ec2-webserver/aws"
  version = "1.0.0"

  instance_name    = "my-webserver"
  allowed_ssh_cidr = "10.0.0.0/8"
}
​```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance_name | Name tag for the EC2 instance | string | n/a | yes |
| ... | ... | ... | ... | ... |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | The ID of the EC2 instance |
| ... | ... |
```

---

## 5. Tests (15 points)

### Test Coverage (15 points)

| Criteria | Points | Description |
|----------|--------|-------------|
| Minimum 3 test runs | 3 | At least 3 `run` blocks |
| All tests pass | 4 | `terraform test` shows all green |
| Tests cover different aspects | 4 | Not just 3 tests checking the same thing |
| Assertions are meaningful | 4 | Tests verify actual behavior, not just "!= null" |

**Good test coverage includes:**
1. **Resource creation test** - Verify primary resource is created with expected attributes
2. **Configuration test** - Verify optional settings work (e.g., versioning enabled)
3. **Tagging test** - Verify required tags are present
4. **Validation test** (bonus) - Verify bad input is rejected

**Example test file:**
```hcl
# tests/basic.tftest.hcl

variables {
  instance_name    = "test-instance"
  allowed_ssh_cidr = "10.0.0.0/8"
}

run "instance_is_created" {
  command = plan

  assert {
    condition     = aws_instance.this.instance_type == "t3.micro"
    error_message = "Instance should use t3.micro by default"
  }
}

run "security_group_allows_http" {
  command = plan

  assert {
    condition     = contains([for rule in aws_security_group.this.ingress : rule.from_port], 80)
    error_message = "Security group should allow HTTP on port 80"
  }
}

run "instance_has_name_tag" {
  command = plan

  assert {
    condition     = aws_instance.this.tags["Name"] == "test-instance"
    error_message = "Instance should have Name tag matching instance_name variable"
  }
}
```

---

## 6. Registry Publication (5 points)

| Criteria | Points | Description |
|----------|--------|-------------|
| Module visible on registry.terraform.io | 3 | Publicly accessible |
| Version 1.0.0 published | 2 | At least one semantic version tag |

---

## Bonus Points (up to 10 extra)

| Criteria | Points | Description |
|----------|--------|-------------|
| Additional version (v1.1.0, etc.) | 2 | Shows iteration on design |
| Complex types (object, list(object)) | 2 | Advanced variable types |
| Dynamic blocks | 2 | Uses `dynamic` for repeated nested blocks |
| Multiple test files | 2 | Organized test suite |
| Exceptional documentation | 2 | Diagrams, detailed examples, troubleshooting |

---

## Grading Notes

### Automatic Failures (0 points for category)

- **Repository name wrong**: Module Structure = 0 (registry won't accept)
- **terraform validate fails**: Code Quality = 0
- **No tests**: Tests = 0
- **Not published to registry**: Publication = 0

### Partial Credit

- Missing 1 of 4 required variables: -5 points
- Missing 1 of 3 required outputs: -3 points
- Tests exist but 1 fails: -5 points
- terraform-docs used but README incomplete: -5 points

### Common Deductions

| Issue | Deduction |
|-------|-----------|
| Hardcoded AWS region | -3 |
| No .gitignore (terraform files committed) | -2 |
| Sensitive variable not marked sensitive | -2 |
| Missing description on variable/output | -1 each |
| Poor error message in validation | -1 |

---

## Submission Checklist

Before submitting, verify:

- [ ] Repository name matches `terraform-aws-<n>` pattern
- [ ] `terraform fmt` passes
- [ ] `terraform validate` passes
- [ ] `terraform test` shows all tests passing
- [ ] README.md exists with usage example
- [ ] Version tag `v1.0.0` pushed to GitHub
- [ ] Module visible at registry.terraform.io
- [ ] SUBMISSION.md created with:
  - GitHub repo URL
  - Registry URL
  - Brief write-up

---

## Grade Scale

| Score | Grade |
|-------|-------|
| 90-100+ | A |
| 80-89 | B |
| 70-79 | C |
| 60-69 | D |
| <60 | F |
