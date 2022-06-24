data "aws_route53_zone" "transfer" {
  name         = var.hosted-zone
  private_zone = false
}

# Record when protocols includes FTPS
resource "aws_route53_record" "ftps" {
  for_each = contains(var.transfer-protocols,"FTPS") ? {
    for dvo in aws_acm_certificate.ftps[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.ftps-record-ttl
  type            = each.value.type
  zone_id         = data.aws_route53_zone.transfer.zone_id
}


# Record when protocol is SFTP and/or FTP
data "aws_route53_zone" "primary" {
  count = var.hosted-zone == null ? 0 : 1
  name  = var.hosted-zone
}

resource "aws_route53_record" "sftp" {
  count   = var.hosted-zone == null ? 0 : 1
  zone_id = join(",", data.aws_route53_zone.primary.*.zone_id)
  name    = "${var.sftp-sub-domain}.${var.hosted-zone}"
  type    = "CNAME"
  ttl     = var.sftp-record-ttl
  records = [local.server-ep]
}
