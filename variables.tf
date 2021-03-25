variable "product" {
  type = string
  default = "payments"
}

variable "core_product" {
  type = string
  default = "ccpay"
}

variable "location" {
  type    = string
  default = "UK South"
}

variable "env" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "tenant_id" {
  description = "(Required) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. This is usually sourced from environemnt variables and not normally required to be specified."
}

variable "jenkins_AAD_objectId" {
  description = "(Required) The Azure AD object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies."
}

# thumbprint of the SSL certificate for API gateway tests
variable api_gateway_test_certificate_thumbprints {
  type = list(string)
  # TODO: remove default and provide environment-specific values
  default = []
}