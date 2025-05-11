# AWS Ghost Deployment

This project contains configuration and scripts for deploying Ghost CMS on AWS infrastructure.

## Setup

1. AWS CLI is already configured with credentials and region (us-east-1)
2. Infrastructure is defined as code using shell scripts with AWS CLI commands

## Components

- EC2 instance(s) for hosting Ghost
- S3 for static assets and backups
- IAM roles and policies for proper access management
- Security groups for network access control

## Documentation

- [AWS Setup Guide](docs/aws-setup-guide.md) - Complete guide to setting up AWS for Ghost
- [AWS Ghost Cheatsheet](docs/aws-ghost-cheatsheet.md) - Quick reference commands
- [Getting Started](docs/getting-started.md) - Step-by-step guide to deploying Ghost

## Scripts

- `deploy-ghost-ec2.sh` - Deploys an EC2 instance with Ghost prerequisites
- `setup-s3-storage.sh` - Sets up S3 storage for Ghost media
- `list-resources.sh` - Lists all AWS resources for this project
- `cleanup-resources.sh` - Cleans up all AWS resources when done 