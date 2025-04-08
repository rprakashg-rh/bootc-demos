#!/bin/bash

# Exit as soon as any step fails with non-zero return code
set -e 

# -----------------------------
# Configuration
# -----------------------------
VPC_CIDR="10.0.0.0/16"
PUBLIC_SUBNET_CIDR="10.0.1.0/24"
PRIVATE_SUBNET_CIDR="10.0.2.0/24"
REGION="us-west-2"
AZ="us-west-2a"
NAME="edge-network"

# -----------------------------
# 1. Create VPC
# -----------------------------
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --region $REGION \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=$NAME}]' \
  --query 'Vpc.VpcId' --output text)

echo "VPC created: $VPC_ID"

# -----------------------------
# 2. Create Internet Gateway
# -----------------------------
IGW_ID=$(aws ec2 create-internet-gateway \
  --region $REGION \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=MyIGW}]' \
  --query 'InternetGateway.InternetGatewayId' --output text)

aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID --region $REGION
echo "Internet Gateway created and attached: $IGW_ID"

# -----------------------------
# 3. Create Subnets
# -----------------------------
PUB_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $PUBLIC_SUBNET_CIDR \
  --availability-zone $AZ \
  --region $REGION \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=PublicSubnet}]' \
  --query 'Subnet.SubnetId' --output text)

PRIV_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $PRIVATE_SUBNET_CIDR \
  --availability-zone $AZ \
  --region $REGION \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=PrivateSubnet}]' \
  --query 'Subnet.SubnetId' --output text)

echo "Public Subnet: $PUB_SUBNET_ID"
echo "Private Subnet: $PRIV_SUBNET_ID"

# Enable auto-assign public IPs for public subnet
aws ec2 modify-subnet-attribute --subnet-id $PUB_SUBNET_ID --map-public-ip-on-launch --region $REGION

# -----------------------------
# 4. Create Route Tables
# -----------------------------
# Public Route Table
PUB_RTB_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --region $REGION \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=PublicRouteTable}]' \
  --query 'RouteTable.RouteTableId' --output text)

# Create route to Internet Gateway
aws ec2 create-route \
  --route-table-id $PUB_RTB_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID \
  --region $REGION

# Associate public subnet with route table
aws ec2 associate-route-table \
  --subnet-id $PUB_SUBNET_ID \
  --route-table-id $PUB_RTB_ID \
  --region $REGION

# -----------------------------
# 5. Create NAT Gateway for Private Subnet
# -----------------------------
# Allocate Elastic IP
EIP_ALLOC_ID=$(aws ec2 allocate-address --domain vpc --region $REGION --query 'AllocationId' --output text)

# Create NAT Gateway in the public subnet
NAT_GW_ID=$(aws ec2 create-nat-gateway \
  --subnet-id $PUB_SUBNET_ID \
  --allocation-id $EIP_ALLOC_ID \
  --region $REGION \
  --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=MyNATGW}]' \
  --query 'NatGateway.NatGatewayId' --output text)

echo "Waiting for NAT Gateway to become available..."
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_ID --region $REGION

# -----------------------------
# 6. Private Route Table
# -----------------------------
PRIV_RTB_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --region $REGION \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=PrivateRouteTable}]' \
  --query 'RouteTable.RouteTableId' --output text)

# Create route to NAT Gateway
aws ec2 create-route \
  --route-table-id $PRIV_RTB_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --nat-gateway-id $NAT_GW_ID \
  --region $REGION

# Associate private subnet with private route table
aws ec2 associate-route-table \
  --subnet-id $PRIV_SUBNET_ID \
  --route-table-id $PRIV_RTB_ID \
  --region $REGION

# -----------------------------
# Done!
# -----------------------------
echo "✅ VPC setup complete!"
echo "VPC ID: $VPC_ID"
echo "Public Subnet ID: $PUB_SUBNET_ID"
echo "Private Subnet ID: $PRIV_SUBNET_ID"
