#!/bin/bash

# Configuration
INSTANCE_TYPE="t4g.small"  # Updated to free tier eligible ARM instance
AMI_ID="ami-0bb72bbbe14b006c1"  # Ubuntu 22.04 LTS ARM64 in us-east-1
KEY_NAME="ghost-key"
SECURITY_GROUP="resume-sg"
INSTANCE_NAME="resume-site"

# Base64-encoded HTML resume
RESUME_HTML_B64="PCFET0NUWVBFIGh0bWw+CjxodG1sIGxhbmc9ImVuIj4KPGhlYWQ+CiAgPG1ldGEgY2hhcnNldD0iVVRGLTgiPgogIDxtZXRhIG5hbWU9InZpZXdwb3J0IiBjb250ZW50PSJ3aWR0aD1kZXZpY2Utd2lkdGgsIGluaXRpYWwtc2NhbGU9MS4wIj4KICA8dGl0bGU+Q2xpbnQncyBSZXN1bWU8L3RpdGxlPgogIDxzdHlsZT4KICAgIGJvZHkgeyBmb250LWZhbWlseTogQXJpYWwsIHNhbnMtc2VyaWY7IG1hcmdpbjogNDBweDsgYmFja2dyb3VuZDogI2Y5ZjlmOTsgfQogICAgLmNvbnRhaW5lciB7IG1heC13aWR0aDogNzAwcHg7IG1hcmdpbjogYXV0bzsgYmFja2dyb3VuZDogI2ZmZjsgcGFkZGluZzogMzBweDsgYm9yZGVyLXJhZGl1czogOHB4OyBib3gtc2hhZG93OiAwIDJweCA4cHggI2VlZTsgfQogICAgaDEgeyBjb2xvcjogIzJjM2U1MDsgfQogICAgaDIgeyBjb2xvcjogIzM0NDk1ZTsgbWFyZ2luLXRvcDogMzBweDsgfQogICAgdWwgeyBwYWRkaW5nLWxlZnQ6IDIwcHg7IH0KICA8L3N0eWxlPgo8L2hlYWQ+Cjxib2R5PgogIDxkaXYgY2xhc3M9ImNvbnRhaW5lciI+CiAgICA8aDE+Q2xpbnQ8L2gxPgogICAgPGgyPlByb2Zlc3Npb25hbCBTdW1tYXJ5PC9oMj4KICAgIDxwPlJlc3VsdHMtZHJpdmVuIHByb2Zlc3Npb25hbCB3aXRoIGV4cGVyaWVuY2UgaW4gY2xvdWQgaW5mcmFzdHJ1Y3R1cmUsIHdlYiBkZXZlbG9wbWVudCwgYW5kIGF1dG9tYXRpb24uIFBhc3Npb25hdGUgYWJvdXQgYnVpbGRpbmcgc2NhbGFibGUgc29sdXRpb25zIGFuZCBkZWxpdmVyaW5nIHZhbHVlIHRocm91Z2ggdGVjaG5vbG9neS48L3A+CiAgICA8aDI+U2tpbGxzPC9oMj4KICAgIDx1bD4KICAgICAgPGxpPkFXUyAmIENsb3VkIEluZnJhc3RydWN0dXJlPC9saT4KICAgICAgPGxpPkxpbnV4ICYgQXV0b21hdGlvbjwvbGk+CiAgICAgIDxsaT5XZWIgRGV2ZWxvcG1lbnQgKEhUTUwsIENTUywgSlMsIE5vZGUuanMpPC9saT4KICAgICAgPGxpPkRldk9wcyAmIENJL0NEPC9saT4KICAgIDwvdWw+CiAgICA8aDI+Q29udGFjdDwvaDI+CiAgICA8cD5FbWFpbDogdW5kYXRhQGVtYWlsLmNvbTxicj5MaW5rZWRJbjogbGlua2VkaW4uY29tL2luL3lvdXJwcm9maWxlPC9wPgogIDwvZGl2Pgo8L2JvZHk+CjwvaHRtbD4K"

# Create security group if it doesn't exist
if ! aws ec2 describe-security-groups --group-names "$SECURITY_GROUP" > /dev/null 2>&1; then
  echo "Creating security group: $SECURITY_GROUP"
  aws ec2 create-security-group --group-name "$SECURITY_GROUP" --description "Security group for Resume Site"
  # Allow SSH
  aws ec2 authorize-security-group-ingress --group-name "$SECURITY_GROUP" --protocol tcp --port 22 --cidr 0.0.0.0/0
  # Allow HTTP
  aws ec2 authorize-security-group-ingress --group-name "$SECURITY_GROUP" --protocol tcp --port 80 --cidr 0.0.0.0/0
fi

# Create user data for automatic Nginx and resume setup
USER_DATA=$(cat <<EOF
#!/bin/bash
apt-get update
apt-get install -y nginx

echo "$RESUME_HTML_B64" | base64 -d > /var/www/html/index.html
systemctl restart nginx
EOF
)

USER_DATA_B64=$(echo "$USER_DATA" | base64 -w 0)

# Launch the instance
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-groups "$SECURITY_GROUP" \
  --user-data "$USER_DATA_B64" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Launching Resume Site instance with ID: $INSTANCE_ID"
echo "Waiting for the instance to be running..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

# Get public IP address
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

echo "Resume site is now running!"
echo "Public IP: $PUBLIC_IP"
echo ""
echo "Visit: http://$PUBLIC_IP to view your resume."
echo "SSH: ssh -i ~/.ssh/$KEY_NAME.pem ubuntu@$PUBLIC_IP"
echo "To update your resume, edit /var/www/html/index.html on the server." 