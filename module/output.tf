output "server-arn" {
  value       = aws_transfer_server.server.arn
  description = "ARN of transfer server"
}

output "server-id" {
  value       = local.server-id
  description = "ID of transfer server"
}

output "server-endpoint" {
  value       = local.server-ep
  description = "Endpoint of transfer server"
}

output "server-domain-name" {
  value       = var.hosted-zone == null ? null : join(",", aws_route53_record.sftp.*.fqdn)
  description = "Custom DNS name mapped in Route53 for transfer server"
}

output "sftp-user-role-ids" {
  value = toset([
    for role in aws_iam_role.sftp-user-role : role.id
  ])
}

output "workflow-role-arn" {
  value = aws_iam_role.post-upload.arn
  description = "ARN of the workflow role"
}
