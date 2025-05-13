# DynamoDB table without encryption
resource "aws_dynamodb_table" "insecure_table" {
  name           = "insecure-dynamodb-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
  
  # Security issue: No server-side encryption
  # server_side_encryption not defined
  
  # Security issue: No point-in-time recovery
  point_in_time_recovery {
    enabled = false
  }
}

# EBS volume without encryption
resource "aws_ebs_volume" "insecure_volume" {
  availability_zone = "us-west-2a"
  size              = 10
  
  # Security issue: No encryption
  encrypted = false
}

# Elasticsearch domain without encryption
resource "aws_elasticsearch_domain" "insecure_es" {
  domain_name           = "insecure-es"
  elasticsearch_version = "7.10"
  
  cluster_config {
    instance_type = "t3.small.elasticsearch"
  }
  
  # Security issue: No encryption at rest
  encrypt_at_rest {
    enabled = false
  }
  
  # Security issue: No node-to-node encryption
  node_to_node_encryption {
    enabled = false
  }
  
  # Security issue: No HTTPS enforcement
  domain_endpoint_options {
    enforce_https = false
  }
  
  # Security issue: Open access policy
  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"  # Security issue: Open to everyone
        }
        Action   = "es:*"  # Security issue: All actions
        Resource = "*"
      }
    ]
  })
}

# Redshift cluster without encryption
resource "aws_redshift_cluster" "insecure_redshift" {
  cluster_identifier = "insecure-redshift"
  database_name      = "mydb"
  master_username    = "admin"
  master_password    = "Insecure123"  # Security issue: Hardcoded password
  node_type          = "dc2.large"
  cluster_type       = "single-node"
  
  # Security issue: No encryption
  encrypted = false
  
  # Security issue: Publicly accessible
  publicly_accessible = true
  
  # Security issue: No logging
  logging {
    enable = false
  }
}

# Neptune cluster without encryption
resource "aws_neptune_cluster" "insecure_neptune" {
  cluster_identifier                  = "insecure-neptune"
  engine                              = "neptune"
  skip_final_snapshot                 = true
  apply_immediately                   = true
  
  # Security issue: No encryption
  storage_encrypted                   = false
  
  # Security issue: No IAM authentication
  iam_database_authentication_enabled = false
}

# SQS queue without encryption
resource "aws_sqs_queue" "insecure_queue" {
  name = "insecure-queue"
  
  # Security issue: No encryption
  # kms_master_key_id not defined
  # kms_data_key_reuse_period_seconds not defined
}
