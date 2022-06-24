module "pay-at-table-transfer-family" {
  source                            = "https://github.com/nancy-cai/terraform-transfer-family.git//module"
  providers = {
    aws.replication = aws.replication
  }
  environment-name                  = "dev"
  availability-zones                = "ap-southeast-2"
  endpoint-type                     = "VPC"
  transfer-protocols                = ["SFTP"]
  transfer-vpc-id                   = "xxxxxx"
  transfer-subnet-ids               = ["xxxxxxx"]
  security-group-ids                = ["xxxxxxx"]
  transfer-domain                   = "S3"
  identity-provider-type            = "SERVICE_MANAGED"
  hosted-zone                       = "dev.example.com"
  sftp-sub-domain                   = "sftp"
  sftp-users                        = { nancy = "nancy" }
  sftp-users-ssh-key                = { "nancy":"ssh-rsa xxxxxxx" }
  sftp-user-role-trust-services     = ["transfer.amazonaws.com"]
  transfer-bucket-prefix            = "sftp"
  transfer-base-domain              = "dev.example.com"
  transfer-replication-enabled      = true
  transfer-logs-expiration          = 90
  transfer-enable-versioning        = false
  transfer-force-destroy-s3-buckets = true
  sftp-record-ttl                   = 60
}
