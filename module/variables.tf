variable "endpoint-type" {
  type = string
  default = "PUBLIC"
  description = "The type of endpoint that you want your SFTP server connect to"
}

variable "transfer-protocols" {
  type = list(any)
  default = ["SFTP"]
  description = "Specifies the file transfer protocol or protocols over which your file transfer protocol client can connect to your server's endpoint"
}

variable "transfer-domain" {
  type = string
  default = "S3"
  description = "The domain of the storage system that is used for file transfers. Valid values are: S3 and EFS"
}

variable "common-tags" {
  type        = map(any)
  description = "Common Tags to apply"
  default     = {}
}

variable "module-name" {
  type        = string
  default     = null
  description = "Name of the module this SFTP server created for"
}

variable "environment-name" {
  type        = string
  default     = null
  description = "Doshii enviroment name"
}

variable "transfer-vpc-id" {
  type        = string
  default     = null
  description = "ID of VPC in which SFTP server endpoint will be hosted"
}

variable "transfer-subnet-ids" {
  type        = list(any)
  default     = null
  description = "List of subnets ids within the VPC for hosting SFTP server endpoint"
}

variable "security-group-ids" {
  type        = list(any)
  default     = null
  description = "List of security group ids within the VPC for hosting SFTP server endpoint"
}

variable "eip-allocation-ids" {
  type        = list(any)
  default     = null
  description = "List of address allocation IDs to attach an Elastic IP address to your SFTP server endpoint"
}

variable "identity-provider-type" {
  type        = string
  default     = "SERVICE_MANAGED"
  description = "Mode of authentication to use for accessing the service. **Valid Values:** SERVICE_MANAGED or API_GATEWAY"
}

variable "api-gw-url" {
  type        = string
  default     = null
  description = "URL of the service endpoint to authenticate users when `identity_provider_type` is of type `API_GATEWAY`"
}

variable "invocation-role" {
  type        = string
  default     = null
  description = "ARN of the IAM role to authenticate the user when `identity_provider_type` is set to `API_GATEWAY`"
}

variable "logging-role" {
  type        = string
  default     = null
  description = "ARN of an IAM role to allow to write your SFTP users’ activity to Amazon CloudWatch logs"
}

variable "force-destroy" {
  type        = bool
  default     = true
  description = "Whether to delete all the users associated with server so that server can be deleted successfully"
}

variable "security-policy-name" {
  type        = string
  default     = "TransferSecurityPolicy-2018-11"
  description = "Specifies the name of the [security policy](https://docs.aws.amazon.com/transfer/latest/userguide/security-policies.html) to associate with the server. **Possible values:** TransferSecurityPolicy-2018-11, TransferSecurityPolicy-2020-06 or TransferSecurityPolicy-FIPS-2020-06"
}

variable "host-key" {
  type        = string
  default     = null
  description = "RSA private key that will be used to identify your server when clients connect to it over SFTP"
}

variable "hosted-zone" {
  type        = string
  default     = null
  description = "Hosted zone name to create DNS entry for SFTP server"
}

variable "sftp-sub-domain" {
  type        = string
  default     = "sftp"
  description = "DNS name for SFTP server. **NOTE: Only sub-domain required. DO NOT provide entire URL**"
}

variable "sftp-users" {
  type        = map(string)
  default     = {}
  description = <<-EOT
    Map of users with key as username and value as their home directory when `identity_provider_type` is set to `SERVICE_MANAGED`
    ```{
      user = "home_dir_path"
    }```
  EOT
}

variable "sftp-users-ssh-key" {
  type        = map(string)
  default     = {}
  description = <<-EOT
    Map of users with key as username and value as their public SSH key when `identity_provider_type` is set to `SERVICE_MANAGED`
    ```{
      user = "ssh_public_key_content"
    }```
  EOT
}

variable "sftp-user-role-trust-services" {
  type        = list(any)
  default     = [
    "transfer.amazonaws.com"
  ]
  description = "List of trusted AWS services that can assume the sftp role"
}

variable "sftp-post-upload-role-trust-services" {
  type        = list(any)
  default     = ["transfer.amazonaws.com",
    "lambda.amazonaws.com"
  ]
  description = "List of trusted AWS services that can assume the sftp role"
}

variable "availability-zones" {
  type    = list(any)
  default = []
}

variable "transfer-base-domain" {
  type        = string
  default     = ""
  description = "The Base Domain for the transfer s3 bucket"
}

variable "transfer-bucket-prefix" {
  type        = string
  default     = ""
  description = "The Bucket prefix for the transfer s3 bucket"
}

variable "transfer-replication-enabled" {
  type        = bool
  default     = false
  description = "If replication needs to be enabled"
}

variable "transfer-enable-versioning" {
  type        = bool
  default     = false
  description = "Whether to enable versioning or not.  True if replication enabled."
}

variable "transfer-logs-expiration" {
  type        = number
  default     = 90
  description = "Number of days to keep logs for s3 access"
}

variable "transfer-force-destroy-s3-buckets" {
  type        = bool
  default     = false
  description = "Whether to force deletion of s3 buckets"
}

variable "aws-profile" {
  type    = string
  default = "default"
}

variable "transfer-replication-region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region to be used for replication of the transfer bucket"
}

variable "ftps-record-ttl" {
  type    = number
  default = 60
  description = "Route 53 record TTL for FTPS protocol"
}

variable "sftp-record-ttl" {
  type    = number
  default = 60
  description = "Route 53 record TTL for SFTP protocol"
}
