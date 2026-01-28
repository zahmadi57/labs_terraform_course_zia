# GitHub Actions + OIDC + Terraform: Portfolio Site

## Goal

Fork the Portfolio Config Generator, configure GitHub Actions with AWS OIDC, and deploy your personalized portfolio to S3 using Terraform. You will build the infrastructure yourself using the Terraform AWS Provider documentation.

## Before You Start

- Do this lab in your own repo (a fork of the portfolio generator)
- Keep the Terraform AWS Provider docs open: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- You will write Terraform code by looking up each resource in the docs

## What You Build

- A React portfolio app with 4 themes (Terminal, Blueprint, Paper, Brutalist)
- S3 static website hosting (you write the Terraform)
- GitHub Actions workflows for CI/CD
- OIDC-based AWS authentication

## Prerequisites

- GitHub account
- Personal AWS account
- Terraform 1.9.0+
- AWS CLI v2
- Node.js 20+

---

## Part 1: Fork and Setup

### Step 1: Fork the Portfolio Generator

1. Go to **https://github.com/jlgore/portfolio-config-generator**
2. Click **Fork** to create your own copy
3. Clone your fork locally:

```bash
git clone https://github.com/YOUR-USERNAME/portfolio-config-generator.git
cd portfolio-config-generator
```

### Step 2: Create Infrastructure Directory

```bash
mkdir -p infra
mkdir -p .github/workflows
```

---

## Part 2: Manual AWS Bootstrap

### Step 3: Create the OIDC Provider

In the AWS console, create an identity provider for GitHub Actions:

1. Go to **IAM → Identity providers → Add provider**
2. Provider type: **OpenID Connect**
3. Provider URL: `https://token.actions.githubusercontent.com`
4. Audience: `sts.amazonaws.com`

### Step 4: Create the IAM Role

Create an IAM role that GitHub Actions can assume:

1. Go to **IAM → Roles → Create role**
2. Trusted entity type: **Web identity**
3. Identity provider: `token.actions.githubusercontent.com`
4. Audience: `sts.amazonaws.com`
5. Add a condition for your repo:
   - Condition: `StringLike`
   - Key: `token.actions.githubusercontent.com:sub`
   - Value: `repo:YOUR-USERNAME/portfolio-config-generator:*`

