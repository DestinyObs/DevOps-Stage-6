# ============================================================================
# SETUP GUIDE - DevOps Stage 6 Infrastructure
# ============================================================================

## Prerequisites Checklist

### 1. AWS Account Setup
- [ ] AWS account created and configured
- [ ] IAM user with programmatic access
- [ ] IAM permissions: EC2, VPC, EIP, KeyPair full access
- [ ] AWS CLI installed: `aws --version`
- [ ] AWS credentials configured: `aws configure`

### 2. Local Tools Installation
- [ ] Terraform >= 1.6.0: `terraform --version`
- [ ] Ansible >= 2.9: `ansible --version`
- [ ] Git installed and configured
- [ ] SSH client available

### 3. Domain Configuration
- [ ] Domain registered (e.g., destinyobs.mooo.com)
- [ ] DNS pointing to Elastic IP (will be output by Terraform)
- [ ] Or use services like No-IP, DuckDNS for free dynamic DNS

## Step-by-Step Setup

### Step 1: Generate SSH Key Pair (if you don't have one)

```bash
# Generate new SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/devops-stage6 -C "devops@stage6"

# This creates:
# - ~/.ssh/devops-stage6 (private key)
# - ~/.ssh/devops-stage6.pub (public key)
```

### Step 2: Configure Terraform Variables

```bash
cd infra/terraform

# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars  # or use your preferred editor
```

**Required values in terraform.tfvars:**

```hcl
# Your email for drift detection notifications
owner_email = "your-email@example.com"

# Your SSH public key content (entire content of .pub file)
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... your-key-here"

# Path to your SSH private key
ssh_private_key_path = "/home/username/.ssh/devops-stage6"

# Your domain name
domain_name = "your-domain.com"

# Restrict SSH access to your IP (recommended)
ssh_allowed_ips = ["YOUR.PUBLIC.IP.ADDRESS/32"]
```

**Find your public IP:**
```bash
curl ifconfig.me
```

**Get your SSH public key:**
```bash
cat ~/.ssh/devops-stage6.pub
```

### Step 3: Initialize Terraform

```bash
cd infra/terraform

# Initialize Terraform (downloads providers and modules)
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan
```

### Step 4: Deploy Infrastructure

```bash
# Apply infrastructure (will prompt for confirmation)
terraform apply

# Or auto-approve (careful!)
terraform apply -auto-approve
```

**What happens during apply:**
1. ✅ Creates VPC and networking resources
2. ✅ Launches EC2 instance with Ubuntu 22.04
3. ✅ Assigns Elastic IP (note this IP!)
4. ✅ Generates Ansible inventory
5. ✅ Waits for SSH to be ready
6. ✅ Runs Ansible to install Docker, Docker Compose, Git
7. ✅ Clones your repository
8. ✅ Builds and starts all Docker containers
9. ✅ Configures Traefik with SSL certificates

**Expected output:**
```
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:

application_url = "https://your-domain.com"
instance_public_ip = "54.XXX.XXX.XXX"
ssh_connection = "ssh -i ~/.ssh/devops-stage6 ubuntu@54.XXX.XXX.XXX"
```

### Step 5: Update DNS Records

```bash
# Get the Elastic IP from Terraform output
terraform output instance_public_ip

# Update your domain's A record to point to this IP
# Wait for DNS propagation (can take up to 48 hours, usually minutes)
```

**Verify DNS:**
```bash
nslookup your-domain.com
dig your-domain.com
```

### Step 6: Verify Deployment

```bash
# SSH to server
ssh -i ~/.ssh/devops-stage6 ubuntu@$(terraform output -raw instance_public_ip)

# Check Docker containers
sudo docker ps

# Check Traefik logs
sudo docker logs traefik

# Exit SSH
exit
```

**Test application:**
```bash
# Visit in browser
https://your-domain.com

# Or test with curl
curl https://your-domain.com
```

### Step 7: Setup GitHub Secrets (for CI/CD)

Go to GitHub Repository → Settings → Secrets and variables → Actions

**Add these secrets:**

