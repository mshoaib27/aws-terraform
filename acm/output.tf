######################### ACM Certificate Outputs #########################

output "certificate_arn" {
  description = "ARN of the imported or validated certificate"
  value       = try(
    aws_acm_certificate.imported[0].arn,
    aws_acm_certificate.validated[0].arn,
    ""
  )
}

output "certificate_id" {
  description = "The ID of the certificate"
  value       = try(
    aws_acm_certificate.imported[0].id,
    aws_acm_certificate.validated[0].id,
    ""
  )
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = try(
    aws_acm_certificate.validated[0].status,
    "imported"
  )
}

output "certificate_domain" {
  description = "The domain name of the certificate"
  value       = try(
    aws_acm_certificate.validated[0].domain_name,
    ""
  )
}

output "certificate_validation_options" {
  description = "Set of domain validation options"
  value       = try(
    aws_acm_certificate.validated[0].domain_validation_options,
    []
  )
}

output "certificate_imported_arn" {
  description = "ARN of imported certificate (if using imported certificate)"
  value       = try(aws_acm_certificate.imported[0].arn, "")
}

output "certificate_validated_arn" {
  description = "ARN of validated certificate (if requesting new certificate)"
  value       = try(aws_acm_certificate.validated[0].arn, "")
}
