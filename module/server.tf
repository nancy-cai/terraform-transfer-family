resource "aws_transfer_server" "server" {
  endpoint_type = var.endpoint-type
  protocols     = var.transfer-protocols
  certificate   = contains(var.transfer-protocols,"FTPS") ? aws_acm_certificate.ftps[0].arn : null
  domain        = var.transfer-domain

  dynamic "endpoint_details" {
    for_each = var.endpoint-type == "VPC" ? [1] : []
    content {
      vpc_id                 = var.transfer-vpc-id
      subnet_ids             = var.transfer-subnet-ids
      security_group_ids     = var.security-group-ids
      address_allocation_ids = coalescelist(aws_eip.eip.*.id,[])
    }
  }

  identity_provider_type = var.identity-provider-type
  url                    = var.identity-provider-type == "API_GATEWAY" ? var.api-gw-url : null
  invocation_role        = var.invocation-role == null ? join(",", aws_iam_role.invocation.*.arn) : var.invocation-role

  logging_role         = var.logging-role == null ? join(",", aws_iam_role.logging.*.arn) : var.logging-role
  force_destroy        = var.force-destroy
  security_policy_name = var.security-policy-name
  host_key             = var.host-key

  tags                 = local.common-tags
}
