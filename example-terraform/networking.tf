# VPC with default configuration
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  # Security issue: Default tenancy instead of dedicated
  instance_tenancy = "default"
  
  # Security issue: DNS hostnames not enabled
  enable_dns_hostnames = false
}

# Network ACL with overly permissive rules
resource "aws_network_acl" "open_acl" {
  vpc_id = aws_vpc.main.id

  # Security issue: Allow all inbound traffic
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  # Security issue: Allow all outbound traffic
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

# Subnet without automatic public IP assignment
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  
  # Security issue: Public subnet with auto-assign public IP
  map_public_ip_on_launch = true
}

# API Gateway without proper logging
resource "aws_api_gateway_rest_api" "insecure_api" {
  name        = "insecure-api"
  description = "Insecure API Gateway"
  
  # Security issue: No endpoint configuration specified
  # Should use PRIVATE or EDGE endpoint types
}

# API Gateway stage without logging or encryption
resource "aws_api_gateway_stage" "insecure_stage" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.insecure_api.id
  stage_name    = "prod"
  
  # Security issue: No access logging
  # access_log_settings not defined
  
  # Security issue: No encryption
  # cache_cluster_enabled = true but no encryption specified
}

# Placeholder for deployment (required by stage)
resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.insecure_api.id
  
  lifecycle {
    create_before_destroy = true
  }
}

# Load balancer with insecure listener
resource "aws_lb" "insecure_lb" {
  name               = "insecure-lb"
  internal           = false
  load_balancer_type = "application"
  
  # Security issue: No access logs configured
}

# Insecure HTTP listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.insecure_lb.arn
  port              = "80"
  protocol          = "HTTP"  # Security issue: Using HTTP instead of HTTPS
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

# Target group for the load balancer
resource "aws_lb_target_group" "example" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"  # Security issue: Using HTTP instead of HTTPS
  vpc_id   = aws_vpc.main.id
}
