module "transfer-bucket" {
  source = "https://github.com/nancy-cai/terraform-s3.git//module"
  providers = {
    aws.replication = aws.replication
  }
  environment-name                  = var.environment-name
  bucket-prefix                     = var.transfer-bucket-prefix
  base-domain                       = var.transfer-base-domain
  replication-enabled               = var.transfer-replication-enabled
  logs-expiration                   = var.transfer-logs-expiration
  enable-versioning                 = var.transfer-enable-versioning
  force-destroy-s3-buckets          = var.transfer-force-destroy-s3-buckets
}
