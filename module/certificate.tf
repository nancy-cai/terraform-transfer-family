# Only FTPS requires server certificate
resource "aws_acm_certificate" "ftps" {
  count = contains(var.transfer-protocols,"FTPS") ? 1 : 0
  domain_name       = "${var.sftp-sub-domain}.${var.hosted-zone}"
  validation_method = "DNS"

  tags = local.common-tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "ftps" {
  count = contains(var.transfer-protocols,"FTPS") ? 1 : 0
  certificate_arn         = aws_acm_certificate.ftps[0].arn
  validation_record_fqdns = [for record in aws_route53_record.ftps : record.fqdn]
}
