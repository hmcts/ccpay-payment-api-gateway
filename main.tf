provider "azurerm" {
  version = "1.36.1"
}

locals {
  # list of the thumbprints of the SSL certificates that should be accepted by the API (gateway)
  payments_thumbprints_in_quotes         = "${formatlist("&quot;%s&quot;", var.payments_api_gateway_certificate_thumbprints)}"
  payments_thumbprints_in_quotes_str     = "${join(",", local.payments_thumbprints_in_quotes)}"
  telephony_thumbprints_in_quotes        = "${formatlist("&quot;%s&quot;", var.telephony_api_gateway_certificate_thumbprints)}"
  telephony_thumbprints_in_quotes_str    = "${join(",", local.telephony_thumbprints_in_quotes)}"
  bulkscanning_thumbprints_in_quotes     = "${formatlist("&quot;%s&quot;", var.bulkscanning_api_gateway_certificate_thumbprints)}"
  bulkscanning_thumbprints_in_quotes_str = "${join(",", local.bulkscanning_thumbprints_in_quotes)}"

  s2sUrl                                 = "http://rpe-service-auth-provider-${var.env}.service.core-compute-${var.env}.internal"
  payments_api_url                       = "http://payment-api-${var.env}.service.core-compute-${var.env}.internal"
  bulkscanning_api_url                   = "http://ccpay-bulkscanning-api-${var.env}.service.core-compute-${var.env}.internal"
}
data "azurerm_key_vault" "payment_key_vault" {
  name                = "ccpay-${var.env}"
  resource_group_name = "ccpay-${var.env}"
}

data "azurerm_key_vault_secret" "s2s_client_secret" {
  name         = "gateway-s2s-client-secret"
  key_vault_id = "${data.azurerm_key_vault.payment_key_vault.id}"
}

data "azurerm_key_vault_secret" "s2s_client_id" {
  name         = "gateway-s2s-client-id"
  key_vault_id = "${data.azurerm_key_vault.payment_key_vault.id}"
}
