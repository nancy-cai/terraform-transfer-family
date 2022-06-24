output "server-id" {
  value       = module.pay-at-table-transfer-family[0].server-id
  description = "ID of transfer server"
}

output "workflow-role-arn" {
  value       = module.pay-at-table-transfer-family[0].workflow-role-arn
  description = "ARN of the workflow role"
}
