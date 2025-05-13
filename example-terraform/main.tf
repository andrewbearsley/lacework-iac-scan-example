provider "aws" {
  region = "us-west-2"
}

# Insecure S3 bucket with public access
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "my-insecure-bucket-example"
  acl    = "public-read"  # Security issue: Public read access
}

# S3 bucket without encryption
resource "aws_s3_bucket" "unencrypted_bucket" {
  bucket = "my-unencrypted-bucket-example"
  # Missing server-side encryption configuration
}

# Security group with overly permissive rules
resource "aws_security_group" "overly_permissive_sg" {
  name        = "allow-all-traffic"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Security issue: All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Security issue: Open to the world
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM policy with admin access
resource "aws_iam_policy" "admin_policy" {
  name        = "AdminAccessPolicy"
  description = "Provides admin access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "*"  # Security issue: Wildcard permission
        Effect   = "Allow"
        Resource = "*"  # Security issue: All resources
      },
    ]
  })
}

# EC2 instance with public IP
resource "aws_instance" "public_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  associate_public_ip_address = true  # Security issue: Public IP exposure
  
  root_block_device {
    encrypted = false  # Security issue: Unencrypted storage
  }
}

# RDS instance without encryption
resource "aws_db_instance" "unencrypted_db" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = "admin"
  password             = "password123"  # Security issue: Hardcoded credentials
  parameter_group_name = "default.mysql5.7"
  publicly_accessible  = true  # Security issue: Publicly accessible database
  storage_encrypted    = false  # Security issue: Unencrypted storage
  skip_final_snapshot  = true
}

# CloudTrail without encryption or log validation
resource "aws_cloudtrail" "insecure_trail" {
  name                          = "insecure-trail"
  s3_bucket_name                = aws_s3_bucket.unencrypted_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = false  # Security issue: Not multi-region
  enable_log_file_validation    = false  # Security issue: No log validation
  kms_key_id                    = null   # Security issue: No encryption
}

# Lambda function with excessive permissions
resource "aws_lambda_function" "insecure_lambda" {
  filename      = "lambda_function.zip"
  function_name = "insecure_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"  # Security issue: Outdated runtime
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_admin" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"  # Security issue: Excessive permissions
}
