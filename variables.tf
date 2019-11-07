variable "product" {
  type    = "string"
  default = "payments"
}

variable "location" {
  type    = "string"
  default = "UK South"
}

variable "env" {
  type = "string"
}

variable "tenant_id" {
  description = "(Required) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. This is usually sourced from environemnt variables and not normally required to be specified."
}

variable "jenkins_AAD_objectId" {
  description = "(Required) The Azure AD object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies."
}

# thumbprint of the SSL certificate for API gateway Telephony
variable payments_api_gateway_certificate_thumbprints {
  type = "list"
}

# thumbprint of the SSL certificate for API gateway Payments API
variable telephony_api_gateway_certificate_thumbprints {
  type = "list"
}

# thumbprint of the SSL certificate for API gateway bulkscanning payment API
variable  bulkscanning_api_gateway_certificate_thumbprints {
  type = "list"
}