# Lacework IAC Scan Example

This project is an example of Infrastructure as Code (IAC) security scanning with Lacework. It contains Terraform configurations with intentional security issues that can be detected by Lacework's IAC scanner.

## Docs

OPA Rego Docs:
https://docs.fortinet.com/document/lacework-forticnapp/latest/administration-guide/651014/getting-started-with-opal

## Security Issues Included

The example Terraform code in the `example-terraform` directory contains numerous security issues across different AWS services, including:

### Storage & Data
- Unencrypted S3 buckets with public access
- Unencrypted databases (RDS, DynamoDB, Redshift, Neptune)
- Publicly accessible databases
- Unencrypted EBS volumes
- Elasticsearch domains without encryption or proper access controls
- SQS queues without encryption

### Networking & Compute
- Overly permissive security groups (0.0.0.0/0)
- EC2 instances with public IPs and unencrypted storage
- Load balancers using HTTP instead of HTTPS
- API Gateways without proper logging or encryption
- VPCs with insecure configurations

### Identity & Access Management
- IAM policies with wildcard permissions
- Weak password policies
- IAM users with console access but no MFA
- Access keys for IAM users
- Lambda functions with excessive permissions

### Logging & Monitoring
- CloudTrail without encryption or log validation
- Disabled GuardDuty
- Disabled Config recorder

## Usage
```bash
# Lacework CLI setup
lacework configure

# List installed components
lacework component list

# Install IAC component
lacework component install iac

# Update IAC component
lacework component update iac

# Scan the current directory
lacework iac scan
```

## Example Output
```
❯ lacework iac scan
[ Info] Lacework iac version v0.10.3
[ Info] Analyzing github.com/andrewbearsley/bimb-rmit
[ Info] Initialising terraform scan...
[ Info] Running terraform scan...
[ Info] Assessment complete, iac scan found 109 findings.
[ Info] Uploading 2 files to Lacework
[ Info] Assessment upload reference: 4bcace7d-6235-476b-b948-419ca368d7fe

POLICY-ID                        SEVERITY PASS  TITLE                                                                                               FILE-PATH                                                 LINE EXCEPTED EXCEPTION
ckv-aws-62                       Critical false Ensure IAM policies doesn't allow administrative privileges                                         lacework-iac-scan-example/example-terraform/main.tf       38   false
lacework-iac-aws-tls-1           Critical false Amazon ALBs should implement HTTPS                                                                  example-terraform/networking.tf                           87   false
ckv-aws-103                      Critical false Ensure that load balancer is using TLS 1.2                                                          lacework-iac-scan-example/example-terraform/networking.tf 87   false
ckv-aws-88                       Critical false EC2 instance should not have public IP                                                              lacework-iac-scan-example/example-terraform/main.tf       55   false
lacework-iac-aws-storage-16      Critical false Redshift cluster should not be publicly accessible                                                  example-terraform/storage.tf                              73   false
lacework-iac-aws-encryption-14   Critical false ElasticSearch domains should enforce HTTPS                                                          example-terraform/storage.tf                              33   false
lacework-iac-aws-tls-5           Critical false ElasticSearch domain endpoint uses outdated TLS policy                                              example-terraform/storage.tf                              33   false
ckv2-aws-29                      High     false Ensure public API gateway are protected by WAF                                                      lacework-iac-scan-example/example-terraform/networking.tf 56   false
lacework-iac-aws-encryption-8    High     false Elasticsearch domain is not encrypted at rest                                                       example-terraform/storage.tf                              33   false
lacework-iac-aws-network-14      High     false Ensure VPC Subnets Do Not Automatically Assign Public IP Addresses                                  example-terraform/networking.tf                           38   false
lacework-iac-aws-encryption-1    High     false Launch configuration with unencrypted EBS block device                                              example-terraform/main.tf                                 55   false
ckv-aws-63                       High     false Ensure no IAM policies documents allow "*" as a statement's actions                                 lacework-iac-scan-example/example-terraform/main.tf       38   false
lacework-iac-aws-network-6       High     false Ensure Redshift is not deployed outside of a VPC                                                    example-terraform/storage.tf                              73   false
ckv-aws-169                      High     false Ensure SNS topic policy is not public by only allowing specific services or principals to access it lacework-iac-scan-example/example-terraform/security.tf   101  false
lacework-iac-aws-storage-14      High     false Ensure Neptune Cluster storage is securely encrypted                                                example-terraform/storage.tf                              94   false
lacework-iac-aws-storage-1       High     false S3 bucket does not block public access                                                              example-terraform/main.tf                                 12   false
ckv2-aws-28                      High     false Ensure public facing ALB are protected by WAF                                                       lacework-iac-scan-example/example-terraform/networking.tf 78   false
lacework-iac-aws-storage-1       High     false S3 bucket does not block public access                                                              example-terraform/main.tf                                 6    false
ckv-aws-189                      High     false Ensure EBS Volume is encrypted by KMS using a customer managed Key (CMK)                            lacework-iac-scan-example/example-terraform/storage.tf    24   false
ckv-aws-17                       High     false Ensure all data stored in the RDS bucket is not public                                              lacework-iac-scan-example/example-terraform/main.tf       67   false
```