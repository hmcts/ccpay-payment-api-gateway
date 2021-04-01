provider "azurerm" {
  version = "1.36.1"
}
locals {
  s2sUrl = "http://rpe-service-auth-provider-${var.env}.service.core-compute-${var.env}.internal"
  # list of the thumbprints of the SSL certificates that should be accepted by the API (gateway)
  thumbprints_in_quotes = "${formatlist("&quot;%s&quot;", var.api_gateway_test_certificate_thumbprints)}"
  thumbprints_in_quotes_str = "${join(",", local.thumbprints_in_quotes)}"
  api_policy = "${replace(file("template/api-policy.xml"), "ALLOWED_CERTIFICATE_THUMBPRINTS", local.thumbprints_in_quotes_str)}"
  api_base_path = "payments-api"
  dummy = "dummy"
}
data "azurerm_key_vault" "payment_key_vault" {
  name = "ccpay-${var.env}"
  resource_group_name = "ccpay-${var.env}"
}

data "azurerm_key_vault_secret" "s2s_client_secret" {
  name = "gateway-s2s-client-secret"
  key_vault_id = "${data.azurerm_key_vault.payment_key_vault.id}"
}

data "azurerm_key_vault_secret" "s2s_client_id" {
  name = "gateway-s2s-client-id"
  key_vault_id = "${data.azurerm_key_vault.payment_key_vault.id}"
}

data "template_file" "policy_template" {
  template = "${file("${path.module}/template/api-policy.xml")}"

  vars {
    allowed_certificate_thumbprints = "${local.thumbprints_in_quotes_str}"
    s2s_client_id = "${data.azurerm_key_vault_secret.s2s_client_id.value}"
    s2s_client_secret = "${data.azurerm_key_vault_secret.s2s_client_secret.value}"
    s2s_base_url = "${local.s2sUrl}"
  }
}

# data "template_file" "api_template" {
#   template = "${file("${path.module}/template/api.json")}"
# }

# resource "azurerm_template_deployment" "api" {
#   template_body       = "${data.template_file.api_template.rendered}"
#   name                = "${var.product}-api-${var.env}"
#   deployment_mode     = "Incremental"
#   resource_group_name = "core-infra-${var.env}"
#   count               = "${var.env != "preview" ? 1: 0}"

#   parameters = {
#     apiManagementServiceName  = "core-api-mgmt-${var.env}"
#     apiName                   = "${var.product}-api"
#     apiProductName            = "${var.product}"
#     serviceUrl                = "http://payment-api-${var.env}.service.core-compute-${var.env}.internal"
#     apiBasePath               = "${local.api_base_path}"
#     policy                    = "${data.template_file.policy_template.rendered}"
#   }
}
