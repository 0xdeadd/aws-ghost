# AWS Setup Guide for Ghost Deployment

This document outlines how to set up your AWS environment for deploying Ghost CMS.

## AWS Configuration

### IAM User Setup

We've configured an IAM user with the necessary permissions to deploy and manage Ghost:

1. User: `clint` with Admin access
2. Custom policy: `GhostDeploymentPolicy` with permissions for:
   - EC2 instance management
   - S3 bucket operations
   - IAM role management

The policy JSON is stored in `ghost-policy.json`.

### SSH Key Pair

Created a new key pair for SSH access to EC2 instances:

```bash
# Key details
Key name: ghost-key
Key file: ~/.ssh/ghost-key.pem
Permissions: 400 (read-only for owner)
```

Always keep this key secure and never share it.

## Deployment Scripts

### `deploy-ghost-ec2.sh`

This script creates and launches an EC2 instance with Ghost prerequisites:

- Ubuntu 20.04 LTS
- t2.micro instance type (free tier eligible)
- Security group with ports 22, 80, 443 and 2368 open
- Pre-installation of Node.js, Nginx, and Ghost CLI

Usage:
```bash
./deploy-ghost-ec2.sh
```

### `setup-s3-storage.sh`

Creates an S3 bucket for Ghost media storage with:

- Unique bucket name based on timestamp
- Versioning enabled
- Public read access for media content
- Proper folder structure for Ghost

Usage:
```bash
./setup-s3-storage.sh
```

### `list-resources.sh`

Lists all AWS resources related to your Ghost deployment:

- EC2 instances
- Security groups
- S3 buckets
- Key pairs

Usage:
```bash
./list-resources.sh
```

### `cleanup-resources.sh`

Cleans up all AWS resources created for Ghost:

- Terminates EC2 instances
- Deletes security groups
- Empties and removes S3 buckets (with confirmation prompt)

Usage:
```bash
./cleanup-resources.sh
```

## Full Deployment Workflow

1. **Verify AWS Configuration**
   ```bash
   aws configure list
   ```

2. **Deploy EC2 Instance**
   ```bash
   ./deploy-ghost-ec2.sh
   ```

3. **Set Up S3 Storage**
   ```bash
   ./setup-s3-storage.sh
   ```

4. **SSH Into Your Instance**
   ```bash
   ssh -i ~/.ssh/ghost-key.pem ubuntu@YOUR_INSTANCE_IP
   ```

5. **Complete Ghost Setup**
   ```bash
   cd /var/www/ghost
   ghost install
   ```

6. **Monitor Resources**
   ```bash
   ./list-resources.sh
   ```

7. **Clean Up When Done**
   ```bash
   ./cleanup-resources.sh
   ```

## Troubleshooting

- If permissions errors occur, verify your IAM policies are correctly attached
- For connectivity issues, check security group rules
- If instance doesn't start properly, check EC2 console for system logs

## Cost Considerations

- The t2.micro instance is free tier eligible (if under 750 hours/month)
- S3 has costs based on storage and data transfer
- Always clean up unused resources to avoid unexpected charges 