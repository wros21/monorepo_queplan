#!/bin/bash

set -e

echo "🗑️  Destroying Queplan Infrastructure..."

cd terraform

# Destroy the infrastructure
echo "💥 Destroying infrastructure..."
terraform destroy -auto-approve

echo "✅ Infrastructure destroyed!"

cd ..
