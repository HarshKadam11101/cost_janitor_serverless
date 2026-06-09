# AWS Cost Janitor 

A production-grade, fully serverless cloud automation tool designed to audit AWS environments, identify orphaned/idle resources, and trigger instant alerts via email before they impact your cloud bill. 

This project is built using **Infrastructure as Code (IaC)** via Terraform and automated through a continuous deployment **CI/CD pipeline** via GitHub Actions.

## Architecture Overview

The system operates on a 100% serverless, event-driven architecture requiring zero active maintenance and racking up $0.00 in costs while idling.

```text
[GitHub Repo] ──(GitHub Actions)──> [Terraform IaC]
                                           │
                                  (Deploys Infrastructure)
                                           │
                                           ▼
[EventBridge Scheduler] ──(Cron Trigger)──> [AWS Lambda (Python/Boto3)] ──> [SNS Topic] ──> [User Email]
                                                   │
                                            (Scans Account)
                                                   │
                                                   ▼
                                         [AWS Resources (EBS/EC2)]
```

Infrastructure Management: Managed completely by Terraform with a secure remote state stored in an Amazon S3 backend.

Automation Trigger: Amazon EventBridge triggers the janitor on an automated cron schedule.

Compute Engine: AWS Lambda executes a highly optimized Python script using the AWS SDK (boto3) to scan the account infrastructure.

Notification Engine: Amazon SNS handles communication and forwards summary alerts straight to verified subscriber endpoints.

## Tech Stack

Cloud Provider: Amazon Web Services (AWS)

Infrastructure as Code: Terraform

Programming Language: Python 3.x (Boto3 SDK)

CI/CD Pipeline: GitHub Actions

## Engineering Challenges & Key Learnings

Building this project from scratch exposed me to real-world edge cases that occur in production enterprise environments. Here is how I debugged and resolved them:

1.The S3 Backend "Chicken and Egg" Paradox
    The Problem: When configuring a remote S3 backend for Terraform, a classic dependency loop occurs: Terraform needs an S3 bucket to store its state file, but if you declare that same bucket inside your code, Terraform will crash trying to provision a bucket that already exists globally (BucketAlreadyExists).

    The Fix: I decoupled the state-tracking infrastructure from the operational code. I manually bootstrapped the foundational S3 bucket, updated the backend configuration blocks, and surgically manipulated the state tracking engine using terraform state rm to bring the remote cloud architecture and local definitions into perfect harmony.

2. Overcoming Git 100MB Push Restrictions
    The Problem: During local environment initialization, a heavy binary file accidentally got tracked in the Git history, blocking all upstream pushes to GitHub due to standard file-size limits.

    The Fix: Simply deleting the file locally didn't fix the bloated commit history tree. I executed a Git "Orphan Branch" nuclear reset to completely wipe the tracked histories, rebuild a clean branch state, and successfully push the project code under the file limit ceiling.

3. Mitigating Configuration Drift
    The Problem: To rapidly troubleshoot live Python logic, edits were made directly within the live AWS Lambda console. This created "Configuration Drift" where the cloud state drifted out of sync with the codebase on my machine.

    The Fix: Adhering to strict DevOps philosophy, once the Boto3 code executed successfully in the staging console, I backported the absolute final fixes directly to the local files and verified them through a code pull before committing, ensuring GitHub remained the definitive Source of Truth.

## Local Setup & Deployment

Prerequisites
AWS CLI configured with appropriate administrator credentials.

Terraform CLI installed.

# Execution

- Clone the repository:

```bash
git clone [https://github.com/your-username/aws_cost_janitor.git](https://github.com/your-username/aws_cost_janitor.git)
cd aws_cost_janitor
```

- Initialize the working directory and remote backend:

```bash
terraform init
```

- Validate the code and view the infrastructure execution layout:

```bash
terraform plan
```

- Push your changes to the main branch to trigger the automated GitHub Actions workflow to safely execute the deployment:

```bash
git add .
git commit -m "feat: deploy automated cost janitor architecture"
git push origin main
```