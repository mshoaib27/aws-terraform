######################### ACM Certificate Import #########################

resource "aws_acm_certificate" "imported" {
  count                     = var.certificate_body != "" ? 1 : 0
  private_key              = var.certificate_private_key
  certificate_body         = var.certificate_body
  certificate_chain        = var.certificate_chain
  tags                     = merge(
    var.tags,
    {
      Name = var.certificate_name
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

######################### ACM Certificate Validation #########################

resource "aws_acm_certificate" "validated" {
  count             = var.domain_name != "" ? 1 : 0
  domain_name       = var.domain_name
  validation_method = var.validation_method

  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = var.certificate_name
    }
  )
}

# DNS validation records (optional - if using DNS validation)
resource "aws_acm_certificate_validation" "validated" {
  count                   = var.domain_name != "" && var.validation_method == "DNS" ? 1 : 0
  certificate_arn         = aws_acm_certificate.validated[0].arn
  timeouts {
    create = "5m"
  }
}
