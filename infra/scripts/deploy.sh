#!/bin/bash

set -e

echo "🚀 Deploying Queplan Infrastructure..."

# Check if terraform.tfvars exists
if [ ! -f "terraform/terraform.tfvars" ]; then
    echo "❌ terraform.tfvars not found. Please copy terraform.tfvars.example to terraform.tfvars and configure it."
    exit 1
fi

# Initialize Terraform
echo "📦 Initializing Terraform..."
cd terraform
terraform init

# Plan the deployment
echo "📋 Planning deployment..."
terraform plan

# Apply the deployment
echo "🔨 Applying deployment..."
terraform apply -auto-approve

echo "✅ Deployment completed!"
echo "📝 Check outputs:"
terraform output

cd ..