For the permissions policy, attach `AmazonS3FullAccess` for now (we'll scope it down later).

**Save the Role ARN** - you'll need it for GitHub Actions.

---

## Part 3: Write Your Terraform

Now you'll write Terraform code by looking up each resource in the provider docs.

### Step 5: Provider Configuration

Create `infra/providers.tf`

**Your task:** Configure the AWS provider.

📖 **Docs:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs#provider-configuration

You need:
- Provider block for `aws`
- Set the region (use a variable or hardcode `us-east-1`)

<details>
<summary>Hint</summary>

```hcl
provider "aws" {
  region = var.aws_region
}
```
</details>

### Step 6: Terraform and Provider Versions

Create `infra/versions.tf`

**Your task:** Lock the Terraform and AWS provider versions.

📖 **Docs:** https://developer.hashicorp.com/terraform/language/providers/requirements

You need:
- `terraform` block with `required_version`
- `required_providers` block specifying AWS provider source and version

<details>
<summary>Hint</summary>

```hcl
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```
</details>

### Step 7: Variables

Create `infra/variables.tf`

**Your task:** Define input variables for your configuration.

📖 **Docs:** https://developer.hashicorp.com/terraform/language/values/variables

Define variables for:
- `aws_region` (string, default "us-east-1")
- `site_bucket_name` (string, required - must be globally unique)
- `student_name` (string, for tagging)

<details>
<summary>Hint</summary>

```hcl
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "site_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for the portfolio site"
}

variable "student_name" {
  type        = string
  description = "Your name for resource tagging"
}
```
</details>

### Step 8: S3 Bucket for Static Website

Create `infra/main.tf`

This is the main challenge. You need to create an S3 bucket configured for static website hosting.

**Your task:** Look up each resource and configure it.

#### 8a. Create the S3 Bucket

📖 **Docs:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket

Create a bucket with:
- Your bucket name variable
- `force_destroy = true` (allows deleting bucket with objects)
- Tags including your student name

#### 8b. Configure Bucket Ownership

📖 **Docs:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls

Set ownership to `BucketOwnerPreferred` or `BucketOwnerEnforced`.

#### 8c. Disable Public Access Block

📖 **Docs:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block

For a public website, you need to allow public access. Set all four block settings to `false`.

#### 8d. Configure Static Website Hosting

📖 **Docs:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration

Configure:
- `index_document` = "index.html"
- `error_document` = "index.html" (for SPA routing)

#### 8e. Add Bucket Policy for Public Read

📖 **Docs:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy

Create a policy that allows `s3:GetObject` for everyone (`*`) on all objects in your bucket.

📖 **Policy docs:** https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteAccessPermissionsReqd.html

<details>
<summary>Hint: Bucket Policy JSON</summary>

```hcl
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.site.arn}/*"
      }
    ]
  })
}
```
</details>

### Step 9: Outputs

Create `infra/outputs.tf`

**Your task:** Output useful values from your infrastructure.

📖 **Docs:** https://developer.hashicorp.com/terraform/language/values/outputs

Output:
- `site_bucket_name` - the bucket name
- `website_endpoint` - the S3 website endpoint
- `website_url` - full URL with http://

<details>
<summary>Hint</summary>

```hcl
output "site_bucket_name" {
  value = aws_s3_bucket.site.id
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.site.website_endpoint
}

output "website_url" {
  value = "http://${aws_s3_bucket_website_configuration.site.website_endpoint}"
}
```
</details>

### Step 10: Backend Configuration

Create `infra/backend.tf`

**Your task:** Configure S3 backend for state storage.

📖 **Docs:** https://developer.hashicorp.com/terraform/language/settings/backends/s3

Use the shared class state bucket:
- Bucket: `terraform-state-YOUR-ACCOUNT-ID`
- Key: `week-02/github-actions-oidc/YOUR-USERNAME/terraform.tfstate`
- Region: your region
- Encrypt: true

<details>
<summary>Hint</summary>

```hcl
terraform {
  backend "s3" {
    bucket  = "terraform-state-123456789012"
    key     = "week-02/github-actions-oidc/myname/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
```
</details>

### Step 11: Create tfvars File

Create `infra/terraform.tfvars`

```hcl
aws_region       = "us-east-1"
site_bucket_name = "YOUR-UNIQUE-BUCKET-NAME"
student_name     = "Your Name"
```

---

## Part 4: GitHub Actions Workflows

### Step 12: Terraform Plan Workflow

Create `.github/workflows/terraform-plan.yml`

**Your task:** Create a workflow that runs `terraform plan` on pull requests.

📖 **Docs:**
- https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
- https://github.com/aws-actions/configure-aws-credentials
- https://github.com/hashicorp/setup-terraform
- https://github.com/actions/setup-node

The workflow should:
1. Trigger on pull requests to `infra/**` and `src/**`
2. Use OIDC to authenticate to AWS (no access keys!)
3. Build the React app with `npm ci && npm run build`
4. Run `terraform init`, `fmt -check`, `validate`, and `plan`

Required permissions:
```yaml
permissions:
  id-token: write
  contents: read
```

<details>
<summary>Hint: Workflow Structure</summary>

```yaml
name: Terraform Plan

on:
  pull_request:
    paths:
      - "infra/**"
      - "src/**"
  workflow_dispatch:

jobs:
  plan:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      # Your steps here
```
</details>

<details>
<summary>Hint: Checkout Step</summary>

```yaml
- name: Checkout
  uses: actions/checkout@v4
```
</details>

<details>
<summary>Hint: OIDC Authentication Step</summary>

```yaml
- name: Configure AWS credentials (OIDC)
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ vars.AWS_ROLE_ARN }}
    aws-region: ${{ vars.AWS_REGION || 'us-east-1' }}
```
</details>

<details>
<summary>Hint: Setup Node.js Step</summary>

```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: 20
    cache: npm
```
</details>

<details>
<summary>Hint: Build React App Steps</summary>

```yaml
- name: Install dependencies
  run: npm ci

- name: Build React app
  run: npm run build
```
</details>

<details>
<summary>Hint: Setup Terraform Step</summary>

```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
  with:
    terraform_version: 1.9.0
```
</details>

<details>
<summary>Hint: Terraform Commands</summary>

```yaml
- name: Terraform fmt
  run: terraform fmt -check
  working-directory: infra

- name: Terraform init
  run: terraform init -input=false
  working-directory: infra

- name: Terraform validate
  run: terraform validate
  working-directory: infra

- name: Terraform plan
  run: terraform plan -input=false
  working-directory: infra
```
</details>

<details>
<summary>Hint: Full Plan Workflow</summary>

```yaml
name: Terraform Plan

on:
  pull_request:
    paths:
      - "infra/**"
      - "src/**"
      - "package.json"
      - ".github/workflows/**"
  workflow_dispatch:

jobs:
  plan:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: ${{ vars.AWS_REGION || 'us-east-1' }}

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm

      - name: Install dependencies
        run: npm ci

      - name: Build React app
        run: npm run build

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.0

      - name: Terraform fmt
        run: terraform fmt -check
        working-directory: infra

      - name: Terraform init
        run: terraform init -input=false
        working-directory: infra

      - name: Terraform validate
        run: terraform validate
        working-directory: infra

      - name: Terraform plan
        run: terraform plan -input=false
        working-directory: infra
```
</details>

### Step 13: Terraform Apply Workflow

Create `.github/workflows/terraform-apply.yml`

**Your task:** Create a workflow that deploys infrastructure and the site.

📖 **Docs:**
- https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#workflow_dispatch
- https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-output-parameter

The workflow should:
1. Trigger on `workflow_dispatch` (manual) with a confirmation input
2. Check that the user typed "APPLY" to confirm
3. Authenticate via OIDC
4. Run `terraform apply -auto-approve`
5. Read Terraform outputs (bucket name)
6. Build the React app
7. Sync the `dist/` folder to S3

<details>
<summary>Hint: Manual Trigger with Confirmation</summary>

```yaml
on:
  workflow_dispatch:
    inputs:
      confirm:
        description: "Type APPLY to confirm"
        required: true
```
</details>

<details>
<summary>Hint: Confirmation Check Step</summary>

```yaml
- name: Confirm apply
  run: |
    if [ "${{ github.event.inputs.confirm }}" != "APPLY" ]; then
      echo "Confirmation missing. Type APPLY to continue."
      exit 1
    fi
```
</details>

<details>
<summary>Hint: Terraform Apply Step</summary>

```yaml
- name: Terraform apply
  run: terraform apply -auto-approve -input=false
  working-directory: infra
```
</details>

<details>
<summary>Hint: Reading Terraform Outputs</summary>

Use step outputs to pass values between steps:

```yaml
- name: Read Terraform outputs
  id: tf
  run: |
    echo "site_bucket=$(terraform output -raw site_bucket_name)" >> "$GITHUB_OUTPUT"
    echo "website_url=$(terraform output -raw website_url)" >> "$GITHUB_OUTPUT"
  working-directory: infra
```

Then reference in later steps: `${{ steps.tf.outputs.site_bucket }}`
</details>

<details>
<summary>Hint: S3 Sync Step</summary>

```yaml
- name: Sync to S3
  run: aws s3 sync dist "s3://${{ steps.tf.outputs.site_bucket }}" --delete
```
</details>

<details>
<summary>Hint: Print Website URL</summary>

```yaml
- name: Print website URL
  run: |
    echo "=========================================="
    echo "Website deployed successfully!"
    echo "URL: ${{ steps.tf.outputs.website_url }}"
    echo "=========================================="
```
</details>

<details>
<summary>Hint: Full Apply Workflow</summary>

```yaml
name: Terraform Apply

on:
  workflow_dispatch:
    inputs:
      confirm:
        description: "Type APPLY to confirm"
        required: true

jobs:
  apply:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Confirm apply
        run: |
          if [ "${{ github.event.inputs.confirm }}" != "APPLY" ]; then
            echo "Confirmation missing. Type APPLY to continue."
            exit 1
          fi

      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: ${{ vars.AWS_REGION || 'us-east-1' }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.0

      - name: Terraform init
        run: terraform init -input=false
        working-directory: infra

      - name: Terraform apply
        run: terraform apply -auto-approve -input=false
        working-directory: infra

      - name: Read Terraform outputs
        id: tf
        run: |
          echo "site_bucket=$(terraform output -raw site_bucket_name)" >> "$GITHUB_OUTPUT"
          echo "website_url=$(terraform output -raw website_url)" >> "$GITHUB_OUTPUT"
        working-directory: infra

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm

      - name: Install dependencies
        run: npm ci

      - name: Build React app
        run: npm run build
        env:
          VITE_BASE_URL: /
          VITE_PORTFOLIO_MODE: production

      - name: Sync to S3
        run: aws s3 sync dist "s3://${{ steps.tf.outputs.site_bucket }}" --delete

      - name: Print website URL
        run: |
          echo "=========================================="
          echo "Website deployed successfully!"
          echo "URL: ${{ steps.tf.outputs.website_url }}"
          echo "=========================================="
```
</details>

### Step 14: Terraform Destroy Workflow

Create `.github/workflows/terraform-destroy.yml`

**Your task:** Create a workflow that tears down everything.

The workflow should:
1. Trigger on `workflow_dispatch` with a confirmation input
2. Check that the user typed "DESTROY" to confirm
3. Authenticate via OIDC
4. Run `terraform destroy -auto-approve`

<details>
<summary>Hint: Destroy Confirmation</summary>

```yaml
on:
  workflow_dispatch:
    inputs:
      confirm:
        description: "Type DESTROY to confirm"
        required: true
```
</details>

<details>
<summary>Hint: Terraform Destroy Step</summary>

```yaml
- name: Terraform destroy
  run: terraform destroy -auto-approve -input=false
  working-directory: infra
```
</details>

<details>
<summary>Hint: Full Destroy Workflow</summary>

```yaml
name: Terraform Destroy

on:
  workflow_dispatch:
    inputs:
      confirm:
        description: "Type DESTROY to confirm"
        required: true

jobs:
  destroy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Confirm destroy
        run: |
          if [ "${{ github.event.inputs.confirm }}" != "DESTROY" ]; then
            echo "Confirmation missing. Type DESTROY to continue."
            exit 1
          fi

      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: ${{ vars.AWS_REGION || 'us-east-1' }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.0

      - name: Terraform init
        run: terraform init -input=false
        working-directory: infra

      - name: Terraform destroy
        run: terraform destroy -auto-approve -input=false
        working-directory: infra
```
</details>

---

## Part 5: Configure and Deploy

### Step 15: Set GitHub Variables

1. Go to your repo → Settings → Secrets and variables → Actions → Variables
2. Add:
   - `AWS_ROLE_ARN` = your IAM role ARN from Step 4
   - `AWS_REGION` = us-east-1 (or your region)

### Step 16: Update Vite Config

Edit `vite.config.ts` and change the base path for S3:

```typescript
base: process.env.VITE_BASE_URL || '/',
```

### Step 17: Customize Your Portfolio

Use the Portfolio Config Generator to create your personalized configuration.

#### 17a. Visit the Portfolio Generator

Go to **https://jlgore.github.io/portfolio-config-generator/**

This visual editor lets you configure your portfolio and preview it in real-time.

#### 17b. Fill In Your Information

Complete each section in the editor:

1. **Basic Info** - Your name, job title, and tagline
2. **Bio** - A few sentences about yourself (supports multiple paragraphs)
3. **Avatar** - Upload a profile photo (see 17c below)
4. **CTAs** - Primary and secondary call-to-action buttons
5. **Highlights** - 3-4 key skills or certifications
6. **Projects** - Add 2-3 projects with descriptions and links
7. **Contact** - Your GitHub, LinkedIn, email, etc.
8. **Meta** - Page title and description for SEO

#### 17c. Upload Your Avatar

1. In the **Avatar** section, click the upload area or drag-and-drop an image
2. Use a square image (recommended: 400x400px or larger)
3. Supported formats: PNG, JPG, JPEG, GIF, WebP
4. The preview will update immediately

**Tip:** A professional headshot or a stylized avatar works well. Keep file size under 500KB for faster loading.

#### 17d. Choose a Theme

Use the theme selector in the header to preview different styles:
- **Terminal** - Dark hacker aesthetic
- **Blueprint** - Technical/engineering feel
- **Paper** - Clean, minimal design
- **Brutalist** - Bold, unconventional style

#### 17e. Export Your Configuration

1. Click the **Export** button in the header
2. A ZIP file downloads containing:
   - `config.ts` - Your portfolio configuration
   - `avatar.*` - Your uploaded avatar image
   - `types.ts` - TypeScript type definitions
   - `README.md` - Usage instructions

#### 17f. Import Into Your Fork

1. Extract the downloaded ZIP file

2. Copy the avatar to your public directory:
   ```bash
   cp ~/Downloads/your-name-portfolio/avatar.png public/avatar.png
   ```

3. Copy the exported config to `src/constants/`:
   ```bash
   cp ~/Downloads/your-name-portfolio/config.ts src/constants/config.ts
   ```

4. Edit `src/constants/defaultConfig.ts` to use your config:
   ```typescript
   import { portfolioConfig } from './config';

   export const defaultConfig = portfolioConfig;
   ```

5. Verify the avatar path in `src/constants/config.ts` matches your file:
   ```typescript
   avatar: '/avatar.png',
   ```

   The exported config should already have the correct path (e.g., `/avatar.png` or `/avatar.jpg`).

#### 17g. Verify Locally

**Development mode** (shows config generator with editor):
```bash
npm run dev
```

**Production mode** (shows only your portfolio):
```bash
VITE_PORTFOLIO_MODE=production npm run dev
```

Open http://localhost:5173 and confirm your portfolio looks correct with your information and avatar.

**Note:** When deployed via GitHub Actions, the build runs with `VITE_PORTFOLIO_MODE=production`, so visitors only see your portfolio - not the config generator.

### Step 18: Test Locally

```bash
npm install
terraform -chdir=infra init
terraform -chdir=infra plan
npm run build
```

### Step 19: Deploy

1. Commit and push your changes
2. Go to Actions → Terraform Apply → Run workflow
3. Type `APPLY` and confirm

### Step 20: Verify

Visit your website URL from the Terraform output!

---

## Part 6: GitOps Workflow (PR-based Deploys)

Now let's set up a more realistic workflow where:
- **Pull requests** → automatically run `terraform plan` and show the diff
- **Merge to main** → automatically run `terraform apply` and deploy

### Step 21: Create the GitOps Workflow

Create `.github/workflows/gitops.yml`

This single workflow handles both PR plans and merge deploys:

```yaml
name: GitOps Deploy

on:
  push:
    branches: [main]
    paths:
      - "infra/**"
      - "src/**"
      - "package.json"
  pull_request:
    branches: [main]
    paths:
      - "infra/**"
      - "src/**"
      - "package.json"

jobs:
  plan:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
      pull-requests: write
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: ${{ vars.AWS_REGION || 'us-east-1' }}

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm

      - name: Install dependencies
        run: npm ci

      - name: Build React app
        run: npm run build
        env:
          VITE_PORTFOLIO_MODE: production

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.0

      - name: Terraform init
        run: terraform init -input=false
        working-directory: infra

      - name: Terraform fmt
        run: terraform fmt -check
        working-directory: infra
        continue-on-error: true

      - name: Terraform validate
        run: terraform validate
        working-directory: infra

      - name: Terraform plan
        id: plan
        run: terraform plan -input=false -no-color -out=tfplan
        working-directory: infra

      - name: Post plan to PR
        uses: actions/github-script@v7
        with:
          script: |
            const output = `#### Terraform Plan 📖

            \`\`\`
            ${{ steps.plan.outputs.stdout }}
            \`\`\`

            *Pushed by: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })

  deploy:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: ${{ vars.AWS_REGION || 'us-east-1' }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.0

      - name: Terraform init
        run: terraform init -input=false
        working-directory: infra

      - name: Terraform apply
        run: terraform apply -auto-approve -input=false
        working-directory: infra

      - name: Read Terraform outputs
        id: tf
        run: |
          echo "site_bucket=$(terraform output -raw site_bucket_name)" >> "$GITHUB_OUTPUT"
          echo "website_url=$(terraform output -raw website_url)" >> "$GITHUB_OUTPUT"
        working-directory: infra

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm

      - name: Install dependencies
        run: npm ci

      - name: Build React app
        run: npm run build
        env:
          VITE_PORTFOLIO_MODE: production

      - name: Sync to S3
        run: aws s3 sync dist "s3://${{ steps.tf.outputs.site_bucket }}" --delete

      - name: Print website URL
        run: |
          echo "=========================================="
          echo "Website deployed successfully!"
          echo "URL: ${{ steps.tf.outputs.website_url }}"
          echo "=========================================="
```

### Step 22: Test the PR Workflow

1. Create a feature branch:
   ```bash
   git checkout -b pull-request-demo
   ```

2. Make a small change (e.g., update your bio in `src/constants/config.ts`)

3. Commit and push:
   ```bash
   git add .
   git commit -m "Update portfolio bio"
   git push -u origin pull-request-demo
   ```

4. Create a pull request:
   ```bash
   gh pr create --title "Update portfolio" --body "Testing GitOps workflow"
   ```

5. Watch the Actions tab - the `plan` job will run and post the Terraform plan as a PR comment

### Step 23: Merge and Auto-Deploy

1. Review the plan in the PR comments
2. Merge the PR:
   ```bash
   gh pr merge --squash
   ```
3. The `deploy` job automatically runs on the merge to main
4. Your site is updated!

### Step 24: Clean Up Old Workflows (Optional)

Now that you have the GitOps workflow, you can optionally disable the manual workflows:

1. Go to **Actions** → **Terraform Apply** → **...** → **Disable workflow**
2. Or delete the old workflow files:
   ```bash
   rm .github/workflows/terraform-plan.yml
   rm .github/workflows/terraform-apply.yml
   ```

Keep `terraform-destroy.yml` for teardown.

---

## Challenges (Optional)

### Challenge 1: Scope Down IAM Permissions

Your IAM role currently has `AmazonS3FullAccess`. Create a custom policy that only allows:
- S3 actions on your site bucket
- S3 actions on the state bucket

📖 **Docs:** https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html

### Challenge 2: Add CloudFront

Add a CloudFront distribution in front of your S3 bucket for HTTPS and caching.

📖 **Docs:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution

### Challenge 3: Custom Domain

Add a custom domain using Route 53 and ACM.

📖 **Docs:**
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate

---

## Clean Up

Run the Terraform Destroy workflow when you're done. The bucket has `force_destroy = true` so objects are deleted automatically.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| OIDC authentication fails | Check IAM role trust policy matches your repo exactly |
| Access denied on state bucket | Add S3 permissions for state bucket to IAM policy |
| Website returns 403 | Check bucket policy and public access block settings |
| Bucket name taken | S3 bucket names are globally unique - try a different name |
| Build fails | Run `npm install` locally first, check Node version |
| `BlockPublicPolicy` error on PutBucketPolicy | Disable account-level S3 Block Public Access (see below) |

### S3 Block Public Access Error

If you see an error like:

```
Error: putting S3 Bucket Policy: api error AccessDenied: ... public policies
are prevented by the BlockPublicPolicy setting in S3 Block Public Access
```

Your AWS account has **account-level** S3 Block Public Access enabled. This is separate from the bucket-level settings in your Terraform code.

**To disable it:**

1. Go to **S3 → Block Public Access settings for this account** (left sidebar)
2. Click **Edit**
3. Uncheck **Block public access to buckets and objects granted through new public bucket or access point policies**
4. Click **Save changes**
5. Type `confirm` when prompted

**Or via AWS CLI:**

```bash
aws s3control put-public-access-block \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=false,RestrictPublicBuckets=false"
```

**Note:** This is a security setting. For production workloads, consider using CloudFront with Origin Access Control instead of making buckets directly public (see Challenge 2).

---

## Reference Links

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [Terraform S3 Backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
