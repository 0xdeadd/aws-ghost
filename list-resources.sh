#!/bin/bash

echo "=== EC2 Instances ==="
aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,Tags[?Key=='Name'].Value|[0]]" --output table

echo -e "\n=== Security Groups ==="
aws ec2 describe-security-groups --query "SecurityGroups[*].[GroupName,GroupId,Description]" --output table

echo -e "\n=== S3 Buckets ==="
aws s3 ls

echo -e "\n=== Key Pairs ==="
aws ec2 describe-key-pairs --query "KeyPairs[*].[KeyName,KeyPairId]" --output table 