# Week 02 Discovery Quiz: State Management Documentation

## Overview

This quiz helps you practice navigating Terraform state documentation - essential for both the certification exam and real-world troubleshooting. State problems are common, and knowing where to find answers quickly is a critical skill.

**Time**: 30-45 minutes  
**Format**: Open-book (documentation only)  
**Purpose**: Build research skills, not memorization

---

## Part 1: State Fundamentals

Navigate to the [State Documentation](https://developer.hashicorp.com/terraform/language/state).

### Question 1.1
Terraform state contains metadata about resource dependencies. What are the TWO reasons given in the documentation for why this metadata is needed?

**Your Answer**: 
1. _________________
2. _________________

**Where to look**: State > Purpose of Terraform State

---

### Question 1.2
By default, where is Terraform state stored when you don't configure a backend?

**Your Answer**: _________________

**Where to look**: State > State Storage

---

### Question 1.3
What sensitive information might be stored in state that makes it important to treat state as sensitive data? Give two examples.

**Your Answer**: 
1. _________________
2. _________________

**Where to look**: State > Sensitive Data in State

---

## Part 2: Backend Configuration

Navigate to the [S3 Backend Documentation](https://developer.hashicorp.com/terraform/language/backend/s3).

### Question 2.1
In Terraform 1.9+, what argument enables S3's native state locking feature (without DynamoDB)?

**Your Answer**: _________________

**Where to look**: S3 Backend > Arguments > State Locking

---

### Question 2.2
What S3 feature must be enabled on the bucket for native state locking to work?

**Your Answer**: _________________

**Where to look**: S3 Backend > S3 State Locking

---

### Question 2.3
What happens if you try to run `terraform apply` while another operation holds the state lock?

**Your Answer**: _________________

**Where to look**: Backend Configuration > State Locking

---

### Question 2.4
What argument would you add to `terraform init` to migrate existing state to a new backend?

**Your Answer**: _________________

**Where to look**: CLI > Commands > init

---

## Part 3: State CLI Commands

Navigate to the [State Command Documentation](https://developer.hashicorp.com/terraform/cli/commands/state).

### Question 3.1
What flag would you add to `terraform state mv` to do a dry run without actually making changes?

**Your Answer**: _________________

**Where to look**: CLI > Commands > state mv

---

### Question 3.2
After using `terraform state rm` to remove a resource from state, what happens to the actual infrastructure (e.g., the EC2 instance in AWS)?

**Your Answer**: _________________

**Where to look**: CLI > Commands > state rm

---

### Question 3.3
What command would you use to view all resources currently tracked in state?

**Your Answer**: _________________

**Where to look**: CLI > Commands > state list

---

### Question 3.4
What command shows the detailed attributes of a specific resource in state?

**Your Answer**: _________________

**Where to look**: CLI > Commands > state show

---

## Part 4: Moved and Removed Blocks

Navigate to the [Moved Blocks](https://developer.hashicorp.com/terraform/language/moved) and [Removed Blocks](https://developer.hashicorp.com/terraform/language/removed) documentation.

### Question 4.1
What are the TWO required arguments in a `moved` block?

**Your Answer**: 
1. _________________
2. _________________

**Where to look**: Language > moved

---

### Question 4.2
After a `moved` block has been applied successfully, what should you do with it?

**Your Answer**: _________________

**Where to look**: Language > moved > Removing moved Blocks

---

### Question 4.3
What is the key difference between using `terraform state rm` and a `removed` block?

**Your Answer**: _________________

**Where to look**: Language > removed

---

### Question 4.4
In a `removed` block, what lifecycle argument would you set to `true` to also destroy the infrastructure (not just remove from state)?

**Your Answer**: _________________

**Where to look**: Language > removed > Lifecycle

---

## Part 5: Troubleshooting

### Question 5.1
You run `terraform plan` and see the error: "Error acquiring the state lock". What command can forcibly release the lock? (Note: When should you use this?)

**Your Answer**: 
- Command: _________________
- When to use: _________________

**Where to look**: CLI > Commands > force-unlock

---

### Question 5.2
You see this message: "Objects have changed outside of Terraform". What Terraform operation detected this, and what are your options?

**Your Answer**: 
- Detected by: _________________
- Options: _________________

**Where to look**: CLI > Commands > plan (refresh-only section)

---

### Question 5.3
What environment variable would you set to see detailed logs of state operations?

**Your Answer**: _________________

**Where to look**: CLI > Environment Variables

---

## Part 6: Practical Exploration

### Question 6.1
Find the documentation for the `terraform state pull` command. What does this command output, and why might you use it?

**Your Answer**: _________________

**Where to look**: CLI > Commands > state pull

---

### Question 6.2
Find documentation on state file format. What is the top-level key in a state file that contains the terraform version?

**Your Answer**: _________________

**Where to look**: Internals > State File Format (or examine a local state file)

---

### Question 6.3
If you're using S3 backend and want to use a different AWS profile than default, what argument would you add to the backend configuration?

**Your Answer**: _________________

**Where to look**: S3 Backend > Arguments

---

## Reflection

### What state concept was most confusing before doing this quiz?

_________________

### What's one troubleshooting command you'll remember for state issues?

_________________

### How would you explain the purpose of state to a colleague who's new to Terraform?

_________________

---

## Submission

Submit your completed quiz as `week-02/DISCOVERY_QUIZ_ANSWERS.md` in your student-work directory.

**Grading**: This quiz is graded on completion and effort, not correct answers. The goal is to build your documentation navigation skills.

---

## Answer Key Location

See [DISCOVERY_QUIZ_INSTRUCTOR.md](DISCOVERY_QUIZ_INSTRUCTOR.md) (instructor access only).
