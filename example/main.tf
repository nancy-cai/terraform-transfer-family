module "pay-at-table-transfer-family" {
  count                             = var.create-transfer-server ? 1 : 0
  source                            = "/global_modules/transfer-family"
  providers = {
    aws.replication = aws.replication
  }
  module-name                       = var.module-name
  environment-name                  = var.environment-name
  availability-zones                = var.availability-zones
  endpoint-type                     = var.endpoint-type
  transfer-protocols                = var.transfer-protocols
  transfer-vpc-id                   = module.pay-at-table-vpc.vpc-id
  transfer-subnet-ids               = module.pay-at-table-vpc.public-subnet-ids
  security-group-ids                = [module.pay-at-table-vpc.default-vpc-security-group-id]
  transfer-domain                   = var.transfer-domain
  identity-provider-type            = var.identity-provider-type
  api-gw-url                        = var.api-gw-url
  host-key                          = var.host-key
  hosted-zone                       = var.hosted-zone
  sftp-sub-domain                   = var.sftp-sub-domain
  sftp-users                        = var.sftp-users
  sftp-users-ssh-key                = jsondecode(data.aws_ssm_parameter.transfer-user-key[0].value)
  sftp-user-role-trust-services     = var.sftp-user-role-trust-services
  transfer-bucket-prefix            = var.transfer-bucket-prefix
  transfer-base-domain              = var.transfer-base-domain
  transfer-replication-enabled      = var.transfer-replication-enabled
  transfer-logs-expiration          = var.transfer-logs-expiration
  transfer-enable-versioning        = var.transfer-enable-versioning
  transfer-force-destroy-s3-buckets = var.transfer-force-destroy-s3-buckets
  ftps-record-ttl                   = var.ftps-record-ttl
  sftp-record-ttl                   = var.sftp-record-ttl
}