| Secret Name | Value | Example |
|-------------|-------|---------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `SSH_PRIVATE_KEY` | Content of private key file | Contents of `~/.ssh/devops-stage6` |
| `SERVER_IP` | Your EC2 Elastic IP | `54.XXX.XXX.XXX` |
| `SMTP_USERNAME` | Gmail address for alerts | `your-email@gmail.com` |
| `SMTP_PASSWORD` | Gmail app password | (Generate in Gmail settings) |
| `NOTIFICATION_EMAIL` | Email to receive alerts | `your-email@gmail.com` |

**Gmail App Password:**
1. Enable 2FA on Gmail
2. Go to Google Account → Security → 2-Step Verification → App passwords
3. Generate app password for "Mail"
4. Use this password (not your regular Gmail password)

### Step 8: Setup GitHub Environment (for manual approval)

Go to GitHub Repository → Settings → Environments

1. Click "New environment"
2. Name: `production`
3. Add protection rules:
   - Check "Required reviewers"
   - Add yourself as reviewer
4. Save

Now drift detection will pause and wait for approval!

## Common Issues & Solutions

### Issue: SSH connection timeout

**Solution:**
```bash
# Check security group allows your IP
terraform output security_group_id

# Verify instance is running
aws ec2 describe-instances --instance-ids $(terraform output -raw instance_id)

# Try with verbose SSH
ssh -v -i ~/.ssh/devops-stage6 ubuntu@<IP>
```

### Issue: Terraform "unauthorized" error

**Solution:**
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Reconfigure if needed
aws configure
```

### Issue: Domain not resolving

**Solution:**
```bash
# Check DNS propagation
dig your-domain.com
nslookup your-domain.com

# Flush local DNS cache (Windows)
ipconfig /flushdns

# Flush local DNS cache (Mac)
sudo dscacheutil -flushcache
```

### Issue: SSL certificate not working

**Solution:**
```bash
# SSH to server
ssh -i ~/.ssh/devops-stage6 ubuntu@<IP>

# Check Traefik logs
sudo docker logs traefik

# Verify acme.json permissions
ls -la ~/DevOps-Stage-6/traefik/letsencrypt/

# Should be: -rw------- (600)
```

## Maintenance Commands

### Check infrastructure status
```bash
cd infra/terraform
terraform show
```

### See all outputs
```bash
terraform output
```

### Destroy infrastructure (careful!)
```bash
terraform destroy
```

### Re-run Ansible only
```bash
cd infra/ansible
ansible-playbook -i inventory/hosts.yml playbook.yml
```

### Re-run only dependencies
```bash
ansible-playbook -i inventory/hosts.yml playbook.yml --tags dependencies
```

### Re-run only deployment
```bash
ansible-playbook -i inventory/hosts.yml playbook.yml --tags deploy
```

## Testing Drift Detection

### Simulate drift
```bash
# Manually modify a resource in AWS Console
# For example, add a tag to the EC2 instance

# Run terraform plan
terraform plan

# Should detect drift and show changes
```

### Test CI/CD workflow
```bash
# Make a change to terraform code
echo "# test change" >> infra/terraform/main.tf

# Commit and push
git add .
git commit -m "Test drift detection"
git push origin main

# Check GitHub Actions
# Should receive email about drift
# Approve in GitHub UI
# Terraform apply runs automatically
```

## Success Criteria

- [ ] Terraform apply completes without errors
- [ ] All 12 resources created
- [ ] Elastic IP assigned and noted
- [ ] DNS pointing to Elastic IP
- [ ] Application accessible at https://your-domain.com
- [ ] Login page loads successfully
- [ ] Can login with admin/Admin123
- [ ] TODO dashboard displays
- [ ] GitHub Actions workflows configured
- [ ] Drift detection email received (after test)
- [ ] Manual approval works in CI/CD

## Next Steps

1. Test application functionality thoroughly
2. Take screenshots for submission
3. Document your setup in presentation slides
4. Practice explaining the architecture
5. Prepare for interview defense

## Support Resources

- Terraform Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- Ansible Docs: https://docs.ansible.com/
- AWS EC2 Docs: https://docs.aws.amazon.com/ec2/
- GitHub Actions: https://docs.github.com/en/actions
