#!/bin/sh

SECURITY_GROUP_NAME="bayguh-dev-security-group-terraform"
VPC_NAME="bayguh-dev-vpc"
VPC_ID=$(eval "aws ec2 describe-vpcs | jq -r '.Vpcs[] | select(.Tags[].Value==\"${VPC_NAME}\") | .VpcId '")
echo "VPC_ID: ${VPC_ID}"

INSTANCE_NAME="bayguh-dev-terraform"
IMAGE_ID="ami-da9e2cbc"
INSTANCE_TYPE="t2.micro"
KEY_NAME="access-key"
SUBNET_NAME="bayguh-dev-subnet-public01"
SUBNET_ID=$(eval "aws ec2 describe-subnets | jq -r '.Subnets[] | select(.Tags) | select(.Tags[].Value==\"${SUBNET_NAME}\") | .SubnetId '")
echo "SUBNET_ID: ${SUBNET_ID}"

# terraformサーバ作成
_create_terraform_server() {
    # セキュリティーグループ作成
    SECURITY_GROUP_ID=$(eval "aws ec2 create-security-group --group-name \"${SECURITY_GROUP_NAME}\" --vpc-id \"${VPC_ID}\" --description \""terraform security group\"" | jq -r '.GroupId' ")
    echo "SECURITY_GROUP_ID: ${SECURITY_GROUP_ID}"
    aws ec2 create-tags --resources ${SECURITY_GROUP_ID} --tags Key=Name,Value=${SECURITY_GROUP_NAME}

    # インスタンス作成
    INSTANCE_ID=$(eval "aws ec2 run-instances --count 1 --image-id \"${IMAGE_ID}\" --instance-type \"${INSTANCE_TYPE}\" --key-name \"${KEY_NAME}\" --subnet-id \"${SUBNET_ID}\" --security-group-ids \"${SECURITY_GROUP_ID}\" | jq -r '.Instances[].InstanceId' ")
    echo "INSTANCE_ID: ${INSTANCE_ID}"
    aws ec2 create-tags --resources ${INSTANCE_ID} --tags Key=Name,Value=${INSTANCE_NAME}

    # インスタンス初期化まで待つ
    sleep 30s

    # 静的IP作成
    ALLOCATION_ID=$(eval "aws ec2 allocate-address --domain vpc | jq -r '.AllocationId' ")
    echo "ALLOCATION_ID: ${ALLOCATION_ID}"
    aws ec2 associate-address --allocation-id ${ALLOCATION_ID} --instance ${INSTANCE_ID}
}

_create_terraform_server
