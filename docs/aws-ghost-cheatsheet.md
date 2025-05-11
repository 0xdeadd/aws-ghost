# AWS Ghost Deployment Cheat Sheet

## AWS CLI Commands

### Check Configuration
```bash
# Verify AWS credentials and region
aws configure list

# Get current identity
aws sts get-caller-identity
```

### EC2 Management
```bash
# List EC2 instances
aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]" --output table

# Stop an instance
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Start an instance
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Terminate an instance
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0
```

### S3 Management
```bash
# List all S3 buckets
aws s3 ls

# List files in a bucket
aws s3 ls s3://your-bucket-name/

# Upload a file to S3
aws s3 cp local-file.txt s3://your-bucket-name/

# Download a file from S3
aws s3 cp s3://your-bucket-name/remote-file.txt local-file.txt

# Delete a file from S3
aws s3 rm s3://your-bucket-name/file-to-delete.txt

# Delete a bucket (must be empty)
aws s3 rb s3://your-bucket-name
```

## Ghost Script Commands

### Deploy and Configure
```bash
# Launch EC2 instance
./deploy-ghost-ec2.sh

# Set up S3 storage for Ghost
./setup-s3-storage.sh

# List all resources
./list-resources.sh

# Clean up all resources
./cleanup-resources.sh
```

### SSH Access
```bash
# Connect to EC2 instance
ssh -i ~/.ssh/ghost-key.pem ubuntu@YOUR_INSTANCE_IP
```

### Ghost Admin Commands (on EC2)
```bash
# Navigate to Ghost directory
cd /var/www/ghost

# Install Ghost
ghost install

# Restart Ghost
ghost restart

# Update Ghost
ghost update

# View logs
ghost log

# Get Ghost status
ghost status
```

## Quick Reference

| Task | Command |
|------|---------|
| Deploy Ghost | `./deploy-ghost-ec2.sh` |
| Set up storage | `./setup-s3-storage.sh` |
| List resources | `./list-resources.sh` |
| Clean up resources | `./cleanup-resources.sh` |
| Connect to instance | `ssh -i ~/.ssh/ghost-key.pem ubuntu@YOUR_INSTANCE_IP` | 