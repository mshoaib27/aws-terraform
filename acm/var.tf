variable "certificate_name" {
  description = "Name/ID for the certificate"
  type        = string
  default     = "tt-uat-cert"
}

variable "certificate_body" {
  description = "PEM-encoded certificate body (for imported certificates)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "certificate_private_key" {
  description = "PEM-encoded private key (for imported certificates)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "certificate_chain" {
  description = "PEM-encoded certificate chain (optional, for imported certificates)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "domain_name" {
  description = "Domain name for certificate request validation"
  type        = string
  default     = ""
}

variable "subject_alternative_names" {
  description = "Set of subject alternative names for the certificate"
  type        = set(string)
  default     = []
}

variable "validation_method" {
  description = "Method to use for validation. Valid values: DNS, EMAIL"
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL"], var.validation_method)
    error_message = "Validation method must be either DNS or EMAIL."
  }
}

variable "tags" {
  description = "Tags to assign to the certificate"
  type        = map(any)
  default = {
    Environment = "production"
  }
}
