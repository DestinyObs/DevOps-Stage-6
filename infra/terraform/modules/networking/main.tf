# ============================================================================
# Networking Module - VPC, Subnet, Security Groups, Internet Gateway
# ============================================================================
# This module creates the network infrastructure for the application:
# - VPC with DNS support for hostname resolution
# - Internet Gateway for public internet access
# - Public subnet with automatic IP assignment
# - Route table for internet-bound traffic
# - Security group with firewall rules for SSH, HTTP, HTTPS, Traefik
# ============================================================================

# ----------------------------------------------------------------------------
# VPC - Virtual Private Cloud
# ----------------------------------------------------------------------------
# Creates an isolated network environment with DNS support enabled
# for service discovery and hostname resolution
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr           # Network IP range (e.g., 10.0.0.0/16)
  enable_dns_hostnames = true                    # Enable DNS hostnames for EC2 instances
  enable_dns_support   = true                    # Enable DNS resolution within VPC

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}

# ----------------------------------------------------------------------------
# Internet Gateway
# ----------------------------------------------------------------------------
# Allows communication between VPC resources and the internet
# Required for public-facing applications and outbound internet access
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id                       # Attach to our VPC

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-igw"
  })
}

# ----------------------------------------------------------------------------
# Public Subnet
# ----------------------------------------------------------------------------
# Subnet with direct internet access via Internet Gateway
# EC2 instances launched here get public IPs automatically
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr  # Subnet IP range (e.g., 10.0.1.0/24)
  availability_zone       = var.availability_zone   # AZ for resource placement
  map_public_ip_on_launch = true                    # Auto-assign public IPs to instances

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-public-subnet"
  })
}

# ----------------------------------------------------------------------------
# Route Table
# ----------------------------------------------------------------------------
# Defines routing rules for the subnet
# Routes all traffic (0.0.0.0/0) to Internet Gateway for public access
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Default route - Send all traffic to Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"                     # All destinations
    gateway_id = aws_internet_gateway.main.id    # Route through IGW
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-public-rt"
  })
}

# ----------------------------------------------------------------------------
# Route Table Association
# ----------------------------------------------------------------------------
# Associates the route table with the public subnet
# This enables internet access for all resources in the subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ----------------------------------------------------------------------------
# Security Group - Firewall Rules
# ----------------------------------------------------------------------------
# Controls inbound and outbound traffic to EC2 instances
# Acts as a virtual firewall at the instance level
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for DevOps Stage 6 application"
  vpc_id      = aws_vpc.main.id

  # Inbound Rule: SSH (Port 22)
  # Allow SSH access from specified IP addresses only for security
  ingress {
    description = "SSH from allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_ips            # Restrict to your IP for security
  }

  # Inbound Rule: HTTP (Port 80)
  # Required for Let's Encrypt HTTP challenge and HTTP→HTTPS redirect
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]                  # Public access
  }

  # Inbound Rule: HTTPS (Port 443)
  # Main application traffic - SSL/TLS encrypted
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]                  # Public access
  }

  # Inbound Rule: Traefik Dashboard (Port 8080)
  # Administrative dashboard - restricted to trusted IPs only
  ingress {
    description = "Traefik Dashboard from allowed IPs"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_ips            # Same restriction as SSH
  }

  # Outbound Rule: Allow All
  # Permits all outbound traffic for package downloads, API calls, etc.
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0                              # All ports
    to_port     = 0                              # All ports
    protocol    = "-1"                           # All protocols
    cidr_blocks = ["0.0.0.0/0"]                  # All destinations
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-app-sg"
  })
}
