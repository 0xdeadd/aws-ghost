# Getting Started with AWS Ghost Deployment

This guide walks you through deploying Ghost CMS on AWS using the scripts in this repository.

## Prerequisites

1. AWS CLI installed and configured with appropriate credentials
2. An EC2 key pair for SSH access (`.pem` file)
3. Basic knowledge of AWS services

## Step 1: Set Up EC2 Instance

1. Edit `deploy-ghost-ec2.sh` and update the following variables:
   - `KEY_NAME`: Your EC2 key pair name
   - `INSTANCE_TYPE`: Change if you need a different size
   - `AMI_ID`: Update if you want a different OS version

2. Run the EC2 deployment script:
   ```bash
   ./deploy-ghost-ec2.sh
   ```

3. Note the Public IP address provided in the output

4. SSH into your instance:
   ```bash
   ssh -i ~/.ssh/YOUR_KEY.pem ubuntu@YOUR_PUBLIC_IP
   ```

5. Complete the Ghost installation:
   ```bash
   cd /var/www/ghost
   ghost install
   ```

## Step 2: Set Up S3 Storage

1. Run the S3 storage setup script:
   ```bash
   ./setup-s3-storage.sh
   ```

2. Note the bucket name and configuration details from the output

3. Install the S3 adapter on your Ghost instance:
   ```bash
   cd /var/www/ghost
   npm install ghost-storage-adapter-s3
   ```

4. Update your Ghost config file with the S3 settings from the script output:
   ```bash
   nano /var/www/ghost/config.production.json
   ```

## Step 3: Finalize Setup

1. Configure a domain name in Route 53 (optional)
2. Set up SSL with Let's Encrypt
3. Configure backups

## Troubleshooting

- Check EC2 instance status in the AWS Console
- Verify security group rules allow necessary traffic
- Check Ghost logs for errors: `/var/www/ghost/content/logs/`

## Additional Resources

- [Ghost Documentation](https://ghost.org/docs/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/) 