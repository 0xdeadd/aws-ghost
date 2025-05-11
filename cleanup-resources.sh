#!/bin/bash

# Script to clean up Ghost deployment resources

# Get instance IDs with the ghost-cms tag
INSTANCE_IDS=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=ghost-cms" "Name=instance-state-name,Values=running,stopped,pending,stopping" \
  --query "Reservations[*].Instances[*].[InstanceId]" \
  --output text)

if [ -n "$INSTANCE_IDS" ]; then
  echo "Terminating EC2 instances: $INSTANCE_IDS"
  aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
  
  echo "Waiting for instances to terminate..."
  aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS
  echo "Instances terminated."
else
  echo "No Ghost instances found."
fi

# Get the security group ID
SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=ghost-sg" \
  --query "SecurityGroups[0].GroupId" \
  --output text)

if [ "$SG_ID" != "None" ] && [ -n "$SG_ID" ]; then
  echo "Deleting security group: $SG_ID"
  aws ec2 delete-security-group --group-id $SG_ID
  echo "Security group deleted."
else
  echo "No Ghost security group found."
fi

# List ghost S3 buckets
BUCKETS=$(aws s3 ls | grep "ghost-cms-storage" | awk '{print $3}')

if [ -n "$BUCKETS" ]; then
  echo "Found Ghost S3 buckets:"
  echo "$BUCKETS"
  
  read -p "Do you want to delete these buckets? (y/n): " confirm
  if [ "$confirm" = "y" ]; then
    for bucket in $BUCKETS; do
      echo "Emptying bucket $bucket..."
      aws s3 rm s3://$bucket --recursive
      
      echo "Deleting bucket $bucket..."
      aws s3 rb s3://$bucket
    done
    echo "S3 buckets deleted."
  else
    echo "Skipping S3 bucket deletion."
  fi
else
  echo "No Ghost S3 buckets found."
fi

echo "Cleanup complete!" 