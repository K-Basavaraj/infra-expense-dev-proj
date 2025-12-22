resource "aws_acm_certificate" "expense-cert" {
  domain_name       = "*.${var.zone_name}"
  validation_method = "DNS"

   tags = merge(
    var.common_tags,
    {
      Name = local.resource_name
    }
  )
}

# This resource creates DNS records in Route53 that are required
# by AWS ACM to prove that we own the domain.
# ACM provides these DNS values dynamically after requesting the certificate.

# ACM may generate one or more domain validation records.
# This for_each loop iterates over all validation options
# and creates the required DNS record(s) automatically.
resource "aws_route53_record" "expense" {
  for_each = {
    for dvo in aws_acm_certificate.expense-cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  # Allows Terraform to overwrite the DNS record
  # if it already exists (useful during re-runs)
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

# This resource tells Terraform to wait until ACM verifies
# the DNS records and the certificate becomes ISSUED.
# Without this, Terraform may continue while the certificate is still in PENDING_VALIDATION state.
resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.expense-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.expense : record.fqdn]
}
