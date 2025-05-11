#!/bin/bash

# Configuration
BUCKET_NAME="ghost-cms-storage-$(date +%Y%m%d%H%M%S)"  # Unique bucket name
REGION="us-east-1"  # Match your AWS region

# Create the bucket
echo "Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"

# Enable versioning for recovery purposes
echo "Enabling versioning on bucket"
aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled

# Set bucket policy for Ghost to access
POLICY='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGhostUploads",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::'$BUCKET_NAME'/content/images/*"
    }
  ]
}'

echo "Setting bucket policy"
aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy "$POLICY"

# Create folders for Ghost
echo "Creating folders for Ghost storage"
touch empty.tmp
aws s3 cp empty.tmp "s3://$BUCKET_NAME/content/images/"
aws s3 cp empty.tmp "s3://$BUCKET_NAME/content/themes/"
aws s3 cp empty.tmp "s3://$BUCKET_NAME/backups/"
rm empty.tmp

echo "S3 bucket setup complete!"
echo "Bucket Name: $BUCKET_NAME"
echo ""
echo "Add these settings to your Ghost config.production.json:"
echo '{
  "storage": {
    "active": "s3",
    "s3": {
      "accessKeyId": "${AWS_ACCESS_KEY_ID}",
      "secretAccessKey": "${AWS_SECRET_ACCESS_KEY}",
      "region": "'$REGION'",
      "bucket": "'$BUCKET_NAME'"
    }
  }
}' 