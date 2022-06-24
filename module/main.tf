locals {
  name-suffix = "${var.environment-name}"

  common-tags = { Environment = var.environment-name }

  server-id = aws_transfer_server.server.id
  server-ep = aws_transfer_server.server.endpoint
  s3-bucket-name = "${var.transfer-bucket-prefix}.${var.transfer-base-domain}"
}
