locals {
  payment_key_vault = join("-", ["ccpay", var.env])
  payments_api_url  = join("", ["http://payment-api-", var.env, ".service.core-compute-", var.env, ".internal"])
  s2sUrl            = join("", ["http://rpe-service-auth-provider-", var.env, ".service.core-compute-", var.env, ".internal"])

  # list of the thumbprints of the SSL certificates that should be accepted by the API (gateway)
  thumbprints_in_quotes     = formatlist("\"%s\"", var.api_gateway_test_certificate_thumbprints)
  thumbprints_in_quotes_str = join(",", local.thumbprints_in_quotes)
}

data "azurerm_key_vault" "payment_key_vault" {
  name                = local.payment_key_vault
  resource_group_name = local.payment_key_vault
}

data "azurerm_key_vault_secret" "s2s_client_secret" {
  name         = "gateway-s2s-client-secret"
  key_vault_id = data.azurerm_key_vault.payment_key_vault.id
}

data "azurerm_key_vault_secret" "s2s_client_id" {
  name         = "gateway-s2s-client-id"
  key_vault_id = data.azurerm_key_vault.payment_key_vault.id
}
