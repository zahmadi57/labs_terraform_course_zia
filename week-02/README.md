# Week 02: State Management Deep Dive

## Exam Objectives Covered

This week covers objectives from the [Terraform Associate 004 Exam](https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004):

| Domain | Objective | Description |
|--------|-----------|-------------|
| 6 | 6a | Describe state backends (local vs remote) |
| 6 | 6b | Describe state locking mechanisms |
| 6 | 6c | Configure backend block for remote state |
| 6 | 6d | Describe when to use `terraform refresh` and manage drift |
| 7 | 7b | Inspect state with CLI commands |

**Domain 6 (State Management) is 15% of the certification exam** - this week is critical for exam success.

---

## Required Reading (Before Labs)

Complete these readings before starting the labs. Estimated time: **60-75 minutes**.

### State Fundamentals (Exam Domain 6)
| Reading | Time | Focus |
|---------|------|-------|
| [State Overview](https://developer.hashicorp.com/terraform/language/state) | 15 min | What state is and why it matters |
| [Purpose of State](https://developer.hashicorp.com/terraform/language/state/purpose) | 10 min | Mapping, metadata, performance |
| [Remote State](https://developer.hashicorp.com/terraform/language/state/remote) | 10 min | Why remote state is essential |

### Backend Configuration (Exam Domain 6)
| Reading | Time | Focus |
|---------|------|-------|
| [Backend Configuration](https://developer.hashicorp.com/terraform/language/backend) | 15 min | Backend block syntax |
| [S3 Backend](https://developer.hashicorp.com/terraform/language/backend/s3) | 10 min | S3 backend options, native locking |

### State Operations (Exam Domain 7)
| Reading | Time | Focus |
|---------|------|-------|
| [State Command](https://developer.hashicorp.com/terraform/cli/commands/state) | 10 min | CLI state operations |
| [Moved Blocks](https://developer.hashicorp.com/terraform/language/moved) | 10 min | Refactoring without state surgery |
| [Removed Blocks](https://developer.hashicorp.com/terraform/language/removed) | 5 min | Removing from state declaratively |

---

## Learning Outcomes

By the end of this week, you will be able to:

- Explain the purpose of Terraform state and its contents
- Configure S3 backend with native locking (Terraform 1.9+)
- Migrate state from local to remote backend
- Use `terraform state` commands: `list`, `show`, `mv`, `rm`
- Detect and resolve configuration drift
- Use `moved` blocks to refactor resources without breaking state
- Use `removed` blocks to remove resources from state declaratively
- Troubleshoot common state issues

---

## Overview

State is the heart of Terraform - it's how Terraform knows what infrastructure exists and maps your configuration to real resources. This week, you'll move beyond the basics and learn to manage state like a professional.

You'll work with the S3 backend (the most common production backend for AWS) and learn the state manipulation commands that every Terraform practitioner needs. We'll also cover the newer `moved` and `removed` blocks that make refactoring much safer.

**Why this matters:** State problems are the #1 cause of Terraform headaches in production. Teams that understand state management avoid hours of debugging and potential outages.

---

## Prerequisites

- Completed Week 00 and Week 01 labs
- Terraform >= 1.9.0 (required for S3 native locking)
- Existing S3 bucket from Week 00 (or ability to create one)
- AWS credentials configured

---

## Labs

| Lab | Time | Description |
|-----|------|-------------|
| [Lab 00: State Operations](lab-00/README.md) | 2-3 hrs | State commands, moved/removed blocks |
| [Lab 01: Drift Detection](lab-01/README.md) | 2 hrs | Detecting and resolving drift |

### Lab 00: State Operations

Learn to inspect and manipulate Terraform state safely. You'll work with existing infrastructure from previous weeks and practice the commands used in real-world state management.

**Key Concepts:**
- `terraform state list` - View resources in state
- `terraform state show` - Inspect resource details
- `terraform state mv` - Move/rename resources in state
- `terraform state rm` - Remove resources from state
- `moved` blocks - Declarative refactoring
- `removed` blocks - Declarative state removal

### Lab 01: Drift Detection & Resolution

Drift happens when infrastructure changes outside of Terraform (console clicks, CLI commands, other tools). Learn to detect drift, understand its impact, and resolve it safely.

**Key Concepts:**
- What causes drift and why it matters
- `terraform plan` as a drift detector
- `terraform plan -refresh-only` for refresh-only plans
- `terraform apply -refresh-only` to accept drift
- Choosing between "accept drift" vs "revert to config"
- Preventing drift with policies and practices

---

## Gym Practice (Recommended)

After completing the labs, reinforce your learning with exercises from the [Terraform Gym](https://github.com/shart-cloud/terraform-gym):

### Foundation Track (State)
| Exercise | Time | Reinforces |
|----------|------|------------|
| [State Ex 01: Remote Backend](https://github.com/shart-cloud/terraform-gym/tree/main/exercises/state/exercise-01-remote-backend) | 25 min | S3 backend setup (6a, 6c) |
| [State Ex 02: State Commands](https://github.com/shart-cloud/terraform-gym/tree/main/exercises/state/exercise-02-state-commands) | 25 min | list, show, mv, rm (7b) |
| [State Ex 04: State Locking](https://github.com/shart-cloud/terraform-gym/tree/main/exercises/state/exercise-04-state-locking) | 25 min | Locking mechanics (6b) |

### Jerry Track (Fix Real Problems) 🔧
| Exercise | Time | Scenario |
|----------|------|----------|
| [Jerry 01: Stale Lock](https://github.com/shart-cloud/terraform-gym/tree/main/exercises/state/jerry-01-stale-lock) | 15 min | Fix abandoned state lock |
| [Jerry 04: Tag Drift](https://github.com/shart-cloud/terraform-gym/tree/main/exercises/state/jerry-04-tag-drift) | 20 min | Resolve console tag changes |
| [Jerry 05: Config Drift](https://github.com/shart-cloud/terraform-gym/tree/main/exercises/state/jerry-05-config-drift) | 25 min | Handle configuration drift |
| [Jerry 08: Rename Refactor](https://github.com/shart-cloud/terraform-gym/tree/main/exercises/state/jerry-08-rename-refactor) | 25 min | Fix broken refactoring |

### Challenge (If Time Permits)
| Exercise | Time | Reinforces |
|----------|------|------------|
| [State Surgery Challenge](https://github.com/shart-cloud/terraform-gym/tree/main/exercises/state/challenge-state-surgery) | 90 min | Advanced state operations |

**Total Gym Time**: ~75 minutes (Foundation) + ~85 minutes (Jerry) + 90 minutes (Challenge)

---

## Discovery Quiz

Complete the [Discovery Quiz](DISCOVERY_QUIZ.md) to practice navigating state-related documentation. This quiz focuses on:
- State file structure and contents
- Backend configuration options
- State CLI commands and flags
- Troubleshooting state issues

---

## Grading

Each lab is worth 100 points:

| Category | Points | Checks |
|----------|--------|--------|
| Code Quality | 25 | `terraform fmt`, `validate`, naming conventions |
| Functionality | 30 | State operations performed correctly |
| Cost Management | 20 | No orphaned resources, proper cleanup |
| Security | 15 | State bucket encryption, no secrets in state |
| Documentation | 10 | README updates, explanation of changes |

---

## Resources

### State Management
- [State Documentation](https://developer.hashicorp.com/terraform/language/state)
- [Backend Types](https://developer.hashicorp.com/terraform/language/backend)
- [State Commands Reference](https://developer.hashicorp.com/terraform/cli/commands/state)

### Refactoring
- [Moved Blocks](https://developer.hashicorp.com/terraform/language/moved)
- [Removed Blocks](https://developer.hashicorp.com/terraform/language/removed)
- [Refactoring Guide](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring)

### Drift Management
- [Refresh Command](https://developer.hashicorp.com/terraform/cli/commands/refresh)
- [Plan -refresh-only](https://developer.hashicorp.com/terraform/cli/commands/plan#refresh-only-mode)

### Troubleshooting
- [State Troubleshooting](https://developer.hashicorp.com/terraform/language/state/troubleshooting)
- [Force Unlock](https://developer.hashicorp.com/terraform/cli/commands/force-unlock)

### Certification Prep
- [Exam Domain 6: State](https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004#6-read-generate-and-modify-configuration)
- [Manage Resources in State Tutorial](https://developer.hashicorp.com/terraform/tutorials/state/state-cli)

---

## Checklist

Before moving to Week 03, ensure you can:

- [ ] Explain why Terraform uses state and what it contains
- [ ] Configure an S3 backend with native locking
- [ ] Migrate state from local to remote backend
- [ ] Use `terraform state list` to view all resources
- [ ] Use `terraform state show` to inspect a specific resource
- [ ] Use `terraform state mv` to rename a resource
- [ ] Use a `moved` block to refactor without state surgery
- [ ] Detect drift using `terraform plan`
- [ ] Explain the difference between `apply` and `apply -refresh-only`
- [ ] Force-unlock a stuck state lock (conceptually)

---

## Next Week

[Week 03: Importing & Debugging](../week-03/README.md) - Learn to import existing infrastructure into Terraform and debug configuration issues.
