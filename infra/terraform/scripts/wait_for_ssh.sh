#!/bin/bash
set -e

SSH_KEY=$1
SSH_USER=$2
SERVER_IP=$3

echo "Waiting for SSH to be ready..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
  if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=5 "${SSH_USER}@${SERVER_IP}" "echo 'SSH is ready'" 2>/dev/null; then
    echo "SSH connection successful!"
    exit 0
  fi
  attempt=$((attempt + 1))
  echo "Attempt $attempt/$max_attempts failed. Retrying in 10 seconds..."
  sleep 10
done

echo "Failed to connect via SSH after $max_attempts attempts"
exit 1