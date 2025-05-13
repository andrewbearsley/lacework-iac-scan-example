# IAM user with console access but no MFA
resource "aws_iam_user" "insecure_user" {
  name = "insecure-user"
  path = "/"
}

# Security issue: Console access without MFA
resource "aws_iam_user_login_profile" "insecure_profile" {
  user    = aws_iam_user.insecure_user.name
  password_reset_required = false  # Security issue: No password reset required
  pgp_key = null  # Security issue: No encryption for password
}

# Security issue: Access keys for IAM user (not recommended)
resource "aws_iam_access_key" "insecure_key" {
  user = aws_iam_user.insecure_user.name
}

# Security issue: Overly permissive IAM policy
resource "aws_iam_user_policy" "insecure_policy" {
  name = "insecure-policy"
  user = aws_iam_user.insecure_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
          "ec2:*",
          "rds:*"
        ]
        Effect   = "Allow"
        Resource = "*"  # Security issue: No resource constraints
      }
    ]
  })
}

# Security issue: Password policy too weak
resource "aws_iam_account_password_policy" "weak_password_policy" {
  minimum_password_length        = 6  # Security issue: Too short (should be at least 14)
  require_lowercase_characters   = false
  require_uppercase_characters   = false
  require_numbers                = false
  require_symbols                = false
  allow_users_to_change_password = true
  password_reuse_prevention      = 0  # Security issue: No password reuse prevention
  max_password_age               = 0  # Security issue: Passwords never expire
}

# Security issue: KMS key with no rotation
resource "aws_kms_key" "insecure_key" {
  description             = "Insecure KMS key"
  deletion_window_in_days = 7
  enable_key_rotation     = false  # Security issue: No key rotation
}

# Security issue: GuardDuty not enabled
resource "aws_guardduty_detector" "disabled_detector" {
  enable = false  # Security issue: GuardDuty disabled
}

# Security issue: Config recorder not enabled
resource "aws_config_configuration_recorder" "disabled_recorder" {
  name     = "disabled-recorder"
  role_arn = aws_iam_role.config_role.arn
  
  recording_group {
    all_supported = false  # Security issue: Not recording all resources
  }
}

resource "aws_config_configuration_recorder_status" "disabled_status" {
  name       = aws_config_configuration_recorder.disabled_recorder.name
  is_enabled = false  # Security issue: Config recorder disabled
}

resource "aws_iam_role" "config_role" {
  name = "config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

# Security issue: Insecure SNS topic policy
resource "aws_sns_topic" "insecure_topic" {
  name = "insecure-topic"
}

resource "aws_sns_topic_policy" "insecure_policy" {
  arn = aws_sns_topic.insecure_topic.arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"  # Security issue: Open to everyone
        Action = "sns:Publish"
        Resource = aws_sns_topic.insecure_topic.arn
      }
    ]
  })
}
