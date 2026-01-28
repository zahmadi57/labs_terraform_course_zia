# Module Publishing Capstone Submission

## Student Information

- **Name**: [Your Name]
- **GitHub Username**: [your-username]
- **Date**: [YYYY-MM-DD]

---

## Module Information

- **Module Name**: terraform-aws-[your-module-name]
- **GitHub Repository**: https://github.com/[your-username]/terraform-aws-[your-module-name]
- **Terraform Registry**: https://registry.terraform.io/modules/[your-username]/[your-module-name]/aws

---

## Module Summary

### What does your module create?

[Describe the AWS resources your module creates and their purpose. 2-3 sentences.]

### Why did you choose this module?

[Explain why you picked this particular module to build. What interested you about it?]

---

## Self-Assessment

### Variables (check all that apply)
- [ ] At least 4 variables defined
- [ ] At least 2 required variables (no default)
- [ ] At least 2 optional variables (with default)
- [ ] All variables have description
- [ ] All variables have explicit type
- [ ] At least 1 validation block

### Resources
- [ ] At least 2 AWS resources
- [ ] Resources properly connected with references
- [ ] Tags applied consistently

### Outputs
- [ ] At least 3 outputs defined
- [ ] All outputs have description

### Documentation
- [ ] README.md generated with terraform-docs
- [ ] Usage example included

### Tests
- [ ] At least 3 test runs
- [ ] All tests pass (`terraform test`)

### Publication
- [ ] Repository name follows `terraform-aws-<n>` pattern
- [ ] Version tag v1.0.0 created
- [ ] Module visible on Terraform Registry

---

## Reflection

### What was the hardest part of this project?

[Your answer here]

### What did you learn that you didn't know before?

[Your answer here]

### If you had more time, what would you add for v2.0.0?

[Your answer here - list 2-3 features or improvements]

---

## Verification

To verify my module works, run:

```bash
# Create a test file
cat > test.tf << 'EOF'
module "test" {
  source  = "[your-username]/[module-name]/aws"
  version = "1.0.0"

  # Required variables
  [variable_name] = "[value]"
  
  # Optional variables (showing non-default values)
  [optional_var] = "[value]"
}

output "test_output" {
  value = module.test.[output_name]
}
EOF

terraform init
terraform plan
```

---

## Screenshots (Optional)

If you want to include screenshots of your Registry page or test output, add them here.
